# Base de Datos Universidad - MySQL

Proyecto realizado en **MySQL** a partir del PDF de la actividad de funciones, procedimientos y triggers y de la estructura original de `universidad.sql`.

## Archivos

- `universidad.sql`: archivo original de la base de datos.
- `01_base_datos.sql`: base completa preparada para la actividad; incluye matrícula, calificaciones e historial.
- `02_funciones.sql`: 5 funciones MySQL.
- `03_procedimientos.sql`: 5 procedimientos almacenados.
- `04_triggers.sql`: 5 triggers.
- `05_pruebas.sql`: consultas y llamadas para comprobar el funcionamiento.
- `Actividad_Completa_MySQL.sql`: todos los scripts anteriores unidos en un único archivo para MySQL Workbench.

## Funciones

1. `fnc_calcular_nota_final`
2. `fnc_obtener_estado_academico`
3. `fnc_total_creditos`
4. `fnc_promedio_asignatura`
5. `fnc_asignaturas_aprobadas`

## Procedimientos

1. `sp_guardar_calificacion`
2. `sp_generar_acta_curso`
3. `sp_matricular_alumno`
4. `sp_reasignar_docente`
5. `sp_reporte_historico_estudiante`

## Triggers

- Validación de notas al insertar.
- Validación de notas al actualizar.
- Conversión de trabajo práctico 0 a NULL.
- Registro automático de fecha.
- Auditoría de cambios de calificaciones.
- Prevención de matrículas duplicadas.

## Ejecución en MySQL Workbench

### Opción 1: todo en un archivo

Abrir `Actividad_Completa_MySQL.sql` y ejecutar con el botón del rayo.

### Opción 2: por archivos

Ejecutar en este orden:

1. `01_base_datos.sql`
2. `02_funciones.sql`
3. `03_procedimientos.sql`
4. `04_triggers.sql`
5. `05_pruebas.sql`

La base queda creada como `universidad`.
