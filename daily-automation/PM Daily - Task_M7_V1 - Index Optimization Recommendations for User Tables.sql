-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: PM Daily - Task_M7_V1 - Index Optimization Recommendations for User Tables
Propósito: Registrar observaciones y recomendaciones sobre índices de tablas de usuario (uso, tamaño, fragmentación) en dbo.Mantto_OptimizacionIndices.
Entradas: BD actual (BDPRINCIPAL); permisos de lectura a sys.indexes, sys.dm_db_index_usage_stats, sys.dm_db_partition_stats, sys.dm_db_index_physical_stats.
Salidas: Inserta filas con métricas y categoría/observación por índice.
Seguridad/Impacto: Solo lectura + inserción; no modifica índices.
Uso rápido: EXEC dbo.Tarea_M7_V1;
Notas: Heurísticas de categorización basadas en umbrales (p.ej., fragmentación >=85%, tamaños >=1MB, ratios de updates/seeks).
*/
USE [BDPRINCIPAL]
GO

-- Paso 0: Verificar si el SP ya existe antes de crearlo
IF OBJECT_ID('[dbo].[Tarea_M7_V1]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[Tarea_M7_V1];
END
GO

-- Paso 1: Verificar si la tabla ya existe antes de crearla
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Mantto_OptimizacionIndices')
BEGIN
	-- Crear tabla para almacenar los resultados
	CREATE TABLE dbo.Mantto_OptimizacionIndices (
		FechaHora DATETIME,
		Tabla NVARCHAR(255),
		Indice NVARCHAR(255),
		[Tipo de Indice] NVARCHAR(50),
		[Tamaño(KB)] NVARCHAR(255),
		Busquedas NVARCHAR(255),
		Escaneos NVARCHAR(255),
		[Consultas Lookup] NVARCHAR(255),
		Actualizaciones NVARCHAR(255),
		[Ultima Busqueda] NVARCHAR(255),
		[Ultimo Escaneo] NVARCHAR(255),
		[Ultima Consulta Lookup] NVARCHAR(255),
		[Ultima Actualizacion] NVARCHAR(255),
		[Categoria Indice] NVARCHAR(50),
		Observacion NVARCHAR(255)
	);
END
GO

-- Paso 2: Ajustar el procedimiento almacenado para insertar resultados en la tabla
CREATE PROCEDURE [dbo].[Tarea_M7_V1]
WITH ENCRYPTION
AS
BEGIN
	-- Insertar los resultados en la tabla
	INSERT INTO dbo.Mantto_OptimizacionIndices (FechaHora, Tabla, Indice, [Tipo de Indice], [Tamaño(KB)], Busquedas, Escaneos, [Consultas Lookup], Actualizaciones, [Ultima Busqueda], [Ultimo Escaneo], [Ultima Consulta Lookup], [Ultima Actualizacion], [Categoria Indice], Observacion)
	SELECT 
		GETDATE() as FechaHora,		
		OBJECT_NAME(IX.OBJECT_ID) as Tabla,
		COALESCE(IX.name, 'Índice Implícito') as Indice,
		IX.type_desc as [Tipo de Indice],
		CAST(SUM(PS.[used_page_count]) * 8 AS NVARCHAR(255)) as [Tamaño(KB)],
		CAST(IXUS.user_seeks AS NVARCHAR(255)) as [Busquedas],
		CAST(IXUS.user_scans AS NVARCHAR(255)) as [Escaneos],
		CAST(IXUS.user_lookups AS NVARCHAR(255)) as [Consultas Lookup],
		CAST(IXUS.user_updates AS NVARCHAR(255)) as [Actualizaciones],
		ISNULL(CONVERT(NVARCHAR(255), IXUS.last_user_seek, 120), 'N/A') as [Ultima Busqueda],
		ISNULL(CONVERT(NVARCHAR(255), IXUS.last_user_scan, 120), 'N/A') as [Ultimo Escaneo],
		ISNULL(CONVERT(NVARCHAR(255), IXUS.last_user_lookup, 120), 'N/A') as [Ultima Consulta Lookup],
		ISNULL(CONVERT(NVARCHAR(255), IXUS.last_user_update, 120), 'N/A') as [Ultima Actualizacion],
		CASE
				WHEN IX.type = 1 THEN 'Clustered'
				WHEN IX.type = 2 THEN 'Nonclustered'
				WHEN IX.type = 3 THEN 'XML'
				ELSE 'Other'
		END as [Categoria Indice],
		CASE
				WHEN ((SUM(IXUS.user_scans) + SUM(IXUS.user_lookups)) > (SUM(IXUS.user_seeks) * 2) AND MAX(DMPS.avg_fragmentation_in_percent) >= 85) THEN 'Índices Fragmentados (' + CAST(MAX(DMPS.avg_fragmentation_in_percent) AS VARCHAR(10)) + '% Fragmentado)'
				WHEN (SUM(IXUS.user_updates) > 0 AND SUM(IXUS.user_seeks) = 0) THEN 'Índices No Utilizados'
				WHEN (SUM(PS.[used_page_count]) * 8 >= 1024) THEN 'Índices Grandes'
				WHEN (SUM(IXUS.user_seeks) > 0 AND SUM(IXUS.user_updates) > 0 AND (SUM(IXUS.user_updates) / SUM(IXUS.user_seeks)) > 2) THEN 'Índices Ineficientes'
				WHEN (CASE WHEN IX.type = 2 THEN 'Nonclustered' ELSE 'Other' END = 'Nonclustered' AND SUM(PS.[used_page_count]) * 8 >= 1024) THEN 'Índices no Clusterizados en Tablas Grandes'
				WHEN (SUM(IXUS.user_seeks) = 0 AND SUM(IXUS.user_updates) = 0) THEN 'Índices sin uso'
				ELSE 'Sin Observación'
		END as [Observacion]
	FROM sys.indexes IX
	INNER JOIN sys.dm_db_index_usage_stats IXUS ON IXUS.index_id = IX.index_id AND IXUS.OBJECT_ID = IX.OBJECT_ID
	INNER JOIN sys.dm_db_partition_stats PS ON PS.object_id = IX.object_id
	CROSS APPLY sys.dm_db_index_physical_stats (DB_ID(), IX.OBJECT_ID, IX.index_id, NULL, 'SAMPLED') AS DMPS
	WHERE OBJECTPROPERTY(IX.OBJECT_ID, 'IsUserTable') = 1
	GROUP BY 
		OBJECT_NAME(IX.OBJECT_ID),
		IX.name,
		IX.type_desc,
		IXUS.user_seeks,
		IXUS.user_scans,
		IXUS.user_lookups,
		IXUS.user_updates,
		IXUS.last_user_seek,
		IXUS.last_user_scan,
		IXUS.last_user_lookup,
		IXUS.last_user_update,
		IX.type,
		DMPS.avg_fragmentation_in_percent
	HAVING 
		-- Observación 1: Índices Fragmentados
		(SUM(IXUS.user_scans) + SUM(IXUS.user_lookups)) > (SUM(IXUS.user_seeks) * 2) AND MAX(DMPS.avg_fragmentation_in_percent) >= 85
		OR
		-- Observación 2: Índices No Utilizados
		(SUM(IXUS.user_updates) > 0 AND SUM(IXUS.user_seeks) = 0)
		OR
		-- Observación 3: Índices Grandes
		(SUM(PS.[used_page_count]) * 8 >= 1024)
		OR
		-- Observación 4: Índices Ineficientes
		(SUM(IXUS.user_seeks) > 0 AND SUM(IXUS.user_updates) > 0 AND (SUM(IXUS.user_updates) / SUM(IXUS.user_seeks)) > 2)
		OR
		-- Observación 5: Índices no Clusterizados en Tablas Grandes
		(CASE WHEN IX.type = 2 THEN 'Nonclustered' ELSE 'Other' END = 'Nonclustered' AND SUM(PS.[used_page_count]) * 8 >= 1024)
		OR
		-- Observación 6: Índices sin uso
		(SUM(IXUS.user_seeks) = 0 AND SUM(IXUS.user_updates) = 0)

END;
GO