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
