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
  const token = parseCookies(req).aevum_admin;
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
  res.json({ ok: true, service: 'aevum-iter-panel' });
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
      pool.query('SELECT id,name,state_id,municipality_id,type,active FROM schools ORDER BY name'),
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
  if (!['lengua', 'idioma'].includes(kind) || name.length < 2 || name.length > 120) {
    return res.status(400).json({ error: 'Sugerencia inválida' });
  }
  try {
    const [existing] = await pool.execute(
      'SELECT id FROM languages WHERE kind=? AND LOWER(name)=LOWER(?) LIMIT 1',
      [kind, name],
    );
    if (existing.length) return res.status(200).json({ ok: true, already_exists: true });
    await pool.execute(
      `INSERT INTO catalog_suggestions(kind,name,status) VALUES(?,?,'pending')
       ON DUPLICATE KEY UPDATE created_at=created_at`,
      [kind, name],
    );
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
    const [studentInsert] = await connection.execute(
      `INSERT INTO students
      (local_profile_id,name,age,gender,state_id,state_name,municipality_id,municipality_name,school_id,school_name)
      VALUES (?,?,?,?,?,?,?,?,?,?)`,
      [
        student.local_profile_id ?? null, student.name, Number(student.age), student.gender ?? null,
        student.state_id ?? null, student.state ?? null, student.municipality_id ?? null,
        student.municipality ?? null, student.school_id ?? null, student.school ?? null,
      ],
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
    io.to('admins').emit('new-evaluation', {
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
  push('s.state_id = ?', query.state);
  push('s.municipality_id = ?', query.municipality);
  push('s.school_id = ?', query.school);
  push('e.holland_code = ?', query.profile);
  push('e.top_career_id = ?', query.career);
  if (query.from) { clauses.push('DATE(e.completed_at) >= ?'); params.push(query.from); }
  if (query.to) { clauses.push('DATE(e.completed_at) <= ?'); params.push(query.to); }
  return { where: clauses.length ? `WHERE ${clauses.join(' AND ')}` : '', params };
}

async function dashboardData(query = {}) {
  const { where, params } = buildEvaluationFilter(query);
  const base = 'FROM evaluations e JOIN students s ON s.id=e.student_id';
  const [[totals]] = await pool.query(
    `SELECT COUNT(*) total_evaluations, COUNT(DISTINCT s.school_name) schools,
            ROUND(AVG(e.top_career_affinity),1) average_affinity,
            COUNT(DISTINCT e.holland_code) profiles ${base} ${where}`,
    params,
  );
  const [careers] = await pool.query(`SELECT e.top_career_name label, COUNT(*) value ${base} ${where} GROUP BY e.top_career_name ORDER BY value DESC LIMIT 10`, params);
  const [schools] = await pool.query(`SELECT COALESCE(s.school_name,'No especificada') label, COUNT(*) value ${base} ${where} GROUP BY s.school_name ORDER BY value DESC LIMIT 10`, params);
  const [provenance] = await pool.query(`SELECT CONCAT(COALESCE(s.municipality_name,'No especificado'), ', ', COALESCE(s.state_name,'No especificado')) label, COUNT(*) value ${base} ${where} GROUP BY s.municipality_name,s.state_name ORDER BY value DESC LIMIT 10`, params);
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
     WHERE sl.kind='lengua' ${languageFilter} GROUP BY sl.name ORDER BY value DESC,sl.name LIMIT 10`,
    params,
  );
  const [idioms] = await pool.query(
    `SELECT sl.name label, COUNT(*) value FROM student_languages sl
     JOIN students s ON s.id=sl.student_id JOIN evaluations e ON e.student_id=s.id
     WHERE sl.kind='idioma' ${languageFilter} GROUP BY sl.name ORDER BY value DESC,sl.name LIMIT 10`,
    params,
  );
  // La tabla de resultados no depende de un JOIN/GROUP BY con student_languages.
  // Esto evita que una evaluación válida desaparezca del panel por diferencias
  // de SQL mode o por no tener lenguas/idiomas asociados.
  const [recentEvaluations] = await pool.query(
    `SELECT e.id,s.state_name,s.municipality_name,s.school_name,e.holland_code,
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
    pool.query(`SELECT sc.*,s.name state_name,m.name municipality_name FROM schools sc LEFT JOIN states s ON s.id=sc.state_id LEFT JOIN municipalities m ON m.id=sc.municipality_id ORDER BY sc.active DESC,sc.name`),
    pool.query('SELECT * FROM languages ORDER BY active DESC,kind,name'),
    pool.query('SELECT * FROM careers ORDER BY active DESC,name'),
    pool.query('SELECT * FROM department_open_questions ORDER BY department'),
    pool.query('SELECT * FROM questions ORDER BY active DESC,position,id'),
    pool.query("SELECT * FROM catalog_suggestions ORDER BY FIELD(status,'pending','approved','rejected'),created_at DESC LIMIT 200"),
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
  res.setHeader('Set-Cookie', `aevum_admin=${encodeURIComponent(sessionToken())}; HttpOnly; SameSite=Lax; Path=/; Max-Age=28800`);
  res.redirect('/');
});
app.post('/logout', (_req, res) => {
  res.setHeader('Set-Cookie', 'aevum_admin=; HttpOnly; SameSite=Lax; Path=/; Max-Age=0');
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
  schools: { table: 'schools', fields: ['id','name','state_id','municipality_id','type','active'] },
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
      await connection.execute(
        'INSERT INTO languages(id,name,kind,active) VALUES(?,?,?,1) ON DUPLICATE KEY UPDATE active=1',
        [id, item.name, item.kind],
      );
      await connection.execute("UPDATE catalog_suggestions SET status='approved',reviewed_at=CURRENT_TIMESTAMP WHERE id=?", [item.id]);
      await bumpCatalogVersion(connection);
    } else {
      await connection.execute("UPDATE catalog_suggestions SET status='rejected',reviewed_at=CURRENT_TIMESTAMP WHERE id=?", [item.id]);
    }
    await connection.commit();
    res.json({ ok: true });
  } catch (error) {
    await connection.rollback();
    console.error(error);
    res.status(400).json({ error: error.sqlMessage ?? 'No fue posible revisar la sugerencia' });
  } finally { connection.release(); }
});

