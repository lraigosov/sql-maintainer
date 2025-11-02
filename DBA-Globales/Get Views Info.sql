-- Obtener información sobre vistas
SELECT 
    TABLE_NAME AS 'NombreVista',
    TABLE_SCHEMA AS 'EsquemaVista',
    VIEW_DEFINITION AS 'DefinicionVista'
FROM 
    INFORMATION_SCHEMA.VIEWS
ORDER BY 
    TABLE_NAME;
