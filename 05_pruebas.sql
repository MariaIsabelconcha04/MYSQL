USE universidad;

-- ============================================================
-- PRUEBAS DE FUNCIONES
-- ============================================================
SELECT fnc_calcular_nota_final(1) AS nota_final_matricula_1;
SELECT fnc_obtener_estado_academico(1) AS estado_matricula_1;
SELECT fnc_total_creditos(1,1) AS creditos_alumno_1_curso_1;
SELECT fnc_promedio_asignatura(1) AS promedio_asignatura_1;
SELECT fnc_asignaturas_aprobadas(1) AS asignaturas_aprobadas_alumno_1;

-- ============================================================
-- PRUEBAS DE PROCEDIMIENTOS
-- ============================================================
CALL sp_generar_acta_curso(1,1);
CALL sp_reporte_historico_estudiante(1);

-- Actualiza una calificación existente y genera un registro de auditoría.
CALL sp_guardar_calificacion(1,4.50,4.00,4.50,NULL);
SELECT * FROM historial_calificaciones ORDER BY id_historial DESC LIMIT 1;

-- Para probar una matrícula duplicada, descomenta la siguiente línea.
-- CALL sp_matricular_alumno(1,1,1);

-- Para probar la reasignación, usa un profesor válido del departamento.
-- CALL sp_reasignar_docente(1,1,14);

-- ============================================================
-- PRUEBAS DE TRIGGERS
-- ============================================================
-- trabajo_practico = 0 se transforma automáticamente en NULL:
-- CALL sp_guardar_calificacion(2,4.00,4.00,4.00,0);
-- SELECT * FROM calificaciones WHERE id_matricula=2;

-- Una nota fuera del rango 0-5 debe generar error:
-- CALL sp_guardar_calificacion(3,6.00,4.00,4.00,NULL);
