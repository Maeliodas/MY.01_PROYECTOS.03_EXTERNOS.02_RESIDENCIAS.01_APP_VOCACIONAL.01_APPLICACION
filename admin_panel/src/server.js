import express from 'express';
import cors from 'cors';
import 'dotenv/config';
import path from 'path';
import { fileURLToPath } from 'url';
import crypto from 'crypto';
import http from 'http';
import { Server as SocketServer } from 'socket.io';
import PDFDocument from 'pdfkit';
import { PassThrough } from 'stream';
import { pool } from './db.js';

const app = express();
app.disable('x-powered-by');
// Detrás de proxy inverso (Nginx/Caddy con HTTPS) para IP real y HSTS.
app.set('trust proxy', 1);
const server = http.createServer(app);
const io = new SocketServer(server, {
  cors: { origin: true, credentials: true },
  path: '/socket.io',
});

/** Emite un evento a todos los paneles admin conectados (tiempo real). */
function notifyAdmins(event, payload = {}) {
  io.to('admins').emit(event, { ...payload, at: new Date().toISOString() });
}


const port = Number(process.env.PORT ?? 8080);
const panelVersion = '1.2.2-8';
const apiIngestKey = process.env.API_INGEST_KEY ?? '';
const adminUser = process.env.ADMIN_USER ?? '';
const adminPassword = process.env.ADMIN_PASSWORD ?? '';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '../views'));
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '../public'), {
  // Solo public/ es visible por HTTP: src/, views/, sql/, .env y
  // node_modules jamás salen del servidor.
  dotfiles: 'deny',
  index: false,
  maxAge: '1h',
  setHeaders(res, filePath) {
    // El service worker debe revalidarse siempre para tomar versiones nuevas.
    if (filePath.endsWith(`${path.sep}sw.js`)) {
      res.setHeader('Cache-Control', 'no-cache');
    }
  },
}));
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');
  res.setHeader('Permissions-Policy', 'geolocation=(), camera=(), microphone=()');
  const proto = req.get('x-forwarded-proto') ?? req.protocol;
  if (proto === 'https') {
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  }
  next();
});

// Freno simple contra fuerza bruta al login (memoria, sin dependencias).
const loginAttempts = new Map();
function loginThrottled(ip) {
  const now = Date.now();
  const entry = loginAttempts.get(ip);
  if (!entry || now > entry.reset) {
    loginAttempts.set(ip, { count: 0, reset: now + 10 * 60 * 1000 });
    return false;
  }
  return entry.count >= 10;
}
function registerFailedLogin(ip) {
  const now = Date.now();
  let entry = loginAttempts.get(ip);
  if (!entry || now > entry.reset) entry = { count: 0, reset: now + 10 * 60 * 1000 };
  entry.count += 1;
  loginAttempts.set(ip, entry);
}

function requireApiKey(req, res, next) {
  if (!apiIngestKey) return next();
  const authorization = req.get('authorization') ?? '';
  if (authorization === `Bearer ${apiIngestKey}`) return next();
  return res.status(401).json({ error: 'Credencial de aplicación inválida' });
}

function parseCookies(req) {
  return Object.fromEntries(String(req.headers.cookie ?? '').split(';').map(v => v.trim()).filter(Boolean).map(v => {
    const i = v.indexOf('='); return i < 0 ? [v, ''] : [v.slice(0, i), decodeURIComponent(v.slice(i + 1))];
  }));
}

const sessionSecret = process.env.ADMIN_SESSION_SECRET || `${adminUser}:${adminPassword}:${apiIngestKey}`;
function sessionToken() {
  const payload = `${adminUser}|${Date.now()}`;
  const sig = crypto.createHmac('sha256', sessionSecret).update(payload).digest('hex');
  return Buffer.from(`${payload}|${sig}`).toString('base64url');
}
function validSession(token) {
  try {
    const [user, issued, sig] = Buffer.from(token, 'base64url').toString('utf8').split('|');
    if (user !== adminUser || !issued || !sig) return false;
    if (Date.now() - Number(issued) > 8 * 60 * 60 * 1000) return false;
    const payload = `${user}|${issued}`;
    const expected = crypto.createHmac('sha256', sessionSecret).update(payload).digest('hex');
    return crypto.timingSafeEqual(Buffer.from(sig), Buffer.from(expected));
  } catch (_) { return false; }
}
function requireAdmin(req, res, next) {
  if (!adminUser || !adminPassword) return next();
  const token = parseCookies(req).app_vocacional_admin;
  if (token && validSession(token)) return next();
  if (req.path.startsWith('/api/')) return res.status(401).json({ error: 'Sesión administrativa requerida' });
  return res.redirect('/login');
}

function slug(value) {
  return String(value ?? '')
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_+|_+$/g, '')
    .slice(0, 50);
}


const DEPARTMENTS = [
  'Ciencias de la Tierra',
  'Económico Administrativo',
  'Química',
  'Sistemas y Computación',
  'Metal Mecánica',
  'Eléctrica',
];

function validateDepartment(value) {
  const department = String(value ?? '').trim();
  if (!DEPARTMENTS.includes(department)) {
    throw new Error('Selecciona un departamento válido.');
  }
  return department;
}

function generatedCatalogId(type, label = '') {
  const token = `${Date.now().toString(36)}${crypto.randomBytes(2).toString('hex')}`;
  if (type === 'states') return `s${crypto.randomBytes(4).toString('hex').slice(0,7)}`;
  const prefix = { municipalities: 'mun', schools: 'esc', languages: 'lan' }[type] ?? type.slice(0, 3);
  const base = slug(label).slice(0, 48) || 'registro';
  return `${prefix}_${base}_${token}`.slice(0, 80);
}

async function bumpCatalogVersion(connection = pool) {
  await connection.query('UPDATE catalog_meta SET version = version + 1 WHERE id = 1');
}

app.get('/health', async (_req, res) => {
  await pool.query('SELECT 1');
  res.json({ ok: true, service: 'app-vocacional-ittux-panel' });
});

// ---------------------------------------------------------------------------
// App: catálogo institucional. JSON se usa únicamente como transporte HTTP;
// la fuente maestra vive en MySQL/MariaDB y la app guarda una copia en SQLite.
// ---------------------------------------------------------------------------
app.get('/api/catalogs', requireApiKey, async (_req, res) => {
  try {
    const [[[meta]], [states], [municipalities], [schools], [languagesRaw], [questions], [careers], [departmentQuestions], [careerWeights], [careerQuestions]] = await Promise.all([
      pool.query('SELECT version, updated_at FROM catalog_meta WHERE id=1'),
      pool.query('SELECT id,name,active FROM states ORDER BY name'),
      pool.query('SELECT id,state_id,name,active FROM municipalities ORDER BY state_id,name'),
      pool.query('SELECT id,name,municipality_id,type,active FROM schools ORDER BY name'),
      pool.query('SELECT id,name,kind,active FROM languages ORDER BY kind,name'),
      pool.query('SELECT id,text,dimension,position,related_career_id,active FROM questions ORDER BY position,id'),
      pool.query('SELECT id,name,description,holland_code,department,website_url,active FROM careers ORDER BY name'),
      pool.query('SELECT department,question_text,updated_at FROM department_open_questions ORDER BY department'),
      pool.query('SELECT career_id,dimension,weight FROM career_riasec_weights ORDER BY career_id,dimension'),
      pool.query('SELECT career_id,question_id FROM career_questions ORDER BY career_id,question_id'),
    ]);
    const languages = languagesRaw.map(row => ({ ...row, type: row.kind }));
    res.json({
      version: meta?.version ?? 1,
      updated_at: meta?.updated_at ?? null,
      states,
      municipalities,
      schools,
      languages: languages.map(({ kind, ...row }) => row),
      questions,
      careers,
      department_questions: departmentQuestions,
      career_weights: careerWeights,
      career_questions: careerQuestions,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'No fue posible obtener los catálogos' });
  }
});

// Versión ligera para que la app detecte novedades sin descargar todo el
// snapshot. La app lo consulta en vivo y al arrancar; sin red, difiere.
app.get('/api/catalog-version', requireApiKey, async (_req, res) => {
  try {
    const [[meta]] = await pool.query('SELECT version, updated_at FROM catalog_meta WHERE id=1');
    res.json({ version: meta?.version ?? 1, updated_at: meta?.updated_at ?? null });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'No fue posible obtener la versión del catálogo' });
  }
});

