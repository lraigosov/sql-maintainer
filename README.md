# SQL Maintainer

Conjunto de herramientas y consultas para mantenimiento y observabilidad de SQL Server, organizado en dos módulos:

- `daily-automation/`: pipeline diario de mantenimiento de índices (M1–M7), con documentación extensa y script de automatización para SQL Server Agent.
- `dba-globals/`: consultas de administración y diagnóstico listas para usar (esperas, rendimiento, índices, metadatos, bloqueos, backups, etc.).

## Enlaces rápidos

- Documentación del pipeline diario: [daily-automation/README.md](./daily-automation/README.md)
- Catálogo de consultas DBA: [dba-globals/README.md](./dba-globals/README.md)

## Requisitos

- SQL Server 2016 o superior (funciona en versiones anteriores, pero pueden variar detalles de DMVs)
- Permisos adecuados (lectura de catálogos, acceso a msdb para backups, y Database Mail para el SP de alertas)
- PowerShell 5+ con módulo `SqlServer` para la automatización opcional

## Uso rápido

- Mantenimiento diario: revisa y ejecuta los scripts M1–M7 en `daily-automation/` o usa el script `Setup-SQLAgentJobs.ps1` para crear trabajos programados.
- Consultas DBA: ejecuta las consultas individuales desde `dba-globals/` según la necesidad de diagnóstico.

## Convenciones

- Base de datos objetivo por defecto: `BDPRINCIPAL` (ajusta según tu entorno).
- Los nombres de archivo están en inglés; el contenido y la documentación permanecen en español.

## Contribución

- Lee [CONTRIBUTING.md](./CONTRIBUTING.md) para conocer el flujo de trabajo y estándares.
- Pull Requests y mejoras son bienvenidos.

## Créditos

- Autor/Mantenedor: lraigosov (LuisRai)
