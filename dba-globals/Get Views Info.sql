/*
Script: Get Views Info
Propósito: Listar vistas con esquema y definición.
Entradas: Permisos de lectura.
Salidas: Nombre de vista, esquema y definición.
Catálogo: INFORMATION_SCHEMA.VIEWS.
Seguridad/Impacto: Solo lectura.
Uso: Ejecutar en la base objetivo.
*/
-- Obtener información sobre vistas
SELECT 
    TABLE_NAME AS 'NombreVista',
    TABLE_SCHEMA AS 'EsquemaVista',
    VIEW_DEFINITION AS 'DefinicionVista'
FROM 
    INFORMATION_SCHEMA.VIEWS
ORDER BY 
    TABLE_NAME;
