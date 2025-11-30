-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: Identify Queries Impacting TEMPDB with HASH Operations
Propósito: Detectar consultas activas con operaciones que impactan tempdb (p. ej., HASH) y métricas de IO/tiempo.
Entradas: Permisos de lectura sobre DMVs. Filtro actual por DB_NAME(r.database_id) = 'BDPRINCIPAL'.
Salidas: Top por tiempo transcurrido con texto, tiempos y lecturas/escrituras.
DMVs: sys.dm_exec_requests, sys.dm_exec_sql_text, sys.dm_exec_query_stats.
Seguridad/Impacto: Solo lectura; puede incluir lecturas sucias si se ajusta el aislamiento.
Uso: Ejecutar en la instancia; adaptar filtro de base de datos o patrones según necesidad.
*/
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
