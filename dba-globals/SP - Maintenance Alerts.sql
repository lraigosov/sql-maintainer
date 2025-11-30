-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: SP - Maintenance Alerts (dbo.MaintenanceAlerts)
Propósito: Procedimiento para evaluar señales de mantenimiento (fragmentación, estadísticas, índices faltantes, uso de log) y notificar por correo.
Entradas: Parámetros @mensaje, @profile_email, @email_to, @send_email_flat.
Salidas: Envío de correo opcional y composición de mensaje con métricas clave.
DMVs/Catálogos: sys.dm_db_index_physical_stats, sys.indexes, sys.stats, sys.dm_db_stats_properties, sys.objects, sys.dm_db_missing_index_*, sys.database_files.
Seguridad/Impacto: Lee metadatos; envía correos con sp_send_dbmail. Revisar y configurar Database Mail previamente.
Uso: Crear/ejecutar en la base objetivo (USE [BDPRINCIPAL]); parametrizar destinatarios y perfil.
*/
USE [BDPRINCIPAL]
GO

/* StoredProcedure: [dbo].[MaintenanceAlerts] - Generic maintenance alerts procedure */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[MaintenanceAlerts]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[MaintenanceAlerts];
GO

CREATE PROCEDURE [dbo].[MaintenanceAlerts]
    -- Parámetros configurables (reemplaza los placeholders por valores reales en tu entorno)
    @mensaje VARCHAR(MAX) = '',
    @profile_email VARCHAR(MAX) = 'DBMailProfile',
    --@email_to VARCHAR(MAX) = 'usuario1@dominio.com;usuario2@dominio.com',
    @email_to VARCHAR(MAX) = 'dba-team@example.com',
    @send_email_flat bit = 0
AS
BEGIN

-- Obtener la lista de índices fragmentados
DECLARE @fragmentedIndexes TABLE (
    ObjectName NVARCHAR(128),
    IndexName NVARCHAR(128),
    Fragmentation FLOAT
);
 
INSERT INTO @fragmentedIndexes
SELECT 
    OBJECT_NAME(ips.object_id) AS ObjectName,
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent AS Fragmentation
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.index_id > 0 AND ips.page_count > 0
AND ips.avg_fragmentation_in_percent >= 10; -- Definir el umbral de fragmentación para clasificar el riesgo
 
-- Calcular el número total de índices
DECLARE @totalIndexes INT = (SELECT COUNT(*) FROM @fragmentedIndexes);
 
-- Calcular el número de índices con fragmentación alta
DECLARE @highFragmentationIndexes INT = (SELECT COUNT(*) FROM @fragmentedIndexes WHERE Fragmentation >= 30); -- Definir el umbral de fragmentación alta
 
-- Calcular el número de índices con fragmentación media
DECLARE @mediumFragmentationIndexes INT = (SELECT COUNT(*) FROM @fragmentedIndexes WHERE Fragmentation >= 10 AND Fragmentation < 30); -- Definir el umbral de fragmentación media
 
-- Clasificar el riesgo de fragmentación
DECLARE @riesgoFragmentacion VARCHAR(10);
IF @highFragmentationIndexes > 0
 BEGIN
    SET @riesgoFragmentacion = 'Alto';
	SET @send_email_flat = 1;
 END
ELSE IF @mediumFragmentationIndexes > 0
 BEGIN
    SET @riesgoFragmentacion = 'Medio';
	SET @send_email_flat = 1;
 END
ELSE
    SET @riesgoFragmentacion = 'Bajo';
 
-- Generar el mensaje de fragmentación
SET @mensaje = '1. Estado general del riesgo por fragmentación de índices: ' + @riesgoFragmentacion 
    + '. Índices fragmentados: ' + CAST(@totalIndexes AS VARCHAR(10))
    + ', Gravedad Alta: ' + CAST(@highFragmentationIndexes AS VARCHAR(10))
    + ', Gravedad Media: ' + CAST(@mediumFragmentationIndexes AS VARCHAR(10));
 
-- Obtener el número total de objetos con estadísticas
DECLARE @totalObjects INT;
SELECT @totalObjects = COUNT(*) FROM sys.objects WHERE type = 'U';
 
-- Obtener el número de objetos con actualización de estadísticas con riesgo
DECLARE @objectsRisk INT;
SELECT @objectsRisk = COUNT(*) 
FROM sys.stats s
JOIN sys.objects o ON o.object_id = s.object_id
WHERE s.auto_created = 0 AND s.user_created = 1
AND EXISTS (
    SELECT 1
    FROM sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
    WHERE sp.modification_counter > 0
);
 
