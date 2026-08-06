# Checklist de Validación en Staging

Este checklist está pensado para validar en staging los scripts corregidos antes de promoverlos a producción. El objetivo es confirmar dos cosas:

- que la lógica corregida produce resultados consistentes;
- que el costo operativo es aceptable para la ventana de mantenimiento y el volumen del entorno.

## Alcance recomendado

Referencia complementaria de perfiles y parámetros:

- [Baselines operativos para staging](./staging-baselines/README.md)

Validar al menos estos scripts:

- daily-automation/Setup-SQLAgentJobs.ps1
- daily-automation/PM Daily - Task_M2_V2 - Initial Rebuild.sql
- daily-automation/PM Daily - Task_M4_V2 - Residual Rebuild.sql
- daily-automation/PM Daily - Task_M6_V1 - Daily Query Times.sql
- daily-automation/PM Daily - Task_M7_V1 - Index Optimization Recommendations for User Tables.sql
- dba-globals/Identify Queries Impacting TEMPDB with HASH Operations.sql
- dba-globals/Top Server Waits and Most Impactful Queries.sql
- dba-globals/Active Transactions and Blocking Details.sql
- dba-globals/SP - Maintenance Alerts.sql
- dba-globals/Top Missing Indexes by Estimated Impact.sql

## Prerrequisitos

1. Disponer de una base de staging con volumen y distribución de índices razonablemente parecidos a producción.
2. Confirmar permisos mínimos necesarios: `ALTER INDEX`, lectura de DMVs, acceso a `msdb` y Database Mail si aplica.
3. Habilitar captura de tiempos y errores durante la prueba.
4. Confirmar espacio suficiente en log, datos y TEMPDB.
5. Tener una ventana de prueba donde el impacto operativo sea observable.

## Validación general

1. Ejecutar todos los scripts primero en una copia controlada o en una base restaurada recientemente.
2. Registrar hora de inicio, duración total, errores y mensajes `PRINT` devueltos por cada script.
3. Comparar los resultados con una ejecución manual equivalente cuando aplique.
4. Confirmar que ningún script deja objetos duplicados, schedules huérfanos ni resultados imposibles.

## Baseline y ajuste por entorno

Para evitar duplicación de parámetros y mantener una única fuente de verdad:

1. Usa perfiles de baseline por entorno en `staging-baselines/M4-and-TopWaits-Profiles.md`.
2. Usa este checklist para validar ejecución, evidencia y criterios de aprobación.

## Validación de señal útil para Top Waits

Objetivo: confirmar que el filtrado de waits benignas reduce ruido sin ocultar cuellos de botella reales.

1. Comparar dos corridas en el mismo periodo: script actual vs snapshot completo de `sys.dm_os_wait_stats` sin exclusiones.
2. Verificar que los waits dominantes de problema real (por ejemplo `PAGEIOLATCH_*`, `CXPACKET`/`CXCONSUMER`, `LCK_*`, `WRITELOG`) siguen apareciendo cuando corresponda.
3. Confirmar que los waits excluidos son mayormente de background y no explican incidentes observados.
4. Si un wait relevante no aparece, reducir exclusiones de forma controlada y repetir comparación.

Métrica de control sugerida:

1. Al menos el 80% del tiempo de espera asociado a incidentes reportados debe estar representado en el resultado filtrado.
2. Las 5 consultas con mayor CPU del script deben mapear con eventos o tickets recientes de rendimiento.

## Validación por script

### 1. Setup-SQLAgentJobs.ps1

1. Ejecutar el script dos veces seguidas con los mismos parámetros.
2. Verificar que no se creen schedules duplicados ni jobs repetidos.
3. Confirmar que los jobs quedan asociados correctamente a la instancia de staging.
4. Validar que un `StartTime` inválido falla con mensaje claro.

### 2. Tarea_M2_V2 y Tarea_M4_V2

1. Preparar índices con fragmentación en distintos niveles y tamaños.
2. Verificar que solo se intentan reconstruir índices válidos, no deshabilitados ni hipotéticos.
3. Confirmar que un error en un índice no aborta toda la ejecución del procedimiento.
4. Revisar que `dbo.Mantto_Reconstruccion` solo registre reconstrucciones realmente ejecutadas con éxito.
5. Medir duración, crecimiento de log y bloqueos observados durante la prueba.

### 3. Tarea_M6_V1

