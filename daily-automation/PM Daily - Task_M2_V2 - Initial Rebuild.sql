-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: PM Daily - Task_M2_V2 - Initial Rebuild
Propósito: REBUILD de índices con fragmentación >30% y registro en dbo.Mantto_Reconstruccion con TipoRevision='Inicial'.
Entradas/Precondiciones:
- Base de datos actual (USE [BDPRINCIPAL]).
- Permisos para ALTER INDEX y lectura de DMVs.
- Crea dbo.Mantto_Reconstruccion si no existe.
Salidas:
- Registros por índice reconstruido (FechaHora, IndexName, TableName, SchemaName, FragmentationPercentage, TipoRevision).
DMVs utilizadas: sys.dm_db_index_physical_stats, sys.indexes, sys.tables.
Seguridad/Impacto: REBUILD es operación intensiva; considerar ventana de mantenimiento, espacio en log y bloqueo.
Uso rápido: EXEC dbo.Tarea_M2_V2;
Notas: Usa FILLFACTOR=80. Ejecutar tras M1.
*/
USE [BDPRINCIPAL]
GO

-- Paso 1: Verificar si el SP ya existe antes de crearlo
IF OBJECT_ID('[dbo].[Tarea_M2_V2]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[Tarea_M2_V2];
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
CREATE PROCEDURE [dbo].[Tarea_M2_V2]
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IndexName NVARCHAR(255)
    DECLARE @TableName NVARCHAR(255)
    DECLARE @SchemaName NVARCHAR(255)
    DECLARE @FragmentationPercentage FLOAT
    DECLARE @Sql NVARCHAR(MAX)

    DECLARE IndexCursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT
        ind.name AS IndexName,
        tab.name AS TableName,
        SCHEMA_NAME(tab.[schema_id]) AS SchemaName,
        ps.avg_fragmentation_in_percent AS FragmentationPercentage
    FROM
        sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) ps
    INNER JOIN
        sys.indexes ind ON ps.object_id = ind.object_id AND ps.index_id = ind.index_id
    INNER JOIN
        sys.tables tab ON tab.object_id = ind.object_id
    WHERE
        ind.name IS NOT NULL
        AND ind.is_disabled = 0
        AND ind.is_hypothetical = 0
        AND ind.type IN (1, 2)
        AND ps.page_count > 0
        AND ps.avg_fragmentation_in_percent > 30

    OPEN IndexCursor
    FETCH NEXT FROM IndexCursor INTO @IndexName, @TableName, @SchemaName, @FragmentationPercentage

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Sql = N'ALTER INDEX ' + QUOTENAME(@IndexName) + N' ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N' REBUILD WITH (FILLFACTOR = 80);';

        BEGIN TRY
            EXEC sp_executesql @Sql;

            PRINT @Sql;

            INSERT INTO dbo.Mantto_Reconstruccion (FechaHora, IndexName, TableName, SchemaName, FragmentationPercentage, TipoRevision)
            VALUES (GETDATE(), @IndexName, @TableName, @SchemaName, @FragmentationPercentage, 'Inicial');
        END TRY
        BEGIN CATCH
            PRINT 'Error en Tarea_M2_V2 para ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' / ' + QUOTENAME(@IndexName) + ': ' + ERROR_MESSAGE();
        END CATCH;

        FETCH NEXT FROM IndexCursor INTO @IndexName, @TableName, @SchemaName, @FragmentationPercentage
    END

    CLOSE IndexCursor
    DEALLOCATE IndexCursor
	
END;
GO