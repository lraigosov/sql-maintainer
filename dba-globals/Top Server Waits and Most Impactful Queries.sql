-- Configuración para mostrar información detallada
/*
Script: Top Server Waits and Most Impactful Queries
Propósito: Mostrar las 3 esperas más significativas del servidor y las 2 consultas con mayor consumo de CPU acumulada, incluyendo plan.
Entradas: Permisos de lectura sobre DMVs; ejecuta en el contexto del servidor.
Salidas: Dos conjuntos de resultados (esperas y consultas con plan XML).
DMVs: sys.dm_os_wait_stats, sys.dm_exec_query_stats, sys.dm_exec_sql_text, sys.dm_exec_query_plan.
Seguridad/Impacto: Solo lectura; usa READ UNCOMMITTED para evitar bloqueos (posibles lecturas sucias).
Uso: Ejecuta directamente en la instancia de interés.
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Obtener información sobre las esperas
WITH TopWaitStats AS (
    SELECT
        wait_type,
        waiting_tasks_count,
        wait_time_ms / 1000.0 AS wait_time_sec,
        (wait_time_ms / waiting_tasks_count) / 1000.0 AS avg_wait_time_sec,
        ROW_NUMBER() OVER (ORDER BY wait_time_ms DESC) AS row_num
    FROM
        sys.dm_os_wait_stats
    WHERE
        waiting_tasks_count > 0
)
SELECT
    wait_type,
    waiting_tasks_count,
    wait_time_sec,
    avg_wait_time_sec
FROM
    TopWaitStats
WHERE
    row_num <= 3
ORDER BY
    row_num;

-- Obtener información sobre las consultas que causan esperas
WITH TopQueries AS (
    SELECT
        query_stats.query_hash,
        query_stats.total_worker_time / 1000.0 AS total_worker_time_sec,
        query_stats.execution_count,
        query_stats.total_logical_reads,
        query_stats.total_logical_writes,
        SUBSTRING(
            text.text,
            (query_stats.statement_start_offset / 2) + 1,
            (
                (CASE query_stats.statement_end_offset
                    WHEN -1 THEN DATALENGTH(text.text)
                    ELSE query_stats.statement_end_offset
                END - query_stats.statement_start_offset) / 2
            ) + 1
        ) AS statement_text,
        query_plan.query_plan,
        ROW_NUMBER() OVER (ORDER BY query_stats.total_worker_time DESC) AS row_num
    FROM
        sys.dm_exec_query_stats AS query_stats
        CROSS APPLY sys.dm_exec_sql_text(query_stats.sql_handle) AS text
        CROSS APPLY sys.dm_exec_query_plan(query_stats.plan_handle) AS query_plan
)
SELECT
    query_hash,
    total_worker_time_sec,
    execution_count,
    total_logical_reads,
    total_logical_writes,
    statement_text,
    query_plan
FROM
    TopQueries
WHERE
    row_num <= 2
ORDER BY
    row_num;