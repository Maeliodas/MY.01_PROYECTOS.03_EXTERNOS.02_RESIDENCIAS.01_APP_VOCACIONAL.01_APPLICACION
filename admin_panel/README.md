<div align="center">

  # Panel web 1.2.2

  **Gestión institucional de orientación vocacional** — catálogos versionados, resultados en vivo y reportes oficiales del Instituto Tecnológico de Tuxtepec.

  [![release](https://img.shields.io/badge/release-1.2.2-00923F?style=for-the-badge)](.)
  [![node](https://img.shields.io/badge/Node.js-Express_4-339933?style=for-the-badge&logo=node.js&logoColor=white)](src/server.js)
  [![mysql](https://img.shields.io/badge/MySQL_MariaDB-utf8mb4-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](sql/schema.sql)
  [![realtime](https://img.shields.io/badge/Tiempo_real-Socket.IO-010101?style=for-the-badge&logo=socket.io&logoColor=white)](src/server.js)
  [![pwa](https://img.shields.io/badge/PWA-instalable-5A0FC8?style=for-the-badge)](public/manifest.json)

  <p>
    <a href="#-capacidades">Capacidades</a> •
    <a href="#-instalación">Instalación</a> •
    <a href="#-api">API</a> •
    <a href="#-app-web-instalable-pwa">PWA</a> •
    <a href="#-despliegue-y-acceso-del-personal">Despliegue</a> •
    <a href="#-versionado">Versionado</a>
  </p>
</div>

---

## ✨ Capacidades

| Módulo | Lo que hace |
|---|---|
| 📊 Dashboard en vivo | Evaluaciones, KPIs, gráficas y procedencia por escuela/municipio, con filtros y actualización por Socket.IO + polling de respaldo |
| 🗂️ Catálogos versionados | Estados, municipios, escuelas, lenguas, idiomas, preguntas, carreras, pesos RIASEC y abiertas por departamento; cada cambio sube `catalog_meta.version` |
| ✅ Sugerencias | Revisión de lenguas, idiomas y escuelas propuestas desde la app, agrupadas por tipo |
| 🧾 Reportes PDF | Documento oficial con encabezado institucional, KPIs, gráficas y detalle anonimizado |
| 📲 Ingesta móvil | Endpoints con API key para evaluaciones, sugerencias y snapshot de catálogos |
| 🔒 Acceso | Login administrativo, sesiones firmadas, freno anti fuerza bruta y cabeceras de seguridad |

## 🚀 Instalación

```powershell
cmd /c "mysql -u root -p -P 3309 < admin_panel\sql\schema.sql"
cd admin_panel
copy .env.example .env
npm install
npm start
```

Edita `.env` antes de arrancar (`DB_*`, `API_INGEST_KEY`, `ADMIN_USER`, `ADMIN_PASSWORD`, `ADMIN_SESSION_SECRET`). Panel en `http://localhost:8080` · Salud en `GET /health`.

## 🔌 API

| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| `GET` | `/health` | Estado del servicio + BD | — |
| `GET` | `/api/catalog-version` | Versión ligera del catálogo (chequeo en vivo de la app) | API key |
| `GET` | `/api/catalogs` | Snapshot versionado de catálogos | API key |
| `POST` | `/api/catalog-suggestions` | Sugerir lengua, idioma o escuela | API key |
| `POST` | `/api/evaluations` | Registrar evaluación del test | API key |
| `GET` | `/api/dashboard/summary` | Estadísticas filtradas (panel) | Sesión admin |
| `GET` | `/api/admin/report.pdf` | Reporte oficial filtrado (panel) | Sesión admin |

## 📲 App web instalable (PWA)

Instalable como aplicación (navegador: “Instalar” o “Añadir a pantalla de inicio”): `manifest.json`, iconos y service worker incluidos. Los estáticos se cachean; `/api/*`, Socket.IO y las páginas **siempre van a la red** para no mostrar datos viejos.

## 🛡️ Despliegue y acceso del personal

- Publica detrás de Nginx/Caddy con HTTPS (Let's Encrypt) hacia el puerto `PORT`. HSTS se activa tras proxy.
- El personal solo recibe **URL + usuario + contraseña**: el código (`src/`, `views/`, `sql/`, `.env`) nunca sale del servidor; por HTTP solo se expone `public/`.
- Permisos sugeridos: proyecto `750`, `.env` `640` del usuario de despliegue, personal **sin cuentas SSH**.

## 🔢 Versionado

Esquema `1.2.2-6` → versión **1**, sub modificación semigrande **2**, subcambios menores **2**, revisión **6**. Independiente de la app (`1.3.2-10`) y de la versión de **datos** (`catalog_meta`, visible como `#N` en el panel).

Detalle en [`CAMBIOS.md`](CAMBIOS.md) (sección superior = revisión actual). Reglas: +revisión por cada modificación pequeña de un archivo; el rediseño de un módulo suma a subcambios menores y a la revisión.

---

<div align="center">
  <sub>Instituto Tecnológico de Tuxtepec · Panel web 1.2.2 · Uso institucional restringido</sub>
</div>
