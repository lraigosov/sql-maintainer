/*
Script: View Blocking Processes
Propósito: Identificar pares de sesiones bloqueadoras/bloqueadas y sus consultas asociadas, con duración de espera.
Entradas: Permisos de lectura sobre DMVs.
Salidas: Lista de sesiones bloqueadoras y bloqueadas, texto SQL y duración (ms).
DMVs: sys.dm_tran_locks, sys.dm_os_waiting_tasks, sys.dm_exec_requests, sys.dm_exec_sql_text.
Seguridad/Impacto: Solo lectura; sin cambios. Puede mostrar texto de consultas activas.
Uso: Ejecutar cuando se sospechen bloqueos. Opcional: filtrar por base de datos o sesión.
*/
/*
Script: View Blocking Processes
Propósito: Identificar sesiones bloqueadoras y bloqueadas con consultas y duración de bloqueo.
Entradas: Permisos de lectura en DMVs.
Salidas: Sesión bloqueadora, bloqueada, consulta y duración en ms.
DMVs: sys.dm_tran_locks, sys.dm_os_waiting_tasks, sys.dm_exec_requests, sys.dm_exec_sql_text.
Seguridad/Impacto: Solo lectura; puede mostrar texto de consultas.
Uso: Ejecutar en la instancia para diagnosticar bloqueos activos.
*/
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