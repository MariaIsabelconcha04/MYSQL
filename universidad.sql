-- ============================================================
-- UNIVERSIDAD - FUNCIONES, PROCEDIMIENTOS Y TRIGGERS
-- Basado en el PDF "Funciones, Procedimientos y Triggers"
-- MySQL / MySQL Workbench
-- ============================================================

DROP DATABASE IF EXISTS universidad;
CREATE DATABASE universidad
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE universidad;

-- ============================================================
-- 1. TABLAS
-- ============================================================

CREATE TABLE alumno (
    id_alumno INT AUTO_INCREMENT PRIMARY KEY,
    documento VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE departamento (
    id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE profesor (
    id_profesor INT AUTO_INCREMENT PRIMARY KEY,
    documento VARCHAR(20) NOT NULL UNIQUE,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    id_departamento INT NOT NULL,
    CONSTRAINT fk_profesor_departamento
        FOREIGN KEY (id_departamento)
        REFERENCES departamento(id_departamento)
) ENGINE=InnoDB;

CREATE TABLE asignatura (
    id_asignatura INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    creditos INT NOT NULL,
    CONSTRAINT chk_asignatura_creditos CHECK (creditos > 0)
) ENGINE=InnoDB;

CREATE TABLE curso_escolar (
    id_curso_escolar INT AUTO_INCREMENT PRIMARY KEY,
    periodo VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE curso_asignatura (
    id_curso_asignatura INT AUTO_INCREMENT PRIMARY KEY,
    id_asignatura INT NOT NULL,
    id_curso_escolar INT NOT NULL,
    id_profesor INT NOT NULL,
    CONSTRAINT uq_curso_asignatura
        UNIQUE (id_asignatura, id_curso_escolar),
    CONSTRAINT fk_curso_asignatura_asignatura
        FOREIGN KEY (id_asignatura)
        REFERENCES asignatura(id_asignatura),
    CONSTRAINT fk_curso_asignatura_curso
        FOREIGN KEY (id_curso_escolar)
        REFERENCES curso_escolar(id_curso_escolar),
    CONSTRAINT fk_curso_asignatura_profesor
        FOREIGN KEY (id_profesor)
        REFERENCES profesor(id_profesor)
) ENGINE=InnoDB;

CREATE TABLE matricula (
    id_matricula INT AUTO_INCREMENT PRIMARY KEY,
    id_alumno INT NOT NULL,
    id_asignatura INT NOT NULL,
    id_curso_escolar INT NOT NULL,
    estado ENUM('ACTIVA','CANCELADA') NOT NULL DEFAULT 'ACTIVA',
    fecha_matricula DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_matricula_alumno
        FOREIGN KEY (id_alumno)
        REFERENCES alumno(id_alumno),
    CONSTRAINT fk_matricula_asignatura
        FOREIGN KEY (id_asignatura)
        REFERENCES asignatura(id_asignatura),
    CONSTRAINT fk_matricula_curso
        FOREIGN KEY (id_curso_escolar)
        REFERENCES curso_escolar(id_curso_escolar)
) ENGINE=InnoDB;

CREATE TABLE calificaciones (
    id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_matricula INT NOT NULL UNIQUE,
    parcial1 DECIMAL(4,2) NOT NULL,
    parcial2 DECIMAL(4,2) NOT NULL,
    parcial_final DECIMAL(4,2) NOT NULL,
    trabajo_practico DECIMAL(4,2) NULL,
    fecha_registro DATETIME NULL,
    CONSTRAINT fk_calificacion_matricula
        FOREIGN KEY (id_matricula)
        REFERENCES matricula(id_matricula)
) ENGINE=InnoDB;

CREATE TABLE historial_calificaciones (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_calificacion INT NOT NULL,
    nota_anterior DECIMAL(4,2) NOT NULL,
    nota_nueva DECIMAL(4,2) NOT NULL,
    fecha_cambio DATETIME NOT NULL,
    CONSTRAINT fk_historial_calificacion
        FOREIGN KEY (id_calificacion)
        REFERENCES calificaciones(id_calificacion)
) ENGINE=InnoDB;

-- ============================================================
-- 2. DATOS DE PRUEBA
-- ============================================================

INSERT INTO departamento (nombre) VALUES
('Ingeniería de Sistemas'),
('Matemáticas'),
('Administración');

INSERT INTO profesor (documento, nombres, apellidos, id_departamento) VALUES
('1001', 'Carlos', 'Gómez', 1),
('1002', 'Ana', 'Martínez', 1),
('1003', 'Luis', 'Rodríguez', 2);

INSERT INTO alumno (documento, nombres, apellidos) VALUES
('2001', 'María', 'Concha'),
('2002', 'Juan', 'Pérez'),
('2003', 'Laura', 'García');

INSERT INTO asignatura (nombre, creditos) VALUES
('Bases de Datos', 4),
('Programación', 3),
('Matemáticas', 4);

INSERT INTO curso_escolar (periodo) VALUES
('2026-1'),
('2026-2');

INSERT INTO curso_asignatura
    (id_asignatura, id_curso_escolar, id_profesor)
VALUES
    (1, 1, 1),
    (2, 1, 2),
    (3, 1, 3);

-- ============================================================
-- 3. FUNCIONES
-- ============================================================

DELIMITER $$

-- ------------------------------------------------------------
-- Función 1: cálculo de nota final ponderada
-- Sin trabajo: 20%, 35%, 45%
-- Con trabajo: 20%, 35%, 35%, 10%
-- ------------------------------------------------------------
CREATE FUNCTION fnc_calcular_nota_final(p_id_matricula INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_parcial1 DECIMAL(4,2);
    DECLARE v_parcial2 DECIMAL(4,2);
    DECLARE v_parcial_final DECIMAL(4,2);
    DECLARE v_trabajo DECIMAL(4,2);
    DECLARE v_nota DECIMAL(4,2);

    SELECT parcial1, parcial2, parcial_final, trabajo_practico
      INTO v_parcial1, v_parcial2, v_parcial_final, v_trabajo
      FROM calificaciones
     WHERE id_matricula = p_id_matricula;

    IF v_trabajo IS NULL THEN
        SET v_nota =
            (v_parcial1 * 0.20) +
            (v_parcial2 * 0.35) +
            (v_parcial_final * 0.45);
    ELSE
        SET v_nota =
            (v_parcial1 * 0.20) +
            (v_parcial2 * 0.35) +
            (v_parcial_final * 0.35) +
            (v_trabajo * 0.10);
    END IF;

    RETURN ROUND(v_nota, 2);
END$$

-- ------------------------------------------------------------
-- Función 2: estado académico
-- ------------------------------------------------------------
CREATE FUNCTION fnc_obtener_estado_academico(p_id_matricula INT)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_nota DECIMAL(4,2);

    SET v_nota = fnc_calcular_nota_final(p_id_matricula);

    IF v_nota >= 3.00 THEN
        RETURN 'APROBADO';
    ELSE
        RETURN 'REPROBADO';
    END IF;
END$$

-- ------------------------------------------------------------
-- Función 3: total de créditos matriculados
-- ------------------------------------------------------------
CREATE FUNCTION fnc_total_creditos(
    p_id_alumno INT,
    p_id_curso_escolar INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COALESCE(SUM(a.creditos), 0)
      INTO v_total
      FROM matricula m
      INNER JOIN asignatura a
              ON a.id_asignatura = m.id_asignatura
     WHERE m.id_alumno = p_id_alumno
       AND m.id_curso_escolar = p_id_curso_escolar
       AND m.estado = 'ACTIVA';

    RETURN v_total;
END$$

-- ------------------------------------------------------------
-- Función 4: promedio general de una asignatura
-- ------------------------------------------------------------
CREATE FUNCTION fnc_promedio_asignatura(p_id_asignatura INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_promedio DECIMAL(4,2);

    SELECT COALESCE(
               AVG(fnc_calcular_nota_final(m.id_matricula)),
               0
           )
      INTO v_promedio
      FROM matricula m
     WHERE m.id_asignatura = p_id_asignatura
       AND m.estado = 'ACTIVA';

    RETURN ROUND(v_promedio, 2);
END$$

-- ------------------------------------------------------------
-- Función 5: cantidad de asignaturas aprobadas
-- ------------------------------------------------------------
CREATE FUNCTION fnc_asignaturas_aprobadas(p_id_alumno INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*)
      INTO v_total
      FROM matricula m
      INNER JOIN calificaciones c
              ON c.id_matricula = m.id_matricula
     WHERE m.id_alumno = p_id_alumno
       AND m.estado = 'ACTIVA'
       AND fnc_calcular_nota_final(m.id_matricula) >= 3.00;

    RETURN v_total;
END$$

-- ============================================================
-- 4. PROCEDIMIENTOS ALMACENADOS
-- ============================================================

-- ------------------------------------------------------------
-- Procedimiento 1: registrar o actualizar calificaciones
-- ------------------------------------------------------------
CREATE PROCEDURE sp_guardar_calificacion(
    IN p_id_matricula INT,
    IN p_parcial1 DECIMAL(4,2),
    IN p_parcial2 DECIMAL(4,2),
    IN p_parcial_final DECIMAL(4,2),
    IN p_trabajo_practico DECIMAL(4,2)
)
BEGIN
    IF EXISTS (
        SELECT 1
          FROM matricula
         WHERE id_matricula = p_id_matricula
    ) THEN

        IF EXISTS (
            SELECT 1
              FROM calificaciones
             WHERE id_matricula = p_id_matricula
        ) THEN

            UPDATE calificaciones
               SET parcial1 = p_parcial1,
                   parcial2 = p_parcial2,
                   parcial_final = p_parcial_final,
                   trabajo_practico = p_trabajo_practico
             WHERE id_matricula = p_id_matricula;

        ELSE

            INSERT INTO calificaciones
                (id_matricula, parcial1, parcial2, parcial_final,
                 trabajo_practico, fecha_registro)
            VALUES
                (p_id_matricula, p_parcial1, p_parcial2, p_parcial_final,
                 p_trabajo_practico, NULL);

        END IF;

    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La matrícula indicada no existe.';
    END IF;
END$$

-- ------------------------------------------------------------
-- Procedimiento 2: generar acta de notas
-- ------------------------------------------------------------
CREATE PROCEDURE sp_generar_acta_curso(
    IN p_id_asignatura INT,
    IN p_id_curso_escolar INT
)
BEGIN
    SELECT
        al.documento,
        CONCAT(al.nombres, ' ', al.apellidos) AS nombre_completo,
        c.parcial1,
        c.parcial2,
        c.parcial_final,
        c.trabajo_practico,
        fnc_calcular_nota_final(m.id_matricula) AS nota_final
    FROM matricula m
    INNER JOIN alumno al
            ON al.id_alumno = m.id_alumno
    INNER JOIN calificaciones c
            ON c.id_matricula = m.id_matricula
    WHERE m.id_asignatura = p_id_asignatura
      AND m.id_curso_escolar = p_id_curso_escolar
      AND m.estado = 'ACTIVA'
    ORDER BY al.apellidos, al.nombres;
END$$

-- ------------------------------------------------------------
-- Procedimiento 3: matricular alumno
-- ------------------------------------------------------------
CREATE PROCEDURE sp_matricular_alumno(
    IN p_id_alumno INT,
    IN p_id_asignatura INT,
    IN p_id_curso_escolar INT
)
BEGIN
    IF EXISTS (
        SELECT 1
          FROM matricula
         WHERE id_alumno = p_id_alumno
           AND id_asignatura = p_id_asignatura
           AND id_curso_escolar = p_id_curso_escolar
           AND estado = 'ACTIVA'
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'El alumno ya esta matriculado en esa asignatura y periodo.';

    ELSE

        INSERT INTO matricula
            (id_alumno, id_asignatura, id_curso_escolar, estado)
        VALUES
            (p_id_alumno, p_id_asignatura, p_id_curso_escolar, 'ACTIVA');

    END IF;
END$$

-- ------------------------------------------------------------
-- Procedimiento 4: reasignación de docente
-- ------------------------------------------------------------
CREATE PROCEDURE sp_reasignar_docente(
    IN p_id_asignatura INT,
    IN p_id_curso_escolar INT,
    IN p_id_departamento INT,
    IN p_id_nuevo_profesor INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM profesor
         WHERE id_profesor = p_id_nuevo_profesor
           AND id_departamento = p_id_departamento
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'El profesor no pertenece al departamento indicado.';

    ELSEIF NOT EXISTS (
        SELECT 1
          FROM curso_asignatura
         WHERE id_asignatura = p_id_asignatura
           AND id_curso_escolar = p_id_curso_escolar
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'No existe la asignatura en el curso escolar indicado.';

    ELSE

        UPDATE curso_asignatura
           SET id_profesor = p_id_nuevo_profesor
         WHERE id_asignatura = p_id_asignatura
           AND id_curso_escolar = p_id_curso_escolar;

    END IF;
END$$

-- ------------------------------------------------------------
-- Procedimiento 5: reporte histórico del estudiante
-- ------------------------------------------------------------
CREATE PROCEDURE sp_reporte_historico_estudiante(IN p_id_alumno INT)
BEGIN
    SELECT
        ce.periodo,
        a.nombre AS asignatura,
        CONCAT(p.nombres, ' ', p.apellidos) AS profesor,
        fnc_calcular_nota_final(m.id_matricula) AS nota_obtenida,
        fnc_obtener_estado_academico(m.id_matricula) AS estado
    FROM matricula m
    INNER JOIN asignatura a
            ON a.id_asignatura = m.id_asignatura
    INNER JOIN curso_escolar ce
            ON ce.id_curso_escolar = m.id_curso_escolar
    LEFT JOIN curso_asignatura ca
           ON ca.id_asignatura = m.id_asignatura
          AND ca.id_curso_escolar = m.id_curso_escolar
    LEFT JOIN profesor p
           ON p.id_profesor = ca.id_profesor
    INNER JOIN calificaciones c
            ON c.id_matricula = m.id_matricula
    WHERE m.id_alumno = p_id_alumno
    ORDER BY ce.periodo, a.nombre;
END$$

-- ============================================================
-- 5. TRIGGERS
-- ============================================================
-- Se usan 5 triggers reales. En MySQL INSERT y UPDATE requieren
-- triggers separados; por eso normalización + validación se
-- agrupan por evento para cumplir los 5 ejercicios del PDF.
-- ============================================================

-- ------------------------------------------------------------
-- Trigger 1: BEFORE INSERT
-- Normaliza trabajo práctico 0 -> NULL y valida notas 0..5
-- ------------------------------------------------------------
CREATE TRIGGER trg_calificaciones_before_insert
BEFORE INSERT ON calificaciones
FOR EACH ROW
BEGIN
    IF NEW.trabajo_practico = 0 THEN
        SET NEW.trabajo_practico = NULL;
    END IF;

    IF NEW.parcial1 < 0 OR NEW.parcial1 > 5
       OR NEW.parcial2 < 0 OR NEW.parcial2 > 5
       OR NEW.parcial_final < 0 OR NEW.parcial_final > 5
       OR (
            NEW.trabajo_practico IS NOT NULL
            AND (NEW.trabajo_practico < 0
                 OR NEW.trabajo_practico > 5)
          )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Las notas deben estar entre 0.00 y 5.00.';
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 2: BEFORE UPDATE
-- Normaliza trabajo práctico 0 -> NULL y valida notas 0..5
-- ------------------------------------------------------------
CREATE TRIGGER trg_calificaciones_before_update
BEFORE UPDATE ON calificaciones
FOR EACH ROW
BEGIN
    IF NEW.trabajo_practico = 0 THEN
        SET NEW.trabajo_practico = NULL;
    END IF;

    IF NEW.parcial1 < 0 OR NEW.parcial1 > 5
       OR NEW.parcial2 < 0 OR NEW.parcial2 > 5
       OR NEW.parcial_final < 0 OR NEW.parcial_final > 5
       OR (
            NEW.trabajo_practico IS NOT NULL
            AND (NEW.trabajo_practico < 0
                 OR NEW.trabajo_practico > 5)
          )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Las notas deben estar entre 0.00 y 5.00.';
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 3: AFTER UPDATE
-- Auditoría de modificación de notas
-- ------------------------------------------------------------
CREATE TRIGGER trg_auditoria_calificacion
AFTER UPDATE ON calificaciones
FOR EACH ROW
BEGIN
    IF NOT (OLD.parcial1 <=> NEW.parcial1)
       OR NOT (OLD.parcial2 <=> NEW.parcial2)
       OR NOT (OLD.parcial_final <=> NEW.parcial_final)
       OR NOT (OLD.trabajo_practico <=> NEW.trabajo_practico)
    THEN
        INSERT INTO historial_calificaciones
            (id_calificacion, nota_anterior, nota_nueva, fecha_cambio)
        VALUES
            (
                NEW.id_calificacion,
                CASE
                    WHEN OLD.trabajo_practico IS NULL THEN
                        ROUND(
                            (OLD.parcial1 * 0.20) +
                            (OLD.parcial2 * 0.35) +
                            (OLD.parcial_final * 0.45), 2
                        )
                    ELSE
                        ROUND(
                            (OLD.parcial1 * 0.20) +
                            (OLD.parcial2 * 0.35) +
                            (OLD.parcial_final * 0.35) +
                            (OLD.trabajo_practico * 0.10), 2
                        )
                END,
                CASE
                    WHEN NEW.trabajo_practico IS NULL THEN
                        ROUND(
                            (NEW.parcial1 * 0.20) +
                            (NEW.parcial2 * 0.35) +
                            (NEW.parcial_final * 0.45), 2
                        )
                    ELSE
                        ROUND(
                            (NEW.parcial1 * 0.20) +
                            (NEW.parcial2 * 0.35) +
                            (NEW.parcial_final * 0.35) +
                            (NEW.trabajo_practico * 0.10), 2
                        )
                END,
                NOW()
            );
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 4: BEFORE INSERT en matrículas
-- Previene duplicidad de alumno/asignatura/periodo
-- ------------------------------------------------------------
CREATE TRIGGER trg_prevenir_matricula_duplicada
BEFORE INSERT ON matricula
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
          FROM matricula
         WHERE id_alumno = NEW.id_alumno
           AND id_asignatura = NEW.id_asignatura
           AND id_curso_escolar = NEW.id_curso_escolar
           AND estado = 'ACTIVA'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'El alumno ya tiene una matricula activa para esa asignatura y periodo.';
    END IF;
END$$

-- ------------------------------------------------------------
-- Trigger 5: BEFORE INSERT en calificaciones
-- Fecha automática si llega NULL
-- ------------------------------------------------------------
CREATE TRIGGER trg_fecha_registro_calificacion
BEFORE INSERT ON calificaciones
FOR EACH ROW
BEGIN
    IF NEW.fecha_registro IS NULL THEN
        SET NEW.fecha_registro = NOW();
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- 6. PRUEBAS
-- ============================================================

-- Matricular alumnos.
CALL sp_matricular_alumno(1, 1, 1);
CALL sp_matricular_alumno(2, 1, 1);
CALL sp_matricular_alumno(3, 2, 1);

-- Guardar calificaciones.
-- El trabajo práctico 0 se convierte automáticamente en NULL.
CALL sp_guardar_calificacion(1, 4.00, 3.50, 4.20, 4.50);
CALL sp_guardar_calificacion(2, 3.00, 3.20, 3.50, 0);
CALL sp_guardar_calificacion(3, 4.50, 4.00, 4.80, 4.70);

-- Consultar funciones.
SELECT fnc_calcular_nota_final(1) AS nota_final;
SELECT fnc_obtener_estado_academico(1) AS estado;
SELECT fnc_total_creditos(1, 1) AS total_creditos;
SELECT fnc_promedio_asignatura(1) AS promedio_asignatura;
SELECT fnc_asignaturas_aprobadas(1) AS asignaturas_aprobadas;

-- Consultar acta.
CALL sp_generar_acta_curso(1, 1);

-- Consultar histórico.
CALL sp_reporte_historico_estudiante(1);

-- Probar auditoría modificando una nota.
UPDATE calificaciones
   SET parcial1 = 4.50
 WHERE id_matricula = 1;

SELECT *
FROM historial_calificaciones;

-- ============================================================
-- 7. CONSULTAS ÚTILES
-- ============================================================

SHOW TABLES;

SHOW FUNCTION STATUS
WHERE Db = 'universidad';

SHOW PROCEDURE STATUS
WHERE Db = 'universidad';

SHOW TRIGGERS
FROM universidad;

SELECT * FROM alumno;
SELECT * FROM profesor;
SELECT * FROM asignatura;
SELECT * FROM matricula;
SELECT * FROM calificaciones;
SELECT * FROM historial_calificaciones;
