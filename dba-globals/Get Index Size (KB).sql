-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: Get Index Size (KB)
Propósito: Calcular tamaño aproximado por índice en KB usando dm_db_partition_stats.
Entradas: Permisos de lectura.
Salidas: Tabla, índice y tamaño en KB.
DMVs/Catálogos: sys.dm_db_partition_stats, sys.indexes, sys.tables.
Seguridad/Impacto: Solo lectura.
Uso: Ejecutar en la base objetivo; excluye objetos del sistema.
*/
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
