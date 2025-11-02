USE [BDPRINCIPAL]
GO

-- Paso 1: Verificar si el SP ya existe antes de crearlo
IF OBJECT_ID('[dbo].[Tarea_M4_V2]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[Tarea_M4_V2];
END
GO

-- Paso 1: Verificar si la tabla ya existe antes de crearla
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Mantto_Reconstruccion')
BEGIN
    -- Crear la tabla para almacenar los resultados con marca de tiempo
    CREATE TABLE dbo.Mantto_Reconstruccion (
        FechaHora DATETIME,
        IndexName NVARCHAR(255),
        TableName NVARCHAR(255),
		SchemaName NVARCHAR(255),
		FragmentationPercentage FLOAT,
		TipoRevision NVARCHAR(10)
    );
END
GO

-- Paso 2: Ajustar el procedimiento almacenado para insertar resultados en la tabla
CREATE PROCEDURE [dbo].[Tarea_M4_V2]
WITH ENCRYPTION
AS
BEGIN
    DECLARE @IndexName NVARCHAR(255)
    DECLARE @TableName NVARCHAR(255)
    DECLARE @SchemaName NVARCHAR(255)
    DECLARE @FragmentationPercentage FLOAT

    DECLARE IndexCursor CURSOR FOR
    SELECT 
        ind.name AS IndexName,
        tab.name AS TableName,
        SCHEMA_NAME(tab.[schema_id]) AS SchemaName,
        ps.avg_fragmentation_in_percent AS FragmentationPercentage
    FROM
        sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) ps
    INNER JOIN
        sys.databases dbs ON ps.database_id = dbs.database_id
    INNER JOIN
        sys.indexes ind ON ps.object_id = ind.object_id
    INNER JOIN
        sys.tables tab ON tab.object_id = ind.object_id
    WHERE
        ind.name IS NOT NULL
        AND ps.index_id = ind.index_id
        AND ps.avg_fragmentation_in_percent >= 10

    OPEN IndexCursor
    FETCH NEXT FROM IndexCursor INTO @IndexName, @TableName, @SchemaName, @FragmentationPercentage

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @Sql NVARCHAR(MAX)
        SET @Sql = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD WITH (FILLFACTOR = 80);'
        EXEC sp_executesql @Sql

        -- Insertar resultados en la tabla con marca de tiempo
        INSERT INTO dbo.Mantto_Reconstruccion (FechaHora, IndexName, TableName, SchemaName, FragmentationPercentage, TipoRevision)
        VALUES (GETDATE(), @IndexName, @TableName, @SchemaName, @FragmentationPercentage, 'Final');

        FETCH NEXT FROM IndexCursor INTO @IndexName, @TableName, @SchemaName, @FragmentationPercentage
    END

    CLOSE IndexCursor
    DEALLOCATE IndexCursor
END;
GO