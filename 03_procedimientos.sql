USE universidad;

DELIMITER $$

CREATE PROCEDURE sp_guardar_calificacion(
    IN p_id_matricula INT, IN p_parcial1 DECIMAL(4,2),
    IN p_parcial2 DECIMAL(4,2), IN p_parcial_final DECIMAL(4,2),
    IN p_trabajo_practico DECIMAL(4,2)
)
BEGIN
    IF NOT EXISTS(SELECT 1 FROM alumno_se_matricula_asignatura WHERE id_matricula=p_id_matricula) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La matrícula indicada no existe.';
    ELSEIF EXISTS(SELECT 1 FROM calificaciones WHERE id_matricula=p_id_matricula) THEN
        UPDATE calificaciones SET parcial1=p_parcial1,parcial2=p_parcial2,
            parcial_final=p_parcial_final,trabajo_practico=p_trabajo_practico
        WHERE id_matricula=p_id_matricula;
    ELSE
        INSERT INTO calificaciones(id_matricula,parcial1,parcial2,parcial_final,trabajo_practico,fecha_registro)
        VALUES(p_id_matricula,p_parcial1,p_parcial2,p_parcial_final,p_trabajo_practico,NULL);
    END IF;
END$$

CREATE PROCEDURE sp_generar_acta_curso(IN p_id_asignatura INT,IN p_id_curso_escolar INT)
BEGIN
    SELECT p.nif AS documento,
           TRIM(CONCAT(p.nombre,' ',p.apellido1,' ',COALESCE(p.apellido2,''))) AS nombre_completo,
           c.parcial1,c.parcial2,c.parcial_final,c.trabajo_practico,
           fnc_calcular_nota_final(c.id_matricula) AS nota_final
    FROM calificaciones c
    JOIN alumno_se_matricula_asignatura m ON m.id_matricula=c.id_matricula
    JOIN persona p ON p.id=m.id_alumno
    WHERE m.id_asignatura=p_id_asignatura AND m.id_curso_escolar=p_id_curso_escolar
    ORDER BY p.apellido1,p.nombre;
END$$

CREATE PROCEDURE sp_matricular_alumno(IN p_id_alumno INT,IN p_id_asignatura INT,IN p_id_curso_escolar INT)
BEGIN
    IF EXISTS(SELECT 1 FROM alumno_se_matricula_asignatura
              WHERE id_alumno=p_id_alumno AND id_asignatura=p_id_asignatura
                AND id_curso_escolar=p_id_curso_escolar) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El alumno ya está matriculado en esa asignatura y curso escolar.';
    ELSE
        INSERT INTO alumno_se_matricula_asignatura(id_alumno,id_asignatura,id_curso_escolar)
        VALUES(p_id_alumno,p_id_asignatura,p_id_curso_escolar);
    END IF;
END$$

CREATE PROCEDURE sp_reasignar_docente(
    IN p_id_asignatura INT,IN p_id_curso_escolar INT,
    IN p_id_departamento INT,IN p_id_nuevo_profesor INT
)
BEGIN
    IF NOT EXISTS(SELECT 1 FROM curso_escolar WHERE id=p_id_curso_escolar) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El curso escolar indicado no existe.';
    ELSEIF NOT EXISTS(SELECT 1 FROM profesor WHERE id_profesor=p_id_nuevo_profesor AND id_departamento=p_id_departamento) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El profesor no pertenece al departamento indicado.';
    ELSEIF NOT EXISTS(SELECT 1 FROM asignatura WHERE id=p_id_asignatura) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='La asignatura indicada no existe.';
    ELSE
        UPDATE asignatura SET id_profesor=p_id_nuevo_profesor WHERE id=p_id_asignatura;
    END IF;
END$$

CREATE PROCEDURE sp_reporte_historico_estudiante(IN p_id_alumno INT)
BEGIN
    SELECT ce.anyo_inicio,ce.anyo_fin,a.nombre AS asignatura,
           TRIM(CONCAT(pp.nombre,' ',pp.apellido1,' ',COALESCE(pp.apellido2,''))) AS profesor,
           fnc_calcular_nota_final(m.id_matricula) AS nota_obtenida,
           fnc_obtener_estado_academico(m.id_matricula) AS estado
    FROM alumno_se_matricula_asignatura m
    JOIN asignatura a ON a.id=m.id_asignatura
    JOIN curso_escolar ce ON ce.id=m.id_curso_escolar
    LEFT JOIN profesor pr ON pr.id_profesor=a.id_profesor
    LEFT JOIN persona pp ON pp.id=pr.id_profesor
    JOIN calificaciones c ON c.id_matricula=m.id_matricula
    WHERE m.id_alumno=p_id_alumno
    ORDER BY ce.anyo_inicio,a.nombre;
END$$

DELIMITER ;