// ─── Reporte PDF (usa los mismos filtros del dashboard) ───────────────────────
app.get('/api/admin/report.pdf', requireAdmin, async (req, res) => {
  try {
    const data = await dashboardData(req.query);
    const doc = new PDFDocument({ margin: 50, size: 'A4' });
    const filename = `aevum-iter-reporte-${new Date().toISOString().slice(0, 10)}.pdf`;
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    doc.pipe(res);

    const green = '#00923f';
    doc.fillColor(green).fontSize(20).text('AEVUM ITER · Reporte de orientaciones', { align: 'left' });
    doc.moveDown(0.3);
    doc.fillColor('#27352e').fontSize(10)
      .text('Instituto Tecnológico de Tuxtepec')
      .text(`Generado: ${new Date().toLocaleString('es-MX')}`)
      .text(`Filtros: estado=${req.query.state || 'todos'} · municipio=${req.query.municipality || 'todos'} · escuela=${req.query.school || 'todos'} · perfil=${req.query.profile || 'todos'} · carrera=${req.query.career || 'todos'}`);
    doc.moveDown();

    // Totales
    doc.fillColor(green).fontSize(14).text('Resumen');
    doc.fillColor('#27352e').fontSize(11).moveDown(0.4);
    const t = data.totals ?? {};
    doc.text(`Total de evaluaciones: ${t.total_evaluations ?? 0}`);
    doc.text(`Escuelas distintas: ${t.schools ?? 0}`);
    doc.text(`Afinidad promedio: ${t.average_affinity ?? 0}%`);
    doc.text(`Perfiles Holland distintos: ${t.profiles ?? 0}`);
    doc.moveDown();

    // Top carreras
    doc.fillColor(green).fontSize(14).text('Top carreras recomendadas');
    doc.fillColor('#27352e').fontSize(10).moveDown(0.3);
    for (const row of (data.careers ?? []).slice(0, 10)) {
      doc.text(`• ${row.label}: ${row.value}`);
    }
    doc.moveDown();

    // Perfiles
    doc.fillColor(green).fontSize(14).text('Perfiles RIASEC (Holland)');
    doc.fillColor('#27352e').fontSize(10).moveDown(0.3);
    for (const row of (data.profiles ?? []).slice(0, 10)) {
      doc.text(`• ${row.label}: ${row.value}`);
    }
    doc.moveDown();

    // Tabla de registros recientes
    doc.fillColor(green).fontSize(14).text('Registros recientes (máx. 40)');
    doc.fillColor('#27352e').fontSize(9).moveDown(0.4);
    const rows = (data.evaluations ?? []).slice(0, 40);
    if (!rows.length) {
      doc.text('No hay evaluaciones para los filtros seleccionados.');
    } else {
      for (const row of rows) {
        const fecha = row.completed_at
          ? new Date(row.completed_at).toLocaleDateString('es-MX')
          : '—';
        doc.text(
          `${fecha} | ${row.municipality_name ?? '—'}, ${row.state_name ?? '—'} | ${row.school_name ?? '—'} | ${row.holland_code ?? '—'} → ${row.top_career_name ?? '—'} (${Number(row.top_career_affinity ?? 0).toFixed(1)}%)`,
          { width: 500 },
        );
        doc.moveDown(0.15);
      }
    }

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
  const token = cookies.aevum_admin;
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
  console.log(`AEVUM ITER Panel: http://localhost:${port}`);
  console.log(`  · Tiempo real (Socket.IO) activo`);
  console.log(`  · Reportes PDF: GET /api/admin/report.pdf`);
});