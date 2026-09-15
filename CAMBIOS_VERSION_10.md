# AEVUM ITER V10

- Corrección integral de codificación UTF-8/utf8mb4 en MySQL y panel.
- Catálogo municipal ampliado y escuelas de procedencia de Tuxtepec ampliadas.
- Selección dependiente Estado → Municipio → Escuela.
- Corrección de lenguas/idiomas personalizados: ya no violan la llave foránea local y permiten continuar aunque la sugerencia siga pendiente.
- Editor de avatar en pantalla separada con avatares de la app, galería y cámara.
- Una pregunta abierta asociada a cada carrera; sus respuestas se guardan localmente y se envían al servidor.
- Carreras con URL oficial del TecNM/Tec de Tuxtepec. “Ver detalles” abre el sitio externo; Arquitectura muestra aviso de página no disponible.
- CRUD de carreras actualizado para editar URL y pregunta abierta.
- Nueva tabla de servidor `evaluation_open_answers`.

## Importación MySQL recomendada en Windows

```powershell
cmd /c "mysql --default-character-set=utf8mb4 -u root -p -P 3309 < admin_panel\sql\schema.sql"
```

La versión está pensada para instalación limpia.
