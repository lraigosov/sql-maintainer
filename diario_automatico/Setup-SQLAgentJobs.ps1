<#
.SYNOPSIS
    Crea y programa jobs de SQL Server Agent para el pipeline diario de mantenimiento de índices (M1-M7).

.DESCRIPTION
    Este script PowerShell genera automáticamente 7 jobs en SQL Server Agent, uno para cada tarea del pipeline:
    - M1: Revisión Inicial
    - M2: Reconstrucción Inicial (>30%)
    - M3: Reorganización Inicial (10-30%)
    - M4: Reconstrucción Residual (≥10%)
    - M5: Revisión Final
    - M6: Tiempos por Consulta Diarios
    - M7: Recomendaciones de Índices

    Todos los jobs se programan en un schedule diario con horarios escalonados durante la ventana de mantenimiento.

.PARAMETER ServerInstance
    Instancia de SQL Server donde se crearán los jobs (por defecto: localhost).

.PARAMETER Database
    Base de datos donde residen los procedimientos (por defecto: BESTDOC_V2).

.PARAMETER StartTime
    Hora de inicio del primer job M1 en formato HH:mm (por defecto: 02:00 para las 2:00 AM).

.PARAMETER IntervalMinutes
    Minutos de separación entre cada tarea M1-M5 (por defecto: 15 minutos).

.EXAMPLE
    .\Setup-SQLAgentJobs.ps1
    Crea los jobs con configuración por defecto en localhost.

.EXAMPLE
    .\Setup-SQLAgentJobs.ps1 -ServerInstance "PROD-SQL01" -Database "MiBaseDatos" -StartTime "01:00"
    Crea los jobs en un servidor específico iniciando a la 1:00 AM.

.NOTES
    Requisitos:
    - SQL Server Agent en ejecución
    - Permisos para crear jobs (rol sysadmin o SQLAgentOperatorRole)
    - Módulo SqlServer de PowerShell instalado (Install-Module -Name SqlServer)
    - Los procedimientos almacenados Tarea_M1_V2 a Tarea_M7_V1 deben existir en la base de datos
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ServerInstance = "localhost",
    
    [Parameter(Mandatory=$false)]
    [string]$Database = "BDPRINCIPAL",
    
    [Parameter(Mandatory=$false)]
    [string]$StartTime = "02:00",
    
    [Parameter(Mandatory=$false)]
    [int]$IntervalMinutes = 15
)

# Verificar si el módulo SqlServer está instalado
if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    Write-Error "El módulo SqlServer no está instalado. Ejecuta: Install-Module -Name SqlServer -Scope CurrentUser"
    exit 1
}

Import-Module SqlServer -ErrorAction Stop

