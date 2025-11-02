# DBA-Globales — Consultas de administración y diagnóstico

Este directorio contiene un conjunto de consultas SQL listas para uso cotidiano del DBA: diagnóstico de rendimiento, visibilidad de índices, relaciones, esperas, bloqueos, backups y más. Los scripts están pensados para ejecutarse de forma manual y puntual, sin crear objetos permanentes (salvo el procedimiento de alertas).

- Audiencia: DBAs y desarrolladores con permisos de solo lectura en catálogos del sistema; algunos scripts requieren msdb o permisos de administración.
- Compatibilidad: SQL Server 2016+ (DMVs usadas existen desde versiones anteriores, pero algunos detalles varían).
- Convención de nombres: se renombraron todos los archivos a inglés manteniendo la documentación en español.

## Índice rápido de scripts

- Rendimiento y esperas
  - [Top Server Waits and Most Impactful Queries.sql](./Top%20Server%20Waits%20and%20Most%20Impactful%20Queries.sql)
  - [Most Executed Queries With Runtime >= 2s.sql](./Most%20Executed%20Queries%20With%20Runtime%20%3E%3D%202s.sql)
  - [Identify Queries Impacting TEMPDB with HASH Operations.sql](./Identify%20Queries%20Impacting%20TEMPDB%20with%20HASH%20Operations.sql)
- Índices y fragmentación
  - [Count Indexes by Fragmentation Level per Table.sql](./Count%20Indexes%20by%20Fragmentation%20Level%20per%20Table.sql)
  - [Print Count of Medium and High Fragmented Indexes.sql](./Print%20Count%20of%20Medium%20and%20High%20Fragmented%20Indexes.sql)
  - [Get Table Indexes Info.sql](./Get%20Table%20Indexes%20Info.sql)
  - [Get Index Columns.sql](./Get%20Index%20Columns.sql)
  - [Get Index Size (KB).sql](./Get%20Index%20Size%20(KB).sql)
  - [Top Missing Indexes by Estimated Impact.sql](./Top%20Missing%20Indexes%20by%20Estimated%20Impact.sql)
  - [Missing Indexes Impact Summary.sql](./Missing%20Indexes%20Impact%20Summary.sql)
  - [Suggested Indexes Without Duplicates.sql](./Suggested%20Indexes%20Without%20Duplicates.sql)
- Metadatos de objetos
  - [Get Tables, Columns, Keys Info.sql](./Get%20Tables%2C%20Columns%2C%20Keys%20Info.sql)
  - [Get Views Info.sql](./Get%20Views%20Info.sql)
  - [Get Stored Procedures Info.sql](./Get%20Stored%20Procedures%20Info.sql)
  - [Get Functions Info.sql](./Get%20Functions%20Info.sql)
  - [Get Triggers Info.sql](./Get%20Triggers%20Info.sql)
  - [Get Table Relationships (Foreign Keys).sql](./Get%20Table%20Relationships%20(Foreign%20Keys).sql)
  - [Get Unique Constraints Info.sql](./Get%20Unique%20Constraints%20Info.sql)
  - [FileTable Details.sql](./FileTable%20Details.sql)
- Operación y administración
  - [Active Transactions and Blocking Details.sql](./Active%20Transactions%20and%20Blocking%20Details.sql)
  - [View Blocking Processes.sql](./View%20Blocking%20Processes.sql)
  - [View Executed Backups Details.sql](./View%20Executed%20Backups%20Details.sql)
  - [SP - Maintenance Alerts.sql](./SP%20-%20Maintenance%20Alerts.sql)

## Notas de uso y seguridad

- Contexto de base de datos: la mayoría de consultas usan la base actual (`DB_NAME()`); ajusta filtros cuando corresponda. Evita hardcodear nombres salvo necesidad.
- Aislamiento y bloqueos: algunos scripts usan `READ UNCOMMITTED` para reducir bloqueos; úsalos con criterio (posibles lecturas sucias).
- Permisos: se requieren permisos de lectura sobre catálogos del sistema y, para backups, acceso a `msdb`. El SP de alertas requiere `Database Mail` configurado.
- Performance: evita ejecutar todas las consultas a la vez en servidores críticos. Prefiere ventanas de baja carga.

## Detalle por script

