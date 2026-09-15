# AEVUM ITER V12 — instalación limpia

## 1. Base de datos MySQL/MariaDB desde cero

Desde la raíz del proyecto:

```powershell
cmd /c "mysql --default-character-set=utf8mb4 -u root -p -P 3309 < admin_panel\sql\schema.sql"
```

`schema.sql` elimina y vuelve a crear `aevum_iter`, por lo que no se debe ejecutar `migrate_v12.sql` en una instalación limpia.

## 2. Variables del panel

Copia `admin_panel/.env.example` a `admin_panel/.env` y configura:

```env
PORT=8080
DB_HOST=127.0.0.1
DB_PORT=3309
DB_USER=root
DB_PASSWORD=TU_CONTRASEÑA_MYSQL
DB_NAME=aevum_iter
API_INGEST_KEY=TU_CLAVE_API
ADMIN_USER=aevum_admin
ADMIN_PASSWORD=TU_CONTRASEÑA_PANEL
ADMIN_SESSION_SECRET=UNA_CLAVE_LARGA_Y_ALEATORIA
```

La pantalla de acceso del panel usa `ADMIN_USER` y `ADMIN_PASSWORD`; ya no depende de la ventana Basic Auth del navegador.

## 3. Panel

```powershell
cd admin_panel
npm install
npm start
```

Abrir `http://localhost:8080`.

## 4. App Flutter

Para una prueba limpia se recomienda desinstalar la versión anterior de la app, de modo que se cree SQLite V12 con el catálogo incluido.

```powershell
flutter clean
flutter pub get
flutter run --dart-define=AEVUM_API_URL=https://TU_URL.ngrok-free.dev/api --dart-define=AEVUM_API_KEY=TU_CLAVE_API
```

## 5. Migración de una BD existente

Solo si se conserva una base anterior:

```powershell
cmd /c "mysql --default-character-set=utf8mb4 -u root -p -P 3309 aevum_iter < admin_panel\sql\migrate_v12.sql"
```
