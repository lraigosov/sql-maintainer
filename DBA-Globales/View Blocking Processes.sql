-- Procesos de bloqueo
WITH LockingRequests AS (
    SELECT
        tl.request_session_id AS [Sesión Bloqueadora],
        wtl.blocking_session_id AS [Sesión Bloqueada],
        r1.text AS [Consulta Bloqueadora],
        r2.text AS [Consulta Bloqueada],
        wt.wait_duration_ms AS [Duración de Bloqueo (ms)]
    FROM sys.dm_tran_locks AS tl
    INNER JOIN sys.dm_os_waiting_tasks AS wt
        ON tl.lock_owner_address = wt.resource_address
    INNER JOIN sys.dm_exec_requests AS wtl
        ON wt.waiting_task_address = wtl.task_address
    CROSS APPLY sys.dm_exec_sql_text(wtl.sql_handle) AS r1
    CROSS APPLY sys.dm_exec_sql_text(wtl.sql_handle) AS r2
)
SELECT * FROM LockingRequests;