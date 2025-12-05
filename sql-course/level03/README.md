# Nivel 3: SQL Senior & Performance

Este módulo cubre temas avanzados de arquitectura, optimización y administración de bases de datos.

## Objetivos de Aprendizaje
- Analizar y optimizar el rendimiento de consultas.
- Entender y diseñar estrategias de indexación.
- Leer planes de ejecución.
- Conceptos de transacciones, bloqueos y seguridad.

## Contenido del Módulo

| Notebook | Tema | Conceptos Clave |
|----------|------|-----------------|
| `01_performance_basico.ipynb` | Performance | `STATISTICS IO`, Tiempos CPU |
| `02_indices_avanzados.ipynb` | Índices | Clustered vs NonClustered, Filtered |
| `03_particiones_basico.ipynb` | Particionamiento | Tablas particionadas, Filegroups |
| `04_seguridad_basica.ipynb` | Seguridad | Roles, Esquemas, Permisos |
| `05_transacciones_bloqueos.ipynb` | Concurrencia | ACID, Isolation Levels, Deadlocks |
| `06_planes_ejecucion.ipynb` | Query Plans | Scans vs Seeks, Key Lookups |
| `07_query_tuning.ipynb` | Tuning | Reescribir consultas lentas |
| `08_almacenamiento_y_mantenimiento.ipynb` | Mantenimiento | Fragmentación, Rebuild/Reorg |
| `09_observabilidad_monitoreo.ipynb` | Monitoreo | DMVs, Extended Events |
| `10_proyecto_senior.ipynb` | **Proyecto** | Auditoría y Optimización de BD |

## ⚠️ Requisito Importante: Datos Masivos
Para que los ejercicios de este nivel funcionen correctamente (especialmente índices y performance), necesitas un volumen de datos significativo.

Ejecuta el script de generación de datos antes de empezar:
```bash
python ../tools/generate_data.py --clients 5000 --sales 50000
```
Esto poblará la base de datos con suficientes registros para que el optimizador de SQL Server tome decisiones interesantes.
