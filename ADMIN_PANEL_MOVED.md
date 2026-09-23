# Panel movido

El panel web se movió a su propio repositorio:

`../(02)_PANEL_DE_CONTROL/admin_panel/` (rama `main`)

Historial preservado con `git subtree split -P admin_panel`
(39 archivos, hasta `1.2.2-9`), más commit de saneado
(`.env` y `node_modules/` ignorados).

La app Flutter no depende de la ruta local del panel,
solo de `APP_VOCACIONAL_API_URL` (`lib/core/constants/app_constants.dart`).
