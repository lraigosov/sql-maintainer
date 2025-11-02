-- Factores que hacen costosos a los índices faltantes más caros

SELECT TOP 10
    [Costo Total] = ROUND(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans), 0),
    avg_user_impact AS [Impacto Promedio del Usuario],
    statement AS [Nombre de la Tabla],
    [Uso de Igualdad] = equality_columns,
    [Uso de Desigualdad] = inequality_columns,
    [Columnas Incluidas] = included_columns,
    [Búsquedas de Usuario] = user_seeks,
    [Escaneos de Usuario] = user_scans,
    [Costo Total Promedio del Usuario] = avg_total_user_cost,
    [Script del Índice] = 
        'CREATE INDEX IX_' + REPLACE(REPLACE(OBJECT_NAME(mid.object_id), ' ', '') + '_' +
        REPLACE(REPLACE(COALESCE(REPLACE(mid.equality_columns, '[', ''), ''), ' ', ''), ',', '_') +
        REPLACE(REPLACE(COALESCE(REPLACE(mid.inequality_columns, '[', ''), ''), ' ', ''), ',', '_'),
        ']', '') + ' ON ' + mid.statement
        + ' (' + COALESCE(mid.equality_columns, '') + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + COALESCE(mid.inequality_columns, '')
        + ')' + COALESCE(' INCLUDE (' + mid.included_columns + ')', '') + ' WITH (FILLFACTOR = 80);'
FROM sys.dm_db_missing_index_groups AS g
INNER JOIN sys.dm_db_missing_index_group_stats AS s ON s.group_handle = g.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid ON mid.index_handle = g.index_handle
ORDER BY [Costo Total] DESC;