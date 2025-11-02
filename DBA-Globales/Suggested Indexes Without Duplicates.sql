-- Imprimir los índices sugeridos por el sistema evitando duplicados

DECLARE @threshold_table_rows INT = 1000,
        @threshold_table_updates INT = 10000;

WITH MissingIndexSubquery AS (
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
    LEFT JOIN sys.dm_db_index_usage_stats sus ON sus.index_id = 1
                                              AND sus.object_id = mid.object_id
                                              AND sus.database_id = mid.database_id
    WHERE mid.database_id = DB_ID()
        AND CONVERT(DECIMAL(28, 1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10
),
DuplicateIndexQuery AS (
    SELECT
        OBJECT_NAME([US].[object_id]) AS [Tabla],
        [IX].[name] AS [Nombre del Índice],
        [US].[last_user_update] AS [Última Actualización por Usuario],
        [US].[user_seeks] AS [Búsquedas por Usuario],
        [US].[user_scans] AS [Exploraciones por Usuario],
        [US].[user_lookups] AS [Búsquedas por Usuario Lookups], -- Cambié el nombre de la columna duplicada
        [US].[user_updates] AS [Actualizaciones por Usuario],
        [US].[last_user_seek] AS [Última Búsqueda por Usuario],
        [US].[last_user_scan] AS [Última Exploración por Usuario],
        [US].[last_user_lookup] AS [Última Búsqueda por Usuario Lookup], -- Cambié el nombre de la columna duplicada
        [TL].[Begin Time] AS [Hora de la Actualización]
    FROM sys.dm_db_index_usage_stats AS [US]
    INNER JOIN sys.indexes AS [IX] ON [US].[object_id] = [IX].[object_id] AND [US].[index_id] = [IX].[index_id]
    LEFT JOIN (
        SELECT [Transaction ID], [Begin Time]
        FROM fn_dblog(NULL, NULL)
        WHERE ([Operation] = 'LOP_INSERT_ROWS'
            OR [Operation] = 'LOP_MODIFY_ROW'
            OR [Operation] = 'LOP_DELETE_ROWS')
            AND ISDATE([Begin Time]) = 1
    ) AS [TL] ON [TL].[Transaction ID] = [US].[last_user_update]
    WHERE [database_id] = DB_ID()
)
SELECT
    DatabaseID AS NombreBD,
    improvement_measure AS Afectación,
    create_index_statement AS ScriptCrearÍndice,
    user_seeks AS BúsquedasUsuario,
    user_scans AS EscaneosUsuario,
    estimated_table_rows AS FilasEstimadasTabla,
    rows_updated AS FilasActualizadas
FROM MissingIndexSubquery
WHERE rows_updated < @threshold_table_updates
    AND estimated_table_rows > @threshold_table_rows
    AND NOT EXISTS (
        SELECT 1
        FROM DuplicateIndexQuery
        WHERE MissingIndexSubquery.DatabaseID = DuplicateIndexQuery.Tabla
            AND MissingIndexSubquery.create_index_statement LIKE '%' + DuplicateIndexQuery.[Nombre del Índice] + '%'
    )
ORDER BY improvement_measure DESC;
