-- Consulta para identificar consultas que afectan la TEMPDB con operaciones de HASH
SELECT TOP 10
    r.session_id AS SessionID,
    DB_NAME(r.database_id) AS DatabaseName,
    r.status AS Status,
    t.text AS QueryText,
    s.creation_time AS StartTime,
    r.total_elapsed_time AS ElapsedTime,
    r.logical_reads AS LogicalReads,
    r.reads AS PhysicalReads,
    r.writes AS Writes,
    r.transaction_isolation_level AS IsolationLevel
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
CROSS APPLY sys.dm_exec_query_stats s
WHERE t.text IS NOT NULL
    AND t.text NOT LIKE '%sys.dm%'
    AND t.text NOT LIKE '%dm_exec%'
    AND t.text NOT LIKE '%tempdb%'
	AND  DB_NAME(r.database_id) = 'BDPRINCIPAL'
ORDER BY r.total_elapsed_time DESC;
