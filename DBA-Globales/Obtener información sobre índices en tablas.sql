-- Obtener información sobre índices en tablas
SELECT 
    t.name AS 'NombreTabla',
    i.name AS 'NombreIndice',
    c.name AS 'NombreColumna',
    i.type_desc AS 'TipoIndice'
FROM 
    sys.tables t
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
ORDER BY 
    t.name, i.name, ic.key_ordinal;
