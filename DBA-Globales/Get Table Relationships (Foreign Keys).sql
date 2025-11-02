-- Obtener información sobre relaciones entre tablas
SELECT 
    OBJECT_NAME(FK.object_id) AS 'NombreConstraint',
    TP.name AS 'TablaPrincipal',
    FKTP.name AS 'TablaReferente',
    COL_NAME(FKC.parent_object_id, FKC.parent_column_id) AS 'ColumnaReferente',
    COL_NAME(FKC.referenced_object_id, FKC.referenced_column_id) AS 'ColumnaPrincipal'
FROM 
    sys.foreign_keys FK
    INNER JOIN sys.tables TP ON FK.parent_object_id = TP.object_id
    INNER JOIN sys.tables FKTP ON FK.referenced_object_id = FKTP.object_id
    INNER JOIN sys.foreign_key_columns FKC ON FK.object_id = FKC.constraint_object_id
ORDER BY 
    TP.name, OBJECT_NAME(FK.object_id);
