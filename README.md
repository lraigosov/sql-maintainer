# SQL Maintainer

Conjunto de herramientas, consultas y material educativo para mantenimiento, observabilidad y capacitación en SQL Server, organizado en tres módulos principales:

- **`daily-automation/`**: Pipeline diario automatizado de mantenimiento de índices (M1–M7) con documentación detallada y script PowerShell para configurar SQL Server Agent jobs.
- **`dba-globals/`**: Catálogo de 35+ consultas SQL de administración y diagnóstico listas para usar (esperas, rendimiento, índices, metadatos, bloqueos, backups, seguridad).
- **`sql-course/`**: Curso estructurado con 47 notebooks Jupyter organizados en niveles progresivos (Junior, Intermedio, Senior), módulo de IA aplicada (7 notebooks), laboratorios prácticos (4 notebooks), evaluaciones (3 rúbricas) y recursos de referencia (4 notebooks).

## Enlaces rápidos

- Documentación del pipeline diario: [daily-automation/README.md](./daily-automation/README.md)
- Catálogo de consultas DBA: [dba-globals/README.md](./dba-globals/README.md)
- Contenido del curso SQL: [sql-course/README.md](./sql-course/README.md)
- Guía de aprovechamiento y mejores prácticas: [GUIDE-APROVECHAMIENTO.md](./GUIDE-APROVECHAMIENTO.md)

## Requisitos

- SQL Server 2016 o superior (funciona en versiones anteriores, pero pueden variar detalles de DMVs)
- Permisos adecuados (lectura de catálogos, acceso a msdb para backups, y Database Mail para el SP de alertas)
- PowerShell 5+ con módulo `SqlServer` para la automatización opcional

## Uso rápido

### Mantenimiento Diario
- Revisa y ejecuta los scripts M1–M7 en `daily-automation/` manualmente, o
- Usa el script PowerShell `Setup-SQLAgentJobs.ps1` para crear y programar jobs automáticos en SQL Server Agent

### Consultas DBA
- Ejecuta las consultas individuales desde `dba-globals/` según necesidad de diagnóstico
- Scripts organizados por categoría: rendimiento, índices, metadatos, bloqueos, seguridad, backups

### Curso SQL
- Sigue la progresión: `level01/` → `level02/` → `level03/`
- Complementa con `module-ia/` y `labs/` según interés
- Usa `resources/` como referencia constante

## Convenciones

- Base de datos objetivo por defecto: `BDPRINCIPAL` (ajusta según tu entorno).
- Los nombres de archivo están en inglés; el contenido y la documentación permanecen en español.
- Cabeceras de scripts:
	- SQL (*.sql): cada archivo inicia con un bloque que resume Propósito, Entradas, Salidas, DMVs/Catálogos usados, Seguridad/Impacto y Uso.
	- PowerShell (*.ps1): se usa ayuda comentada (.SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE, .NOTES) con notas de seguridad y requisitos.

## Contribución

- Lee [CONTRIBUTING.md](./CONTRIBUTING.md) para conocer el flujo de trabajo, estándares de código y proceso de Pull Requests.
- Todas las contribuciones son bienvenidas: corrección de errores, nuevas características, optimizaciones, documentación, pruebas.
- Política de asistencia con IA documentada en `CONTRIBUTING.md` (créditos indicados en pie de archivos afectados).

## Créditos

**Autor/Mantenedor**: lraigosov (LuisRai)

**Nota sobre asistencia con IA**: Parte del contenido fue estructurado con asistencia de modelos de lenguaje (OpenAI GPT-4, Anthropic Claude). Todo el contenido fue validado, curado y probado por el autor para asegurar aplicabilidad práctica y exactitud técnica.
