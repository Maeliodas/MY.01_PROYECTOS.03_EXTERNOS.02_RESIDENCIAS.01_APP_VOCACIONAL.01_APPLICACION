SET NAMES utf8mb4;
USE aevum_iter;
ALTER TABLE questions ADD COLUMN related_career_id VARCHAR(80) NULL AFTER position;
ALTER TABLE career_riasec_weights MODIFY weight DECIMAL(4,2) NOT NULL;
UPDATE career_riasec_weights SET weight = weight * 10 WHERE weight <= 1;
UPDATE catalog_meta SET version = version + 1 WHERE id = 1;
