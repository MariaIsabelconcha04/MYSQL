USE universidad;

-- ============================================================
-- PRUEBAS
-- ============================================================
CALL sp_guardar_calificacion(1,4.00,3.50,4.20,4.50);
CALL sp_guardar_calificacion(2,3.00,3.20,3.50,0);
CALL sp_guardar_calificacion(3,4.50,4.00,4.80,4.70);

SELECT fnc_calcular_nota_final(1) AS nota_final;
SELECT fnc_obtener_estado_academico(1) AS estado_academico;
SELECT fnc_total_creditos(1,1) AS total_creditos;
SELECT fnc_promedio_asignatura(1) AS promedio_asignatura;
SELECT fnc_asignaturas_aprobadas(1) AS asignaturas_aprobadas;

CALL sp_generar_acta_curso(1,1);
CALL sp_reporte_historico_estudiante(1);

UPDATE calificaciones SET parcial1=4.50 WHERE id_matricula=1;
SELECT * FROM historial_calificaciones;

SHOW TABLES;
SHOW FUNCTION STATUS WHERE Db='universidad';
SHOW PROCEDURE STATUS WHERE Db='universidad';
SHOW TRIGGERS FROM universidad;
SELECT * FROM calificaciones;
SELECT * FROM historial_calificaciones;
