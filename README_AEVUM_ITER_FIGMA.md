# AEVUM ITER — integración visual Figma

Esta entrega parte del proyecto Flutter del compañero y conserva su organización por `features`.

## Criterio visual
La referencia visual es la **columna derecha** del documento `comparacion Beta y Figma.docx`.

Se ajustaron especialmente:
- Splash.
- Onboarding de tres pasos.
- Selección de avatar.
- Captura de perfil.
- Path / mapa vocacional.
- Test RIASEC con escala 0–10.
- Diálogo de salida del test.
- Reflexión final y pantalla de finalización.
- Resultado principal, ranking y detalle vocacional.
- Perfil.
- Configuración y modo oscuro.
- Barra de navegación inferior.

## Logros
La sección de **Logros no se implementa** por decisión del proyecto. La navegación inferior usa:
- PATH
- RESULTADOS
- PERFIL

## Funcionalidad conservada / reforzada
- Flutter + Riverpod + GoRouter.
- SQLite para perfil, catálogo y resultados.
- Persistencia local del progreso del test con `SharedPreferences`.
- Test RIASEC de 30 preguntas.
- Escala de respuesta 0–10.
- Cálculo del código Holland y ranking de carreras.
- Historial local de resultados.
- Tema claro / oscuro.

## Primera ejecución
```bash
flutter clean
flutter pub get
flutter run
```

Si ya se había ejecutado una versión anterior de esta misma aplicación, la base local migra a la versión 4 y reconstruye únicamente la tabla de resultados para usar el esquema actual.

## Nota
El Word se usa como referencia de UI. Algunas ilustraciones del Figma fueron recreadas con componentes Material porque no fueron entregadas como assets independientes.
