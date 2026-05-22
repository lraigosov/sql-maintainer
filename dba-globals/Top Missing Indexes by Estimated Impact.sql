-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: Top Missing Indexes by Estimated Impact
Propósito: Listar los índices faltantes con mayor impacto estimado y proponer scripts CREATE INDEX con FILLFACTOR=80.
Entradas: Permisos de lectura; opcional ajustar TOP y cálculo de costo.
Salidas: Top por (avg_total_user_cost * avg_user_impact * (user_seeks + user_scans)) con columnas clave e incluidas.
DMVs: sys.dm_db_missing_index_groups, sys.dm_db_missing_index_group_stats, sys.dm_db_missing_index_details.
Seguridad/Impacto: Solo lectura. NO ejecutar los CREATE INDEX sin validar.
Uso: Ejecutar en la instancia; revisar cada propuesta evitando duplicados/conflictos.
*/
-- Factores que hacen costosos a los índices faltantes más caros

DECLARE @TargetDatabase SYSNAME = DB_NAME();
DECLARE @TopN INT = 10;

;WITH MissingIndexes AS (
    SELECT TOP (@TopN)
        ROUND(s.avg_total_user_cost * s.avg_user_impact * (s.user_seeks + s.user_scans), 0) AS CostoTotal,
        s.avg_user_impact AS ImpactoPromedioUsuario,
        mid.statement AS NombreTabla,
        mid.equality_columns AS UsoIgualdad,
        mid.inequality_columns AS UsoDesigualdad,
        mid.included_columns AS ColumnasIncluidas,
        s.user_seeks AS BusquedasUsuario,
        s.user_scans AS EscaneosUsuario,
        s.avg_total_user_cost AS CostoTotalPromedioUsuario,
        mid.object_id,
        mid.statement,
        mid.equality_columns,
        mid.inequality_columns,
        mid.included_columns,
        LEFT(
            'IX_' +
            REPLACE(REPLACE(OBJECT_NAME(mid.object_id, mid.database_id), ' ', ''), ']', '') + '_' +
            REPLACE(REPLACE(REPLACE(COALESCE(mid.equality_columns, ''), '[', ''), ']', ''), ',', '_') +
            CASE
                WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN '_'
                ELSE ''
            END +
            REPLACE(REPLACE(REPLACE(COALESCE(mid.inequality_columns, ''), '[', ''), ']', ''), ',', '_'),
            128
        ) AS IndexName
    FROM sys.dm_db_missing_index_groups AS g
    INNER JOIN sys.dm_db_missing_index_group_stats AS s ON s.group_handle = g.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details AS mid ON mid.index_handle = g.index_handle
    WHERE mid.database_id = DB_ID(@TargetDatabase)
    ORDER BY ROUND(s.avg_total_user_cost * s.avg_user_impact * (s.user_seeks + s.user_scans), 0) DESC
)
SELECT
    CostoTotal AS [Costo Total],
    ImpactoPromedioUsuario AS [Impacto Promedio del Usuario],
    NombreTabla AS [Nombre de la Tabla],
    UsoIgualdad AS [Uso de Igualdad],
    UsoDesigualdad AS [Uso de Desigualdad],
    ColumnasIncluidas AS [Columnas Incluidas],
    BusquedasUsuario AS [Búsquedas de Usuario],
    EscaneosUsuario AS [Escaneos de Usuario],
    CostoTotalPromedioUsuario AS [Costo Total Promedio del Usuario],
    'CREATE INDEX ' + QUOTENAME(IndexName) + ' ON ' + statement
        + ' (' + COALESCE(equality_columns, '')
        + CASE
            WHEN equality_columns IS NOT NULL AND inequality_columns IS NOT NULL THEN ', '
            ELSE ''
          END
        + COALESCE(inequality_columns, '') + ')'
        + CASE
            WHEN included_columns IS NOT NULL THEN ' INCLUDE (' + included_columns + ')'
            ELSE ''
          END
        + ' WITH (FILLFACTOR = 80);' AS [Script del Índice]
FROM MissingIndexes
ORDER BY [Costo Total] DESC;