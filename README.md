# App Vocacional ITTUX 1.3.1-5

Aplicación Flutter de orientación vocacional RIASEC con operación offline-first, SQLite local, backend Node/Express, MySQL/MariaDB y panel administrativo CRUD.

## Esquema de versión

`1.3.1-5`: versión **1**, sub modificación semigrande **3**, subcambios menores **1**, revisión **5**.

## 1.3.1-5

- Test RIASEC offline-first con SQLite local y catálogos sincronizables: estados, municipios, escuelas, lenguas, idiomas, preguntas y carreras.
- Pregunta abierta obligatoria asociada al departamento de la primera carrera; no modifica puntaje ni afinidad.
- Clasificación lengua materna/extranjera por tipo relacional, no por prefijo de id.
- Verificación de conexión contra el backend (`/health`) y cola de envío con límite de reintentos.
- Editor de avatar con avatares incluidos, galería y cámara.
- Top 3 de carreras con enlaces oficiales de TecNM/Tec de Tuxtepec cuando están disponibles.
- Panel web con CRUD, filtros, dashboard en vivo y reportes PDF.
- Corrección integral de UTF-8/utf8mb4 para acentos y caracteres del español.

Consulta `INSTALACION_VERSION_13.md` antes de instalar.
