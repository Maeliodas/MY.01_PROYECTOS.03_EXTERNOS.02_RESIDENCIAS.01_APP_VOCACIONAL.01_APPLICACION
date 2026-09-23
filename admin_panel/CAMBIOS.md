# Bitácora de cambios · Panel

> Convención: una sola bitácora viva. Cada revisión **añade su sección arriba**;
> no se crean archivos nuevos por subversión. El `README.md` del panel solo
> resume los cambios principales de la versión actual.
> Esquema `X.Y.Z-R`: cada modificación pequeña de un archivo suma **+1 a la
> revisión (R)**; el rediseño de un módulo suma a **subcambios menores (Z)**
> y a la revisión.

## 1.2.2-9 (actual)

Versión **1**, sub modificación semigrande **2**, subcambios menores **2**, revisión **9**.
Cuatro correcciones de precisión en el reporte PDF:

- **Folio y nombre de archivo en fecha local**: `toISOString()` usa UTC, así que
  el folio decía `RV-…-09-23` mientras el encabezado mostraba «22 de
  septiembre». Ahora ambos derivan de `today`/`pad` (declarados antes de
  usarse, para evitar el error de temporalidad TDZ que rompía la ruta).
- **Columna vacía al extremo derecho de la tabla**: los anchos fijos de las
  seis columnas sumaban 480 pts frente a `contentW` 495,28. Ahora se tratan
  como pesos relativos y se escalan para sumar exactamente el ancho de
  contenido.
- **Encabezado de la tabla repetido en cada página**: las páginas de
  continuación del punto 8 empezaban directo en datos. `drawTableHeader()` se
  vuelve a dibujar cuando `ensureSpace()` fuerza el salto (detectado comparando
  `bufferedPageRange().count` antes y después).
- Con esto el documento queda en **10 páginas** (antes 11).

## 1.2.2-8

Versión **1**, sub modificación semigrande **2**, subcambios menores **2**, revisión **8**.
La tabla del punto 8 lleva rejilla completa tipo Excel: contorno y divisiones
verticales en encabezado y filas (antes solo había líneas horizontales); las
filas quedan pegadas para que la cuadrícula sea continua.

## 1.2.2-7

Versión **1**, sub modificación semigrande **2**, subcambios menores **2**, revisión **7**.
Cada punto del reporte es ahora su propia sección en página nueva: las secciones
2–8 abren página con encabezado §4.2 en vez de continuar donde terminó la
anterior. La tabla del punto 8 gana aire en las celdas (margen horizontal de
7 pts y vertical de 6 pts en encabezado y filas).

## 1.2.2-6

Versión **1**, sub modificación semigrande **2**, subcambios menores **2**, revisión **6**.
Se retira del reporte PDF el **punto «9. Nota metodológica»** (a petición del
usuario): el documento termina ahora en la tabla del punto 8; la numeración y
los pies «Página N de M» se recalculan solos. La fecha de emisión se conserva
en la portada (§1).

- **`dashboardData()`**: la consulta de respuestas abiertas suma los mismos
  `LEFT JOIN` de escuela/municipio/estado que el resto; antes, filtrar por
  `?state=` o `?municipality=` fallaba con `ER_BAD_FIELD_ERROR` y el PDF
  respondía 500.
- **Entrega del PDF**: el archivo se arma completo en memoria y sólo se envía
  si terminó sin errores; un fallo a mitad del dibujo responde 500 (JSON) en
  vez de entregar un PDF truncado/corrupto.

## 1.2.0-4

Versión **1**, sub modificación semigrande **2**, subcambios menores **0**, revisión **4**.
Reporte PDF reestructurado como documento formal bajo el punto **4.2 «Hoja
membretada»** del Manual de Identidad Gráfica TecNM 2026. Tamaño **A4**
(decisión del usuario; el manual es carta). Las 9 secciones se conservan
directas, sin portada ni índice.

- **Colores oficiales** (`src/server.js`): `BLUE = #1B396A` (Pantone 294 C,
  RGB 27/57/106, medido sobre el manual) y `GUINDA = #A61D49` (filete del pie).
  Se retiraron `#0033a0` y `#00923f`, que no pertenecen a la paleta; las series
  de datos pasan al azul institucional. Filete vertical dorado `#AE8420`.
- **Encabezado §4.2** (`drawHeader()`): logotipos SEP/TecNM/escudo a la
  izquierda y bloque del plantel a la derecha con filete vertical dorado;
  **sin filete de cierre** (la referencia no lo trae) y nombre del plantel en
  **negro**. El cuerpo arranca en `y = 200` (`margins.top = 200`).
- **Pie §4.2** (`drawFooter()`): filete **guinda de 3.6 pts**, wordmark del
  plantel a la izquierda cruzándolo, domicilio/contacto **alineados a la
  izquierda** arrancando en el `x` del filete (antes iban centrados) y
  numeración «Página N de M».
- **Logos de certificación importados** a `assets/`: `cert_igualdad.png`
  (190×122, esquinas limpiadas a alfa 0) y `cert_libreplastico.png` (150×92,
  extraído del PDF del manual); se dibujan sobre el filete, a la derecha.
