DECLARE @threshold_table_rows INT = 1000 , --> solo me interesan aquellas con algunas filas
    @threshold_table_updates INT = 10000;  --> a partir de estos cambios, se entiende que la tabla sufre muchas actualizaciones 

WITH subquery AS (
    SELECT
        DB_NAME(mid.database_id) AS DatabaseID,
        CONVERT(DECIMAL(28, 1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) AS improvement_measure,
        'CREATE INDEX IX_' + REPLACE(REPLACE(OBJECT_NAME(mid.object_id), ' ', '') + '_' +
        REPLACE(REPLACE(COALESCE(REPLACE(mid.equality_columns, '[', ''), ''), ' ', ''), ',', '_') +
        REPLACE(REPLACE(COALESCE(REPLACE(mid.inequality_columns, '[', ''), ''), ' ', ''), ',', '_'),
        ']', '') + ' ON ' + mid.statement
        + ' (' + COALESCE(mid.equality_columns, '') + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + COALESCE(mid.inequality_columns, '')
        + ')' + COALESCE(' INCLUDE (' + mid.included_columns + ')', '') + ' WITH (FILLFACTOR = 80);' AS create_index_statement,
        migs.user_seeks,
        migs.user_scans,
        ISNULL(CONVERT(INT,
            (
                SELECT SUM(rows)
                FROM sys.partitions s_p
                WHERE mid.object_id = s_p.object_id
                AND s_p.index_id = 1 -- cluster index
            )), 0) AS estimated_table_rows,
        sus.user_updates + sus.system_updates AS rows_updated
    FROM sys.dm_db_missing_index_groups mig
    INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
    LEFT JOIN sys.dm_db_index_usage_stats sus ON sus.index_id = 1 --> quiero solo el indice clustered
                                              AND sus.object_id = mid.object_id
                                              AND sus.database_id = mid.database_id
    WHERE mid.database_id = DB_ID()
        AND CONVERT(DECIMAL(28, 1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10
)
SELECT
DatabaseID as NombreBD,
improvement_measure as Afectación,
create_index_statement as ScriptCrearÍndice,
user_seeks as BúsquedasUsuario,
user_scans as EscaneosUsuario,
estimated_table_rows as FilasEstimadasTabla,
rows_updated as FilasActualizadas
FROM subquery
WHERE subquery.rows_updated < @threshold_table_updates
    AND subquery.estimated_table_rows > @threshold_table_rows
ORDER BY improvement_measure DESC;