app.post('/api/catalog-suggestions', requireApiKey, async (req, res) => {
  const kind = req.body?.kind;
  const name = normalizeDisplayName(req.body?.name);
  const municipalityId = req.body?.municipality_id ? String(req.body.municipality_id) : null;
  if (!['lengua', 'idioma', 'escuela'].includes(kind) || name.length < 2 || name.length > 200 || (kind === 'escuela' && !municipalityId)) {
    return res.status(400).json({ error: 'Sugerencia inválida' });
  }
  try {
    const existingSql = kind === 'escuela'
      ? 'SELECT id FROM schools WHERE municipality_id=? AND LOWER(name)=LOWER(?) LIMIT 1'
      : 'SELECT id FROM languages WHERE kind=? AND LOWER(name)=LOWER(?) LIMIT 1';
    const [existing] = await pool.execute(existingSql, [kind === 'escuela' ? municipalityId : kind, name]);
    if (existing.length) return res.status(200).json({ ok: true, already_exists: true });
    await pool.execute(
      `INSERT INTO catalog_suggestions(kind,name,municipality_id,status) VALUES(?,?,?,'pending')
       ON DUPLICATE KEY UPDATE created_at=created_at`,
      [kind, name, kind === 'escuela' ? municipalityId : null],
    );
    notifyAdmins('suggestion-created', { kind, name });
    res.status(201).json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'No fue posible registrar la sugerencia' });
  }
});

