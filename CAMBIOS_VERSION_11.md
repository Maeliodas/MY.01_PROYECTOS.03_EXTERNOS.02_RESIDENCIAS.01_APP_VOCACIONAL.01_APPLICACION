# AEVUM ITER V11

## Correcciones
- El panel obtiene las evaluaciones sin depender de `GROUP BY` sobre `student_languages`; lenguas e idiomas se agregan mediante subconsultas por estudiante.
- Se conserva el filtrado por estado, municipio, escuela, perfil, carrera y fechas.
- Las respuestas abiertas quedan asociadas a la evaluación y conservan el texto de la pregunta.

## Preguntas complementarias
- Después de las 30 preguntas RIASEC se calcula provisionalmente el ranking.
- Solo se muestran tres preguntas abiertas: una por cada carrera del Top 3.
- Todas están redactadas como actividades concretas en formato “¿Te gustaría...?”.
- No alteran la puntuación RIASEC.

## Instalación
- Instalación nueva: usar `admin_panel/sql/schema.sql`.
- Si ya existe una V10 con datos: ejecutar `admin_panel/sql/migrate_v11.sql` una sola vez y reiniciar Node.
