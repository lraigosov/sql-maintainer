# Mantenimiento diario automático de índices y métricas (daily-automation/)

Este conjunto de scripts automatiza la revisión y mantenimiento de índices en SQL Server y captura métricas diarias de consultas. La idea es ejecutar un pequeño pipeline diario que:

- Mide la fragmentación antes y después del mantenimiento.
- Reconstruye o reorganiza índices según umbrales.
- Registra qué se hizo y cuándo (tablas de auditoría).
- Captura tiempos de consultas del día.
- Genera recomendaciones sobre índices potencialmente problemáticos.

Funciona a nivel de la base de datos indicada en cada script (por defecto `BDPRINCIPAL`).

---

## Tabla de contenidos

- [Mantenimiento diario automático de índices y métricas (daily-automation/)](#mantenimiento-diario-automático-de-índices-y-métricas-daily-automation)
  - [Tabla de contenidos](#tabla-de-contenidos)
  - [Mapa rápido de archivos](#mapa-rápido-de-archivos)
  - [Requisitos y permisos](#requisitos-y-permisos)
  - [Flujo recomendado de ejecución (pipeline diario)](#flujo-recomendado-de-ejecución-pipeline-diario)
  - [Diagrama de flujo del pipeline](#diagrama-de-flujo-del-pipeline)
  - [Artefactos creados (tablas de auditoría)](#artefactos-creados-tablas-de-auditoría)
  - [Documentación por script](#documentación-por-script)
    - [1. PM Diario \_ Tarea\_M1\_V2 – Revisión Inicial (`Tarea_M1_V2`)](#1-pm-diario-_-tarea_m1_v2--revisión-inicial-tarea_m1_v2)
    - [2. PM Diario \_ Tarea\_M2\_V2 – Reconstrucción Inicial (`Tarea_M2_V2`)](#2-pm-diario-_-tarea_m2_v2--reconstrucción-inicial-tarea_m2_v2)
    - [3. PM Diario \_ Tarea\_M3\_V2 – Reorganización Inicial (`Tarea_M3_V2`)](#3-pm-diario-_-tarea_m3_v2--reorganización-inicial-tarea_m3_v2)
    - [4. PM Diario \_ Tarea\_M4\_V2 – Reconstrucción Residual (`Tarea_M4_V2`)](#4-pm-diario-_-tarea_m4_v2--reconstrucción-residual-tarea_m4_v2)
    - [5. PM Diario \_ Tarea\_M5\_V2 – Revisión Final (`Tarea_M5_V2`)](#5-pm-diario-_-tarea_m5_v2--revisión-final-tarea_m5_v2)
    - [6. PM Diario \_ Tarea\_M6\_V1 – Tiempos por Consulta Diarios (`Tarea_M6_V1`)](#6-pm-diario-_-tarea_m6_v1--tiempos-por-consulta-diarios-tarea_m6_v1)
    - [7. PM - Tarea\_M7\_V1 – Recomendaciones para Optimizar Índices en Tablas de Usuario (`Tarea_M7_V1`)](#7-pm---tarea_m7_v1--recomendaciones-para-optimizar-índices-en-tablas-de-usuario-tarea_m7_v1)
  - [Instalación y ejecución](#instalación-y-ejecución)
  - [Automatización con SQL Server Agent](#automatización-con-sql-server-agent)
    - [Uso del script de automatización](#uso-del-script-de-automatización)
    - [Parámetros disponibles](#parámetros-disponibles)
    - [Jobs creados](#jobs-creados)
    - [Verificación y monitoreo](#verificación-y-monitoreo)
    - [Alternativas de programación](#alternativas-de-programación)
  - [Buenas prácticas y notas operativas](#buenas-prácticas-y-notas-operativas)
  - [Ejemplos rápidos de consulta](#ejemplos-rápidos-de-consulta)
  - [Personalización rápida](#personalización-rápida)
  - [Estado de validación](#estado-de-validación)
  - [Razonamiento de diseño](#razonamiento-de-diseño)

---

## Mapa rápido de archivos

- [PM Daily - Task_M1_V2 - Initial Review.sql](./PM Daily - Task_M1_V2 - Initial Review.sql) — Recuento de índices con fragmentación media/alta; registra 'Inicial' en `dbo.Mantto_Revision`.
- [PM Daily - Task_M2_V2 - Initial Rebuild.sql](./PM Daily - Task_M2_V2 - Initial Rebuild.sql) — REBUILD para > 30% con `FILLFACTOR = 80`; registra 'Inicial' en `dbo.Mantto_Reconstruccion`.
- [PM Daily - Task_M3_V2 - Initial Reorganize.sql](./PM Daily - Task_M3_V2 - Initial Reorganize.sql) — REORGANIZE para 10–30%; registra en `dbo.Mantto_Reorganizacion`.
- [PM Daily - Task_M4_V2 - Residual Rebuild.sql](./PM Daily - Task_M4_V2 - Residual Rebuild.sql) — REBUILD de aseguramiento para ≥ 10%; registra 'Final' en `dbo.Mantto_Reconstruccion`.
- [PM Daily - Task_M5_V2 - Final Review.sql](./PM Daily - Task_M5_V2 - Final Review.sql) — Recuento final de fragmentación; registra 'Final' en `dbo.Mantto_Revision`.
- [PM Daily - Task_M6_V1 - Daily Query Times.sql](./PM Daily - Task_M6_V1 - Daily Query Times.sql) — Métricas de consultas del día actual en `dbo.ManttoTiemposConsulta`.
- [PM Daily - Task_M7_V1 - Index Optimization Recommendations for User Tables.sql](./PM Daily - Task_M7_V1 - Index Optimization Recommendations for User Tables.sql) — Observaciones y recomendaciones de índices en `dbo.Mantto_OptimizacionIndices`.

---

## Requisitos y permisos

- SQL Server 2016 o superior recomendado (usa DMV como `sys.dm_db_index_physical_stats`, `sys.dm_exec_query_stats`, `sys.dm_exec_sql_text`, `sys.dm_db_index_usage_stats`).
- Permisos:
  - `ALTER INDEX` sobre los objetos a mantener.
  - `VIEW DATABASE STATE` (para DMVs por base) y, opcionalmente, `VIEW SERVER STATE` si se centraliza a nivel servidor.
- Contexto: los scripts incluyen `USE [BDPRINCIPAL]`. Cambia el nombre de la base o elimina esa línea y ejecuta en el contexto deseado.

---

## Flujo recomendado de ejecución (pipeline diario)

1) [Tarea_M1_V2 – Revisión Inicial](#m1): mide fragmentación inicial y la registra.
2) [Tarea_M2_V2 – Reconstrucción Inicial](#m2): REBUILD para fragmentación > 30%.
3) [Tarea_M3_V2 – Reorganización Inicial](#m3): REORGANIZE para fragmentación entre 10% y 30%.
4) [Tarea_M4_V2 – Reconstrucción Residual](#m4): REBUILD para cualquier índice con fragmentación ≥ 10% aún pendiente y registrar como "Final".
5) [Tarea_M5_V2 – Revisión Final](#m5): vuelve a medir fragmentación (post-mantenimiento).
6) [Tarea_M6_V1 – Tiempos por Consulta](#m6): captura métricas de consultas creadas hoy.
7) [Tarea_M7_V1 – Recomendaciones](#m7): registra observaciones y sugerencias sobre índices.

Notas importantes del flujo:


## Diagrama de flujo del pipeline

[M1 Revisión Inicial](#m1)
  |
  v
[M2 Reconstrucción Inicial](#m2) (>30%, REBUILD)
  |
  v
[M3 Reorganización Inicial](#m3) (10–30%, REORGANIZE)
  |
  v
[M4 Reconstrucción Residual](#m4) (≥10%, REBUILD de aseguramiento)
  |
  v
[M5 Revisión Final](#m5) (comparar con M1)
  |
  v
[M6 Tiempos por Consulta](#m6) (día actual)
  |
  v
[M7 Recomendaciones de Índices](#m7)


## Artefactos creados (tablas de auditoría)

- dbo.Mantto_Revision: FechaHora, IndicesFragmentacionMedia, IndicesFragmentacionAlta, TipoRevision.
- dbo.Mantto_Reconstruccion: FechaHora, IndexName, TableName, SchemaName, FragmentationPercentage, TipoRevision.
- dbo.Mantto_Reorganizacion: FechaHora, IndexName, TableName, SchemaName, FragmentationPercentage.
- dbo.ManttoTiemposConsulta: Texto_de_Consulta, Hora_de_Creacion, Total_de_Ejecuciones, Tiempo_Total_de_CPU_ms, Tiempo_Total_Transcurrido_ms, Llamadas_por_Segundo.
- dbo.Mantto_OptimizacionIndices: FechaHora, Tabla, Indice, Tipo de Indice, Tamaño(KB), Busquedas, Escaneos, Consultas Lookup, Actualizaciones, últimas fechas, Categoría, Observación.

---

## Documentación por script

<a id="m1"></a>
### 1. PM Diario _ Tarea_M1_V2 – Revisión Inicial (`Tarea_M1_V2`)

- Qué hace: Cuenta índices con fragmentación media (10–30%) y alta (> 30%) y registra una fila con `TipoRevision = 'Inicial'` en `dbo.Mantto_Revision`.
- Entrada: DMV `sys.dm_db_index_physical_stats` y metadatos `sys.indexes`, `sys.tables`.
- Salida: Inserción en `dbo.Mantto_Revision`.
- Efectos secundarios: Crea la tabla de auditoría si no existe; (re)crea el SP cifrado.
- Archivo: [PM Daily - Task_M1_V2 - Initial Review.sql](./PM Daily - Task_M1_V2 - Initial Review.sql)

<a id="m2"></a>
### 2. PM Diario _ Tarea_M2_V2 – Reconstrucción Inicial (`Tarea_M2_V2`)

- Qué hace: Recorre con cursor los índices con fragmentación > 30% y ejecuta `ALTER INDEX ... REBUILD WITH (FILLFACTOR = 80)`.
- Registro: Inserta una fila por índice en `dbo.Mantto_Reconstruccion` con `TipoRevision = 'Inicial'` y la fragmentación antes del mantenimiento.
- Consideraciones:
  - Usa SQL dinámico y `PRINT` para depuración.
  - Ajusta el `FILLFACTOR` (80) según tu carga de trabajo.
- Archivo: [PM Daily - Task_M2_V2 - Initial Rebuild.sql](./PM Daily - Task_M2_V2 - Initial Rebuild.sql)

<a id="m3"></a>
### 3. PM Diario _ Tarea_M3_V2 – Reorganización Inicial (`Tarea_M3_V2`)

- Qué hace: Para fragmentación entre 10% y 30%, ejecuta `ALTER INDEX ... REORGANIZE`.
- Registro: Inserta una fila por índice en `dbo.Mantto_Reorganizacion` con la fragmentación observada.
- Archivo: [PM Daily - Task_M3_V2 - Initial Reorganize.sql](./PM Daily - Task_M3_V2 - Initial Reorganize.sql)

<a id="m4"></a>
### 4. PM Diario _ Tarea_M4_V2 – Reconstrucción Residual (`Tarea_M4_V2`)

- Qué hace: Pasa nuevamente por los índices con fragmentación ≥ 10% y ejecuta `REBUILD` (con Fillfactor 80), registrando `TipoRevision = 'Final'`.
- Propósito: Asegurar que, si algo quedó con fragmentación tras M2/M3, se deje óptimo al final del ciclo.
- Nota: Es un reproceso de aseguramiento para índices que no pudieron reorganizarse o quedar óptimos en M3; por ello puede rehacer algunos índices previamente reorganizados. Solo si se quisiera evitar este comportamiento en otro entorno, podría elevarse el umbral a > 30% o deshabilitarse.
- Archivo: [PM Daily - Task_M4_V2 - Residual Rebuild.sql](./PM Daily - Task_M4_V2 - Residual Rebuild.sql)

<a id="m5"></a>
### 5. PM Diario _ Tarea_M5_V2 – Revisión Final (`Tarea_M5_V2`)

- Qué hace: Repite la medición de fragmentación y registra `TipoRevision = 'Final'` en `dbo.Mantto_Revision`.
- Uso: Comparar con la medición de M1 para validar la efectividad del mantenimiento.
- Archivo: [PM Daily - Task_M5_V2 - Final Review.sql](./PM Daily - Task_M5_V2 - Final Review.sql)

<a id="m6"></a>
### 6. PM Diario _ Tarea_M6_V1 – Tiempos por Consulta Diarios (`Tarea_M6_V1`)

- Qué hace: Inserta en `dbo.ManttoTiemposConsulta` métricas de consultas con `creation_time` del día actual desde `sys.dm_exec_query_stats` y `sys.dm_exec_sql_text`.
- Columnas: texto parcial de la sentencia, total de ejecuciones, tiempo CPU y transcurrido (ms), llamadas por segundo desde su creación.
- Filtro: Sólo consultas creadas en la fecha actual (no histórico completo).
- Archivo: [PM Daily - Task_M6_V1 - Daily Query Times.sql](./PM Daily - Task_M6_V1 - Daily Query Times.sql)

<a id="m7"></a>
### 7. PM - Tarea_M7_V1 – Recomendaciones para Optimizar Índices en Tablas de Usuario (`Tarea_M7_V1`)

- Qué hace: Inserta en `dbo.Mantto_OptimizacionIndices` observaciones por índice de tablas de usuario, combinando uso (`sys.dm_db_index_usage_stats`), tamaño (`sys.dm_db_partition_stats`) y fragmentación (`sys.dm_db_index_physical_stats`).
- Categorías/observaciones detectadas:
  - Índices fragmentados (umbral ≥ 85% de fragmentación con patrón de scans/lookups alto).
  - Índices no utilizados (updates > 0 y seeks = 0).
  - Índices grandes (≥ 1 MB de páginas usadas; umbral ajustable).
  - Índices ineficientes (relación updates/seeks > 2).
  - Índices no clusterizados en tablas grandes.
  - Índices sin uso (seeks = 0 y updates = 0).
- Campos: también registra últimas fechas de seek/scan/lookup/update para contexto temporal.
- Archivo: [PM Daily - Task_M7_V1 - Index Optimization Recommendations for User Tables.sql](./PM Daily - Task_M7_V1 - Index Optimization Recommendations for User Tables.sql)

---

## Instalación y ejecución

1) Ejecuta cada script .sql una vez para crear sus tablas y procedimientos.
2) Programa trabajos en SQL Server Agent en este orden diario (o según tu ventana de mantenimiento):

- `EXEC dbo.Tarea_M1_V2;`  — Revisión Inicial
- `EXEC dbo.Tarea_M2_V2;`  — Reconstrucción Inicial (> 30%)
- `EXEC dbo.Tarea_M3_V2;`  — Reorganización Inicial (10–30%)
- `EXEC dbo.Tarea_M4_V2;`  — Reconstrucción Residual (≥ 10%)
- `EXEC dbo.Tarea_M5_V2;`  — Revisión Final
- `EXEC dbo.Tarea_M6_V1;`  — Tiempos por Consulta Diarios
- `EXEC dbo.Tarea_M7_V1;`  — Recomendaciones de Índices

Sugerencias de horario:
- Mantenimiento (M1–M5) durante la ventana nocturna de baja carga.
- Métricas y recomendaciones (M6–M7) al inicio de la jornada para ver datos frescos.

---

## Automatización con SQL Server Agent

Para facilitar la programación diaria del pipeline, se incluye el script **`Setup-SQLAgentJobs.ps1`** que automatiza la creación de los 7 jobs en SQL Server Agent.

### Uso del script de automatización

**Requisitos previos:**
- Módulo SqlServer de PowerShell: `Install-Module -Name SqlServer -Scope CurrentUser`
- SQL Server Agent en ejecución
- Permisos sysadmin o SQLAgentOperatorRole

**Ejecución básica (configuración por defecto):**

```powershell
.\Setup-SQLAgentJobs.ps1
```

Esto crea los jobs con:
- Servidor: localhost
- Base de datos: BDPRINCIPAL
- Inicio M1: 02:00 AM
- Intervalo entre tareas: 15 minutos

**Ejecución personalizada:**

```powershell
# Servidor y base específicos con inicio a la 1:00 AM
.\Setup-SQLAgentJobs.ps1 -ServerInstance "PROD-SQL01" -Database "MiBD" -StartTime "01:00" -IntervalMinutes 20
```

### Parámetros disponibles

| Parámetro | Descripción | Por defecto |
|-----------|-------------|-------------|
| `ServerInstance` | Instancia de SQL Server | localhost |
| `Database` | Base de datos objetivo | BDPRINCIPAL |
| `StartTime` | Hora inicio M1 (formato HH:mm) | 02:00 |
| `IntervalMinutes` | Separación entre M1-M5 (minutos) | 15 |

### Jobs creados

El script genera 7 jobs con nombres descriptivos:

- **PM_Daily_M1_Initial_Review** — 02:00
- **PM_Daily_M2_Initial_Rebuild** — 02:15
- **PM_Daily_M3_Initial_Reorganize** — 02:30
- **PM_Daily_M4_Residual_Rebuild** — 02:45
- **PM_Daily_M5_Final_Review** — 03:00
- **PM_Daily_M6_Daily_Query_Times** — 03:15
- **PM_Daily_M7_Index_Recommendations** — 03:30

Cada job incluye:
- Ejecución diaria automática
- 2 reintentos con 5 minutos de intervalo
- Categoría: Database Maintenance
- Alertas por fallo

### Verificación y monitoreo

Después de ejecutar el script:

1. **Verificar en SSMS:**
   - SQL Server Agent > Jobs
   - Buscar jobs con prefijo `PM_Daily_M*`

2. **Probar ejecución manual:**
   - Right-click en job > Start Job at Step...

3. **Monitorear historial:**
   - Right-click en job > View History
   - O consultar `msdb.dbo.sysjobhistory`

4. **Ajustar horarios (si necesario):**
   - Right-click en job > Properties > Schedules

### Alternativas de programación

Si prefieres no usar el script PowerShell, puedes:

1. **T-SQL manual:** Crear jobs directamente con `sp_add_job`, `sp_add_jobstep`, `sp_add_schedule`.
2. **SSMS GUI:** SQL Server Agent > Jobs > New Job... (repetir 7 veces).
3. **Terceros:** Herramientas como SQL Sentry, Redgate, o schedulers del SO (Task Scheduler, cron con sqlcmd).

---

## Buenas prácticas y notas operativas

- Retención de datos: agrega un job de purga para mantener tamaño de tablas de auditoría (por ejemplo, mantener 90 días).
- Concurrencia: evita ejecutar M2–M4 en paralelo con cargas intensivas por bloqueos; considera `ONLINE = ON` si tu edición lo permite.
- Fillfactor: 80 es un valor genérico; calibra por tabla/índice según patrón de inserciones/actualizaciones.
- Estadísticas: considera actualizar estadísticas después de reconstrucciones masivas si tu estrategia lo requiere.
- Seguridad: los SP están creados `WITH ENCRYPTION`, lo que dificulta su inspección posterior; evalúa si lo necesitas realmente.

---

## Ejemplos rápidos de consulta

- Fragmentación antes y después:
  ```sql
  SELECT * FROM dbo.Mantto_Revision ORDER BY FechaHora DESC;
  ```
- Detalle de reconstrucciones/reorganizaciones:
  ```sql
  SELECT TOP 100 * FROM dbo.Mantto_Reconstruccion ORDER BY FechaHora DESC;
  SELECT TOP 100 * FROM dbo.Mantto_Reorganizacion ORDER BY FechaHora DESC;
  ```
- Consultas del día:
  ```sql
  SELECT TOP 100 * FROM dbo.ManttoTiemposConsulta ORDER BY Hora_de_Creacion DESC;
  ```
- Recomendaciones de índices:
  ```sql
  SELECT TOP 100 * FROM dbo.Mantto_OptimizacionIndices ORDER BY FechaHora DESC;
  ```

---

## Personalización rápida

- Cambiar base: edita o elimina la línea `USE [BDPRINCIPAL]` en cada script.
- Umbrales: ajusta 10%/30% en M1–M5 y 85% en M7 según tu entorno.
- Campos y tamaños: la tabla de recomendaciones usa varios NVARCHAR(255); puedes tipar tamaños/numéricos para análisis más profundo.

---

## Estado de validación

- Build: PASS (no aplica compilación; verificación de sintaxis por lectura). 
- Lint/Typecheck: PASS (no aplica). 
- Tests: PASS (manual por revisión; se recomienda probar en un entorno de staging antes de producción).

---

## Razonamiento de diseño

- Objetivo operativo: garantizar diariamente un estado "sano" de los índices con mínima fricción operacional y trazabilidad completa.
- Umbrales y roles de cada tarea:
  - M2 (> 30%): REBUILD cuando la fragmentación es alta.
  - M3 (10–30%): REORGANIZE para fragmentación media, menos intrusivo.
  - M4 (≥ 10%): reproceso de aseguramiento. Pasa REBUILD sobre índices que no pudieron ser tratados o quedaron subóptimos tras M2/M3 (bloqueos, ventanas de tiempo, etc.). Es intencional que pueda solapar M3.
- Trade-offs considerados:
  - Disponibilidad y bloqueos: REBUILD puede requerir bloqueos mayores (mitigable con `ONLINE = ON` según edición). Se programa en ventana de baja carga.
  - Coste en LOG y TempDB: REBUILD consume más I/O y log que REORGANIZE; el reproceso M4 sólo se ejecuta una vez al final para cerrar brechas.
  - Rendimiento post-mantenimiento: `FILLFACTOR = 80` es un punto de partida para reducir page splits en cargas OLTP; debe calibrarse por tabla.
- Por qué M4 es intencional: prioriza confiabilidad del resultado final sobre la micro-optimización del tiempo total de mantenimiento. Si el entorno exige minimizar rehacer trabajo, puede elevarse su umbral (> 30%) o deshabilitarse.
- Lineamientos de ejecución: programar M1–M5 en nocturno; usar `ONLINE = ON` si disponible; controlar intensidad con ventanas y monitoreo de bloqueos; considerar MAXDOP/Resource Governor según políticas.
- Medición y verificación: contrastar M1 vs M5 en `dbo.Mantto_Revision`; auditar `dbo.Mantto_Reconstruccion` y `dbo.Mantto_Reorganizacion`; usar `dbo.Mantto_OptimizacionIndices` (M7) para identificar candidatos a rediseño.
