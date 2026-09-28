# Base de Datos Universidad

Proyecto de MySQL basado en el ejercicio del PDF **Funciones, Procedimientos y Triggers** y adaptado a la estructura original de `universidad.sql`.

## Archivo principal

- `universidad.sql`: crea la base de datos `universidad`, conserva sus tablas y datos originales y agrega las tablas de calificaciones/auditoría, funciones, procedimientos, triggers y pruebas.

## Funciones

1. `fnc_calcular_nota_final(id_matricula)`
2. `fnc_obtener_estado_academico(id_matricula)`
3. `fnc_total_creditos(id_alumno, id_curso_escolar)`
4. `fnc_promedio_asignatura(id_asignatura)`
5. `fnc_asignaturas_aprobadas(id_alumno)`

## Procedimientos almacenados

1. `sp_guardar_calificacion`
2. `sp_generar_acta_curso`
3. `sp_matricular_alumno`
4. `sp_reasignar_docente`
5. `sp_reporte_historico_estudiante`

## Triggers

- Normalización y validación de notas al insertar.
- Normalización y validación de notas al actualizar.
- Auditoría de modificaciones de notas.
- Prevención de matrículas duplicadas.
- Asignación automática de `fecha_registro` al insertar calificaciones.

## Ejecutar en MySQL Workbench

1. Abrir **MySQL Workbench**.
2. Abrir `universidad.sql`.
3. Ejecutar el script completo con el botón del rayo.
4. Actualizar **Schemas**.
5. Abrir el esquema `universidad`.
6. Revisar **Tables**, **Functions**, **Stored Procedures** y **Triggers**.

El archivo incluye consultas de prueba al final para comprobar las funciones, procedimientos y auditoría.

## Nota

El PDF solicita eventos INSERT/UPDATE para algunos ejercicios de triggers. En MySQL se implementan mediante triggers separados por evento cuando es necesario, manteniendo la funcionalidad solicitada.