### Top Server Waits and Most Impactful Queries
- Propósito: ver las 3 esperas más altas del servidor y las 2 consultas con mayor CPU total, con su plan de ejecución.
- DMVs: `sys.dm_os_wait_stats`, `sys.dm_exec_query_stats`, `sys.dm_exec_sql_text`, `sys.dm_exec_query_plan`.
- Salida: tipo de espera, tiempos acumulados y consultas con plan.

### Most Executed Queries With Runtime >= 2s
- Propósito: identificar las consultas más ejecutadas con tiempo medio por ejecución >= 2 segundos (y más de 1000 ejecuciones).
- Filtros: excluye bases del sistema; puedes ajustar umbrales.
- DMVs: `sys.dm_exec_query_stats`, `sys.dm_exec_sql_text`, `sys.dm_exec_query_plan`.

### Identify Queries Impacting TEMPDB with HASH Operations
- Propósito: listar solicitudes activas que puedan impactar TEMPDB y usan operaciones potencialmente costosas (pistas de HASH en el texto).
- Nota: el script original tenía un filtro por base fija; revisa/ajusta para tu entorno.
- DMVs: `sys.dm_exec_requests`, `sys.dm_exec_sql_text`, `sys.dm_exec_query_stats`.

### Count Indexes by Fragmentation Level per Table
- Propósito: contar por tabla cuántos índices están en estado de fragmentación media (10–30%) y alta (>30%).
- DMVs: `sys.dm_db_index_physical_stats`, `sys.indexes`, `sys.tables`.

### Print Count of Medium and High Fragmented Indexes
- Propósito: imprimir (PRINT) el número total de índices en estado medio y alto en la base actual.
- Útil para: alertas rápidas o pasos previos a mantenimiento.

### Get Table Indexes Info / Get Index Columns / Get Index Size (KB)
- Propósito: inventario de índices por tabla y columnas, y tamaño aproximado en KB por índice.
- DMVs: `sys.indexes`, `sys.index_columns`, `sys.columns`, `sys.dm_db_partition_stats`.

### Top Missing Indexes by Estimated Impact / Missing Indexes Impact Summary / Suggested Indexes Without Duplicates
- Propósito: priorizar índices faltantes por impacto estimado, con scripts `CREATE INDEX` sugeridos; variantes con umbrales y filtrado de duplicados.
- DMVs: `sys.dm_db_missing_index_*`, `sys.dm_db_index_usage_stats`.
- Recomendación: revisar con dominio del modelo de datos; no aplicar ciegamente.

### Get Tables, Columns, Keys Info / Views / Procedures / Functions / Triggers / Relationships / Unique Constraints
- Propósito: metadatos de objetos principales (tablas, columnas, PK/FK, vistas, SPs, funciones, triggers, constraints únicas).
- Orígenes: `INFORMATION_SCHEMA` y catálogos `sys.*`.

### Active Transactions and Blocking Details / View Blocking Processes
- Propósito: detectar transacciones largas, sesiones bloqueadas y pares bloqueador–bloqueado con consultas involucradas.
- DMVs: `sys.dm_tran_*`, `sys.dm_exec_sessions`, `sys.dm_exec_requests`, `sys.dm_exec_sql_text`, `sys.dm_tran_locks`, `sys.dm_os_waiting_tasks`.

### View Executed Backups Details
- Propósito: historial de backups para la base actual desde `msdb.dbo.backupset`.

### SP - Maintenance Alerts
- Propósito: procedimiento almacenado que construye un resumen de salud (fragmentación, estadísticas, índices faltantes, uso del log) y envía correo vía Database Mail.
- Advertencias:
  - El script crea `[dbo].[BestDocAlertas]` y ya apunta a `USE [BDPRINCIPAL]`. Ajusta `@profile_email` y `@email_to` según tu entorno antes de compilar.
  - Requiere perfil de correo (`@profile_email`) y destinatarios válidos.

## Buenas prácticas
- Ejecuta primero en un entorno de prueba.
- Usa filtros de base de datos (`WHERE DB_NAME(...) = ...`) solo si lo necesitas.
- Guarda resultados relevantes (por ejemplo, exporta a XEvent o utiliza resultados a archivo) cuando analices producción.

## Licencia y contribución
- Ver [CONTRIBUTING.md](../CONTRIBUTING.md) para pautas de contribución.
- Los scripts son referencia; valida en tu contexto antes de aplicar cambios.
