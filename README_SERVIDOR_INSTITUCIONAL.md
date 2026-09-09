# AEVUM ITER · Consideraciones para servidor institucional

## Requisitos incorporados

- La app móvil se comunica con el backend mediante una API autenticada por token.
- El panel puede protegerse con credenciales administrativas.
- En producción, toda autenticación y transferencia de datos debe viajar por HTTPS/TLS.
- La base de datos no debe ser accesible directamente desde la app móvil ni desde Internet.
- El backend es compatible con MariaDB/MySQL mediante `mysql2`.
- El despliegue recomendado usa Apache o Nginx como reverse proxy frente a Node.js.
- Las credenciales se suministran mediante variables de entorno y `.env` está excluido del proyecto entregable.

## Flujo de producción

App Flutter → HTTPS/TLS → Apache/Nginx → Node/Express → MariaDB

Panel navegador → HTTPS/TLS → Apache/Nginx → Node/Express → MariaDB

## Operación

La institución indicó que puede alojar el proyecto y que cuenta con servidores, MariaDB, Apache/Nginx, dominios/subdominios y posibilidad de certificados. Antes del despliegue debe existir una beta funcional local y presentarse una solicitud por escrito con los requerimientos de software.

Se recomienda configurar respaldos automáticos de MariaDB mediante tareas programadas/cron, además de respaldos manuales antes de actualizaciones importantes.
