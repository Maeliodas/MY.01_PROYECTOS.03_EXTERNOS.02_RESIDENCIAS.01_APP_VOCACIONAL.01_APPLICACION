import express from 'express';
import cors from 'cors';
import 'dotenv/config';
import path from 'path';
import { fileURLToPath } from 'url';
import crypto from 'crypto';
import http from 'http';
import { Server as SocketServer } from 'socket.io';
import PDFDocument from 'pdfkit';
import { pool } from './db.js';

const app = express();
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
app.use(express.static(path.join(__dirname, '../public')));
app.use((_req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');
  next();
});

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
  const user = String(req.body.user ?? '');
  const password = String(req.body.password ?? '');
  if (user !== adminUser || password !== adminPassword) return res.status(401).render('login', { error: 'Usuario o contraseña incorrectos.' });
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
    res.render('dashboard', { data, catalogs, filters: req.query });
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
      margins: { top: 90, bottom: 70, left: 50, right: 50 },
      info: {
        Title: 'Reporte de orientación vocacional — App Vocacional ITTUX',
        Author: 'Instituto Tecnológico de Tuxtepec',
        Subject: 'Estadísticas de evaluaciones RIASEC filtradas',
        Creator: 'App Vocacional ITTUX Admin Panel',
      },
    });
    const filename = `reporte-vocacional-ittux-${new Date().toISOString().slice(0, 10)}.pdf`;
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    doc.pipe(res);

    const GREEN = '#00923f';
    const INK = '#1a2420';
    const MUTED = '#5a6b62';
    const LINE = '#c5d0c8';
    const BAR = '#00923f';
    const BAR_BG = '#e8f0eb';
    const pageW = doc.page.width;
    const pageH = doc.page.height;
    const marginL = 50;
    const marginR = 50;
    const contentW = pageW - marginL - marginR;

    const generatedAt = new Date().toLocaleString('es-MX', {
      dateStyle: 'long',
      timeStyle: 'short',
    });

    function drawHeader() {
      doc.save();
      // franja superior
      doc.rect(0, 0, pageW, 64).fill(GREEN);
      doc.fillColor('#ffffff').font('Helvetica-Bold').fontSize(13)
        .text('INSTITUTO TECNOLÓGICO DE TUXTEPEC', marginL, 14, { width: contentW, align: 'left' });
      doc.font('Helvetica').fontSize(9)
        .text('App Vocacional ITTUX  ·  Panel de orientación vocacional', marginL, 32, { width: contentW });
      doc.font('Helvetica').fontSize(8)
        .text('Documento oficial de resultados', marginL, 46, { width: contentW });
      // línea decorativa
      doc.rect(0, 64, pageW, 3).fill('#d3d5bd');
      doc.restore();
      doc.y = 90;
    }

    function drawFooter() {
      const range = doc.bufferedPageRange();
      for (let i = 0; i < range.count; i++) {
        doc.switchToPage(range.start + i);
        doc.save();
        doc.strokeColor(LINE).lineWidth(0.6)
          .moveTo(marginL, pageH - 48)
          .lineTo(pageW - marginR, pageH - 48)
          .stroke();
        doc.fillColor(MUTED).font('Helvetica').fontSize(8);
        doc.text(
          'Confidencial — uso institucional · Generado automáticamente por el panel administrativo',
          marginL,
          pageH - 40,
          { width: contentW * 0.72, align: 'left' },
        );
        doc.text(
          `Página ${i + 1} de ${range.count}`,
          marginL,
          pageH - 40,
          { width: contentW, align: 'right' },
        );
        doc.restore();
      }
    }

    function ensureSpace(needed = 80) {
      if (doc.y + needed > pageH - 70) {
        doc.addPage();
        drawHeader();
      }
    }

    function sectionTitle(title) {
      ensureSpace(36);
      doc.fillColor(GREEN).font('Helvetica-Bold').fontSize(12).text(title, marginL, doc.y, { width: contentW });
      doc.moveDown(0.25);
      doc.strokeColor(LINE).lineWidth(0.8)
        .moveTo(marginL, doc.y)
        .lineTo(marginL + contentW, doc.y)
        .stroke();
      doc.moveDown(0.6);
      doc.fillColor(INK);
    }

    function formalParagraph(text) {
      ensureSpace(40);
      doc.fillColor(INK).font('Helvetica').fontSize(10).text(text, marginL, doc.y, {
        width: contentW,
        align: 'justify',
        lineGap: 2,
      });
      doc.moveDown(0.7);
    }

    /** Gráfico de barras horizontales dibujado con primitivas PDFKit */
    function drawBarChart(title, rows, { maxBars = 8, barHeight = 14, gap = 8 } = {}) {
      const series = (rows || []).slice(0, maxBars).filter(r => r && r.label != null);
      ensureSpace(60 + series.length * (barHeight + gap));
      doc.fillColor(INK).font('Helvetica-Bold').fontSize(10).text(title, marginL, doc.y, { width: contentW });
      doc.moveDown(0.4);

      if (!series.length) {
        doc.fillColor(MUTED).font('Helvetica-Oblique').fontSize(9)
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
        const label = String(row.label).slice(0, 42);

        doc.fillColor(INK).font('Helvetica').fontSize(8)
          .text(label, marginL, y + 2, { width: labelW, ellipsis: true });

        // fondo de barra
        doc.roundedRect(marginL + labelW + 6, y, barMaxW, barHeight, 3).fill(BAR_BG);
        // valor
        doc.roundedRect(marginL + labelW + 6, y, w, barHeight, 3).fill(BAR);

        doc.fillColor(INK).font('Helvetica-Bold').fontSize(8)
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
        doc.roundedRect(x, y, boxW, 48, 4).fill('#f4f7f5');
        doc.fillColor(MUTED).font('Helvetica').fontSize(7)
          .text(item.label.toUpperCase(), x + 8, y + 8, { width: boxW - 16 });
        doc.fillColor(GREEN).font('Helvetica-Bold').fontSize(14)
          .text(item.value, x + 8, y + 22, { width: boxW - 16 });
      });
      doc.y = y + 56;
      doc.moveDown(0.3);
    }

    // ── Página 1: portada / introducción ────────────────────────────────────
    drawHeader();

    doc.fillColor(INK).font('Helvetica-Bold').fontSize(16)
      .text('Reporte de orientación vocacional', marginL, doc.y, { width: contentW });
    doc.moveDown(0.3);
    doc.fillColor(MUTED).font('Helvetica').fontSize(9)
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

    sectionTitle('2. Indicadores generales');
    formalParagraph(
      'A continuación se resumen los indicadores principales derivados del conjunto de evaluaciones que cumplen los filtros indicados. La afinidad media expresa el promedio del porcentaje de coincidencia entre el perfil RIASEC del estudiante y la carrera recomendada en primer lugar.',
    );
    kpiRow(data.totals ?? {});

    sectionTitle('3. Distribución de carreras recomendadas');
    formalParagraph(
      'La gráfica muestra las carreras con mayor frecuencia como recomendación principal. Cada barra representa el número de evaluaciones en las que dicha carrera ocupó el primer lugar del ranking individual.',
    );
    drawBarChart('Carreras más recomendadas', data.careers, { maxBars: 10 });

    sectionTitle('4. Perfiles RIASEC (códigos Holland)');
    formalParagraph(
      'Los códigos Holland agrupan las tres dimensiones RIASEC predominantes de cada evaluación (Realista, Investigador, Artístico, Social, Emprendedor, Convencional). La distribución permite identificar los perfiles vocacionales más frecuentes en la población filtrada.',
    );
    drawBarChart('Frecuencia de códigos Holland', data.profiles, { maxBars: 10 });

    sectionTitle('5. Afinidad con la carrera principal');
    formalParagraph(
      'Se agrupan las evaluaciones según el intervalo de afinidad porcentual respecto a la carrera recomendada en primer lugar. Intervalos altos sugieren una coincidencia sólida entre intereses del estudiante y la oferta formativa sugerida.',
    );
    drawBarChart('Distribución por rango de afinidad', data.affinity, { maxBars: 6 });

    sectionTitle('6. Planteles y procedencia');
    formalParagraph(
      'Se detalla la participación por escuela de procedencia y por municipio/estado, útil para contrastar cobertura territorial y carga de orientación por plantel.',
    );
    drawBarChart('Evaluaciones por escuela', data.schools, { maxBars: 8 });
    drawBarChart('Evaluaciones por municipio / estado', data.provenance, { maxBars: 8 });

    if ((data.languages ?? []).length || (data.idioms ?? []).length) {
      sectionTitle('7. Lenguas originarias e idiomas');
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

    sectionTitle('8. Registro detallado de evaluaciones recientes');
    formalParagraph(
      'Se listan hasta cuarenta evaluaciones más recientes que cumplen los filtros. Cada fila indica procedencia, plantel, código Holland, carrera principal recomendada, afinidad y fecha de conclusión. Las respuestas abiertas complementarias, de existir, se indican de forma resumida.',
    );

    const evalRows = (data.evaluations ?? []).slice(0, 40);
    if (!evalRows.length) {
      doc.fillColor(MUTED).font('Helvetica-Oblique').fontSize(9)
        .text('No hay evaluaciones para los filtros seleccionados.', marginL, doc.y);
    } else {
      // encabezado de tabla
      ensureSpace(30);
      const cols = [
        { key: 'fecha', w: 62, title: 'Fecha' },
        { key: 'lugar', w: 110, title: 'Municipio / Edo.' },
        { key: 'escuela', w: 100, title: 'Escuela' },
        { key: 'holland', w: 40, title: 'Holland' },
        { key: 'carrera', w: 120, title: 'Carrera principal' },
        { key: 'afinidad', w: 48, title: 'Afinidad' },
      ];
      const headerY = doc.y;
      doc.rect(marginL, headerY, contentW, 16).fill('#e8f0eb');
      let x = marginL + 3;
      doc.fillColor(GREEN).font('Helvetica-Bold').fontSize(7);
      for (const c of cols) {
        doc.text(c.title, x, headerY + 4, { width: c.w - 4 });
        x += c.w;
      }
      doc.y = headerY + 18;

      doc.font('Helvetica').fontSize(7).fillColor(INK);
      for (const row of evalRows) {
        ensureSpace(22);
        const fecha = row.completed_at
          ? new Date(row.completed_at).toLocaleDateString('es-MX')
          : '—';
        const lugar = `${row.municipality_name ?? '—'}, ${row.state_name ?? '—'}`.slice(0, 40);
        const escuela = String(row.school_name ?? '—').slice(0, 36);
        const holland = String(row.holland_code ?? '—');
        const carrera = String(row.top_career_name ?? '—').slice(0, 42);
        const afinidad = `${Number(row.top_career_affinity ?? 0).toFixed(1)}%`;
        const values = [fecha, lugar, escuela, holland, carrera, afinidad];
        const rowY = doc.y;
        x = marginL + 3;
        values.forEach((v, i) => {
          doc.fillColor(INK).text(v, x, rowY, { width: cols[i].w - 4, ellipsis: true });
          x += cols[i].w;
        });
        doc.y = rowY + 12;
        doc.strokeColor(LINE).lineWidth(0.3)
          .moveTo(marginL, doc.y)
          .lineTo(marginL + contentW, doc.y)
          .stroke();
        doc.moveDown(0.25);
      }
    }

    doc.moveDown(1);
    ensureSpace(50);
    sectionTitle('9. Nota metodológica');
    formalParagraph(
      'Las evaluaciones se basan en un instrumento de treinta reactivos alineados al modelo RIASEC. El código Holland se obtiene a partir de las tres dimensiones con mayor puntuación. El ranking de carreras combina el perfil del estudiante con los pesos RIASEC definidos en el catálogo institucional. Este reporte no sustituye la asesoría personalizada de orientadores educativos.',
    );
    formalParagraph(
      `Documento generado el ${generatedAt}. Cualquier reproducción o difusión fuera del ámbito institucional del Instituto Tecnológico de Tuxtepec debe autorizarse expresamente.`,
    );

    // Pie de página en todas las páginas (después de buffer completo)
    drawFooter();
    doc.end();
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