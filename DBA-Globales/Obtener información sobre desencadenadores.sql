-- Obtener información sobre desencadenadores

SELECT
    name AS 'NombreDesencadenador',
    OBJECT_SCHEMA_NAME(object_id) AS 'EsquemaTabla',
    OBJECT_NAME(parent_id) AS 'NombreTabla',
    create_date AS 'FechaCreacion',
    modify_date AS 'FechaEdicion'
FROM sys.triggers
ORDER BY name;