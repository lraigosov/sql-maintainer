-- Detalles de las FileTables
SELECT 
    FT.name AS 'NombreFileTable',
    SCHEMA_NAME(FT.schema_id) AS 'EsquemaFileTable',
    FT.is_filetable AS 'EsFileTable',
    FT.create_date AS 'FechaCreacion',
    FT.modify_date AS 'FechaUltimaModificacion'
FROM 
    sys.tables FT
WHERE 
    FT.is_filetable = 1
ORDER BY 
    FT.name;