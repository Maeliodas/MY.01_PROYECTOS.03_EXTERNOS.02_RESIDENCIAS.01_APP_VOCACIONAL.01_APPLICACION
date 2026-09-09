CREATE DATABASE IF NOT EXISTS aevum_iter CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE aevum_iter;

CREATE TABLE IF NOT EXISTS students (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  local_profile_id VARCHAR(64) NULL,
  name VARCHAR(160) NOT NULL,
  age INT NOT NULL,
  gender VARCHAR(40) NULL,
  state_id VARCHAR(8) NULL,
  state_name VARCHAR(120) NULL,
  municipality_id VARCHAR(16) NULL,
  municipality_name VARCHAR(160) NULL,
  school_id VARCHAR(80) NULL,
  school_name VARCHAR(200) NULL,
  languages_json JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_students_school (school_name),
  INDEX idx_students_state (state_name),
  INDEX idx_students_municipality (municipality_name)
);

CREATE TABLE IF NOT EXISTS evaluations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  external_result_id VARCHAR(80) NOT NULL UNIQUE,
  session_id VARCHAR(80) NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  holland_code VARCHAR(8) NOT NULL,
  score_r DECIMAL(6,2) NOT NULL DEFAULT 0,
  score_i DECIMAL(6,2) NOT NULL DEFAULT 0,
  score_a DECIMAL(6,2) NOT NULL DEFAULT 0,
  score_s DECIMAL(6,2) NOT NULL DEFAULT 0,
  score_e DECIMAL(6,2) NOT NULL DEFAULT 0,
  score_c DECIMAL(6,2) NOT NULL DEFAULT 0,
  top_career_id VARCHAR(80) NULL,
  top_career_name VARCHAR(200) NOT NULL,
  top_career_affinity DECIMAL(6,2) NOT NULL DEFAULT 0,
  completed_at DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_evaluation_student FOREIGN KEY (student_id)
    REFERENCES students(id) ON DELETE CASCADE,
  INDEX idx_eval_career (top_career_name),
  INDEX idx_eval_completed (completed_at)
);
