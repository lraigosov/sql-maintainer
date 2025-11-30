-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: View Executed Backups Details
Propósito: Listar los respaldos ejecutados (msdb.backupset) para la base de datos actual, con tamaños y fechas.
Entradas: Acceso de lectura a msdb.
Salidas: Conjunto de resultados con base, tipo, fechas y tamaño/comprimido.
Catálogo: msdb.dbo.backupset.
Seguridad/Impacto: Solo lectura; sin cambios.
Uso: Ejecutar en la instancia; el filtro actual usa DB_NAME() (base actual). Ajustar si se requiere otra base.
*/
-- Ver detalles de backups ejecutados
SELECT
    database_name AS 'NombreBaseDatos',
    type AS 'TipoBackup',
    backup_start_date AS 'FechaInicioBackup',
    backup_finish_date AS 'FechaFinBackup',
    backup_size AS 'TamañoBackup (bytes)',
    compressed_backup_size AS 'TamañoBackupComprimido (bytes)'
FROM
    msdb.dbo.backupset
WHERE
    database_name = DB_NAME() -- Filtrar por la base de datos actual
ORDER BY
    backup_start_date DESC;