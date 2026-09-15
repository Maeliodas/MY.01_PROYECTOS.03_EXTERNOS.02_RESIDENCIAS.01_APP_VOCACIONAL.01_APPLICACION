# Instalación AEVUM ITER V13

## 1. Base de datos limpia (recomendado para este proyecto)

Desde la raíz del proyecto en PowerShell:

```powershell
cmd /c "mysql --default-character-set=utf8mb4 -u root -p -P 3309 < admin_panel\sql\schema.sql"
```

No ejecutes `migrate_v13.sql` si vas a crear la base desde cero.

## 2. Panel web

```powershell
cd admin_panel
npm install
npm start
```

Configura `admin_panel/.env` con los datos de MariaDB/MySQL, `API_INGEST_KEY`, `ADMIN_USER`, `ADMIN_PASSWORD` y `ADMIN_SESSION_SECRET`.

## 3. App Flutter

Con el teléfono conectado y Depuración USB habilitada:

```powershell
flutter clean
flutter pub get
flutter run --dart-define="AEVUM_API_URL=https://TU_URL_NGROK/api" --dart-define="AEVUM_API_KEY=TU_API_INGEST_KEY"
```

La aplicación usa `assets/database/aevum_catalog_v13.db` como catálogo inicial offline.

## 4. Instalación existente V12

Solo si conservas una base MySQL/MariaDB V12:

```powershell
cmd /c "mysql --default-character-set=utf8mb4 -u root -p -P 3309 aevum_iter < admin_panel\sql\migrate_v13.sql"
```

Flutter migrará su SQLite local a versión 13 al abrir la aplicación.
