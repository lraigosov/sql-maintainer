-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: Get Stored Procedures Info
Propósito: Listar procedimientos almacenados con fechas de creación y última modificación.
Entradas: Permisos de lectura.
Salidas: Nombre, tipo, creación y última alteración.
Catálogo: INFORMATION_SCHEMA.ROUTINES (filtrado por PROCEDURE).
Seguridad/Impacto: Solo lectura.
Uso: Ejecutar en la base objetivo.
*/
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
