# App Vocacional ITTUX V18

## Normalización de bases de datos
- SQLite y MySQL/MariaDB normalizan la dependencia geográfica a `states 1:N municipalities 1:N schools`.
- Se elimina `schools.state_id`; el estado de una escuela se obtiene mediante `schools.municipality_id -> municipalities.state_id`.
- `municipality_id` permanece nullable únicamente para la opción global `Otra escuela`.
- SQLite sube a versión 15, activa `PRAGMA foreign_keys = ON` y migra perfiles/escuelas conservando datos.
- Se regeneró la semilla SQLite como `app_vocacional_catalog_v15.db`.
- Se añadió `admin_panel/sql/migrate_v18_normalizacion.sql` para bases MySQL/MariaDB V17 existentes.
- El panel conserva el selector Estado al capturar escuelas solo para filtrar municipios; `state_id` ya no se almacena en `schools`.
- Se eliminaron rastros textuales del nombre anterior en panel, servicio, cookies, reportes y paquetes.
