# SQL Course: De Junior a Senior con Enfoque de Negocio

Curso estructurado de SQL con 47 notebooks Jupyter organizados progresivamente desde fundamentos hasta temas avanzados de performance y administración (DBA).

## Estructura de Notebooks (por tema)

- `level01/` Fundamentos (1.1–1.9):
	- `01_introduccion_relacional.ipynb`
	- `02_select_basico.ipynb`
	- `03_funciones_tipos.ipynb`
	- `04_filtrado_avanzado.ipynb`
	- `05_joins.ipynb`
	- `06_agregaciones_kpis.ipynb`
	- `07_consultas_multitabla.ipynb`
	- `08_calidad_datos_basica.ipynb`
	- `09_proyecto_cierre_junior.ipynb`

- `level02/` Analítica Intermedia (2.1–2.10):
	- `01_fundamentos_window_functions.ipynb`
	- `02_ctes_recursivas.ipynb`
	- `03_subconsultas_avanzadas.ipynb`
	- `04_modelado_dimensional_basico.ipynb`
	- `05_kpis_avanzados.ipynb`
	- `06_segmentacion_basica.ipynb`
	- `07_optimizar_consultas_basico.ipynb`
	- `08_control_version_datos.ipynb`
	- `09_integracion_fuentes.ipynb`
	- `10_proyecto_intermedio.ipynb`

- `level03/` Senior (3.1–3.10):
	- `01_performance_basico.ipynb`
	- `02_indices_avanzados.ipynb`
	- `03_particiones_basico.ipynb`
	- `04_seguridad_basica.ipynb`
	- `05_transacciones_bloqueos.ipynb`
	- `06_planes_ejecucion.ipynb`
	- `07_query_tuning.ipynb`
	- `08_almacenamiento_y_mantenimiento.ipynb`
	- `09_observabilidad_monitoreo.ipynb`
	- `10_proyecto_senior.ipynb`

- `module-ia/` Módulo de IA aplicada a SQL (4.1–4.7)
- `labs/` Laboratorios (5.1–5.4)
- `evaluation/` Evaluación y Certificación (6.1–6.3)
- `resources/` Glosario + Recetario + Prompts (4 notebooks)

## Dataset Base

Archivo: `dataset_setup.sql` crea tablas:
- `dim_clientes` (clientes)
- `dim_productos` (productos)
- `dim_regiones` (regiones)
- `fact_ventas` (ventas)
- `fact_suscripciones` (suscripciones SaaS simplificadas)
- `fact_inventario` (stock e inventarios)

Cada notebook ejecutable asume que las tablas existen. Ejecuta primero el script en tu motor (SQL Server recomendado) o adapta a PostgreSQL/MySQL.

## Progresión y Objetivos

1. Fundamentos: Sintaxis, joins, agregaciones, calidad de datos básica.
2. Analítica: CTEs, funciones de ventana, modelado estrella, segmentación marketing, finanzas y calendarios.
3. Senior: Arquitectura, índices, planes de ejecución, particionado, transacciones, seguridad, data quality avanzada, documentación y lineage.
4. Complementos avanzados: explicación, revisión y documentación de SQL con enfoque práctico.
5. Laboratorios: Prácticas focalizadas por nivel.
6. Evaluación: Rúbricas y entregables de proyectos.
7. Glosario/Recetario: Referencia rápida y prompts reutilizables.

## Convenciones Técnicas

- SQL dialecto base: T-SQL (señalando diferencias donde aplica).
- Uso de CTE para legibilidad en lugar de subconsultas anidadas profundas.
- Nombres: snake_case para tablas y columnas, prefijos `dim_` y `fact_` en modelo analítico.
- Índices: sugerencias indicadas pero no creadas automáticamente (validar en contexto real).
- Comentarios: BLOQUES arriba de cada sección y línea para pasos clave.
- Buenas prácticas: validar siempre contra esquema real y documentar decisiones.

## Ejercicios y Retos

Cada notebook incluye:
- Conceptos clave
- Ejemplos ejecutables
- Ejercicios guiados (🟢 Básico, 🟠 Intermedio, 🔴 Avanzado)
- Retos “Senior Challenge” (⚙️) para pensamiento crítico
- Sección de errores comunes y cómo evitarlos

## Evaluación

Ver `evaluacion_certificacion.ipynb` para criterios por nivel y rubricas de proyectos.

 

## Cómo Empezar

1. Ejecuta `dataset_setup.sql` en tu instancia.
2. Abre `level01/01_introduccion_relacional.ipynb` y sigue el orden por archivos.
3. Completa cada proyecto (`level01/09_proyecto_cierre_junior.ipynb`, `level02/10_proyecto_intermedio.ipynb`, `level03/10_proyecto_senior.ipynb`) antes de avanzar.
4. Usa el glosario/recetario (cuando esté disponible) como apoyo.
