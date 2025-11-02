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