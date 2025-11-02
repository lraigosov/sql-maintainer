-- Obtener información de SP

SELECT 
    ROUTINE_NAME AS 'NombreProcedimiento',
    ROUTINE_TYPE AS 'TipoProcedimiento',
    CREATED AS 'FechaCreacion',
    LAST_ALTERED AS 'FechaUltimaModificacion'
FROM 
    INFORMATION_SCHEMA.ROUTINES
WHERE 
    ROUTINE_TYPE = 'PROCEDURE'
ORDER BY 
    ROUTINE_NAME;
