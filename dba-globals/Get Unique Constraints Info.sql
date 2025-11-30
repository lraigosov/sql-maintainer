-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: Get Unique Constraints Info
Propósito: Listar constraints UNIQUE por tabla y columna.
Entradas: Permisos de lectura.
Salidas: Constraint, tabla y columna.
Catálogos: INFORMATION_SCHEMA.TABLE_CONSTRAINTS, INFORMATION_SCHEMA.KEY_COLUMN_USAGE.
Seguridad/Impacto: Solo lectura.
Uso: Ejecutar en la base objetivo.
*/
-- Obtener información sobre restricciones únicas
SELECT 
    tc.constraint_name AS 'NombreConstraint',
    tc.table_name AS 'NombreTabla',
    kcu.column_name AS 'NombreColumna'
FROM 
    information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
WHERE 
    tc.constraint_type = 'UNIQUE'
ORDER BY 
    tc.table_name, tc.constraint_name;
