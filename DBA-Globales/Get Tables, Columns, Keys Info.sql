-- Obtener información sobre tablas
SELECT 
    t.name AS 'NombreTabla',
    SCHEMA_NAME(t.schema_id) AS 'EsquemaTabla',
    'BASE TABLE' AS 'TipoTabla',
    c.COLUMN_COUNT AS 'NumeroColumnas',
    t.create_date AS 'FechaCreacion',
    t.modify_date AS 'FechaUltimaModificacion'
FROM 
    sys.tables t
JOIN (
    SELECT 
        t.name AS 'TABLE_NAME',
        COUNT(*) AS COLUMN_COUNT
    FROM 
        sys.tables t
    JOIN sys.columns c ON t.object_id = c.object_id
    GROUP BY 
        t.name
) c ON t.name = c.TABLE_NAME
ORDER BY 
    t.name;

-- Obtener información sobre columnas
SELECT 
    TABLE_NAME AS 'NombreTabla',
    COLUMN_NAME AS 'NombreColumna',
    DATA_TYPE AS 'TipoDato',
    CHARACTER_MAXIMUM_LENGTH AS 'LongitudMaxima',
    IS_NULLABLE AS 'PermiteNulos'
FROM 
    INFORMATION_SCHEMA.COLUMNS
ORDER BY 
    TABLE_NAME, ORDINAL_POSITION;

-- Obtener información sobre claves primarias
SELECT 
    KCU.TABLE_NAME AS 'NombreTabla',
    KCU.COLUMN_NAME AS 'NombreColumna',
    TC.CONSTRAINT_TYPE AS 'TipoConstraint'
FROM 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU ON TC.CONSTRAINT_NAME = KCU.CONSTRAINT_NAME
WHERE 
    TC.CONSTRAINT_TYPE = 'PRIMARY KEY';

-- Obtener información sobre claves foráneas
SELECT 
    KCU1.TABLE_NAME AS 'TablaReferente',
    KCU1.COLUMN_NAME AS 'ColumnaReferente',
    KCU2.TABLE_NAME AS 'TablaReferenciada',
    KCU2.COLUMN_NAME AS 'ColumnaReferenciada',
    TC.CONSTRAINT_NAME AS 'NombreConstraint'
FROM 
    INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS TC
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU1 ON TC.UNIQUE_CONSTRAINT_NAME = KCU1.CONSTRAINT_NAME
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU2 ON TC.CONSTRAINT_NAME = KCU2.CONSTRAINT_NAME;
