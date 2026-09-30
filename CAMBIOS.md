# Bitácora de cambios · App

> Convención: una sola bitácora viva. Cada revisión **añade su sección arriba**;
> no se crean archivos nuevos por subversión. El `README.md` principal solo
> resume los cambios principales de la versión actual.

## 1.3.3-11 (actual)

Versión **1**, sub modificación semigrande **3**, subcambios menores **3**, revisión **11**.
Rediseño del módulo tema (suma a Z y R): misma lógica, rutas y esquema de BD (SQLite v16 / MySQL sin ALTERs).

### Tema institucional azul TecNM (Pantone 294 C, §§2.3–2.5)
- Fuente: Manual de Identidad Gráfica TecNM 2026 — `Pantone 294 C / C100 M85 Y30 K20 / R27 G57 B106 / #1B396A`. Solo azul.
- `lib/app/theme/app_colors.dart`: primario `#1B396A`, escala `50 #EEF2F7 → 900 #0B1A30`, secundario `#2F6AAE`, acero `#5A8AC0` (reemplaza morado), fondos `light #F1F5FA / dark #0B1526`, `onPrimary #FFFFFF`.
- `lib/app/theme/app_theme.dart`: responsivo claro/oscuro, `ColorScheme.fromSeed(primary)`, `indicatorColor` primario con etiqueta seleccionada blanca, sliders/switches/inputs en azules.
- Migración de duros verdes a azules en 16 pantallas (`0xFF00923F→0xFF1B396A`, claros `→#DCE9F8/#CBD8EA`, dark verdosos `→#0B1526/#111E33/#1A2A45`, cian `0xFF18A9D3→0xFF2F6AAE`, morado `0xFF6C2BC8→0xFF5A8AC0`).
- `pubspec.yaml`: `0.3.0+3 → 1.3.3+11` para alinear con esquema `X.Y.Z-R`.
- `README.md`: título/badge/versionado/footer a `1.3.3-11`, badge a `1B396A`, fila de tema + roadmap marcado.

## 1.3.2-10

Versión **1**, sub modificación semigrande **3**, subcambios menores **2**, revisión **10**.
Solo lógica: misma UI, colores, rutas y esquema de BD (SQLite v16 / MySQL sin ALTERs).

## App Flutter

### Catálogos en vivo y al arranque
- `lib/core/sync/catalog_live_sync.dart` (nuevo): observa el ciclo de vida y cada 5 min
  compara la versión ligera del panel; si hay novedades descarga, aplica, refresca
  pantallas y avisa con snackbar. No toca el test en curso.
- `lib/app/app.dart`: monta el observador vía `builder` (cubre todas las rutas).
- `lib/features/splash/presentation/pages/splash_page.dart`: el sync corre **acotado
  (8s) antes de navegar** para que lo nuevo del panel se vea desde la 1ª apertura;
  timeout global 25s con pantalla de error + **Reintentar** (adiós spinner infinito);
  texto de estado (“Actualizando catálogos…” / “Cargando…”).
- `lib/features/catalog/data/catalog_repository.dart`: si la versión no cambió se
  omite toda la escritura; si cambió, UPSERT de 1 sentencia por fila (sin REPLACE
  para no disparar cascadas de FK) y error con tabla e id exactos.

### Envío de resultados
- `lib/core/sync/sync_service.dart`: lenguas/idiomas por tipo relacional (ya no por
  prefijo `idioma_`, que fallaba con IDs `lan_...` del panel); conexión verificada
  contra el backend (`/health`) en vez de `google.com`; cola con tope de 5 intentos
  (`failed` se archiva, no reintenta infinito).
- `lib/core/sync/sync_queue.dart`: `markFailed()`.
- `lib/features/result/data/result_local_datasource.dart`: IDs de resultado UUID.
- `lib/core/network/dashboard_api.dart`: `fetchCatalogVersion()` (chequeo ligero, 8s).
- `lib/core/sync/catalog_sync_service.dart`: `getLocalCatalogVersion()` y
  `checkAndSync()` (solo descarga si la versión remota es mayor; sin red, difiere
  al siguiente arranque con red).
- `lib/core/network/network_info.dart`: `hasBackendConnection()` (conserva
  `hasConnection()` original).

### Test y abierta obligatoria
- `lib/features/test/presentation/pages/open_question_page.dart`: mínimo 10
  caracteres para finalizar (antes 1).
- `lib/features/test/presentation/pages/thank_you_page.dart`: test incompleto
  regresa a `/test`; sin abierta del top 1 (existiendo pregunta) regresa a
  `/open-question`; el top se fija y reutiliza al guardar; estados de progreso
  (“Calculando… → Guardando… → Enviando…”).
- `lib/features/profile/data/repositories/profile_repository.dart`: tipo de lengua
  resuelto desde el catálogo local con respaldo a prefijo.
- `lib/features/settings/presentation/pages/settings_page.dart`: diálogo de espera
  al actualizar manual + timeout de 60s (siempre cierra con mensaje).

## Panel web
- `admin_panel/src/server.js`: `GET /api/catalog-version` (con `API key`,
  `{version, updated_at}`) para el chequeo ligero de la app.

## Probar en físico
1. Agregar pregunta en el panel → abrir la app **una vez** (sin “Actualizar”) →
   test nuevo → debe aparecer.
2. Con red: cambiar algo en el panel → reanudar la app → snackbar de novedad.
3. Sin red: usar la app normal → al volver la red, entra en el siguiente arranque.
