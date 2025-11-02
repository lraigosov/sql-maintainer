-- Contar el número de índices con diferentes niveles de defragmentación en cada tabla
WITH FragmentedIndexes AS (
    SELECT DISTINCT
        DB_NAME() AS DatabaseName,
        SCHEMA_NAME(tab.[schema_id]) AS SchemaName,
        tab.name AS TableName,
        ind.name AS IndexName,
        ps.avg_fragmentation_in_percent AS FragmentationPercentage
    FROM
        sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) ps
    INNER JOIN
        sys.databases dbs ON ps.database_id = dbs.database_id
    INNER JOIN
        sys.indexes ind ON ps.object_id = ind.object_id
    INNER JOIN
        sys.tables tab ON tab.object_id = ind.object_id
    WHERE
        ind.name IS NOT NULL
        AND ps.index_id = ind.index_id
        AND ps.avg_fragmentation_in_percent > 10 -- Cambio en el filtro de fragmentación
)
SELECT
    SchemaName AS [Esquema Tabla],
    TableName AS [Nombre Tabla],
	SUM(CASE 
            WHEN FragmentationPercentage <= 30 AND FragmentationPercentage > 10 THEN 1
            ELSE 0
        END) AS [Indices Fragmentación Media 10 < X <= 30%],
    SUM(CASE 
            WHEN FragmentationPercentage > 30 THEN 1
            ELSE 0
        END) AS [Indices Fragmentación Alta X > 30%],
    COUNT(*) AS [Total de Indices con Fragmentación Media y Alta > 10%]
FROM
    FragmentedIndexes
GROUP BY
    SchemaName,
    TableName
ORDER BY
    SchemaName,
    TableName;
