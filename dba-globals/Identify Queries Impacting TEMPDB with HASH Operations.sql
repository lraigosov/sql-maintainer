-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: Identify Queries Impacting TEMPDB with HASH Operations
Propósito: Detectar solicitudes activas que probablemente presionan TEMPDB por operaciones HASH y mostrar evidencia útil para diagnóstico.
Entradas: Permisos de lectura sobre DMVs. Opcionalmente permite filtrar por base de datos con @TargetDatabase.
Salidas: Top de solicitudes activas por tiempo transcurrido con texto de sentencia, lecturas, escrituras y evidencia de HASH.
DMVs: sys.dm_exec_requests, sys.dm_exec_sql_text, sys.dm_exec_query_plan.
Seguridad/Impacto: Solo lectura; usa READ UNCOMMITTED para reducir bloqueos durante el análisis.
Uso: Ajusta @TargetDatabase si deseas limitar el análisis a una base concreta; en NULL analiza todas las bases de usuario.
*/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @TargetDatabase SYSNAME = NULL;
DECLARE @TopN INT = 10;

SELECT TOP (@TopN)
    r.session_id AS SessionID,
    DB_NAME(r.database_id) AS DatabaseName,
    r.status AS Status,
    SUBSTRING(
        t.text,
        (r.statement_start_offset / 2) + 1,
        ((CASE r.statement_end_offset
            WHEN -1 THEN DATALENGTH(t.text)
            ELSE r.statement_end_offset
        END - r.statement_start_offset) / 2) + 1
    ) AS QueryText,
    r.start_time AS StartTime,
    r.total_elapsed_time AS ElapsedTimeMs,
    r.logical_reads AS LogicalReads,
    r.reads AS PhysicalReads,
    r.writes AS Writes,
    CASE r.transaction_isolation_level
        WHEN 0 THEN 'Unspecified'
        WHEN 1 THEN 'ReadUncommitted'
        WHEN 2 THEN 'ReadCommitted'
        WHEN 3 THEN 'RepeatableRead'
        WHEN 4 THEN 'Serializable'
        WHEN 5 THEN 'Snapshot'
        ELSE 'Unknown'
    END AS IsolationLevel,
    CASE
        WHEN qp.query_plan IS NOT NULL AND qp.query_plan.exist('//RelOp[@LogicalOp="Hash Match"]') = 1 THEN 'Plan'
        WHEN t.text LIKE '%HASH%' THEN 'Texto'
        ELSE 'No Detectado'
    END AS HashEvidence
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
WHERE r.session_id <> @@SPID
    AND r.database_id > 4
    AND t.text IS NOT NULL
    AND t.text NOT LIKE '%sys.dm%'
    AND t.text NOT LIKE '%dm_exec%'
    AND (@TargetDatabase IS NULL OR DB_NAME(r.database_id) = @TargetDatabase)
    AND (
        (qp.query_plan IS NOT NULL AND qp.query_plan.exist('//RelOp[@LogicalOp="Hash Match"]') = 1)
        OR t.text LIKE '%HASH%'
    )
ORDER BY r.total_elapsed_time DESC;
