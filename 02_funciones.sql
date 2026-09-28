USE universidad;

DROP FUNCTION IF EXISTS fnc_calcular_nota_final;
DROP FUNCTION IF EXISTS fnc_obtener_estado_academico;
DROP FUNCTION IF EXISTS fnc_total_creditos;
DROP FUNCTION IF EXISTS fnc_promedio_asignatura;
DROP FUNCTION IF EXISTS fnc_asignaturas_aprobadas;

DELIMITER $$

CREATE FUNCTION fnc_calcular_nota_final(p_id_matricula INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v1 DECIMAL(4,2);
    DECLARE v2 DECIMAL(4,2);
    DECLARE vf DECIMAL(4,2);
    DECLARE vt DECIMAL(4,2);
    SELECT parcial1, parcial2, parcial_final, trabajo_practico
      INTO v1, v2, vf, vt
      FROM calificaciones
     WHERE id_matricula = p_id_matricula;
    IF vt IS NULL THEN
        RETURN ROUND(v1 * 0.20 + v2 * 0.35 + vf * 0.45, 2);
    ELSE
        RETURN ROUND(v1 * 0.20 + v2 * 0.35 + vf * 0.35 + vt * 0.10, 2);
    END IF;
END$$

CREATE FUNCTION fnc_obtener_estado_academico(p_id_matricula INT)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    IF fnc_calcular_nota_final(p_id_matricula) >= 3.00 THEN
        RETURN 'APROBADO';
    ELSE
        RETURN 'REPROBADO';
    END IF;
END$$

CREATE FUNCTION fnc_total_creditos(p_id_alumno INT, p_id_curso_escolar INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT COALESCE(SUM(a.creditos),0)
      INTO v_total
      FROM alumno_se_matricula_asignatura m
      JOIN asignatura a ON a.id = m.id_asignatura
     WHERE m.id_alumno = p_id_alumno
       AND m.id_curso_escolar = p_id_curso_escolar;
    RETURN v_total;
END$$

CREATE FUNCTION fnc_promedio_asignatura(p_id_asignatura INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_promedio DECIMAL(4,2);
    SELECT COALESCE(ROUND(AVG(fnc_calcular_nota_final(c.id_matricula)),2),0)
      INTO v_promedio
      FROM calificaciones c
      JOIN alumno_se_matricula_asignatura m
        ON m.id_matricula = c.id_matricula
     WHERE m.id_asignatura = p_id_asignatura;
    RETURN v_promedio;
END$$

CREATE FUNCTION fnc_asignaturas_aprobadas(p_id_alumno INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*)
      INTO v_total
      FROM calificaciones c
      JOIN alumno_se_matricula_asignatura m
        ON m.id_matricula = c.id_matricula
     WHERE m.id_alumno = p_id_alumno
       AND fnc_calcular_nota_final(c.id_matricula) >= 3.00;
    RETURN v_total;
END$$

DELIMITER ;
