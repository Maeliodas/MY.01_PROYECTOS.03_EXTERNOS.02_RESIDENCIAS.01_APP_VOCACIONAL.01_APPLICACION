# Panel administrativo AEVUM ITER V9

El panel funciona como interfaz CRUD de la base MySQL/MariaDB `aevum_iter`.

## Funciones

- Dashboard de evaluaciones con filtros.
- CRUD de estados.
- CRUD de municipios dependientes del estado.
- CRUD de escuelas dependientes del municipio.
- CRUD de lenguas originarias e idiomas.
- CRUD de carreras, descripción, Holland, pesos RIASEC y preguntas relacionadas.
- CRUD de preguntas del test.
- Revisión de sugerencias enviadas desde la app.
- Cada cambio de catálogo incrementa `catalog_meta.version`.

La app obtiene un snapshot del catálogo mediante el backend propio y lo almacena en SQLite para continuar funcionando offline. No se consultan APIs externas en tiempo de ejecución.

## Instalación limpia

Desde la raíz del proyecto:

```powershell
cmd /c "mysql -u root -p -P 3309 < admin_panel\sql\schema.sql"
cd admin_panel
copy .env.example .env
npm install
npm start
```

Edita `.env` antes de arrancar el servidor.
