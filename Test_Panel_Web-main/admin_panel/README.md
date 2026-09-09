# AEVUM ITER · Panel institucional

Panel Node.js/Express para recibir evaluaciones de la app y consultar estadísticas almacenadas en MariaDB/MySQL.

## Desarrollo local

1. Copia `.env.example` como `.env` y configura la conexión a la base de datos.
2. Importa `sql/schema.sql`.
3. Ejecuta `npm install` y `npm start`.
4. Abre `http://localhost:8080`.

Si defines `API_INGEST_KEY`, compila Flutter con el mismo valor:

```bash
flutter run \
  --dart-define=AEVUM_API_URL=http://IP_PC:8080/api \
  --dart-define=AEVUM_API_KEY=EL_MISMO_TOKEN
```

Si defines `ADMIN_USER` y `ADMIN_PASSWORD`, el navegador solicitará credenciales para acceder al panel y a `/api/dashboard/summary`.

## Lineamientos para infraestructura institucional

La entrevista técnica establece que la institución dispone de servidores Windows Server, FreeBSD y OpenSUSE, con MariaDB disponible y posibilidad de Apache/Nginx. La versión beta debe funcionar localmente antes de solicitar su publicación.

Para producción:

- Publicar Node.js detrás de Apache o Nginx como reverse proxy.
- Exponer únicamente HTTPS/TLS mediante el dominio o subdominio institucional.
- No publicar directamente MariaDB hacia Internet.
- Mantener `API_INGEST_KEY`, `ADMIN_USER`, `ADMIN_PASSWORD` y credenciales de BD fuera del repositorio.
- Usar credenciales fuertes y distintas para aplicación, panel y base de datos.
- Restringir la administración remota mediante SSH/certificados según la política del Centro de Cómputo.
- Programar respaldos automáticos de MariaDB y conservar un procedimiento de restauración probado.
- Entregar al Centro de Cómputo los requisitos de software y una recomendación de crecimiento horizontal/vertical.

## Crecimiento recomendado

**Vertical:** aumentar CPU/RAM/almacenamiento del servidor si crece el volumen de evaluaciones; agregar índices a consultas de reporte conforme aumenten los datos.

**Horizontal:** mantener el backend sin estado para poder ejecutar varias instancias detrás de Apache/Nginx; centralizar MariaDB; separar posteriormente el servicio de reportes si la carga lo requiere.

## Catálogos de la app

Estados, municipios, preparatorias/escuelas y lenguas se administran como catálogos locales de la app. No existe dependencia de INEGI ni de otra API geográfica. Los nuevos municipios y escuelas deben agregarse a `assets/database/seed_catalog_v7.json` y distribuirse en una actualización de la aplicación.
