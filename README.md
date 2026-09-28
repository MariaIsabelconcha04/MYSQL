# Base de Datos Universidad

Proyecto de MySQL realizado a partir del PDF **Funciones, Procedimientos y Triggers**.

## Archivo principal

- `universidad.sql`: crea la base de datos `universidad`, sus tablas, datos de prueba, 5 funciones, 5 procedimientos almacenados y 5 triggers.

## Contenido

### Funciones
1. `fnc_calcular_nota_final`
2. `fnc_obtener_estado_academico`
3. `fnc_total_creditos`
4. `fnc_promedio_asignatura`
5. `fnc_asignaturas_aprobadas`

### Procedimientos
1. `sp_guardar_calificacion`
2. `sp_generar_acta_curso`
3. `sp_matricular_alumno`
4. `sp_reasignar_docente`
5. `sp_reporte_historico_estudiante`

### Triggers
1. `trg_calificaciones_before_insert`: normaliza el trabajo práctico en 0 a NULL y valida el rango de notas.
2. `trg_calificaciones_before_update`: normaliza el trabajo práctico en 0 a NULL y valida el rango de notas.
3. `trg_auditoria_calificacion`: registra cambios de notas.
4. `trg_prevenir_matricula_duplicada`: evita matrículas activas duplicadas.
5. `trg_fecha_registro_calificacion`: asigna la fecha actual cuando llega NULL.

> En MySQL, un trigger no puede atender simultáneamente INSERT y UPDATE. Por eso la normalización/validación del ejercicio correspondiente se implementa mediante dos triggers por evento, manteniendo cinco triggers como ejercicios funcionales del PDF.

## Cómo ejecutarlo

1. Abrir MySQL Workbench.
2. Abrir el archivo `universidad.sql`.
3. Ejecutar el script completo con el botón del rayo.
4. Actualizar **Schemas**.
5. Seleccionar la base de datos `universidad`.

El script incluye datos de prueba y consultas de verificación al final.
