# AEVUM ITER — Fase 4: datos en SQLite + panel web

## Cambios principales

La app deja de tomar los catálogos vocacionales principales desde listas Dart. Los datos se cargan a SQLite desde `assets/database/seed_catalog_v7.json` y después todas las pantallas/repositorios consultan la base local.

### Tablas de catálogo

- `states`
- `municipalities`
- `schools`
- `languages`
- `questions`
- `careers`
- `career_riasec_weights`
- `career_questions`

### Tablas operativas

- `user_profile`
- `user_languages`
- `avatar_configuration`
- `test_sessions`
- `test_answers`
- `test_results`
- `content_metadata`
- `sync_queue`

La base se actualizó a versión 5.

## Estados y municipios

Se incluyen las 32 entidades federativas en SQLite. Los municipios, escuelas y lenguas se administran manualmente en el catálogo local `seed_catalog_v7.json`. La aplicación no consulta APIs externas para estos catálogos; los selectores leen exclusivamente desde SQLite.

## Preguntas y carreras

Las 30 preguntas RIASEC y los perfiles de carreras ya no están definidos en `questions_data.dart` ni `careers_data.dart`. Se insertan en la base y son consultados mediante repositorios. Los pesos RIASEC y la relación carrera-pregunta también están normalizados en tablas.

## Progreso del test

El progreso dejó de depender de SharedPreferences. Sesiones y respuestas se guardan en `test_sessions` y `test_answers`.

## Panel web

La carpeta `admin_panel/` contiene:

- API REST Node.js + Express
- MySQL
- panel EJS
- gráficos con Chart.js
- estadísticas por carrera, escuela, estado, municipio y lenguas/idiomas

Consulta `admin_panel/README.md` para ejecutarlo.

## Conectar un teléfono físico

El emulador Android usa por defecto:

`http://10.0.2.2:8080/api`

Para un teléfono físico:

```bash
flutter run --dart-define=AEVUM_API_URL=http://IP_DE_TU_PC:8080/api
```

## Limpieza realizada

Se eliminaron implementaciones que no estaban conectadas al árbol real de imports/rutas, entre ellas páginas antiguas de mapa, resultados, perfil setup, componentes no utilizados, modelos/repositories obsoletos y los catálogos Dart duplicados. También se eliminaron directorios generados de build.

## Antes de probar

Como cambió el esquema SQLite, para una prueba totalmente limpia se recomienda desinstalar la app anterior del emulador/teléfono o borrar sus datos, y después:

```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```

Para conservar datos anteriores, la migración v5 intenta mantener el perfil y los resultados ya existentes, aunque el progreso antiguo guardado con mecanismos previos no se migra a las nuevas sesiones SQLite.

## Catálogos temporales heredados (v7)

Mientras se reciben los catálogos oficiales, la aplicación reutiliza los valores que existían en la interfaz anterior y los distribuye desde SQLite, no desde código Dart ni APIs externas.

Preparatorias temporales: CBTis 107, COBAO 07, CONALEP 157, CBTA 51, Preparatoria SIMÓN BOLÍVAR y Otra.

Para municipios se conserva el catálogo local disponible en el proyecto: San Juan Bautista Tuxtepec para Oaxaca y la opción `Otro municipio` como respaldo por entidad. No se consulta INEGI ni ningún servicio externo. Cuando se reciba la lista institucional definitiva, estos registros podrán sustituirse en el seed local.
