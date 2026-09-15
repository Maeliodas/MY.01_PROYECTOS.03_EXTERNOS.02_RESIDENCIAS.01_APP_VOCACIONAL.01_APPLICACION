# AEVUM ITER - Instalación limpia V10

Esta versión está preparada para una instalación desde cero. No uses los scripts de migración de versiones anteriores.

## 1. Preparar Flutter

Desde la raíz del proyecto:

```powershell
flutter create --platforms=android .
flutter clean
flutter pub get
```

Si ya existe la carpeta `android`, no es necesario volver a crearla.

## 2. Limpiar la instalación anterior del teléfono

Para evitar conservar la base SQLite sincronizada de una versión anterior, desinstala la app anterior del dispositivo antes de instalar V10. También puedes limpiar los datos de la aplicación desde Android.

## 3. Crear MySQL/MariaDB desde cero

El archivo `admin_panel/sql/schema.sql` elimina y vuelve a crear `aevum_iter`, por lo que borra los datos anteriores.

Desde la raíz del proyecto:

```powershell
cmd /c "mysql --default-character-set=utf8mb4 -u root -p -P 3309 < admin_panel\sql\schema.sql"
```

El parámetro `--default-character-set=utf8mb4` es importante para conservar correctamente acentos, eñes, signos de apertura y demás caracteres Unicode.

Comprueba la instalación:

```powershell
mysql --default-character-set=utf8mb4 -u root -p -P 3309 aevum_iter
```

Luego:

```sql
SHOW TABLES;
SELECT name FROM states WHERE id IN ('15','19','22');
EXIT;
```

Los nombres deben mostrarse como `México`, `Nuevo León` y `Querétaro`.

## 4. Configurar el backend

```powershell
cd admin_panel
copy .env.example .env
npm install
```

Edita `admin_panel/.env` con tus credenciales. Ejemplo:

```env
PORT=8080
DB_HOST=127.0.0.1
DB_PORT=3309
DB_USER=root
DB_PASSWORD=TU_PASSWORD
DB_NAME=aevum_iter
API_INGEST_KEY=TU_CLAVE_API
ADMIN_USER=aevum_admin
ADMIN_PASSWORD=TU_PASSWORD_PANEL
```

Inicia el servidor:

```powershell
npm start
```

## 5. Iniciar ngrok

En otra terminal:

```powershell
ngrok http 8080
```

Copia la URL HTTPS que te proporcione.

## 6. Ejecutar Flutter

Desde la raíz del proyecto:

```powershell
flutter run --dart-define=AEVUM_API_URL=https://TU_URL.ngrok-free.dev/api --dart-define=AEVUM_API_KEY=TU_CLAVE_API
```

La clave debe ser exactamente igual a `API_INGEST_KEY` en `.env`.

## 7. Verificaciones recomendadas

- Los nombres con acentos deben verse correctamente en Flutter y en el panel.
- Estado -> municipio -> escuela debe filtrar los catálogos relacionados.
- Una lengua o idioma escrito manualmente debe permitir continuar inmediatamente y aparecer como sugerencia pendiente en el panel.
- Aprobar una sugerencia debe convertirla en una opción normal del catálogo para futuras sincronizaciones.
- El editor de avatar debe abrirse en una pantalla separada y permitir avatar incluido, galería o cámara.
- Al finalizar las 30 preguntas RIASEC aparecen las preguntas abiertas de intereses por carrera.
- En el top 3, `Ver detalles en TecNM` abre la página oficial correspondiente. Arquitectura muestra un aviso porque aún no tiene enlace.

## Catálogos

Los catálogos se almacenan en bases de datos: MySQL/MariaDB en el servidor y SQLite como copia local de la app. La aplicación no consulta INEGI ni otra API externa durante su uso. El panel CRUD modifica MySQL y la app recibe esos cambios mediante la sincronización con el propio backend AEVUM ITER.
