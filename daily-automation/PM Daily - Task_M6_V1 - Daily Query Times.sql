/*
Script: PM Daily - Task_M6_V1 - Daily Query Times
Propósito: Capturar métricas de consultas ejecutadas en el día y registrarlas en dbo.ManttoTiemposConsulta.
Entradas: Base actual (BDPRINCIPAL); permisos de lectura a sys.dm_exec_query_stats y sys.dm_exec_sql_text.
Salidas: Inserta texto de consulta, timestamps, conteos y tiempos totales/promedios.
DMVs: sys.dm_exec_query_stats, sys.dm_exec_sql_text.
Seguridad/Impacto: Solo lectura + inserción de resultados; cuidado con tamaño de texto.
Uso rápido: EXEC dbo.Tarea_M6_V1;
Notas: Filtra por fecha actual (CONVERT(date, creation_time) = GETDATE()).
*/
USE [BDPRINCIPAL]
GO

-- Paso 1: Verificar si el SP ya existe antes de crearlo
IF OBJECT_ID('[dbo].[Tarea_M6_V1]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[Tarea_M6_V1];
END
GO

-- Paso 1: Verificar si la tabla ya existe antes de crearla
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'ManttoTiemposConsulta')
BEGIN
    CREATE TABLE [dbo].ManttoTiemposConsulta (
        Texto_de_Consulta NVARCHAR(MAX),
        Hora_de_Creacion DATETIME,
        Total_de_Ejecuciones INT,
        Tiempo_Total_de_CPU_ms FLOAT,
        Tiempo_Total_Transcurrido_ms FLOAT,
        Llamadas_por_Segundo FLOAT
    );
END
GO

-- Paso 3: Crea el procedimiento almacenado Tarea_M6_V1.
CREATE PROCEDURE [dbo].[Tarea_M6_V1]
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    -- Inserta los resultados de la consulta en la tabla ManttoTiemposConsulta.
    INSERT INTO [dbo].ManttoTiemposConsulta (
        Texto_de_Consulta,
        Hora_de_Creacion,
        Total_de_Ejecuciones,
        Tiempo_Total_de_CPU_ms,
        Tiempo_Total_Transcurrido_ms,
        Llamadas_por_Segundo
    )
    SELECT 
        SUBSTRING(t.text, (s.statement_start_offset / 2) + 1, 
            ((CASE statement_end_offset 
                WHEN -1 THEN DATALENGTH(t.text)
                ELSE s.statement_end_offset 
            END - s.statement_start_offset) / 2) + 1) AS Texto_de_Consulta,
        s.creation_time AS Hora_de_Creacion,
        s.execution_count AS Total_de_Ejecuciones,
        s.total_worker_time / 1000 AS Tiempo_Total_de_CPU_ms,
        s.total_elapsed_time / 1000 AS Tiempo_Total_Transcurrido_ms,
        s.execution_count / NULLIF(DATEDIFF(second, s.creation_time, GETDATE()), 0) AS Llamadas_por_Segundo
    FROM 
        sys.dm_exec_query_stats AS s
    CROSS APPLY 
        sys.dm_exec_sql_text(s.sql_handle) AS t
    WHERE
        CONVERT(DATE, s.creation_time) = CONVERT(DATE, GETDATE());
END
GO