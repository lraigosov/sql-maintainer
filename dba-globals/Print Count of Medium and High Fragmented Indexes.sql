/*
Script: Print Count of Medium and High Fragmented Indexes
Propósito: Calcular y mostrar con PRINT el número de índices con fragmentación media (10<%<=30) y alta (>30) en la base actual.
Entradas: Permisos de lectura; umbrales ajustables.
Salidas: Mensajes PRINT con conteos por categoría.
DMVs: sys.dm_db_index_physical_stats, sys.indexes, sys.tables, sys.databases.
Seguridad/Impacto: Solo lectura.
Uso: Ejecutar en la base objetivo; útil para monitorización rápida o agentes.
*/
-- Declarar variables para almacenar los resultados
DECLARE @IndicesFragmentacionMedia INT
DECLARE @IndicesFragmentacionAlta INT

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
    @IndicesFragmentacionMedia = SUM(CASE 
            WHEN FragmentationPercentage <= 30 AND FragmentationPercentage > 10 THEN 1
            ELSE 0
        END),
    @IndicesFragmentacionAlta = SUM(CASE 
            WHEN FragmentationPercentage > 30 THEN 1
            ELSE 0
        END)
FROM
    FragmentedIndexes

-- Mostrar mensajes PRINT con los valores
PRINT 'Número de índices con fragmentación media (10 < X <= 30%): ' + CAST(@IndicesFragmentacionMedia AS NVARCHAR(10))
PRINT 'Número de índices con fragmentación alta (X > 30%): ' + CAST(@IndicesFragmentacionAlta AS NVARCHAR(10))