# Guía de aprovechamiento, buenas prácticas y valor de negocio

Esta guía explica cómo sacar el máximo provecho de los scripts de este repositorio, conectando cada tarea técnica con objetivos de negocio: disponibilidad, rendimiento, reducción de costos, cumplimiento y decisiones mejor informadas.

- Para quién: DBAs, SRE/DevOps, Ingenieros de Datos, Líderes TI y responsables de producto/negocio.
- Módulos cubiertos:
  - `daily-automation/`: pipeline diario M1–M7 para mantenimiento de índices y métricas.
  - `dba-globals/`: consultas de observabilidad, diagnóstico y gobierno de datos.

## Valor de negocio en términos simples

- Continuidad operativa: menos caídas e incidentes por contención o bloqueos → más ventas y mejor experiencia de usuario.
- Rendimiento estable: tiempos de respuesta consistentes → más conversiones y menor abandono.
- Costos controlados: menos CPU/IO derrochado, índices pertinentes → menor gasto en infraestructura/licencias.
- Trazabilidad y gobierno: evidencia de respaldos, seguridad y cambios → cumplimiento regulatorio y auditorías más simples.
- Decisiones con datos: métricas diarias sobre consultas e índices → priorización efectiva de mejoras.

## Cómo usar `daily-automation/` (pipeline M1–M7)

Resumen de tareas:
- M1 (Revisión inicial): radiografía de fragmentación (baseline del día).
- M2 (Reconstrucción >30%): REBUILD donde el impacto es mayor.
- M3 (Reorganización 10–30%): REORGANIZE para casos medios.
- M4 (Residual ≥10%): REBUILD de aseguramiento para cerrar brechas.
- M5 (Revisión final): contraste post-mantenimiento (validación de efectividad).
- M6 (Tiempos por consulta): métricas de ejecución para foco en rendimiento.
- M7 (Recomendaciones de índices): insumos para optimizaciones futuras (no aplicar a ciegas).

Recomendaciones operativas:
- Ventana de mantenimiento: programe M1→M7 con el script `Setup-SQLAgentJobs.ps1` y horarios escalonados. Empiece con ventanas bajas y amplíe según evidencia.
- Umbrales: los 10%/30% son base razonable; calibrelos por tabla/carga (p. ej., fillfactor según patrón de inserciones/actualizaciones).
- Seguridad: el SP `dbo.MaintenanceAlerts` envía avisos cuando hay riesgo; configure Database Mail y destinatarios.
- Observabilidad: registre métricas de M6 y compárelas semana a semana.
- Control de cambios: pruebe en no productivo; documente ajustes; use control de versiones (este repositorio).

KPIs sugeridos:
- Fragmentación media/alta por tabla e índice.
- Variación de tiempo promedio/p95 por consulta (M6).
- Número e impacto de índices faltantes validados/aplicados.
- Incidentes por contención o bloqueos antes/después.

Buenas prácticas técnicas:
- Preferir mantenimiento online donde sea posible (ediciones Enterprise). Planificar el log y espacio en disco.
- Evitar REBUILD masivos en horas pico; distribuir cargas.
- Validar planes de ejecución tras cambios en índices.
- Actualizar estadísticas si hay cambios de cardinalidad.

## Cómo usar `dba-globals/` (catálogo DBA)

Categorías y casos de uso rápidos:
- Rendimiento del servidor:
  - Top Server Waits and Most Impactful Queries: cuando el servidor “está lento”, identifique esperas dominantes y consultas más costosas.
- Índices y almacenamiento:
  - Count/Print Fragmented Indexes y Get Index Size (KB): medir fragmentación y footprint para planes de limpieza.
  - Missing/Suggested/Top Missing Indexes: identificar candidatos; validar contra consultas reales y evitar duplicados.
- Bloqueos y transacciones:
  - View Blocking Processes y Active Transactions and Blocking Details: encontrar quién bloquea a quién y qué está ejecutando.
- TEMPDB y operaciones HASH:
  - Identify Queries Impacting TEMPDB with HASH Operations: aislar consultas que estresan tempdb.
- Metadatos y gobierno:
  - Get Tables/Columns/Keys, Views, Functions, Stored Procedures, Triggers: inventario completo con fechas.
  - Get Table Relationships (FKs), Unique Constraints Info: integridad referencial y diseño lógico.
- Seguridad y respaldos:
  - User Security Details: mapa de usuarios, roles y permisos.
  - View Executed Backups Details: evidencia de respaldos en msdb.
  - SP - Maintenance Alerts: alertas de salud de mantenimiento (fragmentación, stats, log, índices faltantes).

