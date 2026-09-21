# Bitácora de cambios · Panel

> Convención: una sola bitácora viva. Cada revisión **añade su sección arriba**;
> no se crean archivos nuevos por subversión. El `README.md` del panel solo
> resume los cambios principales de la versión actual.

## 1.2.0-2 (actual)

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