app.post('/api/evaluations', requireApiKey, async (req, res) => {
  const body = req.body ?? {};
  const student = body.student ?? {};
  const result = body.result ?? {};
  if (!body.result_id || !body.session_id || !student.name || !student.age || !result.top_career_name) {
    return res.status(400).json({ error: 'Payload incompleto' });
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const [existing] = await connection.query('SELECT id FROM evaluations WHERE external_result_id = ? LIMIT 1', [body.result_id]);
    if (existing.length > 0) {
      await connection.rollback();
      return res.status(200).json({ ok: true, duplicated: true });
    }
    let schoolSuggestionId = null;
    if (!student.school_id && student.pending_school?.name && student.pending_school?.municipality_id) {
      await connection.execute(
        `INSERT INTO catalog_suggestions(kind,name,municipality_id,status) VALUES('escuela',?,?,'pending')
         ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id)`,
        [normalizeDisplayName(student.pending_school.name), student.pending_school.municipality_id],
      );
      const [suggestionRows] = await connection.execute(
        `SELECT id FROM catalog_suggestions WHERE kind='escuela' AND LOWER(name)=LOWER(?) AND municipality_id=? AND status='pending' LIMIT 1`,
        [normalizeDisplayName(student.pending_school.name), student.pending_school.municipality_id],
      );
      schoolSuggestionId = suggestionRows[0]?.id ?? null;
    }
    const [studentInsert] = await connection.execute(
      `INSERT INTO students (local_profile_id,name,age,gender,school_id,school_suggestion_id)
       VALUES (?,?,?,?,?,?)`,
      [student.local_profile_id ?? null, student.name, Number(student.age), student.gender ?? null, student.school_id ?? null, schoolSuggestionId],
    );
    for (const name of Array.isArray(student.languages) ? student.languages : []) {
      await connection.execute('INSERT INTO student_languages (student_id, kind, name) VALUES (?, ?, ?)', [studentInsert.insertId, 'lengua', String(name)]);
    }
    for (const name of Array.isArray(student.idioms) ? student.idioms : []) {
      await connection.execute('INSERT INTO student_languages (student_id, kind, name) VALUES (?, ?, ?)', [studentInsert.insertId, 'idioma', String(name)]);
    }
    const [evaluationInsert] = await connection.execute(
      `INSERT INTO evaluations
      (external_result_id,session_id,student_id,holland_code,score_r,score_i,score_a,score_s,score_e,score_c,top_career_id,top_career_name,top_career_affinity,completed_at)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        body.result_id, body.session_id, studentInsert.insertId, result.holland_code ?? '',
        Number(result.score_r ?? 0), Number(result.score_i ?? 0), Number(result.score_a ?? 0),
        Number(result.score_s ?? 0), Number(result.score_e ?? 0), Number(result.score_c ?? 0),
        result.top_career_id ?? null, result.top_career_name, Number(result.top_career_affinity ?? 0),
        new Date(body.completed_at ?? Date.now()),
      ],
    );
    for (const item of Array.isArray(body.career_open_answers) ? body.career_open_answers : []) {
      const careerId = String(item?.career_id ?? '').trim();
      const answer = String(item?.answer ?? '').trim();
      if (careerId && answer) {
        const questionText = String(item?.question_text ?? '').trim();
        await connection.execute(
          `INSERT INTO evaluation_open_answers(evaluation_id,career_id,question_text,answer)
           SELECT ?, c.id,
                  COALESCE(NULLIF(?,''), dq.question_text),
                  ?
             FROM careers c
             LEFT JOIN department_open_questions dq ON dq.department=c.department
            WHERE c.id=?`,
          [evaluationInsert.insertId, questionText, answer, careerId],
        );
      }
    }
    await connection.commit();
    // Notificar en tiempo real a los paneles admin conectados
    notifyAdmins('new-evaluation', {
      id: evaluationInsert.insertId,
      result_id: body.result_id,
      holland_code: result.holland_code ?? '',
      top_career_name: result.top_career_name,
      school_name: student.school ?? null,
      state_name: student.state ?? null,
      municipality_name: student.municipality ?? null,
      completed_at: body.completed_at ?? new Date().toISOString(),
    });
    res.status(201).json({ ok: true });
  } catch (error) {
    await connection.rollback();
    console.error(error);
    res.status(500).json({ error: 'No fue posible guardar la evaluación' });
  } finally {
    connection.release();
  }
});

function buildEvaluationFilter(query) {
  const clauses = [];
  const params = [];
  const push = (sql, value) => { if (value) { clauses.push(sql); params.push(value); } };
  push('COALESCE(st.id, pst.id) = ?', query.state);
  push('COALESCE(m.id, pm.id) = ?', query.municipality);
  push('s.school_id = ?', query.school);
  push('e.holland_code = ?', query.profile);
  push('e.top_career_id = ?', query.career);
  if (query.from) { clauses.push('DATE(e.completed_at) >= ?'); params.push(query.from); }
  if (query.to) { clauses.push('DATE(e.completed_at) <= ?'); params.push(query.to); }
  return { where: clauses.length ? `WHERE ${clauses.join(' AND ')}` : '', params };
}

async function dashboardData(query = {}) {
  const { where, params } = buildEvaluationFilter(query);
  const base = `FROM evaluations e
    JOIN students s ON s.id=e.student_id
    LEFT JOIN schools sc ON sc.id=s.school_id
    LEFT JOIN municipalities m ON m.id=sc.municipality_id
    LEFT JOIN states st ON st.id=m.state_id
    LEFT JOIN catalog_suggestions cs ON cs.id=s.school_suggestion_id AND cs.kind='escuela'
    LEFT JOIN municipalities pm ON pm.id=cs.municipality_id
    LEFT JOIN states pst ON pst.id=pm.state_id`;
  const [[totals]] = await pool.query(
    `SELECT COUNT(*) total_evaluations, COUNT(DISTINCT COALESCE(sc.name,cs.name)) schools,
            ROUND(AVG(e.top_career_affinity),1) average_affinity,
            COUNT(DISTINCT e.holland_code) profiles ${base} ${where}`,
    params,
  );
  const [careers] = await pool.query(`SELECT e.top_career_name label, COUNT(*) value ${base} ${where} GROUP BY e.top_career_name ORDER BY value DESC LIMIT 10`, params);
  const [schools] = await pool.query(`SELECT COALESCE(sc.name,cs.name,'No especificada') label, COUNT(*) value ${base} ${where} GROUP BY COALESCE(sc.name,cs.name,'No especificada') ORDER BY value DESC LIMIT 10`, params);
  const [provenance] = await pool.query(`SELECT CONCAT(COALESCE(m.name,pm.name,'No especificado'), ', ', COALESCE(st.name,pst.name,'No especificado')) label, COUNT(*) value ${base} ${where} GROUP BY CONCAT(COALESCE(m.name,pm.name,'No especificado'), ', ', COALESCE(st.name,pst.name,'No especificado')) ORDER BY value DESC LIMIT 10`, params);
  const [profiles] = await pool.query(`SELECT e.holland_code label, COUNT(*) value ${base} ${where} GROUP BY e.holland_code ORDER BY value DESC LIMIT 10`, params);
  const [affinity] = await pool.query(
    `SELECT CASE WHEN e.top_career_affinity < 50 THEN 'Menos de 50%' WHEN e.top_career_affinity < 65 THEN '50–64%' WHEN e.top_career_affinity < 80 THEN '65–79%' WHEN e.top_career_affinity < 90 THEN '80–89%' ELSE '90–100%' END label,
            COUNT(*) value,
            CASE WHEN e.top_career_affinity < 50 THEN 1 WHEN e.top_career_affinity < 65 THEN 2 WHEN e.top_career_affinity < 80 THEN 3 WHEN e.top_career_affinity < 90 THEN 4 ELSE 5 END sort_order
     ${base} ${where} GROUP BY label,sort_order ORDER BY sort_order`,
    params,
  );
  // Languages are filtered through the selected evaluation students.
  const languageFilter = where ? where.replaceAll('e.', 'e.').replace('WHERE', 'AND') : '';
  const [languages] = await pool.query(
    `SELECT sl.name label, COUNT(*) value FROM student_languages sl
     JOIN students s ON s.id=sl.student_id JOIN evaluations e ON e.student_id=s.id
     LEFT JOIN schools sc ON sc.id=s.school_id LEFT JOIN municipalities m ON m.id=sc.municipality_id LEFT JOIN states st ON st.id=m.state_id
     LEFT JOIN catalog_suggestions cs ON cs.id=s.school_suggestion_id AND cs.kind='escuela' LEFT JOIN municipalities pm ON pm.id=cs.municipality_id LEFT JOIN states pst ON pst.id=pm.state_id
     WHERE sl.kind='lengua' ${languageFilter} GROUP BY sl.name ORDER BY value DESC,sl.name LIMIT 10`,
    params,
  );
  const [idioms] = await pool.query(
    `SELECT sl.name label, COUNT(*) value FROM student_languages sl
     JOIN students s ON s.id=sl.student_id JOIN evaluations e ON e.student_id=s.id
     LEFT JOIN schools sc ON sc.id=s.school_id LEFT JOIN municipalities m ON m.id=sc.municipality_id LEFT JOIN states st ON st.id=m.state_id
     LEFT JOIN catalog_suggestions cs ON cs.id=s.school_suggestion_id AND cs.kind='escuela' LEFT JOIN municipalities pm ON pm.id=cs.municipality_id LEFT JOIN states pst ON pst.id=pm.state_id
     WHERE sl.kind='idioma' ${languageFilter} GROUP BY sl.name ORDER BY value DESC,sl.name LIMIT 10`,
    params,
  );
  // La tabla de resultados no depende de un JOIN/GROUP BY con student_languages.
  // Esto evita que una evaluación válida desaparezca del panel por diferencias
  // de SQL mode o por no tener lenguas/idiomas asociados.
  const [recentEvaluations] = await pool.query(
    `SELECT e.id,COALESCE(st.name,pst.name) state_name,COALESCE(m.name,pm.name) municipality_name,COALESCE(sc.name,cs.name) school_name,e.holland_code,
            e.top_career_name,e.top_career_affinity,e.completed_at,
            (SELECT GROUP_CONCAT(DISTINCT sl.name ORDER BY sl.name SEPARATOR ', ')
               FROM student_languages sl WHERE sl.student_id=s.id AND sl.kind='lengua') lenguas,
            (SELECT GROUP_CONCAT(DISTINCT sl.name ORDER BY sl.name SEPARATOR ', ')
               FROM student_languages sl WHERE sl.student_id=s.id AND sl.kind='idioma') idiomas
     ${base} ${where}
     ORDER BY e.completed_at DESC, e.id DESC LIMIT 300`,
    params,
  );
  const [openAnswers] = await pool.query(
    `SELECT oa.evaluation_id, c.name career_name,
            COALESCE(NULLIF(oa.question_text,''), dq.question_text) question_text, oa.answer
       FROM evaluation_open_answers oa
       JOIN careers c ON c.id=oa.career_id
       LEFT JOIN department_open_questions dq ON dq.department=c.department
       JOIN evaluations e ON e.id=oa.evaluation_id
       JOIN students s ON s.id=e.student_id
       LEFT JOIN schools sc ON sc.id=s.school_id
       LEFT JOIN municipalities m ON m.id=sc.municipality_id
       LEFT JOIN states st ON st.id=m.state_id
       LEFT JOIN catalog_suggestions cs ON cs.id=s.school_suggestion_id AND cs.kind='escuela'
       LEFT JOIN municipalities pm ON pm.id=cs.municipality_id
       LEFT JOIN states pst ON pst.id=pm.state_id
       ${where}
       ORDER BY e.completed_at DESC, oa.id`,
    params,
  );
  const answersByEvaluation = {};
  for (const row of openAnswers) {
    answersByEvaluation[row.evaluation_id] ??= [];
    answersByEvaluation[row.evaluation_id].push(row);
  }
  for (const row of recentEvaluations) row.open_answers = answersByEvaluation[row.id] ?? [];
  return { totals, careers, schools, provenance, profiles, affinity, languages, idioms, evaluations: recentEvaluations };
}

async function catalogAdminData() {
  const [[meta], [states], [municipalities], [schools], [languages], [careers], [departmentQuestions], [questions], [suggestions], [weights], [careerQuestions]] = await Promise.all([
    pool.query('SELECT version,updated_at FROM catalog_meta WHERE id=1'),
    pool.query('SELECT * FROM states ORDER BY active DESC,name'),
    pool.query(`SELECT m.*,s.name state_name FROM municipalities m JOIN states s ON s.id=m.state_id ORDER BY m.active DESC,s.name,m.name`),
    pool.query(`SELECT sc.*,m.state_id,s.name state_name,m.name municipality_name FROM schools sc LEFT JOIN municipalities m ON m.id=sc.municipality_id LEFT JOIN states s ON s.id=m.state_id ORDER BY sc.active DESC,sc.name`),
    pool.query('SELECT * FROM languages ORDER BY active DESC,kind,name'),
    pool.query('SELECT * FROM careers ORDER BY active DESC,name'),
    pool.query('SELECT * FROM department_open_questions ORDER BY department'),
    pool.query('SELECT * FROM questions ORDER BY active DESC,position,id'),
    pool.query("SELECT cs.*,m.name municipality_name,st.name state_name FROM catalog_suggestions cs LEFT JOIN municipalities m ON m.id=cs.municipality_id LEFT JOIN states st ON st.id=m.state_id ORDER BY FIELD(cs.status,'pending','approved','rejected'),cs.created_at DESC LIMIT 200"),
    pool.query('SELECT career_id,dimension,weight FROM career_riasec_weights'),
    pool.query('SELECT career_id,question_id FROM career_questions ORDER BY question_id'),
  ]);
  const weightMap = {};
  for (const row of weights) {
    weightMap[row.career_id] ??= {};
    weightMap[row.career_id][row.dimension] = Number(row.weight);
  }
  const questionMap = {};
  for (const row of careerQuestions) {
    questionMap[row.career_id] ??= [];
    questionMap[row.career_id].push(row.question_id);
  }
  const careersWithRules = careers.map(row => ({...row, weights: weightMap[row.id] ?? {}, question_ids: questionMap[row.id] ?? []}));
  return { meta: meta ?? { version: 1 }, states, municipalities, schools, languages, careers: careersWithRules, departmentQuestions, departments: DEPARTMENTS, questions, suggestions };
}

app.get('/api/dashboard/summary', requireAdmin, async (req, res) => {
  try { res.json(await dashboardData(req.query)); }
  catch (error) { console.error(error); res.status(500).json({ error: 'Error consultando estadísticas' }); }
});

app.get('/login', (req, res) => {
  if (!adminUser || !adminPassword) return res.redirect('/');
  res.render('login', { error: null });
});
app.post('/login', (req, res) => {
  if (loginThrottled(req.ip)) {
    return res.status(429).render('login', { error: 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.' });
  }
  const user = String(req.body.user ?? '');
  const password = String(req.body.password ?? '');
  if (user !== adminUser || password !== adminPassword) {
    registerFailedLogin(req.ip);
    return res.status(401).render('login', { error: 'Usuario o contraseña incorrectos.' });
  }
  loginAttempts.delete(req.ip);
  res.setHeader('Set-Cookie', `app_vocacional_admin=${encodeURIComponent(sessionToken())}; HttpOnly; SameSite=Lax; Path=/; Max-Age=28800`);
  res.redirect('/');
});
app.post('/logout', (_req, res) => {
  res.setHeader('Set-Cookie', 'app_vocacional_admin=; HttpOnly; SameSite=Lax; Path=/; Max-Age=0');
  res.redirect('/login');
});

app.get('/', requireAdmin, async (req, res) => {
  try {
    const [data, catalogs] = await Promise.all([dashboardData(req.query), catalogAdminData()]);
    res.render('dashboard', { data, catalogs, filters: req.query, panelVersion });
  } catch (error) {
    console.error(error);
    res.status(500).send('No fue posible cargar el panel.');
  }
});

const simpleCatalogs = {
  states: { table: 'states', fields: ['id','name','active'] },
  municipalities: { table: 'municipalities', fields: ['id','state_id','name','active'] },
  schools: { table: 'schools', fields: ['id','name','municipality_id','type','active'] },
  languages: { table: 'languages', fields: ['id','name','kind','active'] },
};

function bodyValues(fields, body) {
  const values = {};
  for (const field of fields) {
    if (body[field] !== undefined) values[field] = body[field] === '' ? null : body[field];
  }
  if ('active' in values) values.active = Number(values.active) ? 1 : 0;
  return values;
}

function normalizeDisplayName(value) {
  const clean = String(value ?? '').trim().replace(/\s+/g, ' ').toLocaleLowerCase('es-MX');
  return clean ? clean.charAt(0).toLocaleUpperCase('es-MX') + clean.slice(1) : '';
}
function readCareerWeights(body) {
  const weights = {};
  for (const dim of ['R','I','A','S','E','C']) {
    const value = Number(body[`weight_${dim}`]);
    if (!Number.isFinite(value) || value < 0 || value > 10) throw new Error(`El valor ${dim} debe estar entre 0 y 10.`);
    weights[dim] = value;
  }
  return weights;
}
function hollandFromWeights(weights) {
  const order = ['R','I','A','S','E','C'];
  return [...order].sort((a,b) => weights[b] - weights[a] || order.indexOf(a)-order.indexOf(b)).slice(0,3).join('');
}
async function validateRelatedCareer(connection, id) {
  if (!id) return null;
  const [rows] = await connection.execute('SELECT id FROM careers WHERE id=? LIMIT 1', [id]);
  if (!rows.length) throw new Error('La carrera relacionada no existe.');
  return id;
}

app.post('/api/admin/catalog/:type', requireAdmin, async (req, res) => {
  const type = req.params.type;
  try {
    if (type === 'careers') {
      const id = `${slug(req.body.name) || 'career'}_${Date.now().toString(36)}${crypto.randomBytes(2).toString('hex')}`.slice(0,80);
      const connection = await pool.getConnection();
      try {
        await connection.beginTransaction();
        const weights = readCareerWeights(req.body);
        const hollandCode = hollandFromWeights(weights);
        if (!String(req.body.name ?? '').trim()) throw new Error('El nombre de la carrera es obligatorio.');
        const department = validateDepartment(req.body.department);
        await connection.execute(
          'INSERT INTO careers(id,name,description,holland_code,department,website_url,active) VALUES(?,?,?,?,?,?,?)',
          [id, String(req.body.name).trim(), req.body.description ?? '', hollandCode, department, req.body.website_url || null, Number(req.body.active ?? 1)],
        );
        for (const dim of ['R','I','A','S','E','C']) {
          await connection.execute('INSERT INTO career_riasec_weights(career_id,dimension,weight) VALUES(?,?,?)', [id, dim, weights[dim]]);
        }
        const questionIds = String(req.body.question_ids ?? '').split(',').map(x=>Number(x.trim())).filter(Number.isInteger);
        for (const questionId of questionIds) {
          await connection.execute('INSERT IGNORE INTO career_questions(career_id,question_id) VALUES(?,?)', [id, questionId]);
        }
        await bumpCatalogVersion(connection);
        await connection.commit();
      } catch (error) {
        await connection.rollback();
        throw error;
      } finally { connection.release(); }
      notifyAdmins('catalog-updated', { type: 'careers', action: 'create', id });
      return res.status(201).json({ ok: true, id });
    }
    if (type === 'questions') {
      const connection = await pool.getConnection();
      try {
        const text = String(req.body.text ?? '').trim();
        const dimension = String(req.body.dimension ?? '').toUpperCase();
        if (!text) throw new Error('El texto de la pregunta es obligatorio.');
        if (!['R','I','A','S','E','C'].includes(dimension)) throw new Error('Dimensión RIASEC inválida.');
        const related = await validateRelatedCareer(connection, req.body.related_career_id || null);
        const [[maxRow]] = await connection.query('SELECT COALESCE(MAX(id),0) max_id, COALESCE(MAX(position),0) max_position FROM questions');
        const id = Number(maxRow.max_id) + 1;
        const position = Number(req.body.position) || Number(maxRow.max_position) + 1;
        await connection.execute('INSERT INTO questions(id,text,dimension,position,related_career_id,active) VALUES(?,?,?,?,?,?)', [id,text,dimension,position,related,Number(req.body.active ?? 1)]);
        await bumpCatalogVersion(connection);
        notifyAdmins('catalog-updated', { type: 'questions', action: 'create', id });
        return res.status(201).json({ok:true,id});
      } finally { connection.release(); }
    }
    const cfg = simpleCatalogs[type];
    if (!cfg) return res.status(404).json({ error: 'Catálogo no soportado' });
    const values = bodyValues(cfg.fields, req.body);
    values.id = generatedCatalogId(type, values.name || values.text);
    const fields = Object.keys(values);
    await pool.execute(`INSERT INTO ${cfg.table} (${fields.join(',')}) VALUES (${fields.map(()=>'?').join(',')})`, fields.map(f => values[f]));
    await bumpCatalogVersion();
    notifyAdmins('catalog-updated', { type, action: 'create', id: values.id });
    res.status(201).json({ ok: true, id: values.id });
  } catch (error) {
    console.error(error);
    res.status(400).json({ error: error.sqlMessage ?? error.message ?? 'No fue posible crear el registro' });
  }
});

app.put('/api/admin/catalog/:type/:id', requireAdmin, async (req, res) => {
  const type = req.params.type;
  const id = req.params.id;
  try {
    if (type === 'careers') {
      const connection = await pool.getConnection();
      try {
        await connection.beginTransaction();
        const weights = readCareerWeights(req.body);
        const hollandCode = hollandFromWeights(weights);
        if (!String(req.body.name ?? '').trim()) throw new Error('El nombre de la carrera es obligatorio.');
        const department = validateDepartment(req.body.department);
        await connection.execute(
          'UPDATE careers SET name=?,description=?,holland_code=?,department=?,website_url=?,active=? WHERE id=?',
          [String(req.body.name).trim(), req.body.description ?? '', hollandCode, department, req.body.website_url || null, Number(req.body.active ?? 1), id],
        );
        for (const dim of ['R','I','A','S','E','C']) {
          await connection.execute('INSERT INTO career_riasec_weights(career_id,dimension,weight) VALUES(?,?,?) ON DUPLICATE KEY UPDATE weight=VALUES(weight)', [id, dim, weights[dim]]);
        }
        if (req.body.question_ids !== undefined) {
          await connection.execute('DELETE FROM career_questions WHERE career_id=?', [id]);
          const questionIds = String(req.body.question_ids ?? '').split(',').map(x=>Number(x.trim())).filter(Number.isInteger);
          for (const questionId of questionIds) {
            await connection.execute('INSERT IGNORE INTO career_questions(career_id,question_id) VALUES(?,?)', [id, questionId]);
          }
        }
        await bumpCatalogVersion(connection);
        await connection.commit();
      } catch (error) {
        await connection.rollback();
        throw error;
      } finally { connection.release(); }
      notifyAdmins('catalog-updated', { type: 'careers', action: 'update', id: req.params.id });
      return res.json({ ok: true });
    }
    if (type === 'questions') {
      const connection = await pool.getConnection();
      try {
        const text = String(req.body.text ?? '').trim();
        const dimension = String(req.body.dimension ?? '').toUpperCase();
        if (!text) throw new Error('El texto de la pregunta es obligatorio.');
        if (!['R','I','A','S','E','C'].includes(dimension)) throw new Error('Dimensión RIASEC inválida.');
        const related = await validateRelatedCareer(connection, req.body.related_career_id || null);
        await connection.execute('UPDATE questions SET text=?,dimension=?,position=?,related_career_id=?,active=? WHERE id=?', [text,dimension,Number(req.body.position)||1,related,Number(req.body.active ?? 1),id]);
        await bumpCatalogVersion(connection);
        notifyAdmins('catalog-updated', { type: 'questions', action: 'update', id });
        return res.json({ok:true});
      } finally { connection.release(); }
    }
    const cfg = simpleCatalogs[type];
    if (!cfg) return res.status(404).json({ error: 'Catálogo no soportado' });
    const values = bodyValues(cfg.fields.filter(f => f !== 'id'), req.body);
    const fields = Object.keys(values);
    if (!fields.length) return res.status(400).json({ error: 'Sin cambios' });
    await pool.execute(`UPDATE ${cfg.table} SET ${fields.map(f=>`${f}=?`).join(',')} WHERE id=?`, [...fields.map(f => values[f]), id]);
    await bumpCatalogVersion();
    notifyAdmins('catalog-updated', { type, action: 'update', id });
    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(400).json({ error: error.sqlMessage ?? error.message ?? 'No fue posible actualizar' });
  }
});

app.put('/api/admin/department-questions/:department', requireAdmin, async (req, res) => {
  try {
    const department = validateDepartment(req.params.department);
    const questionText = String(req.body.question_text ?? '').trim();
    if (!questionText) return res.status(400).json({ error: 'La pregunta es obligatoria.' });
    if (questionText.length > 800) return res.status(400).json({ error: 'La pregunta es demasiado larga.' });
    await pool.execute(
      `INSERT INTO department_open_questions(department,question_text)
       VALUES(?,?)
       ON DUPLICATE KEY UPDATE question_text=VALUES(question_text)`,
      [department, questionText],
    );
    await bumpCatalogVersion();
    notifyAdmins('catalog-updated', { type: 'department-questions', action: 'update', department });
    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(400).json({ error: error.sqlMessage ?? error.message ?? 'No fue posible guardar la pregunta departamental' });
  }
});

app.delete('/api/admin/catalog/:type/:id', requireAdmin, async (req, res) => {
  const type = req.params.type;
  const cfg = type === 'careers' ? { table: 'careers' } : type === 'questions' ? { table: 'questions' } : simpleCatalogs[type];
  if (!cfg) return res.status(404).json({ error: 'Catálogo no soportado' });
  try {
    // Baja lógica: la app recibe active=0 y deja de mostrar el registro sin romper históricos.
    await pool.execute(`UPDATE ${cfg.table} SET active=0 WHERE id=?`, [req.params.id]);
    await bumpCatalogVersion();
    notifyAdmins('catalog-updated', { type, action: 'delete', id: req.params.id });
    res.json({ ok: true });
  } catch (error) {
    console.error(error);
    res.status(400).json({ error: error.sqlMessage ?? 'No fue posible dar de baja' });
  }
});

app.post('/api/admin/suggestions/:id/:action', requireAdmin, async (req, res) => {
  const action = req.params.action;
  if (!['approve','reject'].includes(action)) return res.status(400).json({ error: 'Acción inválida' });
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const [rows] = await connection.execute('SELECT * FROM catalog_suggestions WHERE id=? FOR UPDATE', [req.params.id]);
    if (!rows.length) { await connection.rollback(); return res.status(404).json({ error: 'Sugerencia no encontrada' }); }
    const item = rows[0];
    if (action === 'approve') {
      const id = `${item.kind}_${slug(item.name)}_${String(item.id).padStart(3,'0')}`.slice(0,80);
      if (item.kind === 'escuela') {
        await connection.execute(
          'INSERT INTO schools(id,name,municipality_id,active) VALUES(?,?,?,1) ON DUPLICATE KEY UPDATE active=1',
          [id, item.name, item.municipality_id],
        );
        await connection.execute('UPDATE students SET school_id=?, school_suggestion_id=NULL WHERE school_suggestion_id=?', [id, item.id]);
      } else {
        await connection.execute(
          'INSERT INTO languages(id,name,kind,active) VALUES(?,?,?,1) ON DUPLICATE KEY UPDATE active=1',
          [id, item.name, item.kind],
        );
      }
      await connection.execute("UPDATE catalog_suggestions SET status='approved',reviewed_at=CURRENT_TIMESTAMP WHERE id=?", [item.id]);
      await bumpCatalogVersion(connection);
    } else {
      await connection.execute("UPDATE catalog_suggestions SET status='rejected',reviewed_at=CURRENT_TIMESTAMP WHERE id=?", [item.id]);
    }
    await connection.commit();
    notifyAdmins('suggestion-updated', {
      id: item.id,
      action,
      kind: item.kind,
      name: item.name,
      catalogChanged: action === 'approve',
    });
    if (action === 'approve') {
      notifyAdmins('catalog-updated', { type: item.kind === 'escuela' ? 'schools' : 'languages', action: 'create', name: item.name });
    }
    res.json({ ok: true });
  } catch (error) {
    await connection.rollback();
    console.error(error);
    res.status(400).json({ error: error.sqlMessage ?? 'No fue posible revisar la sugerencia' });
  } finally { connection.release(); }
});


// ─── Estado en vivo + sugerencias (refresco sin recargar la página) ─────────
app.get('/api/admin/live-state', requireAdmin, async (req, res) => {
  try {
    const [metaResult, pendingResult, totalsResult] = await Promise.all([
      pool.query('SELECT version, updated_at FROM catalog_meta WHERE id=1'),
      pool.query("SELECT COUNT(*) AS c FROM catalog_suggestions WHERE status='pending'"),
      pool.query(`SELECT COUNT(*) total_evaluations,
                         COUNT(DISTINCT COALESCE(sc.name,cs.name)) schools,
                         COUNT(DISTINCT e.holland_code) profiles,
                         ROUND(AVG(e.top_career_affinity),1) average_affinity
                    FROM evaluations e JOIN students s ON s.id=e.student_id LEFT JOIN schools sc ON sc.id=s.school_id LEFT JOIN catalog_suggestions cs ON cs.id=s.school_suggestion_id`),
    ]);
    const meta = metaResult[0][0] ?? {};
    const pending = pendingResult[0][0] ?? {};
    const totals = totalsResult[0][0] ?? {};
    res.json({
      catalogVersion: meta.version ?? 1,
      catalogUpdatedAt: meta.updated_at ?? null,
      pendingSuggestions: Number(pending.c ?? 0),
      totals: {
        total_evaluations: Number(totals.total_evaluations ?? 0),
        schools: Number(totals.schools ?? 0),
        profiles: Number(totals.profiles ?? 0),
        average_affinity: totals.average_affinity != null ? Number(totals.average_affinity) : null,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'No fue posible obtener el estado en vivo' });
  }
});

app.get('/api/admin/suggestions', requireAdmin, async (_req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT cs.id, cs.kind, cs.name, cs.municipality_id, m.name municipality_name, st.name state_name, cs.status, cs.created_at, cs.reviewed_at FROM catalog_suggestions cs LEFT JOIN municipalities m ON m.id=cs.municipality_id LEFT JOIN states st ON st.id=m.state_id ORDER BY FIELD(status,'pending','approved','rejected'), created_at DESC LIMIT 200",
    );
    res.json({ suggestions: rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'No fue posible listar sugerencias' });
  }
});

// ─── Reporte PDF (plantilla formal + gráficos + encabezado/pie) ───────────────
app.get('/api/admin/report.pdf', requireAdmin, async (req, res) => {
  try {
    const data = await dashboardData(req.query);
    const filters = req.query ?? {};

    // Resolver nombres legibles de filtros (si vienen como id)
    let filterLabels = {
      state: filters.state || null,
      municipality: filters.municipality || null,
      school: filters.school || null,
      profile: filters.profile || null,
      career: filters.career || null,
      from: filters.from || null,
      to: filters.to || null,
    };
    try {
      if (filters.state) {
        const [[r]] = await pool.query('SELECT name FROM states WHERE id=? LIMIT 1', [filters.state]);
        if (r?.name) filterLabels.state = r.name;
      }
      if (filters.municipality) {
        const [[r]] = await pool.query('SELECT name FROM municipalities WHERE id=? LIMIT 1', [filters.municipality]);
        if (r?.name) filterLabels.municipality = r.name;
      }
      if (filters.school) {
        const [[r]] = await pool.query('SELECT name FROM schools WHERE id=? LIMIT 1', [filters.school]);
        if (r?.name) filterLabels.school = r.name;
      }
      if (filters.career) {
        const [[r]] = await pool.query('SELECT name FROM careers WHERE id=? LIMIT 1', [filters.career]);
        if (r?.name) filterLabels.career = r.name;
      }
    } catch (_) { /* nombres opcionales */ }

    const doc = new PDFDocument({
      size: 'A4',
      bufferPages: true,
      // Membretada §4.2 del Manual TecNM: la banda superior aloja el
      // encabezado institucional y la inferior el pie con filete y domicilio.
      margins: { top: 200, bottom: 130, left: 50, right: 50 },
      info: {
        Title: 'Reporte de orientación vocacional — App Vocacional ITTUX',
        Author: 'Instituto Tecnológico de Tuxtepec',
        Subject: 'Estadísticas de evaluaciones RIASEC filtradas',
        Creator: 'App Vocacional ITTUX Admin Panel',
      },
    });
    // Noto Sans: tipografía oficial del Manual de Identidad Gráfica TecNM.
    doc.registerFont('Noto', path.join(__dirname, '../fonts/NotoSans-Regular.ttf'));
    doc.registerFont('Noto-Bold', path.join(__dirname, '../fonts/NotoSans-Bold.ttf'));
    doc.registerFont('Noto-Italic', path.join(__dirname, '../fonts/NotoSans-Italic.ttf'));
    doc.registerFont('Noto-BoldItalic', path.join(__dirname, '../fonts/NotoSans-BoldItalic.ttf'));
    const filename = `reporte-vocacional-ittux-${new Date().toISOString().slice(0, 10)}.pdf`;
    // El PDF se arma completo en memoria y sólo se envía si terminó sin
    // errores: si algo falla a mitad del dibujo se responde 500 (JSON)
    // en vez de entregar un archivo truncado/corrupto al navegador.
    const pdfChunks = [];
    const pdfStream = new PassThrough();
    pdfStream.on('data', (chunk) => pdfChunks.push(chunk));
    const pdfReady = new Promise((resolve, reject) => {
      pdfStream.on('end', resolve);
      pdfStream.on('error', reject);
      doc.on('error', reject);
    });
    pdfReady.catch(() => {});   // evita unhandledRejection si se aborta antes
    doc.pipe(pdfStream);

    const ASSET = (name) => path.join(__dirname, '../assets', name);
    // Paleta oficial (Manual de Identidad Gráfica TecNM 2026, §2.3 Colores):
    //  · Pantone 294 C = RGB(27,57,106) = #1B396A (coincide con los PNG de
    //    ../assets, cuya tinta institucional mide exactamente lo mismo).
    //  · Cool Gray 10 C = #807E82, Negro 100% = #000000.
    //  · Guinda SEP = #A61D49, medida sobre el filete del pie de §4.2.
    const BLUE = '#1B396A';
    const GUINDA = '#A61D49';
    const GREEN = '#1B396A';   // serie de datos: se usa la azul institucional
    const INK = '#1a2432';
    const MUTED = '#5a6675';
    const LINE = '#c9d3e0';
    const BAR = '#1B396A';
    const BAR_BG = '#e6eaf3';
    const pageW = doc.page.width;
    const pageH = doc.page.height;
    const marginL = 50;
    const marginR = 50;
    const contentW = pageW - marginL - marginR;
    // Límite de contenido = maxY() de PDFKit; se usa en los saltos manuales.
    // Debe coincidir con margins.bottom si no, el pie invadiría el cuerpo.
    const bottomLimit = pageH - 130;

    const generatedAt = new Date().toLocaleString('es-MX', {
      dateStyle: 'long',
      timeStyle: 'short',
    });
    const issuedDate = new Date().toLocaleDateString('es-MX', {
      day: '2-digit', month: 'long', year: 'numeric',
    });
    const reportFolio = `RV-${new Date().toISOString().slice(0, 10)}`;

    // Proporciones (ancho/alto) de los PNG en ../assets, para colocarlos sin
    // deformarlos aunque solo se indique una dimensión.
    const ASPECT = {
      sep: 4.8326,       // sep_educacion.png
      tecnm: 2.2627,     // tecnm_horizontal.png
      escudo: 1.1029,    // escudo_nacional_gris.png
      wordmark: 4.0623,  // tecnm_ittux_wordmark.png
      certIg: 1.5574,    // cert_igualdad.png
      certLp: 1.6304,    // cert_libreplastico.png
    };

    /**
     * Encabezado institucional — Manual de Identidad Gráfica TecNM 2026,
     * §4.2 «Hoja membretada IT Federal y Centro» (medido sobre el manual):
     *   · Izquierda: logotipo Educación (SEP) 50..219 x 55..88 ⟩ filete
     *     vertical dorado en x 233, y 58..85 ⟩ logotipo TecNM 248..314.
     *   · Derecha: escudo en gris 40..108, nombre del plantel en negrita
     *     (negro, no azul) y, debajo, unidad responsable, lugar/fecha y
     *     folio, todo alineado a la derecha.
     *   · §4.2 NO lleva filete de cierre bajo el encabezado: el cuerpo
     *     arranca directamente en y 207.
     */
    function drawHeader() {
      const RX = pageW - marginR;
      // ── bloque izquierdo: logotipos ──────────────────────────────────
      const sepH = 33;
      const sepW = Math.round(sepH * ASPECT.sep * 100) / 100;
      doc.image(ASSET('sep_educacion.png'), marginL, 55, { width: sepW, height: sepH });
      // filete vertical separador — dorado (medido: RGB 174,132,32)
      const sepVX = marginL + sepW + 14;
      doc.strokeColor('#AE8420').lineWidth(0.9)
        .moveTo(sepVX, 58)
        .lineTo(sepVX, 85)
        .stroke();
      const tecH = 28;
      const tecW = Math.round(tecH * ASPECT.tecnm * 100) / 100;
      doc.image(ASSET('tecnm_horizontal.png'), sepVX + 14, 58, { width: tecW, height: tecH });

      // ── bloque derecho: escudo + plantel + datos del documento ───────
      const escH = 68;
      const escW = Math.round(escH * ASPECT.escudo * 100) / 100;
      doc.image(ASSET('escudo_nacional_gris.png'), RX - escW, 40, { width: escW, height: escH });

      const rightW = 340;
      const rightX = RX - rightW;
      // §4.2 imprime el nombre del plantel en negro; el azul Pantone 294 C
      // queda reservado para titulares y series de datos del cuerpo.
      doc.fillColor(INK).font('Noto-Bold').fontSize(10)
        .text('Instituto Tecnológico de Tuxtepec', rightX, 123, { width: rightW, align: 'right' });
      doc.fillColor(INK).font('Noto').fontSize(8)
        .text('Subdirección Académica', rightX, 134, { width: rightW, align: 'right' });
      doc.fillColor(INK).font('Noto').fontSize(9.5)
        .text(`Tuxtepec, Oaxaca, ${issuedDate}`, rightX, 160, { width: rightW, align: 'right' });
      doc.fillColor(INK).font('Noto').fontSize(9.5)
        .text(`Reporte No. ${reportFolio}`, rightX, 175, { width: rightW, align: 'right' });

      doc.x = marginL;
      doc.y = 200;
      doc.fillColor(INK);
    }

    /**
     * Pie institucional — §4.2 «Hoja membretada», geometría medida sobre el
     * manual (carta, en pts):
     *   · logotipo del plantel a la izquierda, x 46..192, tocando el filete;
     *   · filete guinda #A61D49 de x 190 a 574, grosor 3.6, y 720;
     *   · domicilio y contacto ALINEADOS A LA IZQUIERDA bajo el filete,
     *     arrancando en el mismo x en que éste empieza (no centrados);
     *   · logos de certificación sobre el filete, alineados a la derecha.
     *
     * BUG DE PÁGINAS FANTASMA: PDFKit evalúa
     *   `if (document.y > page.maxY() || y + lineHeight > maxY) nextSection()`
     * con `maxY() = height − margins.bottom`. Cualquier `doc.text()` con y
     * dentro de la banda del pie superaba maxY y creaba una página nueva por
     * cada llamada (5 págs × 3 textos = 15 fantasma → 20 totales, y
     * «Página 1 de 5» porque bufferedPageRange() se lee antes del bucle).
     * Se anula el margen inferior sólo durante el dibujo del pie y se
     * restaura después. Sin save()/restore(): con bufferPages + switchToPage
     * esos operadores caían en streams de página equivocados.
     */
    function drawFooter() {
      const range = doc.bufferedPageRange();
      const RX = pageW - marginR;
      const wmH = 34;
      const wmW = Math.round(wmH * ASPECT.wordmark * 100) / 100;
      // El filete empieza a la derecha del logotipo, como en §4.2.
      const ruleX = marginL + wmW + 14;
      const blockW = RX - ruleX;
      const savedBottom = doc.page.margins.bottom;
      doc.page.margins.bottom = 0;   // maxY pasa a ser pageH: sin auto-addPage

      // Logos de certificación: en §4.2 van SOBRE el filete, alineados al
      // margen derecho (medido: x 418..574, y 671..718, es decir 2 pts por
      // encima del filete de y 720).
      const certH = 30;
      const certIgW = Math.round(certH * ASPECT.certIg * 100) / 100;
      const certLpW = Math.round(certH * ASPECT.certLp * 100) / 100;
      const certGap = 12;
      const certBlockW = certIgW + certGap + certLpW;
      const certX = RX - certBlockW;
      const certY = pageH - 76 - certH;

      for (let i = 0; i < range.count; i++) {
        doc.switchToPage(range.start + i);
        // logotipo del plantel, a la izquierda del filete (lo cruza, como
        // el aniversario de §4.2)
        doc.image(ASSET('tecnm_ittux_wordmark.png'), marginL, pageH - 80, { width: wmW, height: wmH });
        // filete guinda §4.2
        doc.strokeColor(GUINDA).lineWidth(3.6)
          .moveTo(ruleX, pageH - 72)
          .lineTo(RX, pageH - 72)
          .stroke();
        // logos de certificación sobre el filete, alineados a la derecha
        doc.image(ASSET('cert_igualdad.png'), certX, certY, { width: certIgW, height: certH });
        doc.image(ASSET('cert_libreplastico.png'), certX + certIgW + certGap, certY, { width: certLpW, height: certH });
        doc.fillColor(MUTED).font('Noto').fontSize(6.5);
        doc.text(
          'Calzada Dr. Víctor Bravo Ahuja No. 561, Col. Predio el Paraíso, C.P. 68350, San Juan Bautista Tuxtepec, Oaxaca.',
          ruleX, pageH - 67, { width: blockW, align: 'left' },
        );
        doc.text(
          'Tel. 287 875 6191, 287 52170 y 287 875 1880  ·  cyd_tuxtepec@tecnm.mx  ·  tecnm.mx  ·  tuxtepec.tecnm.mx',
          ruleX, pageH - 57, { width: blockW, align: 'left' },
        );
        doc.text(
          `Página ${i + 1} de ${range.count}`,
          ruleX, pageH - 45, { width: blockW, align: 'right' },
        );
        doc.x = marginL;
        doc.fillColor(INK);
      }
      doc.page.margins.bottom = savedBottom;
    }

    function ensureSpace(needed = 80) {
      if (doc.y + needed > bottomLimit) {
        doc.addPage();
        drawHeader();
      }
    }

    function sectionTitle(title) {
      ensureSpace(36);
      doc.fillColor(BLUE).font('Noto-Bold').fontSize(12).text(title, marginL, doc.y, { width: contentW });
      doc.moveDown(0.25);
      doc.strokeColor(LINE).lineWidth(0.8)
        .moveTo(marginL, doc.y)
        .lineTo(marginL + contentW, doc.y)
        .stroke();
      doc.moveDown(0.6);
      doc.fillColor(INK);
    }

    // Cada punto del reporte abre su propia página (con encabezado §4.2):
    // ninguna sección continúa en la página donde terminó la anterior.
    function newSection(title) {
      doc.addPage();
      drawHeader();
      sectionTitle(title);
    }

    function formalParagraph(text) {
      // Medir antes de dibujar evita saltos automáticos a mitad de párrafo
      // (páginas sin encabezado).
      doc.fillColor(INK).font('Noto').fontSize(10);
      const h = doc.heightOfString(text, {
        width: contentW,
        align: 'justify',
        lineGap: 2,
      });
      ensureSpace(h + 14);
      doc.text(text, marginL, doc.y, {
        width: contentW,
        align: 'justify',
        lineGap: 2,
      });
      doc.moveDown(0.7);
    }

    /** Gráfico de barras horizontales dibujado con primitivas PDFKit */
    function drawBarChart(title, rows, { maxBars = 8, barHeight = 14, gap = 8 } = {}) {
      const series = (rows || []).slice(0, maxBars).filter(r => r && r.label != null);
      // Estimación exacta (título + filas + cierre): sobrestimar aquí creaba
      // saltos prematuros y dejaba páginas semivacías.
      ensureSpace(24 + series.length * (barHeight + gap));
      doc.fillColor(INK).font('Noto-Bold').fontSize(10).text(title, marginL, doc.y, { width: contentW });
      doc.moveDown(0.4);

      if (!series.length) {
        doc.fillColor(MUTED).font('Noto-Italic').fontSize(9)
          .text('Sin datos para los filtros seleccionados.', marginL, doc.y);
        doc.moveDown(0.8);
        return;
      }

      const maxVal = Math.max(...series.map(r => Number(r.value) || 0), 1);
      const labelW = 150;
      const valueW = 36;
      const barMaxW = contentW - labelW - valueW - 12;
      let y = doc.y;

      for (const row of series) {
        ensureSpace(barHeight + gap + 8);
        y = doc.y;
        const val = Number(row.value) || 0;
        const w = Math.max(2, (val / maxVal) * barMaxW);
        const label = String(row.label).slice(0, 34);

        doc.fillColor(INK).font('Noto').fontSize(8)
          .text(label, marginL, y + 2, { width: labelW, height: barHeight + 2, ellipsis: true });

        // fondo de barra
        doc.roundedRect(marginL + labelW + 6, y, barMaxW, barHeight, 3).fill(BAR_BG);
        // valor
        doc.roundedRect(marginL + labelW + 6, y, w, barHeight, 3).fill(BAR);

        doc.fillColor(INK).font('Noto-Bold').fontSize(8)
          .text(String(val), marginL + labelW + 6 + barMaxW + 6, y + 2, { width: valueW });

        doc.y = y + barHeight + gap;
      }
      doc.moveDown(0.5);
    }

    function kpiRow(totals) {
      ensureSpace(70);
      const items = [
        { label: 'Evaluaciones', value: String(totals.total_evaluations ?? 0) },
        { label: 'Escuelas', value: String(totals.schools ?? 0) },
        { label: 'Perfiles Holland', value: String(totals.profiles ?? 0) },
        {
          label: 'Afinidad media',
          value: totals.average_affinity != null ? `${totals.average_affinity}%` : '—',
        },
      ];
      const boxW = (contentW - 18) / 4;
      const y = doc.y;
      items.forEach((item, i) => {
        const x = marginL + i * (boxW + 6);
        doc.roundedRect(x, y, boxW, 48, 4).fill('#f2f5fa');
        doc.fillColor(MUTED).font('Noto').fontSize(7)
          .text(item.label.toUpperCase(), x + 8, y + 8, { width: boxW - 16 });
        doc.fillColor(GREEN).font('Noto-Bold').fontSize(14)
          .text(item.value, x + 8, y + 22, { width: boxW - 16 });
      });
      doc.y = y + 56;
      doc.moveDown(0.3);
    }

    // ── Página 1: portada / introducción ────────────────────────────────────
    drawHeader();

    doc.fillColor(BLUE).font('Noto-Bold').fontSize(16)
      .text('Reporte de orientación vocacional', marginL, doc.y, { width: contentW });
    doc.moveDown(0.3);
    doc.fillColor(MUTED).font('Noto').fontSize(9)
      .text(`Fecha de emisión: ${generatedAt}`, marginL, doc.y, { width: contentW });
    doc.moveDown(0.8);

    sectionTitle('1. Alcance del reporte');

    const scopeParts = [];
    if (filterLabels.state) scopeParts.push(`entidad federativa «${filterLabels.state}»`);
    if (filterLabels.municipality) scopeParts.push(`municipio «${filterLabels.municipality}»`);
    if (filterLabels.school) scopeParts.push(`plantel «${filterLabels.school}»`);
    if (filterLabels.profile) scopeParts.push(`código Holland «${filterLabels.profile}»`);
    if (filterLabels.career) scopeParts.push(`carrera principal «${filterLabels.career}»`);
    if (filterLabels.from || filterLabels.to) {
      const a = filterLabels.from || 'inicio';
      const b = filterLabels.to || 'fecha actual';
      scopeParts.push(`periodo del ${a} al ${b}`);
    }

    const scopeText = scopeParts.length
      ? `El presente documento consolida los resultados de las evaluaciones vocacionales (modelo RIASEC / Holland) registradas en el sistema App Vocacional ITTUX, limitados a los siguientes criterios de filtrado: ${scopeParts.join('; ')}.`
      : 'El presente documento consolida los resultados de las evaluaciones vocacionales (modelo RIASEC / Holland) registradas en el sistema App Vocacional ITTUX, sin criterios de filtrado adicionales: se incluyen todos los registros disponibles en la base de datos al momento de la generación.';

    formalParagraph(scopeText);
    formalParagraph(
      'La información se presenta con fines de análisis institucional y toma de decisiones en materia de orientación educativa. Los datos personales de los estudiantes no se exponen de forma nominativa en este reporte; las cifras corresponden a agregados estadísticos y a registros anonimizados o seudonimizados según la configuración del panel.',
    );

    newSection('2. Indicadores generales');
    formalParagraph(
      'A continuación se resumen los indicadores principales derivados del conjunto de evaluaciones que cumplen los filtros indicados. La afinidad media expresa el promedio del porcentaje de coincidencia entre el perfil RIASEC del estudiante y la carrera recomendada en primer lugar.',
    );
    kpiRow(data.totals ?? {});

    newSection('3. Distribución de carreras recomendadas');
    formalParagraph(
      'La gráfica muestra las carreras con mayor frecuencia como recomendación principal. Cada barra representa el número de evaluaciones en las que dicha carrera ocupó el primer lugar del ranking individual.',
    );
    drawBarChart('Carreras más recomendadas', data.careers, { maxBars: 10 });

    newSection('4. Perfiles RIASEC (códigos Holland)');
    formalParagraph(
      'Los códigos Holland agrupan las tres dimensiones RIASEC predominantes de cada evaluación (Realista, Investigador, Artístico, Social, Emprendedor, Convencional). La distribución permite identificar los perfiles vocacionales más frecuentes en la población filtrada.',
    );
    drawBarChart('Frecuencia de códigos Holland', data.profiles, { maxBars: 10 });

    newSection('5. Afinidad con la carrera principal');
    formalParagraph(
      'Se agrupan las evaluaciones según el intervalo de afinidad porcentual respecto a la carrera recomendada en primer lugar. Intervalos altos sugieren una coincidencia sólida entre intereses del estudiante y la oferta formativa sugerida.',
    );
    drawBarChart('Distribución por rango de afinidad', data.affinity, { maxBars: 6 });

    newSection('6. Planteles y procedencia');
    formalParagraph(
      'Se detalla la participación por escuela de procedencia y por municipio/estado, útil para contrastar cobertura territorial y carga de orientación por plantel.',
    );
    drawBarChart('Evaluaciones por escuela', data.schools, { maxBars: 8 });
    drawBarChart('Evaluaciones por municipio / estado', data.provenance, { maxBars: 8 });

    if ((data.languages ?? []).length || (data.idioms ?? []).length) {
      newSection('7. Lenguas originarias e idiomas');
      formalParagraph(
        'Cuando los estudiantes declararon lenguas originarias o idiomas adicionales, se resume su frecuencia en el conjunto filtrado. Estos datos contextualizan la diversidad lingüística de la población atendida.',
      );
      if ((data.languages ?? []).length) {
        drawBarChart('Lenguas originarias declaradas', data.languages, { maxBars: 8 });
      }
      if ((data.idioms ?? []).length) {
        drawBarChart('Idiomas declarados', data.idioms, { maxBars: 8 });
      }
    }

    newSection('8. Registro detallado de evaluaciones recientes');
    formalParagraph(
      'Se listan hasta cuarenta evaluaciones más recientes que cumplen los filtros. Cada fila indica procedencia, plantel, código Holland, carrera principal recomendada, afinidad y fecha de conclusión. Las respuestas abiertas complementarias, de existir, se indican de forma resumida.',
    );

    const evalRows = (data.evaluations ?? []).slice(0, 40);
    if (!evalRows.length) {
      doc.fillColor(MUTED).font('Noto-Italic').fontSize(9)
        .text('No hay evaluaciones para los filtros seleccionados.', marginL, doc.y);
    } else {
      // encabezado de tabla (celdas con aire: HPAD horizontal, VPAD vertical)
      const HPAD = 7;
      const VPAD = 6;
      ensureSpace(60);
      const cols = [
        { key: 'fecha', w: 62, title: 'Fecha' },
        { key: 'lugar', w: 110, title: 'Municipio / Edo.' },
        { key: 'escuela', w: 100, title: 'Escuela' },
        { key: 'holland', w: 40, title: 'Holland' },
        { key: 'carrera', w: 120, title: 'Carrera principal' },
        { key: 'afinidad', w: 48, title: 'Afinidad' },
      ];
      const headerY = doc.y;
      const headerH = 26;
      doc.rect(marginL, headerY, contentW, headerH).fill('#e8edf7');
      let x = marginL + HPAD;
      doc.fillColor(BLUE).font('Noto-Bold').fontSize(7);
      for (const c of cols) {
        doc.text(c.title, x, headerY + VPAD, { width: c.w - HPAD - 3 });
        x += c.w;
      }
      // Rejilla tipo Excel: contorno + divisiones verticales del encabezado
      doc.strokeColor(LINE).lineWidth(0.6);
      doc.rect(marginL, headerY, contentW, headerH).stroke();
      let hx = marginL;
      for (const c of cols) {
        hx += c.w;
        doc.moveTo(hx, headerY).lineTo(hx, headerY + headerH).stroke();
      }
      doc.y = headerY + headerH;

      doc.font('Noto').fontSize(7).fillColor(INK);
      for (const row of evalRows) {
        const fecha = row.completed_at
          ? new Date(row.completed_at).toLocaleDateString('es-MX')
          : '—';
        const lugar = `${row.municipality_name ?? '—'}, ${row.state_name ?? '—'}`;
        const escuela = String(row.school_name ?? '—');
        const holland = String(row.holland_code ?? '—');
        const carrera = String(row.top_career_name ?? '—');
        const afinidad = `${Number(row.top_career_affinity ?? 0).toFixed(1)}%`;
        const values = [fecha, lugar, escuela, holland, carrera, afinidad];
        // Alto medido por celda: el texto envuelve en vez de encimarse.
        const heights = values.map((v, i) =>
          doc.heightOfString(String(v), { width: cols[i].w - HPAD * 2 }),
        );
        const rowH = Math.min(Math.max(...heights, 10) + VPAD * 2 + 2, 64);
        ensureSpace(rowH + 6);
        const rowY = doc.y;
        x = marginL + HPAD;
        values.forEach((v, i) => {
          doc.fillColor(INK).text(v, x, rowY + VPAD, {
            width: cols[i].w - HPAD * 2,
            height: rowH - VPAD * 2,
            ellipsis: true,
          });
          x += cols[i].w;
        });
        // Rejilla tipo Excel: contorno de la fila + divisiones verticales
        // (las filas quedan pegadas para que la cuadrícula sea continua).
        doc.strokeColor(LINE).lineWidth(0.6);
        doc.rect(marginL, rowY, contentW, rowH).stroke();
        let vx = marginL;
        for (const c of cols) {
          vx += c.w;
          doc.moveTo(vx, rowY).lineTo(vx, rowY + rowH).stroke();
        }
        doc.y = rowY + rowH;
      }
    }

    // El punto «9. Nota metodológica» se retiró del reporte a petición del
    // usuario: el documento termina en la tabla del punto 8 (la fecha de
    // emisión se conserva en la portada).

    // Pie de página en todas las páginas (después de buffer completo)
    drawFooter();
    doc.end();
    await pdfReady;
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.send(Buffer.concat(pdfChunks));
  } catch (error) {
    console.error(error);
    if (!res.headersSent) res.status(500).json({ error: 'No fue posible generar el PDF' });
  }
});

// ─── Socket.IO: salas de administradores ──────────────────────────────────────
io.use((socket, next) => {
  // Autenticación simple por cookie de sesión (mismo token que requireAdmin)
  const cookieHeader = socket.handshake.headers.cookie ?? '';
  const cookies = Object.fromEntries(
    String(cookieHeader).split(';').map(v => v.trim()).filter(Boolean).map(v => {
      const i = v.indexOf('=');
      return i < 0 ? [v, ''] : [v.slice(0, i), decodeURIComponent(v.slice(i + 1))];
    }),
  );
  const token = cookies.app_vocacional_admin;
  if (!adminUser || !adminPassword) {
    // Sin credenciales configuradas, permitir (modo desarrollo)
    return next();
  }
  if (token && validSession(token)) return next();
  return next(new Error('No autorizado'));
});

io.on('connection', (socket) => {
  socket.join('admins');
  socket.emit('connected', { ok: true, message: 'Panel en tiempo real activo' });
  socket.on('disconnect', () => {});
});

server.listen(port, '0.0.0.0', () => {
  console.log(`App Vocacional ITTUX Panel: http://localhost:${port}`);
  console.log(`  · Tiempo real (Socket.IO) activo`);
  console.log(`  · Reportes PDF: GET /api/admin/report.pdf`);
});