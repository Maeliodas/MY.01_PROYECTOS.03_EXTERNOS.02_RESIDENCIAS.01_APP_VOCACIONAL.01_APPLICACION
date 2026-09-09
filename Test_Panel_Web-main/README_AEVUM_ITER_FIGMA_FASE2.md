# AEVUM ITER — Fase 2 de fidelidad visual y estabilidad

Esta versión conserva la arquitectura del proyecto base del compañero y sigue como referencia visual las capturas de la columna derecha del documento comparativo Figma/Beta.

## Cambios principales

- Historial conectado directamente a la tabla local de resultados y con detalle de cada evaluación.
- Conteo real de tests completados en Perfil.
- Los nodos/círculos disponibles del mapa permiten continuar el test; el nodo Resultado abre el resultado.
- Opción **Reiniciar test** añadida a Perfil. Reinicia el progreso actual sin borrar resultados anteriores del Historial.
- Nueva animación de análisis antes de mostrar resultados.
- TabBar rediseñado como barra flotante/pastilla inspirada en Figma con PATH, RESULTADOS y PERFIL.
- Mejora del cálculo de afinidad profesional: cada carrera utiliza un perfil RIASEC propio y preguntas específicas, reduciendo empates entre carreras con códigos Holland similares.
- Se conserva la escala 0–10 y las 30 preguntas RIASEC.
- Ajustes de APIs de Flutter para reducir avisos deprecados, incluyendo PopScope y DropdownButtonFormField.initialValue.
- Logros continúa excluido del proyecto.

## Importante sobre resultados anteriores

Los resultados ya almacenados fueron calculados con el algoritmo anterior y se conservan en el Historial. Para evaluar el nuevo algoritmo de afinidad, usa **Perfil > Reiniciar test** y completa una nueva evaluación.

## Ejecución

```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```

Si `flutter analyze` muestra un warning dependiente de la versión concreta de Flutter instalada, se recomienda usar una versión estable reciente compatible con Dart >= 3.2.
