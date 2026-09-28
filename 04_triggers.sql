USE universidad;

DELIMITER $$

CREATE TRIGGER trg_calificaciones_before_insert
BEFORE INSERT ON calificaciones FOR EACH ROW
BEGIN
    IF NEW.trabajo_practico=0 THEN SET NEW.trabajo_practico=NULL; END IF;
    IF NEW.parcial1<0 OR NEW.parcial1>5 OR NEW.parcial2<0 OR NEW.parcial2>5
       OR NEW.parcial_final<0 OR NEW.parcial_final>5
       OR (NEW.trabajo_practico IS NOT NULL AND (NEW.trabajo_practico<0 OR NEW.trabajo_practico>5)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las notas deben estar entre 0.00 y 5.00.';
    END IF;
END$

CREATE TRIGGER trg_calificaciones_before_update
BEFORE UPDATE ON calificaciones FOR EACH ROW
BEGIN
    IF NEW.trabajo_practico=0 THEN SET NEW.trabajo_practico=NULL; END IF;
    IF NEW.parcial1<0 OR NEW.parcial1>5 OR NEW.parcial2<0 OR NEW.parcial2>5
       OR NEW.parcial_final<0 OR NEW.parcial_final>5
       OR (NEW.trabajo_practico IS NOT NULL AND (NEW.trabajo_practico<0 OR NEW.trabajo_practico>5)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las notas deben estar entre 0.00 y 5.00.';
    END IF;
END$

CREATE TRIGGER trg_fecha_registro_calificacion
BEFORE INSERT ON calificaciones FOR EACH ROW
BEGIN
    IF NEW.fecha_registro IS NULL THEN SET NEW.fecha_registro=NOW(); END IF;
END$

CREATE TRIGGER trg_auditoria_calificacion
AFTER UPDATE ON calificaciones FOR EACH ROW
BEGIN
    IF NOT(OLD.parcial1<=>NEW.parcial1) OR NOT(OLD.parcial2<=>NEW.parcial2)
       OR NOT(OLD.parcial_final<=>NEW.parcial_final)
       OR NOT(OLD.trabajo_practico<=>NEW.trabajo_practico) THEN
        INSERT INTO historial_calificaciones(id_calificacion,nota_anterior,nota_nueva,fecha_cambio)
        VALUES(
          NEW.id_calificacion,
          CASE WHEN OLD.trabajo_practico IS NULL THEN ROUND(OLD.parcial1*.20+OLD.parcial2*.35+OLD.parcial_final*.45,2)
               ELSE ROUND(OLD.parcial1*.20+OLD.parcial2*.35+OLD.parcial_final*.35+OLD.trabajo_practico*.10,2) END,
          CASE WHEN NEW.trabajo_practico IS NULL THEN ROUND(NEW.parcial1*.20+NEW.parcial2*.35+NEW.parcial_final*.45,2)
               ELSE ROUND(NEW.parcial1*.20+NEW.parcial2*.35+NEW.parcial_final*.35+NEW.trabajo_practico*.10,2) END,
          NOW()
        );
    END IF;
END$$

CREATE TRIGGER trg_prevenir_matricula_duplicada
BEFORE INSERT ON alumno_se_matricula_asignatura FOR EACH ROW
BEGIN
    IF EXISTS(SELECT 1 FROM alumno_se_matricula_asignatura
              WHERE id_alumno=NEW.id_alumno AND id_asignatura=NEW.id_asignatura
                AND id_curso_escolar=NEW.id_curso_escolar) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El alumno ya está matriculado en esa asignatura y curso escolar.';
    END IF;
END$$

DELIMITER ;

DELIMITER ;
