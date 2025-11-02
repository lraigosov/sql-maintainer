-- Obtener tamaño de índices
SELECT 
    t.name AS 'NombreTabla',
    i.name AS 'NombreIndice',
    SUM(s.used_page_count) * 8 AS 'TamañoKB'
FROM 
    sys.indexes i
    INNER JOIN sys.tables t ON i.object_id = t.object_id
    INNER JOIN sys.dm_db_partition_stats s ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE 
    t.is_ms_shipped = 0
    AND i.object_id > 255 -- Filtrar índices del sistema
GROUP BY 
    t.name, i.name
ORDER BY 
    t.name, i.name;
