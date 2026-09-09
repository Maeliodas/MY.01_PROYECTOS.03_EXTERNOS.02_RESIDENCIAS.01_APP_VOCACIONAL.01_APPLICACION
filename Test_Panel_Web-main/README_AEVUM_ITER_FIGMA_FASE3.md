# AEVUM ITER — Fase 3

Correcciones principales:

- Historial corregido: se eliminó la dependencia de formato de fecha con locale `es` que provocaba `LocaleDataException`.
- La animación de análisis de resultados solo se abre desde el flujo posterior a finalizar el test.
- Abrir RESULTADOS desde el TabBar o desde el mapa ya no reproduce la animación.
- Mejoras de modo oscuro en tema global, tarjetas, textos secundarios, historial, test, resultados, perfil y hojas modales.
- TabBar refinado manteniendo PATH / RESULTADOS / PERFIL y sin implementar Logros.
- Se reemplazó `activeColor` de switches por `activeThumbColor` para evitar deprecaciones recientes de Flutter.
- `android/settings.gradle.kts` ahora falla con un mensaje claro si falta `flutter.sdk` en `android/local.properties`, evitando rutas `android/null/...`.

Para la instalación local, `android/local.properties` debe incluir, por ejemplo:

```properties
flutter.sdk=C:\\src\\flutter
sdk.dir=C:\\Users\\Jesus\\AppData\\Local\\Android\\Sdk
```

Después ejecutar:

```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```
