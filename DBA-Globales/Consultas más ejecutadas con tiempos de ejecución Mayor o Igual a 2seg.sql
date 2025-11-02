-- Consultas más ejecutadas con tiempos de ejecución >= 2seg - Incluye Plan de ejecución y última fecha de ejecución
SELECT
    qs.creation_time as UltimaFechaEjecucion,
    qs.execution_count as NEjecuciones,
    (qs.total_worker_time / 60000) as tiempo_total_ejecución_minutos,
    (qs.total_worker_time / 1000 / qs.execution_count) as tiempo_medio_ejecución_SegundosporConsulta,
    SUBSTRING(qt.text, qs.statement_start_offset / 2,
              (CASE WHEN qs.statement_end_offset = -1
                    THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
                    ELSE qs.statement_end_offset END - qs.statement_start_offset) / 2) as Consulta,
    qt.dbid,
    NombreBD = DB_NAME(qt.dbid),
    qt.objectid as IDObjecto,
    qp.query_plan
FROM
    sys.dm_exec_query_stats qs
CROSS APPLY
    sys.dm_exec_sql_text(qs.sql_handle) as qt
CROSS APPLY
    sys.dm_exec_query_plan(qs.plan_handle) as qp
WHERE
    DB_NAME(qt.dbid) NOT IN ('master', 'model', 'msdb', 'tempdb', 'AdminSQL')
    AND (qs.total_worker_time / 1000 / qs.execution_count) >= 2
    AND qs.execution_count > 1000
ORDER BY
    (qs.total_worker_time / 1000 / qs.execution_count) DESC
