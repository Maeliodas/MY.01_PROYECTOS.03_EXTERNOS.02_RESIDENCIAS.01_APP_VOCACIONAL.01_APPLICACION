# AEVUM ITER — Cambios versión 13

## App Flutter

- Los avisos de "página de carrera no disponible" ahora se muestran en un diálogo centrado con diseño propio de AEVUM ITER.
- El aviso de privacidad se abre como diálogo centrado desde onboarding y Configuración.
- Se agregó `department` al catálogo local de carreras.
- Se agregó el catálogo SQLite `department_open_questions`.
- Cada carrera está asociada a uno de seis departamentos.
- Al finalizar el test se muestra una sola pregunta complementaria: la del departamento de la carrera Top 1.
- La respuesta complementaria no modifica RIASEC, Holland ni el porcentaje de afinidad.
- El catálogo de preguntas departamentales se sincroniza desde el backend y funciona offline con SQLite.

## Panel / backend

- Carrera: nuevo selector obligatorio de Departamento.
- Se eliminó del formulario la pregunta individual por carrera.
- Se agregó un administrador visual con una única pregunta complementaria por cada departamento.
- Los formularios de altas ya no solicitan clave ni ID; el servidor los genera automáticamente.
- Las preguntas del test conservan un orden opcional, pero su ID se genera automáticamente.
- El endpoint `/api/catalogs` sincroniza el departamento de cada carrera y `department_questions`.
- Nuevo endpoint administrativo: `PUT /api/admin/department-questions/:department`.

## Departamentos

- Ciencias de la Tierra: Ingeniería Civil, Arquitectura.
- Económico Administrativo: Administración, Gestión Empresarial, Contador Público.
- Química: Ingeniería Bioquímica.
- Sistemas y Computación: Informática, Desarrollo de Aplicaciones, Sistemas Computacionales.
- Metal Mecánica: Electromecánica.
- Eléctrica: Electrónica.

## Base de datos

- `careers.department` en MySQL/MariaDB y SQLite.
- Nueva tabla `department_open_questions` / `department_open_questions` en servidor y `department_open_questions` en SQLite.
- `schema.sql` ya contiene todos los cambios para instalación limpia.
- `migrate_v13.sql` se incluye únicamente para instalaciones existentes V12.
