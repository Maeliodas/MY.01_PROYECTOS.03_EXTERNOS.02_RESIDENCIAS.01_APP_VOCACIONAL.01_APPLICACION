<div align="center">
  <img src="assets/branding/app_logo_light.png" alt="App Vocacional ITTUX" width="160"/>

  # App Vocacional ITTUX 1.3.3

  **Descubre tu camino** — Orientación vocacional con modelo RIASEC / Holland, operación offline-first y panel institucional en tiempo real.

  [![release](https://img.shields.io/badge/release-1.3.3--11-1B396A?style=for-the-badge)](.)
  [![flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](.)
  [![dart](https://img.shields.io/badge/Dart-%5E3.2-0175C2?style=for-the-badge&logo=dart&logoColor=white)](.)
  [![node](https://img.shields.io/badge/Node.js-Express_4-339933?style=for-the-badge&logo=node.js&logoColor=white)](admin_panel/)
  [![mysql](https://img.shields.io/badge/MySQL_MariaDB-utf8mb4-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](admin_panel/sql/schema.sql)
  [![sqlite](https://img.shields.io/badge/SQLite-offline--first-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](lib/core/database/)
  [![platforms](https://img.shields.io/badge/Android_iOS_Web_Desktop-multimedia-6E26C8?style=for-the-badge)](.)

  <p>
    <a href="#-características">Características</a> •
    <a href="#-rediseño-visual-institucional">Rediseño visual</a> •
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
| 💬 Pregunta abierta | Obligatoria (mín. 10 caracteres), ligada al departamento del top 1; no modifica puntaje y no se puede saltar por URL |
| 🏫 Catálogos vivos | Versionados con atajo por versión y UPSERT rápido: sync acotado en arranque, en vivo al reanudar/cada 5 min, manual en Ajustes |
| 🗣️ Lenguas e idiomas | Clasificación por tipo relacional + sugerencias ciudadanas con aprobación administrativa |
| 📴 Offline-first | SQLite local precargado, verificación contra el backend (`/health`), colas de envío con tope de reintentos |
| 🖥️ Panel web | CRUD de catálogos, dashboard en vivo (Socket.IO), filtros, revisión de sugerencias, reportes PDF y endpoint ligero de versión |
| 🔒 Datos | UTF-8/utf8mb4 integral, bajas lógicas (`active=0`) que no rompen históricos, IDs de resultado UUID |
| 🎨 Tema institucional | Sistema de diseño TecNM Pantone 294 C `#1B396A`, claro/oscuro responsivo, tipografía **Noto Sans** y logotipos oficiales (ver [Rediseño visual](#-rediseño-visual-institucional)) |

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

## 🎨 Rediseño visual institucional

Rediseño integral de la interfaz conforme al **Manual de Identidad Gráfica TecNM 2026**, preservando al 100% la lógica, datos, rutas, sincronización y ambos temas (claro/oscuro). Cambios visuales únicamente.

**Sistema de diseño** (fuente de verdad en `lib/app/theme/`)

- `app_colors.dart` — paleta institucional: azul Pantone 294 C `#1B396A`, gris `#807E82`, negro, escalas neutras y tokens por tema. Eliminados verdes, cianes, morados y naranjas de todas las pantallas (242 literales de color duro migrados a tokens).
- `app_typography.dart` — jerarquía tipográfica **Noto Sans** (Regular/SemiBold/Bold) empaquetada en `assets/fonts/` y registrada en `pubspec.yaml`.
- `app_metrics.dart` + `app_theme.dart` — espaciados, radios, sombras y tematización completa de componentes (botones, inputs, nav, chips) para claro/oscuro.

**Identidad y logotipos**

- Uso exclusivo de los archivos oficiales de `assets/institution/` (sin redibujar ni recolorear): banda membrete, lockup TecNM + escudo ITTUX y pie institucional reutilizables (`lib/core/widgets/institutional_logos.dart`).
- Los **mismos archivos se usan en claro y en oscuro** (sin variantes por tema ni cajas de protección).
- Regla de no repetir logos por pantalla; pies institucionales en onboarding, intro del test, agradecimiento, resultado, ranking, privacidad y ajustes.

**Componentes nuevos** (`lib/core/widgets/`)

- `institutional_components.dart`: `PageHeader`, `SectionLabel`, `InstitutionalBand` (banda membrete con `FittedBox` — siempre cabe en pantallas estrechas y nunca queda bajo la barra de estado), `InstitutionalCard`.
- `institutional_support_sheet.dart`: **burbuja flotante de ayuda** en el mapa vocacional que abre los canales oficiales del TecNM Tuxtepec (sitio, Facebook, Instagram, WhatsApp, correo) con colores de marca y `url_launcher`; URLs centralizadas en `AppConstants`.
- Botones institucionales (`PrimaryButton`/`SecondaryButton` en mayúsculas), `AppBackButton`, `EmptyState`, `AppNoticeDialog` reestilizados.

**Pantallas destacadas**

- **Splash**: banda membrete en área segura + hero TecNM/ITTUX + línea "SISTEMA DE ORIENTACIÓN VOCACIONAL".
- **Onboarding**: ilustración a todo lo ancho por paso — degradado por acento, círculos decorativos, anillo orbital, disco central con sombra de color, pastilla "PASO n DE 3" e insignias flotantes; encabezado adaptable (`FittedBox`).
- **Elección de avatar**: rejilla de 3 columnas con anillo de selección + insignia de check, secciones rotuladas y tarjeta de galería con previsualización de la foto personal.
- **Mapa vocacional**: encabezado con saludo y escudo ITTUX agrandado, y burbuja de apoyo institucional flotante.
- **Ranking de carreras**: tarjeta de contacto TecNM con iconos de redes en sus colores de marca (excepción autorizada solo para redes).

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
    N -->|5. Versión ligera<br/>+ snapshot| A
```

1. El splash sincroniza catálogos (acotado) **antes** de navegar: los datos nuevos se ven desde la 1ª apertura.
2. El test se responde **sin internet** contra el SQLite local, con progreso reanudable.
3. Al terminar reactivos se calcula el ranking y se exige la pregunta abierta del departamento ganador.
4. El resultado (Holland, RIASEC, top 1, abierta, género, edad, escuela, lenguas) se envía o encola con reintentos acotados.
5. Con red, la app revisa la versión del panel al reanudar y cada 5 min; sin red, lo pendiente entra en el siguiente arranque.

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
│   ├── core/             # BD, red, sync, constantes, widgets de identidad
│   └── features/         # test, result, profile, catalog, avatar…
├── assets/               # avatares, branding, seed SQLite, institución
├── admin_panel/          # Panel web + API (repo separado sugerido)
│   ├── src/server.js     # API + vistas
│   ├── sql/schema.sql    # Esquema MySQL maestro
│   ├── public/ views/    # UI del panel
├── database_model/       # Modelos SQLite de referencia
└── CAMBIOS.md              # Bitácora viva (arriba = revisión actual)
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
| `GET` | `/api/catalog-version` | Versión ligera del catálogo (chequeo en vivo) | API key |
| `GET` | `/api/catalogs` | Snapshot versionado de catálogos | API key |
| `POST` | `/api/catalog-suggestions` | Sugerir lengua, idioma o escuela | API key |
| `POST` | `/api/evaluations` | Registrar evaluación del test | API key |

## 🔢 Versionado

Esquema `1.3.3-11` → versión **1**, sub modificación semigrande **3**, subcambios menores **3**, revisión **11**.
Rediseño de módulo tema: suma a **Z** y a **R** (+1 cada uno sobre `1.3.2-10`).

Detalle de esta versión en [`CAMBIOS.md`](CAMBIOS.md) (sección superior = revisión actual).

## 🗺️ Hoja de ruta

- [x] Chequeo ligero de versión de catálogo + sync en vivo
- [x] Paleta institucional azul TecNM 294 C `#1B396A` (claro/oscuro responsivo)
- [x] Rediseño visual integral: sistema de diseño, Noto Sans, logotipos oficiales en todas las pantallas, onboarding y avatar rediseñados, burbuja de ayuda social
- [ ] Generación del seed SQLite desde MySQL (`npm run export:seed`)
- [ ] Actualización del APK por Drive (endpoint `app-status` + instalador)
- [ ] Higiene del repo (sacar `node_modules` del tracking)

---

<div align="center">
  <img src="assets/institution/LOGO-TECNM-una-linea-azul.png" height="26"/>
  &nbsp;&nbsp;
  <img src="assets/institution/ITTUX.png" height="50"/>
  <br/>
  <sub>Instituto Tecnológico de Tuxtepec · App Vocacional ITTUX 1.3.3-11 · Uso institucional</sub>
</div>
