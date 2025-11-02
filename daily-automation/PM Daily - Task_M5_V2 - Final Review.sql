/*
Script: PM Daily - Task_M5_V2 - Final Review
Propósito: Medir nuevamente la fragmentación (>=10%) tras el mantenimiento y registrar snapshot 'Final' en dbo.Mantto_Revision.
Entradas: Base actual (BDPRINCIPAL), permisos de lectura de DMVs.
Salidas: Inserta (FechaHora, IndicesFragmentacionMedia, IndicesFragmentacionAlta, TipoRevision='Final').
DMVs: sys.dm_db_index_physical_stats, sys.indexes, sys.tables.
Seguridad/Impacto: Solo lectura + inserción en tabla de auditoría.
Uso rápido: EXEC dbo.Tarea_M5_V2;
Notas: Comparar con M1 para evaluación de efectividad.
*/
USE [BDPRINCIPAL]
GO

-- Paso 1: Verificar si el SP ya existe antes de crearlo
IF OBJECT_ID('[dbo].[Tarea_M5_V2]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[Tarea_M5_V2];
END
GO

-- Paso 1: Verificar si la tabla ya existe antes de crearla
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Mantto_Revision')
BEGIN
    -- Crear la tabla para almacenar los resultados con marca de tiempo
    CREATE TABLE dbo.Mantto_Revision (
        FechaHora DATETIME,
        IndicesFragmentacionMedia INT,
        IndicesFragmentacionAlta INT,
		TipoRevision NVARCHAR(10)
    );
END
GO

-- Paso 2: Ajustar el procedimiento almacenado para insertar resultados en la tabla
CREATE PROCEDURE [dbo].[Tarea_M5_V2]
WITH ENCRYPTION
AS
BEGIN
    -- Declarar variables para almacenar los resultados
    DECLARE @IndicesFragmentacionMedia INT
    DECLARE @IndicesFragmentacionAlta INT;

    -- Contar el número de índices con diferentes niveles de defragmentación en cada tabla
    WITH FragmentedIndexes AS (
        SELECT DISTINCT
            DB_NAME() AS DatabaseName,
            SCHEMA_NAME(tab.[schema_id]) AS SchemaName,
            tab.name AS TableName,
            ind.name AS IndexName,
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
            AND ps.avg_fragmentation_in_percent >= 10 -- Cambio en el filtro de fragmentación
    )
    SELECT
        @IndicesFragmentacionMedia = ISNULL(SUM(CASE 
                WHEN FragmentationPercentage <= 30 AND FragmentationPercentage > 10 THEN 1
                ELSE 0
            END), 0), -- Asigna 0 si no hay índices con fragmentación media
        @IndicesFragmentacionAlta = ISNULL(SUM(CASE 
                WHEN FragmentationPercentage > 30 THEN 1
                ELSE 0
            END), 0) -- Asigna 0 si no hay índices con fragmentación alta
    FROM
        FragmentedIndexes

	-- Insertar resultados en la tabla con marca de tiempo
	INSERT INTO dbo.Mantto_Revision (FechaHora, IndicesFragmentacionMedia, IndicesFragmentacionAlta, TipoRevision)
	VALUES (GETDATE(), @IndicesFragmentacionMedia, @IndicesFragmentacionAlta, 'Final');
	
END;
GO