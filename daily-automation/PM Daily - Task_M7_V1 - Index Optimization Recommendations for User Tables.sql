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
	;WITH IndexMetrics AS (
		SELECT
			OBJECT_NAME(ix.object_id) AS Tabla,
			COALESCE(ix.name, 'Índice Implícito') AS Indice,
			ix.type_desc AS [Tipo de Indice],
			ix.type AS IndexType,
			SUM(ISNULL(ps.used_page_count, 0)) * 8 AS TamanoKB,
			ISNULL(ixus.user_seeks, 0) AS Busquedas,
			ISNULL(ixus.user_scans, 0) AS Escaneos,
			ISNULL(ixus.user_lookups, 0) AS ConsultasLookup,
			ISNULL(ixus.user_updates, 0) AS Actualizaciones,
			ixus.last_user_seek AS UltimaBusqueda,
			ixus.last_user_scan AS UltimoEscaneo,
			ixus.last_user_lookup AS UltimaConsultaLookup,
			ixus.last_user_update AS UltimaActualizacion,
			MAX(ISNULL(dmps.avg_fragmentation_in_percent, 0)) AS Fragmentacion
		FROM sys.indexes AS ix
		LEFT JOIN sys.dm_db_index_usage_stats AS ixus
			ON ixus.database_id = DB_ID()
			AND ixus.object_id = ix.object_id
			AND ixus.index_id = ix.index_id
		LEFT JOIN sys.dm_db_partition_stats AS ps
			ON ps.object_id = ix.object_id
			AND ps.index_id = ix.index_id
		OUTER APPLY sys.dm_db_index_physical_stats(DB_ID(), ix.object_id, ix.index_id, NULL, 'SAMPLED') AS dmps
		WHERE OBJECTPROPERTY(ix.object_id, 'IsUserTable') = 1
			AND ix.index_id > 0
		GROUP BY
			ix.object_id,
			ix.index_id,
			ix.name,
			ix.type_desc,
			ix.type,
			ixus.user_seeks,
			ixus.user_scans,
			ixus.user_lookups,
			ixus.user_updates,
			ixus.last_user_seek,
			ixus.last_user_scan,
			ixus.last_user_lookup,
			ixus.last_user_update
	)
	INSERT INTO dbo.Mantto_OptimizacionIndices (FechaHora, Tabla, Indice, [Tipo de Indice], [Tamaño(KB)], Busquedas, Escaneos, [Consultas Lookup], Actualizaciones, [Ultima Busqueda], [Ultimo Escaneo], [Ultima Consulta Lookup], [Ultima Actualizacion], [Categoria Indice], Observacion)
	SELECT
		GETDATE() AS FechaHora,
		Tabla,
		Indice,
		[Tipo de Indice],
		CAST(TamanoKB AS NVARCHAR(255)) AS [Tamaño(KB)],
		CAST(Busquedas AS NVARCHAR(255)) AS Busquedas,
		CAST(Escaneos AS NVARCHAR(255)) AS Escaneos,
		CAST(ConsultasLookup AS NVARCHAR(255)) AS [Consultas Lookup],
		CAST(Actualizaciones AS NVARCHAR(255)) AS Actualizaciones,
		ISNULL(CONVERT(NVARCHAR(255), UltimaBusqueda, 120), 'N/A') AS [Ultima Busqueda],
		ISNULL(CONVERT(NVARCHAR(255), UltimoEscaneo, 120), 'N/A') AS [Ultimo Escaneo],
		ISNULL(CONVERT(NVARCHAR(255), UltimaConsultaLookup, 120), 'N/A') AS [Ultima Consulta Lookup],
		ISNULL(CONVERT(NVARCHAR(255), UltimaActualizacion, 120), 'N/A') AS [Ultima Actualizacion],
		CASE
			WHEN IndexType = 1 THEN 'Clustered'
			WHEN IndexType = 2 THEN 'Nonclustered'
			WHEN IndexType = 3 THEN 'XML'
			ELSE 'Other'
		END AS [Categoria Indice],
		CASE
			WHEN (Escaneos + ConsultasLookup) > (Busquedas * 2) AND Fragmentacion >= 85 THEN 'Índices Fragmentados (' + CAST(CAST(Fragmentacion AS DECIMAL(10,2)) AS VARCHAR(20)) + '% Fragmentado)'
			WHEN Actualizaciones > 0 AND Busquedas = 0 AND Escaneos = 0 AND ConsultasLookup = 0 THEN 'Índices No Utilizados'
			WHEN TamanoKB >= 1024 AND IndexType = 2 THEN 'Índices no Clusterizados en Tablas Grandes'
			WHEN TamanoKB >= 1024 THEN 'Índices Grandes'
			WHEN Busquedas > 0 AND Actualizaciones > 0 AND (Actualizaciones * 1.0 / NULLIF(Busquedas, 0)) > 2 THEN 'Índices Ineficientes'
			WHEN Busquedas = 0 AND Escaneos = 0 AND ConsultasLookup = 0 AND Actualizaciones = 0 THEN 'Índices sin uso'
			ELSE 'Sin Observación'
		END AS Observacion
	FROM IndexMetrics
	WHERE
		((Escaneos + ConsultasLookup) > (Busquedas * 2) AND Fragmentacion >= 85)
		OR (Actualizaciones > 0 AND Busquedas = 0 AND Escaneos = 0 AND ConsultasLookup = 0)
		OR (TamanoKB >= 1024)
		OR (Busquedas > 0 AND Actualizaciones > 0 AND (Actualizaciones * 1.0 / NULLIF(Busquedas, 0)) > 2)
		OR (Busquedas = 0 AND Escaneos = 0 AND ConsultasLookup = 0 AND Actualizaciones = 0)

END;
GO