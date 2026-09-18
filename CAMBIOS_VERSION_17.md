# App Vocacional ITTUX - Versión 17

## SQLite
- La base local pasa a llamarse `app_vocacional_ittux.db` y la versión del esquema sube a 14.
- Se añadieron claves foráneas físicas en las tablas operativas del test para que las herramientas de ingeniería inversa puedan detectar las relaciones.
- Se mantienen `PRAGMA foreign_keys = ON` y las relaciones existentes de catálogos y perfil.
- El archivo semilla pasa a `assets/database/app_vocacional_catalog_v14.db` y fue reconstruido con sus claves foráneas.
- Se incluye `database_model/app_vocacional_ittux_sqlite_v14.db`, una base vacía de 19 tablas preparada específicamente para abrir en DBeaver y generar el diagrama relacional completo.

## MySQL/MariaDB
- El esquema central pasa a llamarse `app_vocacional_ittux` en `schema.sql`, migraciones, configuración y documentación.
- Se actualizaron los nombres predeterminados del panel y de la conexión para eliminar la denominación anterior.

## Configuración
- Las variables de compilación Flutter ahora son `APP_VOCACIONAL_API_URL` y `APP_VOCACIONAL_API_KEY`.
- Se actualizaron `.vscode/launch.json`, `.env.example`, README y documentos de instalación.

## Nota de actualización
El cambio del nombre físico de la base SQLite implica que una instalación existente creará una nueva base local. Para probar esta versión se recomienda una instalación limpia de la app. En MySQL/MariaDB, `schema.sql` crea el nuevo esquema `app_vocacional_ittux`; respalda cualquier información que necesites conservar antes de recrearlo.
