# APP VOCACIONAL ITTUX

Aplicación Android del proyecto de Residencias Profesionales

## Estado de esta primera implementación

- Flutter + Material 3
- Riverpod + GoRouter
- SQLite local
- Test RIASEC de 30 preguntas
- Escala entera de 0 a 9 con valor visual inicial 5 sin registrar respuesta hasta interacción
- Orden aleatorio por cada test nuevo y persistente al reanudar
- Código Holland y ranking de 10 carreras
- Historial local
- Pregunta abierta final almacenada localmente
- Cola de sincronización anónima en segundo plano
- Catálogos de escuelas y lenguas preparados para poblar SQLite desde el servidor

## API

Compilar con `--dart-define=ANALYTICS_API_BASE_URL=https://tu-servidor` cuando exista el backend
