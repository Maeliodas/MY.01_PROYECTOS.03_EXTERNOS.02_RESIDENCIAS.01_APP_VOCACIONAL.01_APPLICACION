# Cambios AEVUM ITER V9

- MySQL/MariaDB pasa a ser la fuente maestra de todos los catálogos administrables.
- El panel web incorpora CRUD para estados, municipios, escuelas, lenguas/idiomas, carreras y preguntas.
- Carreras permite editar descripción, código Holland, pesos RIASEC y relaciones con preguntas.
- Las bajas son lógicas para proteger evaluaciones históricas.
- La app sincroniza catálogos del servidor hacia SQLite al iniciar y manualmente desde Configuración.
- Se agregó cola SQLite para sugerencias de lengua/idioma cuando no hay conexión.
- Las sugerencias aparecen en el panel y pueden aprobarse/rechazarse.
- Estado → municipios y municipio → escuelas son selectores dependientes.
- Se amplió el catálogo inicial de municipios en las 32 entidades; los nombres siguen nomenclatura geográfica mexicana y el catálogo puede ampliarse desde el CRUD.
- Se ampliaron los idiomas.
- El botón de avatar ahora dice **Elegir desde galería o fotos** y abre la galería del dispositivo.
- El ranking muestra solamente las tres carreras con mayor afinidad y las tres permiten abrir su detalle.
- El panel incorpora filtros por procedencia, escuela, perfil, carrera y fechas, además de búsqueda textual.
- Se mantiene el requisito de no consumir APIs externas para catálogos en la app. El intercambio app-servidor es únicamente con el backend propio de AEVUM ITER.
