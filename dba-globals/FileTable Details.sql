/*
Script: FileTable Details
Propósito: Listar FileTables en la base actual con fechas y esquema.
Entradas: Permisos de lectura.
Salidas: Nombre de FileTable, esquema, flags y fechas.
Catálogos: sys.tables (is_filetable = 1).
Seguridad/Impacto: Solo lectura.
Uso: Ejecutar en la base objetivo.
*/
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