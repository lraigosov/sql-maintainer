# SQL Maintainer

Repositorio orientado a resolver un problema frecuente en equipos que trabajan con SQL Server: el conocimiento y las tareas críticas de operación suelen quedar dispersos entre scripts sueltos, revisiones manuales, respuestas reactivas a incidentes y material formativo no estandarizado.

SQL Maintainer unifica en un solo lugar tres frentes que normalmente viven separados:

- operación y mantenimiento preventivo de bases de datos;
- observabilidad y diagnóstico para troubleshooting y mejora continua;
- formación progresiva de analistas, desarrolladores y perfiles DBA.

El resultado es un repositorio que sirve tanto para ejecutar trabajo operativo real como para acelerar la madurez técnica de un equipo.

## Tabla de contenidos

- [Qué problema resuelve](#qué-problema-resuelve)
- [Ámbitos donde aplica](#ámbitos-donde-aplica)
- [Casos de uso](#casos-de-uso)
- [Qué contiene el repositorio](#qué-contiene-el-repositorio)
- [Perfiles a los que sirve](#perfiles-a-los-que-sirve)
- [Valor técnico y de negocio](#valor-técnico-y-de-negocio)
- [Inicio rápido](#inicio-rápido)
- [Requisitos](#requisitos)
- [Convenciones](#convenciones)
- [Documentación relacionada](#documentación-relacionada)
- [Contribución](#contribución)
- [Créditos](#créditos)

## Qué problema resuelve

En muchos entornos SQL Server aparecen de forma simultánea estos problemas:

- índices fragmentados y mantenimiento inconsistente;
- consultas lentas sin una línea base ni métricas recurrentes;
- incidentes de bloqueos, esperas o consumo de recursos difíciles de diagnosticar;
- recomendaciones de índices y tuning sin un proceso claro para priorizarlas;
- conocimiento operativo distribuido entre personas, correos, scripts locales o wikis incompletas;
- dificultad para formar nuevos integrantes en SQL con un camino práctico y alineado al trabajo real.

SQL Maintainer ataca esos frentes con un enfoque combinado:

- automatiza tareas repetitivas de mantenimiento diario;
- centraliza consultas de observabilidad y diagnóstico listas para usar;
- ofrece un recorrido formativo estructurado desde fundamentos hasta performance, observabilidad e IA aplicada a SQL.

## Ámbitos donde aplica

Este repositorio es útil en varios ámbitos de trabajo:

- **Administración de bases de datos**: mantenimiento de índices, revisión de backups, seguridad, bloqueos y salud general de la instancia o base.
- **Operación y soporte**: atención de incidentes de rendimiento, análisis de contención, diagnóstico de TEMPDB y priorización de acciones correctivas.
- **Ingeniería de datos y desarrollo**: entendimiento del modelo, revisión de consultas, análisis de índices faltantes y optimización de cargas o reportes.
- **Capacitación técnica**: onboarding de perfiles junior, nivelación de equipos y entrenamiento interno en SQL orientado a negocio.
- **Gobierno y mejora continua**: establecimiento de playbooks, KPIs operativos y evidencia para auditoría o cumplimiento.

## Casos de uso

Casos de uso típicos donde este repositorio aporta valor inmediato:

1. **Programar mantenimiento preventivo diario** con un pipeline M1-M7 para reducir fragmentación, registrar auditoría y capturar métricas de consultas.
2. **Investigar por qué una base “está lenta”** usando consultas listas para revisar esperas, queries costosas, bloqueos y presión sobre TEMPDB.
3. **Construir backlog de optimización** a partir de recomendaciones de índices, uso real y métricas de impacto.
4. **Estandarizar operación DBA** con scripts reutilizables, documentación técnica y criterios de uso seguros.
5. **Formar talento SQL** desde nivel junior hasta senior con notebooks, proyectos, rúbricas y laboratorios prácticos.
6. **Alinear trabajo técnico con valor de negocio** midiendo estabilidad, tiempos de respuesta, riesgos operativos y oportunidades de ahorro.

## Qué contiene el repositorio

El repositorio está organizado en tres módulos principales y documentos de apoyo:

| Módulo | Qué aporta | Resultado esperado |
|---|---|---|
| [daily-automation/](./daily-automation/README.md) | Pipeline diario M1-M7 para mantenimiento de índices, revisión antes/después, métricas de consultas y recomendaciones | Operación recurrente, trazabilidad y reducción de trabajo manual |
| [dba-globals/](./dba-globals/README.md) | Catálogo de consultas SQL para diagnóstico y administración | Troubleshooting más rápido y análisis técnico con menos improvisación |
| [sql-course/](./sql-course/README.md) | Ruta formativa con notebooks progresivos, laboratorios, evaluaciones y módulo de IA | Desarrollo de capacidades y transferencia de conocimiento |
| [GUIDE-APROVECHAMIENTO.md](./GUIDE-APROVECHAMIENTO.md) | Guía operativa con foco en valor de negocio, KPIs y buenas prácticas | Uso consistente del repositorio en entornos reales |

### Resumen estructural

- **daily-automation/**
  - 7 scripts SQL de mantenimiento y captura de métricas.
  - 1 script PowerShell para crear jobs en SQL Server Agent.
  - documentación del pipeline, artefactos creados y recomendaciones operativas.

- **dba-globals/**
  - catálogo de consultas listas para operación diaria;
  - cobertura de rendimiento, índices, metadatos, bloqueos, seguridad y backups;
  - incluye procedimiento de alertas de mantenimiento.

- **sql-course/**
  - 1 notebook de configuración inicial;
  - 29 notebooks de progresión técnica en 3 niveles;
  - 7 notebooks de IA aplicada a SQL;
  - 4 laboratorios prácticos;
  - 3 rúbricas de evaluación;
  - 4 recursos de referencia y diagrama ER;
  - script de dataset base para ejercicios.

## Perfiles a los que sirve

- **DBA**: para ejecutar mantenimiento, revisar salud y responder incidentes con más velocidad.
- **Desarrollador backend o full stack**: para entender índices, tuning y comportamiento de consultas en producción.
- **Ingeniero de datos o BI**: para validar calidad, rendimiento y estructura del modelo relacional.
- **Líder técnico o gerente de TI**: para estandarizar operación, reducir dependencia de conocimiento tácito y acelerar onboarding.
- **Instructor o mentor interno**: para usar una ruta didáctica ya organizada con ejercicios y evaluaciones.

## Valor técnico y de negocio

Desde la perspectiva técnica, el repositorio ayuda a:

- reducir mantenimiento manual y trabajo repetitivo;
- detectar antes problemas de fragmentación, rendimiento y bloqueo;
- convertir observaciones puntuales en procesos repetibles;
- documentar criterios operativos y de revisión.

Desde la perspectiva de negocio, ayuda a:

- mejorar continuidad operativa y estabilidad de aplicaciones;
- reducir tiempos de respuesta inconsistentes que afectan experiencia de usuario;
- controlar costos por uso ineficiente de CPU, IO y almacenamiento;
- fortalecer auditoría, trazabilidad y gobierno del entorno de datos;
- acelerar formación interna sin depender exclusivamente de transferencia oral.

## Inicio rápido

### Si tu foco es operación DBA

1. Revisa [daily-automation/README.md](./daily-automation/README.md).
2. Ajusta la base objetivo por defecto, normalmente `BDPRINCIPAL`, a tu entorno.
3. Ejecuta los scripts M1-M7 manualmente o usa [daily-automation/Setup-SQLAgentJobs.ps1](./daily-automation/Setup-SQLAgentJobs.ps1) para programarlos.
4. Usa [dba-globals/README.md](./dba-globals/README.md) para diagnosticar incidencias o priorizar optimizaciones.

### Si tu foco es troubleshooting o tuning

1. Empieza por [dba-globals/README.md](./dba-globals/README.md).
2. Ejecuta consultas de esperas, bloqueos, índices faltantes y metadatos según el síntoma.
3. Cruza hallazgos con las métricas y auditorías generadas por [daily-automation/README.md](./daily-automation/README.md).

### Si tu foco es formación u onboarding

1. Sigue [sql-course/README.md](./sql-course/README.md).
2. Configura el entorno con [sql-course/00_setup_environment.ipynb](./sql-course/00_setup_environment.ipynb).
3. Crea el dataset con [sql-course/dataset_setup.sql](./sql-course/dataset_setup.sql).
4. Avanza en orden: `level01` → `level02` → `level03`.

## Requisitos

- SQL Server 2016 o superior recomendado.
- Permisos adecuados para lectura de catálogos, DMVs y, según el script, `msdb`, `ALTER INDEX`, `VIEW DATABASE STATE` o `VIEW SERVER STATE`.
- PowerShell 5 o superior con módulo `SqlServer` para la automatización opcional.
- Jupyter Notebook y dependencias de Python si se utilizará el módulo formativo en [sql-course/](./sql-course/README.md).

## Convenciones

- Base de datos objetivo por defecto: `BDPRINCIPAL`; ajústala según tu entorno.
- Los nombres de archivo están en inglés; la documentación y explicaciones permanecen en español.
- Los scripts SQL documentan propósito, entradas, salidas, dependencias y consideraciones operativas.
- Los scripts PowerShell usan ayuda comentada y parámetros explícitos para facilitar su reutilización.
- Las recomendaciones de índices y tuning deben validarse en el contexto real antes de aplicarse en producción.

## Documentación relacionada

- [daily-automation/README.md](./daily-automation/README.md)
- [dba-globals/README.md](./dba-globals/README.md)
- [sql-course/README.md](./sql-course/README.md)
- [staging-baselines/README.md](./staging-baselines/README.md)
- [STAGING-VALIDATION-CHECKLIST.md](./STAGING-VALIDATION-CHECKLIST.md)
- [SCRIPT-PRIORITIZATION-MATRIX.md](./SCRIPT-PRIORITIZATION-MATRIX.md)
- [DOCUMENTATION-SOURCE-OF-TRUTH.md](./DOCUMENTATION-SOURCE-OF-TRUTH.md)
- [GUIDE-APROVECHAMIENTO.md](./GUIDE-APROVECHAMIENTO.md)
- [CONTRIBUTING.md](./CONTRIBUTING.md)

## Contribución

- Revisa [CONTRIBUTING.md](./CONTRIBUTING.md) para conocer el flujo de trabajo, estándares y proceso de Pull Requests.
- Se aceptan contribuciones de documentación, mejoras de scripts, optimización, validaciones y material formativo.
- Antes de proponer cambios operativos, valida siempre el comportamiento en un entorno de prueba representativo.

## Créditos

**Autor/Mantenedor**: lraigosov (LuisRai)

**Nota sobre asistencia con IA**: Parte del contenido fue estructurado con asistencia de modelos de lenguaje. El contenido final del repositorio fue curado y validado manualmente para mantener utilidad práctica y consistencia técnica.
