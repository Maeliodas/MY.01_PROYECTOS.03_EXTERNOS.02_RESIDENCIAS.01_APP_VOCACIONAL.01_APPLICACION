# Bitácora de cambios · App

> Convención: una sola bitácora viva. Cada revisión **añade su sección arriba**;
> no se crean archivos nuevos por subversión. El `README.md` principal solo
> resume los cambios principales de la versión actual.

## 1.3.2-10 (actual)

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
