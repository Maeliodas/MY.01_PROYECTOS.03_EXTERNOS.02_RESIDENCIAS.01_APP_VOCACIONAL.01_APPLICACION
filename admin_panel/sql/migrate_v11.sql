SET NAMES utf8mb4;
USE aevum_iter;

ALTER TABLE evaluation_open_answers
  ADD COLUMN question_text VARCHAR(800) NULL AFTER career_id;

UPDATE careers SET open_question='¿Te gustaría desarrollar aplicaciones, sistemas o soluciones con inteligencia artificial, ciberseguridad o análisis de datos?' WHERE id='isc';
UPDATE careers SET open_question='¿Te gustaría crear soluciones digitales, administrar bases de datos, redes o servicios informáticos para una organización?' WHERE id='ii';
UPDATE careers SET open_question='¿Te gustaría diseñar y desarrollar aplicaciones móviles, web o productos digitales que resuelvan necesidades reales?' WHERE id='idap';
UPDATE careers SET open_question='¿Te gustaría trabajar con máquinas, sistemas eléctricos y mecánicos, energía o mantenimiento industrial?' WHERE id='iem';
UPDATE careers SET open_question='¿Te gustaría diseñar o experimentar con circuitos, sensores, robótica, control o automatización?' WHERE id='ie';
UPDATE careers SET open_question='¿Te gustaría participar en el diseño, construcción o supervisión de edificios, carreteras y otras obras de infraestructura?' WHERE id='ic';
UPDATE careers SET open_question='¿Te gustaría realizar proyectos de laboratorio relacionados con biotecnología, alimentos, química o procesos bioquímicos?' WHERE id='ibq';
UPDATE careers SET open_question='¿Te gustaría organizar proyectos, dirigir equipos, emprender o proponer mejoras para que una empresa funcione mejor?' WHERE id='ige';
UPDATE careers SET open_question='¿Te gustaría coordinar personas, recursos y estrategias para alcanzar los objetivos de una organización?' WHERE id='la';
UPDATE careers SET open_question='¿Te gustaría trabajar con finanzas, auditoría, impuestos, costos y analizar la situación económica de una organización?' WHERE id='cp';
UPDATE careers SET open_question='¿Te gustaría diseñar espacios, edificios o proyectos arquitectónicos que combinen creatividad, funcionalidad y necesidades de las personas?' WHERE id='arq';

UPDATE catalog_meta SET version=version+1 WHERE id=1;
