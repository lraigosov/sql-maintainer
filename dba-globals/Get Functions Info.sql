/*
Script: Get Functions Info
Propósito: Listar funciones definidas por el usuario con esquema y fecha de creación.
Entradas: Permisos de lectura.
Salidas: Nombre, esquema y fecha de creación.
Catálogo: INFORMATION_SCHEMA.ROUTINES (filtrado por FUNCTION).
Seguridad/Impacto: Solo lectura.
Uso: Ejecutar en la base objetivo.
*/
-- Obtener información sobre funciones
SELECT 
    ROUTINE_NAME AS 'NombreFuncion',
    ROUTINE_SCHEMA AS 'EsquemaFuncion',
    CREATED AS 'FechaCreacion'
FROM 
    INFORMATION_SCHEMA.ROUTINES
WHERE 
    ROUTINE_TYPE = 'FUNCTION'
ORDER BY 
    ROUTINE_NAME;