# Definición de las tareas del pipeline
$tasks = @(
    @{
        Name = "PM_Daily_M1_Initial_Review"
        Description = "Revisión Inicial - Cuenta índices con fragmentación media/alta"
        Procedure = "Tarea_M1_V2"
        OffsetMinutes = 0
    },
    @{
        Name = "PM_Daily_M2_Initial_Rebuild"
        Description = "Reconstrucción Inicial - REBUILD para >30%"
        Procedure = "Tarea_M2_V2"
        OffsetMinutes = $IntervalMinutes
    },
    @{
        Name = "PM_Daily_M3_Initial_Reorganize"
        Description = "Reorganización Inicial - REORGANIZE para 10-30%"
        Procedure = "Tarea_M3_V2"
        OffsetMinutes = $IntervalMinutes * 2
    },
    @{
        Name = "PM_Daily_M4_Residual_Rebuild"
        Description = "Reconstrucción Residual - REBUILD de aseguramiento ≥10%"
        Procedure = "Tarea_M4_V2"
        OffsetMinutes = $IntervalMinutes * 3
    },
    @{
        Name = "PM_Daily_M5_Final_Review"
        Description = "Revisión Final - Medición post-mantenimiento"
        Procedure = "Tarea_M5_V2"
        OffsetMinutes = $IntervalMinutes * 4
    },
    @{
        Name = "PM_Daily_M6_Daily_Query_Times"
        Description = "Tiempos por Consulta - Métricas del día actual"
        Procedure = "Tarea_M6_V1"
        OffsetMinutes = $IntervalMinutes * 5
    },
    @{
        Name = "PM_Daily_M7_Index_Recommendations"
        Description = "Recomendaciones de Índices - Observaciones y sugerencias"
        Procedure = "Tarea_M7_V1"
        OffsetMinutes = $IntervalMinutes * 6
    }
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Configuración de SQL Server Agent Jobs" -ForegroundColor Cyan
Write-Host "  Pipeline de Mantenimiento Diario de Índices" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Servidor: $ServerInstance" -ForegroundColor Yellow
Write-Host "Base de Datos: $Database" -ForegroundColor Yellow
Write-Host "Inicio M1: $StartTime" -ForegroundColor Yellow
Write-Host "Intervalo entre M1-M5: $IntervalMinutes minutos" -ForegroundColor Yellow
Write-Host ""

# Calcular hora base
$baseTime = [DateTime]::ParseExact($StartTime, "HH:mm", $null)

# Crear los jobs
foreach ($task in $tasks) {
    $jobName = $task.Name
    $scheduledTime = $baseTime.AddMinutes($task.OffsetMinutes).ToString("HHmmss")
    
    Write-Host "Creando job: $jobName..." -ForegroundColor Green
    
    # T-SQL para crear el job
    $tsql = @"
USE msdb;
GO

-- Eliminar job si ya existe
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'$jobName')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'$jobName';
END
GO

-- Crear el job
EXEC msdb.dbo.sp_add_job
    @job_name = N'$jobName',
    @enabled = 1,
    @description = N'$($task.Description)',
    @category_name = N'Database Maintenance',
    @owner_login_name = N'sa';

-- Agregar paso de ejecución
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'$jobName',
    @step_name = N'Ejecutar_$($task.Procedure)',
    @subsystem = N'TSQL',
    @command = N'EXEC dbo.$($task.Procedure);',
    @database_name = N'$Database',
    @retry_attempts = 2,
    @retry_interval = 5,
    @on_success_action = 1,
    @on_fail_action = 2;

-- Agregar schedule diario
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'Schedule_$jobName',
    @enabled = 1,
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = $scheduledTime;

-- Asociar schedule al job
EXEC msdb.dbo.sp_attach_schedule
    @job_name = N'$jobName',
    @schedule_name = N'Schedule_$jobName';

-- Agregar el job al servidor local
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'$jobName',
    @server_name = N'(local)';

PRINT 'Job $jobName creado exitosamente - Ejecuta a las $($baseTime.AddMinutes($task.OffsetMinutes).ToString("HH:mm"))';
GO
"@

    try {
        Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "msdb" -Query $tsql -ErrorAction Stop
        Write-Host "  ✓ Job $jobName creado - Programado para $($baseTime.AddMinutes($task.OffsetMinutes).ToString("HH:mm"))" -ForegroundColor Green
    }
    catch {
        Write-Error "Error creando job $jobName : $_"
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Resumen de Jobs Creados" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Listar los jobs creados
$jobList = @"
SELECT 
    j.name AS JobName,
    CASE j.enabled WHEN 1 THEN 'Habilitado' ELSE 'Deshabilitado' END AS Estado,
    s.name AS ScheduleName,
    STUFF(STUFF(RIGHT('000000' + CAST(s.active_start_time AS VARCHAR(6)), 6), 5, 0, ':'), 3, 0, ':') AS HoraInicio
FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
LEFT JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
WHERE j.name LIKE 'PM_Daily_M%'
ORDER BY j.name;
"@

try {
    $results = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "msdb" -Query $jobList
    $results | Format-Table -AutoSize
}
catch {
    Write-Warning "No se pudo listar los jobs: $_"
}

Write-Host ""
Write-Host "✓ Configuración completada exitosamente" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Verifica los jobs en SQL Server Management Studio > SQL Server Agent > Jobs" -ForegroundColor White
Write-Host "2. Ajusta los horarios si es necesario desde SSMS o modificando este script" -ForegroundColor White
Write-Host "3. Ejecuta manualmente un job para probar: Right-click > Start Job at Step..." -ForegroundColor White
Write-Host "4. Monitorea el historial de ejecución: Right-click > View History" -ForegroundColor White
Write-Host ""