Playbooks por síntoma:
- “Picos de CPU/espera”: espereas + consultas de mayor impacto → revisar planes, índices, parametrización.
- “Consultas lentas”: métricas de M6 + detalles en dba-globals → focalizar índices/reescrituras.
- “Bloqueos recurrentes”: Blocking/Active Transactions → refactorizar transacciones y aislamientos.
- “Crecimiento de disco”: Index Size + Missing Indexes → balancear espacio/beneficio.
- “Auditoría/compliance”: Security Details + Backups Details → evidencia rápida.

Buenas prácticas de revisión:
- Baseline: capture estado inicial (M1, tamaños, esperas) y compare periódicamente.
- Priorización por valor: primero lo que toque más transacciones/consultas críticas.
- Revisión mensual de índices sugeridos: validar con workload; evitar redundancias.
- Documentar excepciones: tablas particionadas, índices filtrados, cargas batch.

## Checklist operativa y KPIs por cadencia

Diaria (5–10 min):
- Jobs M1–M7 ejecutados sin fallas (objetivo: 100%). Revisar historial en SQL Agent.
- M5: fragmentación residual en tablas críticas — objetivo: Alta = 0%, Media <= 5%.
- M6: p95 de consultas clave no aumenta > 10% vs baseline semanal.
- `dbo.MaintenanceAlerts`: sin alertas de nivel Alto. Si hay, abrir ticket y asignar.
- Respaldo de la base objetivo en últimas 24h — objetivo: 100% éxito (RPO).

Semanal (30–60 min):
- Tendencia de fragmentación por tabla; proponer ajustes de fillfactor donde aplique.
- Validar 3–5 índices sugeridos de mayor impacto; abrir PR/CR con scripts validados.
- Esperas del servidor: ninguna espera individual > 50% del total; si ocurre, plan de acción.
- Bloqueos recurrentes: identificar patrones (sesión/objeto) y mitigaciones.
- Revisión de jobs: schedules coherentes, owner/categoría correctos y sin jobs huérfanos.

Mensual (2–4 h):
- KPIs globales:
  - p95 de consultas clave — objetivo definido con producto (p. ej., <= 800 ms).
  - Incidentes por bloqueo — objetivo: <= N por mes (según criticidad).
  - Crecimiento de tamaño de índices — objetivo: <= X% mensual (control de costos).
  - Applied vs. Suggested indexes — objetivo: validar/aplicar top X% con mayor ROI.
- Auditoría de seguridad: cambios en permisos/roles; confirmación de mínimos privilegios.
- Pruebas de restore: 1 restauración de validación (muestra) — objetivo: 100% éxito.
- Ajuste de umbrales (10/30, fillfactor) y de ventanas según evidencia del mes.

SLIs/SLOs sugeridos:
- Disponibilidad de jobs de mantenimiento: SLO 99.9% mensual.
- Éxito de backups: SLI 100% dentro de RPO acordado.
- Fragmentación alta en tablas críticas: SLI 0% sostenido.

Notas operativas:
- Definir lista de tablas críticas con negocio y aplicar objetivos más estrictos.
- Registrar evidencia: exportar resultados clave (M5/M6/esperas/bloqueos) a un repositorio de reportes o tabla de métricas.

## Operar de forma segura

- Lecturas sucias: varios scripts usan READ UNCOMMITTED para evitar bloqueos; úselo conscientemente.
- Permisos: asegure roles mínimos; el SP de alertas requiere Database Mail.
- No aplicar ciegamente índices sugeridos: verifique duplicidad, cardinalidad y patrón de acceso.
- Pruebe siempre en entornos de prueba con datos representativos.

## Trabajo conjunto: pipeline + catálogo

- Use el pipeline para mantener la salud estructural (índices, fragmentación) y el catálogo para observar y diagnosticar.
- Integre KPIs en tableros (Grafana/Power BI) y alinee con SLOs del negocio.
- Haga retrospectivas mensuales con producto: ¿Qué mejoró? ¿Qué duele aún? Ajuste umbrales y prioridades.

## Cómo empezar (Quickstart)

1) Ajuste la base objetivo (por defecto `BDPRINCIPAL`).
2) Configure Database Mail y cree `dbo.MaintenanceAlerts` (ver `dba-globals/`).
3) Programe el pipeline con `daily-automation/Setup-SQLAgentJobs.ps1`.
4) Revise resultados de M5 y métricas de M6 la mañana siguiente.
5) Alimente un backlog con hallazgos de M7 + dba-globals (índices, consultas a optimizar).

## Referencias del repositorio

- Documentación del pipeline diario: `daily-automation/README.md`
- Catálogo de consultas DBA: `dba-globals/README.md`
- Script de automatización: `daily-automation/Setup-SQLAgentJobs.ps1`
- Procedimiento de alertas: `dba-globals/SP - Maintenance Alerts.sql`

---

Sugerencias y mejoras son bienvenidas mediante Pull Requests. Mantén la guía viva con lo aprendido en tu entorno.