- **Bug de páginas fantasma corregido**: PDFKit autoañadía página cuando
  `doc.text()` caía bajo `maxY() = height − margins.bottom`, así que el pie
  generaba 15 páginas extra (20 en total) y dejaba la numeración en «1 de 5».
  `margins.bottom` se anula **sólo** durante `drawFooter()` y se restaura
  después; sin `save()/restore()`, que con `bufferPages + switchToPage` caía en
  streams de página equivocados. Resultado: **20 → 6 páginas**, numeración
  consistente y 0 avisos de sintaxis PDF.
- **Tipografía**: sólo Noto Sans en todo el documento (sin Helvetica/Times).
- **Tipos** (`package.json`): `@types/express`, `@types/ejs`, `@types/pdfkit`,
  `@types/cors` en `devDependencies` → **0 errores TS7016**.

> **Pendiente:** escudo del plantel. El del manual es de Tepic y no sirve para
> Tuxtepec; no se encontró un PNG oficial accesible (`ittux.edu.mx` inaccesible,
> rutas `img/escudo.png`/`img/isttux.png` → 404). Falta aportar el archivo u
> omitirlo.

## 1.2.0-3

Versión **1**, sub modificación semigrande **2**, subcambios menores **0**, revisión **3**.
Identidad visual: Noto Sans garantizada y logo institucional en el panel.

- **Noto Sans autohospedada** (`public/fonts/`, `@font-face` en `styles.css`):
  recorte latín de los TTF del proyecto (~43 KB c/u, cobertura ñ/acentos
  verificada); ya no depende de la fuente instalada en cada equipo.
- **Logo real** (`public/img/app-logo.png`): sidebar y login usan el logo en vez
  de la “A” genérica.
- Caché del service worker a `v2` para que las PWA instaladas tomen el cambio.

## 1.2.0-2

Versión **1**, sub modificación semigrande **2**, subcambios menores **0**, revisión **2**.
Animaciones del panel y reporte PDF bajo Manual de Identidad TecNM; sin cambios
de esquema MySQL.

- **Tarjetas animadas** (`public/styles.css`): entrada `fade-up` con escalonado en
  cards/KPIs + hover con elevación; respeta `prefers-reduced-motion`; sin
  animación de entrada en listas en vivo para no parpadear con Socket.IO.
- **Tabla del PDF sin traslapes** (`src/server.js`): filas con alto medido
  (`heightOfString`), texto con envoltura y `ellipsis` acotada; salto de página
  por alto real; retirados los recortes `.slice()`.
- **Tipografías oficiales** (`fonts/`, `src/server.js`): Noto Sans embebida y
  registrada para cuerpos de texto; títulos destacados en Helvetica-Bold
  (Patria no se distribuye como TTF).
- Corrección de registro de fuentes en el generador PDF.

## 1.2.0-0

Versión **1**, sub modificación semigrande **2**, subcambios menores **0**, revisión **0**.
Renumeración base del panel bajo el esquema unificado (antes `1.1.0`/`V9`, obsoletos).
Consolida todo el estado actual; sin cambios de esquema MySQL.

## Identidad y versión
- `package.json`: `1.1.0` → `1.2.0-0`.
- Versión visible en el panel: sidebar (“Panel v1.2.0-0”) y pie de página,
  separada de la versión de **datos** (`#N` de `catalog_meta`).
- Encabezado `V9` retirado del README.

## Tiempo real y app móvil
- `GET /api/catalog-version` (con API key): versión ligera para el chequeo en
  vivo de la app sin descargar el snapshot completo.
- Dashboard en vivo por Socket.IO con polling de respaldo e indicador de estado
  (“Servidor conectado” / “polling” / “sin conexión”).
- Refresco suave conservando filtros y pestaña; tiempos de refresco optimizados.

## App web instalable (PWA)
- `public/manifest.json`, `public/sw.js`, `public/icons/` (192/512 + iOS).
- Registro en login y dashboard; estáticos cacheados, API/Socket/navegaciones
  siempre en vivo.

## Seguridad y despliegue
- `X-Powered-By` oculto, `Permissions-Policy`, HSTS tras proxy HTTPS,
  `trust proxy`, estáticos con `dotfiles: deny` y revalidación del SW.
- Freno anti fuerza bruta en `/login` (10 intentos / 10 min por IP).
- `.gitignore`: `node_modules/` fuera del tracking; `.env` nunca versionado.

## Catálogos y reportes
- Sugerencias agrupadas por tipo (lengua/idioma/escuela) con aprobar/rechazar.
- Preguntas complementarias por departamento y constructor de pesos RIASEC.
- Reporte PDF oficial con encabezado institucional, KPIs, gráficas y detalle.
- Modal de confirmación propio y diálogos de borrado con refresco.

## Probar
1. `npm start` → abrir `/` → verificar “Panel v1.2.0-0” en sidebar y pie.
2. DevTools → Application: manifest e iconos sin errores, SW activo.
3. Cambiar un catálogo → `#N` sube y la app lo detecta al reanudar.
4. Fallar login 11 veces → `429` con aviso.
