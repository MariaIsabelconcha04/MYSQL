USE universidad;

DELIMITER $$

CREATE FUNCTION fnc_calcular_nota_final(p_id_matricula INT)
RETURNS DECIMAL(4,2) DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v1,v2,vf,vt DECIMAL(4,2);
    SELECT parcial1,parcial2,parcial_final,trabajo_practico
      INTO v1,v2,vf,vt FROM calificaciones WHERE id_matricula=p_id_matricula;
    IF vt IS NULL THEN
        RETURN ROUND(v1*.20+v2*.35+vf*.45,2);
    ELSE
        RETURN ROUND(v1*.20+v2*.35+vf*.35+vt*.10,2);
    END IF;
END$$

CREATE FUNCTION fnc_obtener_estado_academico(p_id_matricula INT)
RETURNS VARCHAR(20) DETERMINISTIC READS SQL DATA
BEGIN
    IF fnc_calcular_nota_final(p_id_matricula)>=3.00 THEN
        RETURN 'APROBADO';
    ELSE
        RETURN 'REPROBADO';
    END IF;
END$$

CREATE FUNCTION fnc_total_creditos(p_id_alumno INT,p_id_curso_escolar INT)
RETURNS INT DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COALESCE(SUM(a.creditos),0) INTO v_total
    FROM alumno_se_matricula_asignatura m
    JOIN asignatura a ON a.id=m.id_asignatura
    WHERE m.id_alumno=p_id_alumno AND m.id_curso_escolar=p_id_curso_escolar;
    RETURN v_total;
END$$

CREATE FUNCTION fnc_promedio_asignatura(p_id_asignatura INT)
RETURNS DECIMAL(4,2) DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_promedio DECIMAL(4,2);
    SELECT COALESCE(AVG(fnc_calcular_nota_final(c.id_matricula)),0) INTO v_promedio
    FROM calificaciones c
    JOIN alumno_se_matricula_asignatura m ON m.id_matricula=c.id_matricula
    WHERE m.id_asignatura=p_id_asignatura;
    RETURN ROUND(v_promedio,2);
END$$

CREATE FUNCTION fnc_asignaturas_aprobadas(p_id_alumno INT)
RETURNS INT DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total
    FROM calificaciones c
    JOIN alumno_se_matricula_asignatura m ON m.id_matricula=c.id_matricula
    WHERE m.id_alumno=p_id_alumno
      AND fnc_calcular_nota_final(c.id_matricula)>=3.00;
    RETURN v_total;
END$$

DELIMITER ;
