import express from 'express';
import cors from 'cors';
import 'dotenv/config';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from './db.js';

const app = express();
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

function requireAdmin(req, res, next) {
  if (!adminUser || !adminPassword) return next();
  const authorization = req.get('authorization') ?? '';
  if (!authorization.startsWith('Basic ')) {
    res.setHeader('WWW-Authenticate', 'Basic realm="AEVUM ITER"');
    return res.status(401).send('Autenticación requerida');
  }
  try {
    const decoded = Buffer.from(authorization.slice(6), 'base64').toString('utf8');
    const separator = decoded.indexOf(':');
    const user = decoded.slice(0, separator);
    const password = decoded.slice(separator + 1);
    if (separator > 0 && user === adminUser && password === adminPassword) return next();
  } catch (_) {}
  res.setHeader('WWW-Authenticate', 'Basic realm="AEVUM ITER"');
  return res.status(401).send('Credenciales inválidas');
}

app.get('/health', async (_req, res) => {
  await pool.query('SELECT 1');
  res.json({ ok: true, service: 'aevum-iter-panel' });
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
    const [existing] = await connection.query(
      'SELECT id FROM evaluations WHERE external_result_id = ? LIMIT 1',
      [body.result_id]
    );
    if (existing.length > 0) {
      await connection.rollback();
      return res.status(200).json({ ok: true, duplicated: true });
    }

    const [studentInsert] = await connection.execute(
      `INSERT INTO students
      (local_profile_id,name,age,gender,state_id,state_name,municipality_id,municipality_name,school_id,school_name,languages_json)
      VALUES (?,?,?,?,?,?,?,?,?,?,?)`,
      [
        student.local_profile_id ?? null,
        student.name,
        Number(student.age),
        student.gender ?? null,
        student.state_id ?? null,
        student.state ?? null,
        student.municipality_id ?? null,
        student.municipality ?? null,
        student.school_id ?? null,
        student.school ?? null,
        JSON.stringify(student.languages ?? [])
      ]
    );

    await connection.execute(
      `INSERT INTO evaluations
      (external_result_id,session_id,student_id,holland_code,score_r,score_i,score_a,score_s,score_e,score_c,top_career_id,top_career_name,top_career_affinity,completed_at)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        body.result_id,
        body.session_id,
        studentInsert.insertId,
        result.holland_code ?? '',
        Number(result.score_r ?? 0),
        Number(result.score_i ?? 0),
        Number(result.score_a ?? 0),
        Number(result.score_s ?? 0),
        Number(result.score_e ?? 0),
        Number(result.score_c ?? 0),
        result.top_career_id ?? null,
        result.top_career_name,
        Number(result.top_career_affinity ?? 0),
        new Date(body.completed_at ?? Date.now())
      ]
    );

    await connection.commit();
    res.status(201).json({ ok: true });
  } catch (error) {
    await connection.rollback();
    console.error(error);
    res.status(500).json({ error: 'No fue posible guardar la evaluación' });
  } finally {
    connection.release();
  }
});

async function dashboardData() {
  const [[totals]] = await pool.query(
    `SELECT COUNT(*) total_evaluations, ROUND(AVG(s.age),1) average_age,
            COUNT(DISTINCT s.school_name) schools,
            ROUND(AVG(e.top_career_affinity),1) average_affinity
     FROM evaluations e JOIN students s ON s.id=e.student_id`
  );
  const [careers] = await pool.query(
    `SELECT top_career_name label, COUNT(*) value
     FROM evaluations GROUP BY top_career_name ORDER BY value DESC LIMIT 10`
  );
  const [schools] = await pool.query(
    `SELECT COALESCE(s.school_name,'No especificada') label, COUNT(*) value
     FROM evaluations e JOIN students s ON s.id=e.student_id
     GROUP BY s.school_name ORDER BY value DESC LIMIT 10`
  );
  const [states] = await pool.query(
    `SELECT COALESCE(s.state_name,'No especificado') label, COUNT(*) value
     FROM evaluations e JOIN students s ON s.id=e.student_id
     GROUP BY s.state_name ORDER BY value DESC LIMIT 10`
  );
  const [municipalities] = await pool.query(
    `SELECT COALESCE(s.municipality_name,'No especificado') label, COUNT(*) value
     FROM evaluations e JOIN students s ON s.id=e.student_id
     GROUP BY s.municipality_name ORDER BY value DESC LIMIT 10`
  );
  const [languages] = await pool.query(
    `SELECT languages_json FROM students WHERE languages_json IS NOT NULL`
  );
  const languageCounts = new Map();
  for (const row of languages) {
    let values = [];
    try { values = typeof row.languages_json === 'string' ? JSON.parse(row.languages_json) : row.languages_json; } catch (_) {}
    if (!Array.isArray(values)) continue;
    for (const language of values) {
      languageCounts.set(language, (languageCounts.get(language) ?? 0) + 1);
    }
  }
  const languageStats = [...languageCounts.entries()]
    .map(([label,value]) => ({label,value}))
    .sort((a,b) => b.value-a.value)
    .slice(0,10);

  const [recentEvaluations] = await pool.query(
    `SELECT e.id, s.name, s.age, s.state_name, s.municipality_name, s.school_name,
            s.languages_json, e.holland_code, e.top_career_name,
            e.top_career_affinity, e.completed_at
     FROM evaluations e JOIN students s ON s.id=e.student_id
     ORDER BY e.completed_at DESC LIMIT 100`
  );
  const evaluations = recentEvaluations.map((row) => {
    let languages = [];
    try { languages = typeof row.languages_json === 'string' ? JSON.parse(row.languages_json) : (row.languages_json ?? []); } catch (_) {}
    return { ...row, languages: Array.isArray(languages) ? languages : [] };
  });

  return { totals, careers, schools, states, municipalities, languages: languageStats, evaluations };
}

app.get('/api/dashboard/summary', requireAdmin, async (_req, res) => {
  try { res.json(await dashboardData()); }
  catch (error) { console.error(error); res.status(500).json({ error: 'Error consultando estadísticas' }); }
});

app.get('/', requireAdmin, async (_req, res) => {
  try { res.render('dashboard', { data: await dashboardData() }); }
  catch (error) { console.error(error); res.status(500).send('No fue posible cargar el panel.'); }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`AEVUM ITER Panel: http://localhost:${port}`);
});
