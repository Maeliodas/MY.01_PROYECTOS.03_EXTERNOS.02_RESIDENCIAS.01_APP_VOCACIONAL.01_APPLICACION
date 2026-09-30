# App Vocacional ITTUX — Arquitectura · 1.3.3-11 (actual)

Esquema `X.Y.Z-R`: +1 a revisión (R) por modificación pequeña; rediseño de módulo suma a subcambios menores (Z) y a R.
Versión **1**, semigrande **3**, menores **3**, revisión **11**. Detalle vivo en [`CAMBIOS.md`](../../CAMBIOS.md).

## Base 1.3.2-10 (conservada)
- 11 carreras, incluyendo Arquitectura.
- SQLite local para escuelas, lenguas y carreras.
- Escuela mediante lista desplegable.
- Selección múltiple de lenguas maternas y extranjeras.
- Opción de agregar lenguas no incluidas.
- Navegación persistente: Mapa, Resultados y Perfil.
- Mapa interactivo con nodos, caminos curvos y estados.
- Personalización inicial de avatar.
- Sync offline-first + catálogos versionados.

## Novedad 1.3.3-11 — Tema institucional
- Primario TecNM Pantone 294 C `#1B396A` (§§2.3–2.5, solo azul).
- `lib/app/theme/app_colors.dart`: escala 50–900 + `secondary #2F6AAE` + `steel #5A8AC0`.
- `lib/app/theme/app_theme.dart`: claro `#F1F5FA` / oscuro `#0B1526`, `onPrimary` blanco.
- Sin cambios de lógica, rutas ni BD.

## Estructura
- `lib/app/`: app, routes, theme.
- `lib/core/`: constants, database, network, sync, utils, widgets.
- `lib/features/`: avatar, catalog, history, onboarding, path, profile, result, settings, splash, test.

## Importante
Los recursos gráficos exactos de Figma (avatars, ilustraciones, SVG y fondos) deben añadirse en `assets/`
para fidelidad visual; el color base ya es el institucional.
