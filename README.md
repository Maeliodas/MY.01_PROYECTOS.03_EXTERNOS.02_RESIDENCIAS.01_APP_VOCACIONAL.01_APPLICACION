<div align="center">
  <img src="assets/branding/app_logo_light.png" alt="App Vocacional ITTUX" width="160"/>

  # App Vocacional ITTUX

  **Descubre tu camino** — Orientación vocacional con modelo RIASEC / Holland, operación offline-first y panel institucional en tiempo real.

  [![release](https://img.shields.io/badge/release-1.3.1--5-00923F?style=for-the-badge)](.)
  [![flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](.)
  [![dart](https://img.shields.io/badge/Dart-%5E3.2-0175C2?style=for-the-badge&logo=dart&logoColor=white)](.)
  [![node](https://img.shields.io/badge/Node.js-Express_4-339933?style=for-the-badge&logo=node.js&logoColor=white)](admin_panel/)
  [![mysql](https://img.shields.io/badge/MySQL_MariaDB-utf8mb4-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](admin_panel/sql/schema.sql)
  [![sqlite](https://img.shields.io/badge/SQLite-offline--first-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](lib/core/database/)
  [![platforms](https://img.shields.io/badge/Android_iOS_Web_Desktop-multimedia-6E26C8?style=for-the-badge)](.)

  <p>
    <a href="#-características">Características</a> •
    <a href="#-cómo-funciona">Cómo funciona</a> •
    <a href="#-instalación">Instalación</a> •
    <a href="#-api-del-panel">API</a> •
    <a href="#-versionado">Versionado</a>
  </p>
</div>

---

## ✨ Características

| Módulo | Lo que hace |
|---|---|
| 📝 Test RIASEC | 30 reactivos offline, puntajes 0–50 por dimensión y código Holland de 3 letras |
| 🎯 Ranking de carreras | Afinidad por perfil vectorial + congruencia hexagonal Holland, top 3 con enlaces TecNM |
| 💬 Pregunta abierta | Obligatoria, ligada al departamento del top 1; verifica respuesta consciente sin alterar puntaje |
| 🏫 Catálogos vivos | Estados, municipios, escuelas, lenguas, idiomas, preguntas y carreras sincronizables desde el panel |
| 🗣️ Lenguas e idiomas | Clasificación por tipo relacional + sugerencias ciudadanas con aprobación administrativa |
| 📴 Offline-first | SQLite local precargado, cola de envío con reintentos y verificación contra el backend (`/health`) |
| 🖥️ Panel web | CRUD de catálogos, dashboard en vivo (Socket.IO), filtros, revisión de sugerencias y reportes PDF |
| 🔒 Datos | UTF-8/utf8mb4 integral, bajas lógicas (`active=0`) que no rompen históricos |

<div align="center">
  <img src="assets/avatars/avatar_01.png" width="64"/>
  <img src="assets/avatars/avatar_02.png" width="64"/>
  <img src="assets/avatars/avatar_03.png" width="64"/>
  <img src="assets/avatars/avatar_04.png" width="64"/>
  <img src="assets/avatars/avatar_05.png" width="64"/>
  <img src="assets/avatars/avatar_06.png" width="64"/>
  <br/>
  <em>Avatares incluidos + editor con galería y cámara</em>
</div>

## 🧭 Cómo funciona

```mermaid
flowchart LR
    E[Estudiante] --> A[App Flutter<br/>offline-first]
    A -->|1. Reactivos| C{Cálculo RIASEC}
    C -->|2. Top 1| P[Pregunta abierta<br/>por departamento]
    P -->|3. Respuesta| R[Resultado + Holland]
    R -->|4. Cola sync| N[Panel Node/Express]
    N --> M[(MySQL / MariaDB)]
    M --> D[Dashboard + PDF]
    N -->|5. Snapshot| A
```

1. El test se responde **sin internet** contra el SQLite precargado.
2. Al terminar reactivos se calcula el ranking y se muestra la pregunta abierta del departamento ganador.
3. El resultado (Holland, RIASEC, top 1, abierta, género, edad, escuela, lenguas) se encola y envía al panel.
4. El panel publica catálogos versionados que la app descarga en segundo plano.

## 🛠️ Stack

| Capa | Tecnología |
|---|---|
| App | Flutter 3, Riverpod, go_router, sqflite |
| Panel | Node.js, Express 4, EJS, Socket.IO, PDFKit |
| Datos | MySQL/MariaDB (maestro) → SQLite (copia local) |
| Auth ingesta | `Authorization: Bearer API_INGEST_KEY` |

## 📁 Estructura

```
app_vocacional/
├── lib/                  # App Flutter (app, core, features)
│   ├── core/             # BD, red, sync, constantes
│   └── features/         # test, result, profile, catalog, avatar…
├── assets/               # avatares, branding, seed SQLite, institución
├── admin_panel/          # Panel web + API (repo separado sugerido)
│   ├── src/server.js     # API + vistas
│   ├── sql/schema.sql    # Esquema MySQL maestro
│   ├── public/ views/    # UI del panel
├── database_model/       # Modelos SQLite de referencia
└── *.md                  # Bitácoras por versión
```

## 🚀 Instalación

<details>
<summary><strong>📱 App Flutter</strong></summary>

```bash
flutter pub get
flutter run --dart-define=APP_VOCACIONAL_API_URL=http://IP_DE_TU_PC:8080/api
```

> En producción usa exclusivamente la URL HTTPS institucional y define `APP_VOCACIONAL_API_KEY` con el mismo valor de `API_INGEST_KEY` del panel.

</details>

<details>
<summary><strong>🖥️ Panel web + API</strong></summary>

```bash
mysql -u root -p < admin_panel/sql/schema.sql
cd admin_panel
cp .env.example .env   # edita credenciales y API_INGEST_KEY
npm install
npm start
```

Panel en `http://localhost:8080` · Salud en `GET /health`. Detalle completo en [`INSTALACION_VERSION_13.md`](INSTALACION_VERSION_13.md) y [`admin_panel/README.md`](admin_panel/README.md).

</details>

## 🔌 API del panel

| Método | Ruta | Descripción | Auth |
|---|---|---|---|
| `GET` | `/health` | Estado del servicio + BD | — |
| `GET` | `/api/catalogs` | Snapshot versionado de catálogos | API key |
| `POST` | `/api/catalog-suggestions` | Sugerir lengua, idioma o escuela | API key |
| `POST` | `/api/evaluations` | Registrar evaluación del test | API key |

## 🔢 Versionado

Esquema `1.3.1-5` → versión **1**, sub modificación semigrande **3**, subcambios menores **1**, revisión **5**.

Bitácoras: [`CAMBIOS_VERSION_9.md`](CAMBIOS_VERSION_9.md) · [`CAMBIOS_VERSION_10.md`](CAMBIOS_VERSION_10.md) · [`CAMBIOS_VERSION_11.md`](CAMBIOS_VERSION_11.md) · [`CAMBIOS_VERSION_12.md`](CAMBIOS_VERSION_12.md) · [`CAMBIOS_VERSION_13.md`](CAMBIOS_VERSION_13.md) · [`CAMBIOS_VERSION_17.md`](CAMBIOS_VERSION_17.md) · [`CAMBIOS_VERSION_18.md`](CAMBIOS_VERSION_18.md)

## 🗺️ Hoja de ruta

- [ ] Contrato OpenAPI del panel (`openapi.yaml`)
- [ ] Generación del seed SQLite desde MySQL (`npm run export:seed`)
- [ ] Endpoints de versión de app y catálogo (actualización guiada)
- [ ] Higiene del repo (sacar `node_modules` del tracking)

---

<div align="center">
  <img src="assets/institution/tecnm_ittux_wordmark.png" width="210"/>
  <br/>
  <sub>Instituto Tecnológico de Tuxtepec · App Vocacional ITTUX 1.3.1-5 · Uso institucional</sub>
</div>
