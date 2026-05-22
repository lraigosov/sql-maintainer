-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
-- Configuración para mostrar información detallada
/*
Script: Top Server Waits and Most Impactful Queries
Propósito: Mostrar esperas relevantes del servidor y consultas con mayor consumo de CPU acumulada, incluyendo plan.
Entradas: Permisos de lectura sobre DMVs; ejecuta en el contexto del servidor.
Salidas: Dos conjuntos de resultados (esperas y consultas con plan XML).
DMVs: sys.dm_os_wait_stats, sys.dm_exec_query_stats, sys.dm_exec_sql_text, sys.dm_exec_query_plan.
Seguridad/Impacto: Solo lectura; usa READ UNCOMMITTED para evitar bloqueos (posibles lecturas sucias).
Uso: Ejecuta directamente en la instancia de interés.
*/
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @TopWaits INT = 10;
DECLARE @TopQueries INT = 5;

-- Obtener esperas significativas excluyendo waits benignas/comunes de background.
;WITH WaitStats AS (
    SELECT
        ws.wait_type,
        ws.waiting_tasks_count,
        ws.wait_time_ms,
        ws.signal_wait_time_ms,
        ws.wait_time_ms * 100.0 / NULLIF(SUM(ws.wait_time_ms) OVER (), 0) AS wait_pct
    FROM sys.dm_os_wait_stats AS ws
    WHERE ws.waiting_tasks_count > 0
        AND ws.wait_type NOT IN (
            'BROKER_EVENTHANDLER','BROKER_RECEIVE_WAITFOR','BROKER_TASK_STOP','BROKER_TO_FLUSH','BROKER_TRANSMITTER',
            'CHECKPOINT_QUEUE','CHKPT','CLR_AUTO_EVENT','CLR_MANUAL_EVENT','CLR_SEMAPHORE',
            'DBMIRROR_DBM_EVENT','DBMIRROR_EVENTS_QUEUE','DBMIRROR_WORKER_QUEUE','DBMIRRORING_CMD',
            'DIRTY_PAGE_POLL','DISPATCHER_QUEUE_SEMAPHORE','EXECSYNC','FSAGENT',
            'FT_IFTS_SCHEDULER_IDLE_WAIT','FT_IFTSHC_MUTEX','HADR_CLUSAPI_CALL','HADR_FILESTREAM_IOMGR_IOCOMPLETION',
            'HADR_LOGCAPTURE_WAIT','HADR_NOTIFICATION_DEQUEUE','HADR_TIMER_TASK','HADR_WORK_QUEUE',
            'KSOURCE_WAKEUP','LAZYWRITER_SLEEP','LOGMGR_QUEUE','MEMORY_ALLOCATION_EXT','ONDEMAND_TASK_QUEUE',
            'PARALLEL_REDO_DRAIN_WORKER','PARALLEL_REDO_LOG_CACHE','PARALLEL_REDO_TRAN_LIST','PARALLEL_REDO_WORKER_SYNC',
            'PARALLEL_REDO_WORKER_WAIT_WORK','PREEMPTIVE_OS_FLUSHFILEBUFFERS','PREEMPTIVE_XE_GETTARGETSTATE',
            'PVS_PREALLOCATE','PWAIT_ALL_COMPONENTS_INITIALIZED','PWAIT_DIRECTLOGCONSUMER_GETNEXT','PWAIT_EXTENSIBILITY_CLEANUP_TASK',
            'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP','QDS_ASYNC_QUEUE','QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
            'QDS_SHUTDOWN_QUEUE','REDO_THREAD_PENDING_WORK','REQUEST_FOR_DEADLOCK_SEARCH',
            'RESOURCE_QUEUE','SERVER_IDLE_CHECK','SLEEP_BPOOL_FLUSH','SLEEP_DBSTARTUP','SLEEP_DCOMSTARTUP',
            'SLEEP_MASTERDBREADY','SLEEP_MASTERMDREADY','SLEEP_MASTERUPGRADED','SLEEP_MSDBSTARTUP',
            'SLEEP_SYSTEMTASK','SLEEP_TASK','SLEEP_TEMPDBSTARTUP','SNI_HTTP_ACCEPT','SOS_WORK_DISPATCHER',
            'SP_SERVER_DIAGNOSTICS_SLEEP','SQLTRACE_BUFFER_FLUSH','SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
            'SQLTRACE_WAIT_ENTRIES','WAIT_FOR_RESULTS','WAITFOR','WAITFOR_TASKSHUTDOWN','WAIT_XTP_RECOVERY',
            'WAIT_XTP_HOST_WAIT','WAIT_XTP_OFFLINE_CKPT_NEW_LOG','WAIT_XTP_CKPT_CLOSE','XE_DISPATCHER_JOIN',
            'XE_DISPATCHER_WAIT','XE_TIMER_EVENT'
        )
)
SELECT TOP (@TopWaits)
    wait_type,
    waiting_tasks_count,
    wait_time_ms / 1000.0 AS wait_time_sec,
    signal_wait_time_ms / 1000.0 AS signal_wait_time_sec,
    wait_pct,
    wait_time_ms * 1.0 / NULLIF(waiting_tasks_count, 0) AS avg_wait_time_ms
FROM WaitStats
ORDER BY wait_time_ms DESC;

-- Obtener consultas más costosas por CPU acumulada con métricas promedio por ejecución.
;WITH TopQueryHandles AS (
    SELECT TOP (@TopQueries)
        qs.query_hash,
        qs.sql_handle,
        qs.plan_handle,
        qs.statement_start_offset,
        qs.statement_end_offset,
        qs.total_worker_time,
        qs.total_elapsed_time,
        qs.execution_count,
        qs.total_logical_reads,
        qs.total_logical_writes,
        qs.last_execution_time
    FROM sys.dm_exec_query_stats AS qs
    ORDER BY qs.total_worker_time DESC
)
SELECT
    tq.query_hash,
    DB_NAME(txt.dbid) AS database_name,
    tq.total_worker_time / 1000.0 AS total_worker_time_ms,
    tq.total_elapsed_time / 1000.0 AS total_elapsed_time_ms,
    tq.execution_count,
    tq.total_logical_reads,
    tq.total_logical_writes,
    tq.last_execution_time,
    (tq.total_worker_time * 1.0 / NULLIF(tq.execution_count, 0)) / 1000.0 AS avg_worker_time_ms,
    (tq.total_elapsed_time * 1.0 / NULLIF(tq.execution_count, 0)) / 1000.0 AS avg_elapsed_time_ms,
    SUBSTRING(
        txt.text,
        (tq.statement_start_offset / 2) + 1,
        ((CASE tq.statement_end_offset
            WHEN -1 THEN DATALENGTH(txt.text)
            ELSE tq.statement_end_offset
        END - tq.statement_start_offset) / 2) + 1
    ) AS statement_text,
    qp.query_plan
FROM TopQueryHandles AS tq
CROSS APPLY sys.dm_exec_sql_text(tq.sql_handle) AS txt
OUTER APPLY sys.dm_exec_query_plan(tq.plan_handle) AS qp
WHERE txt.text IS NOT NULL
    AND txt.text NOT LIKE '%sys.dm_exec_query_stats%'
ORDER BY tq.total_worker_time DESC;