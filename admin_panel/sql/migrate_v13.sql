SET NAMES utf8mb4;
USE aevum_iter;

ALTER TABLE careers
  ADD COLUMN department ENUM(
    'Ciencias de la Tierra',
    'Económico Administrativo',
    'Química',
    'Sistemas y Computación',
    'Metal Mecánica',
    'Eléctrica'
  ) NULL AFTER holland_code;

UPDATE careers SET department='Ciencias de la Tierra' WHERE id IN ('ic','arq');
UPDATE careers SET department='Económico Administrativo' WHERE id IN ('la','ige','cp');
UPDATE careers SET department='Química' WHERE id='ibq';
UPDATE careers SET department='Sistemas y Computación' WHERE id IN ('ii','idap','isc');
UPDATE careers SET department='Metal Mecánica' WHERE id='iem';
UPDATE careers SET department='Eléctrica' WHERE id='ie';

ALTER TABLE careers MODIFY department ENUM(
  'Ciencias de la Tierra',
  'Económico Administrativo',
  'Química',
  'Sistemas y Computación',
  'Metal Mecánica',
  'Eléctrica'
) NOT NULL;

CREATE TABLE IF NOT EXISTS department_open_questions (
  department ENUM(
    'Ciencias de la Tierra',
    'Económico Administrativo',
    'Química',
    'Sistemas y Computación',
    'Metal Mecánica',
    'Eléctrica'
  ) PRIMARY KEY,
  question_text VARCHAR(800) NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO department_open_questions(department,question_text) VALUES
('Ciencias de la Tierra','¿Te gustaría participar en el diseño, construcción o supervisión de edificios, carreteras u otras obras de infraestructura?'),
('Económico Administrativo','¿Te gustaría organizar proyectos, dirigir equipos, emprender o proponer mejoras para que una organización funcione mejor?'),
('Química','¿Te gustaría realizar proyectos de laboratorio relacionados con biotecnología, alimentos, química o procesos bioquímicos?'),
('Sistemas y Computación','¿Te gustaría desarrollar aplicaciones, sistemas o soluciones con inteligencia artificial, ciberseguridad, bases de datos o análisis de datos?'),
('Metal Mecánica','¿Te gustaría trabajar con máquinas, sistemas eléctricos y mecánicos, energía o mantenimiento industrial?'),
('Eléctrica','¿Te gustaría diseñar o experimentar con circuitos, sensores, robótica, control o automatización?')
ON DUPLICATE KEY UPDATE question_text=VALUES(question_text);

UPDATE catalog_meta SET version = version + 1 WHERE id = 1;
