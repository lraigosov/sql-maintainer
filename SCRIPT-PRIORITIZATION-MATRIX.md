# Matriz de Priorización de Scripts

Esta matriz ordena los scripts más relevantes del repositorio según dos ejes:

- **Criticidad operativa**: cuánto afecta el script a operación, mantenimiento o diagnóstico diario.
- **Riesgo funcional**: probabilidad de producir resultados incompletos, engañosos o costosos si su lógica no es correcta.

Se usa una escala simple: **Alta**, **Media**, **Baja**.

## Prioridad inmediata

| Prioridad | Script | Módulo | Criticidad operativa | Riesgo funcional | Estado | Motivo principal |
|---|---|---|---|---|---|---|
| P1 | daily-automation/PM Daily - Task_M7_V1 - Index Optimization Recommendations for User Tables.sql | Daily automation | Alta | Alta | Corregido | El join original podía inflar tamaños por índice y omitir índices sin uso. |
| P1 | dba-globals/SP - Maintenance Alerts.sql | DBA globals | Alta | Alta | Corregido | Podía sobreestimar riesgo de estadísticas, ignorar el contexto real de índices faltantes y resumir mal el uso de log. |
| P1 | daily-automation/PM Daily - Task_M6_V1 - Daily Query Times.sql | Daily automation | Alta | Media | Corregido | Filtraba por `creation_time`, no por ejecución del día, y calculaba tasa con división entera. |
| P1 | dba-globals/Identify Queries Impacting TEMPDB with HASH Operations.sql | DBA globals | Alta | Alta | Corregido | Cruzaba de forma incorrecta DMVs y no detectaba HASH de forma coherente con su propósito. |
| P1 | daily-automation/Setup-SQLAgentJobs.ps1 | Daily automation | Alta | Media | Corregido | Podía dejar schedules huérfanos y atar jobs al servidor local incluso en ejecuciones remotas. |

## Prioridad alta

| Prioridad | Script | Módulo | Criticidad operativa | Riesgo funcional | Estado | Motivo principal |
|---|---|---|---|---|---|---|
| P2 | daily-automation/PM Daily - Task_M2_V2 - Initial Rebuild.sql | Daily automation | Alta | Media | Corregido parcialmente | Se endureció la ejecución por índice con filtros, `QUOTENAME` y `TRY/CATCH`; falta validar costo operativo en staging. |
| P2 | daily-automation/PM Daily - Task_M4_V2 - Residual Rebuild.sql | Daily automation | Alta | Media | Corregido parcialmente | Se endureció la ejecución y continuidad ante fallos; sigue siendo clave validar la estrategia residual en ventana real. |
| P2 | dba-globals/Active Transactions and Blocking Details.sql | DBA globals | Alta | Media | Corregido parcialmente | Ya se eliminó el filtro fijo por base; aún conviene revisar formato, filtros opcionales y señalización de bloqueos críticos. |
| P2 | dba-globals/Top Missing Indexes by Estimated Impact.sql | DBA globals | Alta | Media | Corregido parcialmente | Ahora limita resultados a la base objetivo y genera scripts más seguros; aún requiere validación manual contra duplicados reales. |
| P2 | daily-automation/PM Daily - Task_M3_V2 - Initial Reorganize.sql | Daily automation | Media | Media | Pendiente de revisión profunda | Parte del flujo crítico; conviene revisar consistencia con M2/M4 y manejo de errores. |

## Prioridad media

| Prioridad | Script | Módulo | Criticidad operativa | Riesgo funcional | Estado | Motivo principal |
|---|---|---|---|---|---|---|
| P3 | daily-automation/PM Daily - Task_M1_V2 - Initial Review.sql | Daily automation | Media | Baja | No revisado a detalle | Su función es de línea base; el riesgo es menor, pero conviene validar exactitud de conteos. |
| P3 | daily-automation/PM Daily - Task_M5_V2 - Final Review.sql | Daily automation | Media | Baja | No revisado a detalle | Similar a M1; importante para comparación antes/después. |
| P3 | dba-globals/Top Server Waits and Most Impactful Queries.sql | DBA globals | Media | Baja | Corregido parcialmente | Se mejoró el filtrado de waits benignas y se ampliaron métricas de consultas; falta validar señal en staging. |
| P3 | dba-globals/Count Indexes by Fragmentation Level per Table.sql | DBA globals | Media | Baja | No revisado a detalle | Script descriptivo; conviene revisar precisión y costo en bases grandes. |
| P3 | dba-globals/Print Count of Medium and High Fragmented Indexes.sql | DBA globals | Media | Baja | No revisado a detalle | Bajo riesgo, pero depende de la misma lógica de fragmentación del módulo. |

## Criterio de priorización recomendado

1. Revisar primero lo que toma decisiones o dispara acciones operativas automáticas.
2. Después, revisar lo que sintetiza salud o genera recomendaciones para backlog técnico.
3. Finalmente, revisar scripts descriptivos o de inventario que tienen menor impacto directo.

## Siguiente lote sugerido para revisión profunda

1. daily-automation/PM Daily - Task_M2_V2 - Initial Rebuild.sql
2. daily-automation/PM Daily - Task_M4_V2 - Residual Rebuild.sql
3. dba-globals/Top Missing Indexes by Estimated Impact.sql
4. daily-automation/PM Daily - Task_M3_V2 - Initial Reorganize.sql