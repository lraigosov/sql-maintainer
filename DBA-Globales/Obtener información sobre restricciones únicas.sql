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