1. Ejecutar consultas de prueba hoy y dejar al menos una consulta con plan antiguo creado días antes.
2. Confirmar que el script captura consultas ejecutadas hoy usando `last_execution_time`.
3. Validar que `Llamadas_por_Segundo` no se trunca por división entera.
4. Verificar que el texto capturado de la sentencia corresponde al fragmento correcto.

### 4. Tarea_M7_V1

1. Comparar el tamaño por índice contra una consulta manual a `sys.dm_db_partition_stats` filtrada por `object_id` e `index_id`.
2. Confirmar que aparecen índices sin uso aunque no tengan fila en `sys.dm_db_index_usage_stats`.
3. Revisar que la observación asignada coincide con las métricas del índice.
4. Verificar que no se insertan filas evidentemente duplicadas para el mismo índice en una ejecución individual.

### 5. Identify Queries Impacting TEMPDB with HASH Operations.sql

1. Lanzar una consulta controlada con `HASH JOIN` o evidencia clara de HASH.
2. Verificar que aparezca como solicitud activa en el resultado.
3. Confirmar que no se multiplican filas artificialmente por joins incorrectos.
4. Probar con `@TargetDatabase = NULL` y con una base específica.

### 6. Active Transactions and Blocking Details.sql

1. Generar al menos una transacción abierta y una sesión bloqueada en staging.
2. Confirmar que el script ya no depende de un `database_id` fijo.
3. Verificar que el filtro opcional por base funciona correctamente.
4. Comparar la información de sesión y transacción contra `sp_whoisactive` o una consulta manual equivalente si está disponible.

### 7. SP - Maintenance Alerts.sql

1. Ejecutar el procedimiento en una base con varios escenarios: sin tablas de usuario, con tablas modificadas y con varios archivos de log si aplica.
2. Confirmar que no falla por división entre cero cuando no hay objetos de usuario.
3. Verificar que el conteo de objetos con riesgo de estadísticas no sobrecuenta múltiples estadísticas del mismo objeto.
4. Confirmar que los índices sugeridos se calculan para la base actual y no para otras bases de la instancia.
5. Validar que el porcentaje de ocupación del log sea razonable cuando existen varios archivos de log.
6. Si se habilita correo, validar destinatarios, perfil y contenido del mensaje.

### 8. Top Missing Indexes by Estimated Impact.sql

1. Ejecutarlo en una base concreta y confirmar que solo devuelve recomendaciones de esa base.
2. Verificar que el nombre sugerido del índice no exceda 128 caracteres.
3. Revisar que el script generado usa `INCLUDE` solo cuando corresponde.
4. Validar manualmente al menos las 5 recomendaciones principales contra índices existentes, duplicidad y patrón real de consultas.

### 9. Top Server Waits and Most Impactful Queries.sql

1. Ejecutar el script en staging y confirmar que las esperas reportadas excluyen waits benignas de background.
2. Verificar que `wait_pct` sea coherente y no supere 100% en el conjunto total.
3. Validar que las consultas costosas incluyan base, métricas totales y promedio por ejecución.
4. Revisar que el texto de sentencia y el plan correspondan al mismo handle/fragmento esperado.

### 10. Calibración fina de M4

1. Probar tres escenarios de fragmentación y tamaño: menor al umbral, mayor al umbral con pocas páginas, y mayor al umbral con tamaño alto.
2. Confirmar que M4 solo reconstruye índices que cumplen ambos criterios (`fragmentación` y `page_count`).
3. Ajustar temporalmente `@ResidualMinFragmentationPercent` y `@ResidualMinPageCount` para verificar sensibilidad de la selección.
4. Medir impacto de duración, log y bloqueo comparando calibración por defecto versus calibración más agresiva.

## Criterios de aprobación antes de producción

1. Cero errores de ejecución no esperados en dos corridas consecutivas.
2. Resultados consistentes frente a consultas manuales de verificación.
3. Impacto de CPU, log, IO y bloqueo dentro de la ventana aceptable del entorno.
4. Ningún script genera resultados engañosos o estructuras duplicadas.
5. Validación funcional firmada por quien opera SQL Server en el entorno.

## Evidencia mínima a guardar

1. Resultado de ejecución o capturas de salida de cada script.
2. Métricas de tiempo total y observaciones de impacto.
3. Muestreo de filas insertadas en tablas de auditoría.
4. Lista de ajustes requeridos antes de producción, si los hubiera.