-- Calcular el porcentaje de objetos con actualización de estadísticas con riesgo
DECLARE @porcentajeRisk FLOAT;
SET @porcentajeRisk = (@objectsRisk * 100.0) / @totalObjects;
 
-- Clasificar el riesgo de actualización de estadísticas
DECLARE @riesgoEstadisticas VARCHAR(10);
IF @porcentajeRisk >= 10
 BEGIN
    SET @riesgoEstadisticas = 'Alto';
	SET @send_email_flat = 1;
 END
ELSE IF @porcentajeRisk >= 5
 BEGIN
    SET @riesgoEstadisticas = 'Medio';
	SET @send_email_flat = 1;
 END
ELSE
    SET @riesgoEstadisticas = 'Bajo';
 
-- Generar el mensaje de actualización de estadísticas
SET @mensaje = @mensaje + CHAR(13) + CHAR(13) + CHAR(10) + '2. Estado general de actualización de estadísticas, Riesgo Actual: ' + @riesgoEstadisticas 
    + '. Objetos con riesgo: ' + CAST(@objectsRisk AS VARCHAR(10)) + '/' + CAST(@totalObjects AS VARCHAR(10));
 
-- Obtener la cantidad de índices sugeridos por el sistema
DECLARE @suggestedIndexesCount INT = (SELECT COUNT(*) FROM sys.dm_db_missing_index_details);
 
-- Obtener el impacto probable de los índices sugeridos
DECLARE @impactoProbable VARCHAR(10);
IF @suggestedIndexesCount > 0
BEGIN
    DECLARE @totalImpact FLOAT = (SELECT SUM(avg_total_user_cost) FROM sys.dm_db_missing_index_group_stats);
    DECLARE @averageImpact FLOAT = @totalImpact / @suggestedIndexesCount;
 
    IF @suggestedIndexesCount > 30
	 BEGIN
        SET @impactoProbable = 'Alto';
		SET @send_email_flat = 1;
	 END
    ELSE IF @suggestedIndexesCount > 10
	 BEGIN
        SET @impactoProbable = 'Medio';
		SET @send_email_flat = 1;
	 END
    ELSE
        SET @impactoProbable = 'Bajo';
END
ELSE
BEGIN
    SET @impactoProbable = 'No Aplica';
    SET @mensaje = @mensaje + CHAR(13)+ CHAR(13) + CHAR(10) + 'No hay índices sugeridos por el sistema.';
END
 
-- Generar el mensaje
SET @mensaje = @mensaje + CHAR(13) + CHAR(13) + CHAR(10) + '3. Cantidad de índices sugeridos por el sistema: ' + CAST(@suggestedIndexesCount AS VARCHAR(10))
    + ', Impacto probable de su ausencia: ' + @impactoProbable;
 
-- Obtener información del archivo de registro
DECLARE @logSize FLOAT, @logUsedPercent FLOAT;
SELECT
    @logSize = size * 8.0 / 1024, -- Tamaño en MB
    @logUsedPercent = CAST(FILEPROPERTY(name, 'SpaceUsed') AS FLOAT) / CAST(size AS FLOAT) * 100.0 -- Porcentaje de ocupación
FROM sys.database_files
WHERE type = 1; -- Tipo 1 para archivos de registro
 
-- Clasificar el estado de gravedad
DECLARE @gravedad VARCHAR(10);
IF @logUsedPercent >= 80
 BEGIN
    SET @gravedad = 'Alto';
	SET @send_email_flat = 1;
 END
ELSE IF @logUsedPercent >= 50
 BEGIN
    SET @gravedad = 'Medio';
	SET @send_email_flat = 1;
 END
ELSE
    SET @gravedad = 'Bajo';
 
-- Generar el mensaje
SET @mensaje = @mensaje + CHAR(13) + CHAR(13) + CHAR(10) + '4. Tamaño del archivo de registros: ' + CAST(@logSize AS VARCHAR(10)) + ' MB'
    + ', Ocupación de disco: ' + CAST(@logUsedPercent AS VARCHAR(10)) + '%'
    + ', Estado de gravedad del disco Log: ' + @gravedad;

IF @send_email_flat = 1
 BEGIN
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = @profile_email 
  , @recipients = @email_to
    , @subject = 'SQL Maintainer - Maintenance Alerts'
  , @body = @mensaje
  , @importance ='HIGH' 
 END

END
GO
