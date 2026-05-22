# SQL Course: De Junior a Senior con Enfoque de Negocio

Curso estructurado de SQL con 47 notebooks Jupyter organizados progresivamente desde fundamentos hasta temas avanzados de performance y administración (DBA), más 1 notebook de configuración inicial (`00_setup_environment.ipynb`).

## Para quién está pensado este módulo

- Analistas o desarrolladores que necesitan una ruta guiada para fortalecer SQL con enfoque práctico.
- Equipos que buscan un material interno de onboarding o nivelación técnica.
- Perfiles que ya saben consultar, pero quieren avanzar hacia performance, observabilidad y criterio de negocio.

## Qué se obtiene al completarlo

- dominio progresivo de consultas, modelado, KPIs y depuración de calidad de datos;
- práctica sobre optimización, índices, planes de ejecución y mantenimiento;
- criterio para usar IA como apoyo y no como sustituto del razonamiento técnico;
- evidencia de avance mediante laboratorios y rúbricas por nivel.

## Estructura de Notebooks (por tema)

- **`level01/` Fundamentos (1.1–1.9)**:
	- [01 – Introducción Relacional](./level01/01_introduccion_relacional.ipynb)
	- [02 – SELECT Básico](./level01/02_select_basico.ipynb)
	- [03 – Funciones y Tipos](./level01/03_funciones_tipos.ipynb)
	- [04 – Filtrado Avanzado](./level01/04_filtrado_avanzado.ipynb)
	- [05 – JOINs](./level01/05_joins.ipynb)
	- [06 – Agregaciones y KPIs](./level01/06_agregaciones_kpis.ipynb)
	- [07 – Consultas Multitabla](./level01/07_consultas_multitabla.ipynb)
	- [08 – Calidad de Datos Básica](./level01/08_calidad_datos_basica.ipynb)
	- [09 – Proyecto Cierre Junior](./level01/09_proyecto_cierre_junior.ipynb)

- **`level02/` Analítica Intermedia (2.1–2.10)**:
	- [01 – Fundamentos Window Functions](./level02/01_fundamentos_window_functions.ipynb)
	- [02 – CTEs y Recursividad](./level02/02_ctes_recursivas.ipynb)
	- [03 – Subconsultas Avanzadas](./level02/03_subconsultas_avanzadas.ipynb)
	- [04 – Modelado Dimensional Básico](./level02/04_modelado_dimensional_basico.ipynb)
	- [05 – KPIs Avanzados](./level02/05_kpis_avanzados.ipynb)
	- [06 – Segmentación Básica](./level02/06_segmentacion_basica.ipynb)
	- [07 – Optimizar Consultas Básico](./level02/07_optimizar_consultas_basico.ipynb)
	- [08 – Control Version Datos](./level02/08_control_version_datos.ipynb)
	- [09 – Integración de Fuentes](./level02/09_integracion_fuentes.ipynb)
	- [10 – Proyecto Intermedio](./level02/10_proyecto_intermedio.ipynb)

- **`level03/` Senior (3.1–3.10)**:
	- [01 – Performance Básico](./level03/01_performance_basico.ipynb)
	- [02 – Índices Avanzados](./level03/02_indices_avanzados.ipynb)
	- [03 – Particiones Básico](./level03/03_particiones_basico.ipynb)
	- [04 – Seguridad Básica](./level03/04_seguridad_basica.ipynb)
	- [05 – Transacciones y Bloqueos](./level03/05_transacciones_bloqueos.ipynb)
	- [06 – Planes de Ejecución](./level03/06_planes_ejecucion.ipynb)
	- [07 – Query Tuning](./level03/07_query_tuning.ipynb)
	- [08 – Almacenamiento y Mantenimiento](./level03/08_almacenamiento_y_mantenimiento.ipynb)
	- [09 – Observabilidad y Monitoreo](./level03/09_observabilidad_monitoreo.ipynb)
	- [10 – Proyecto Senior](./level03/10_proyecto_senior.ipynb)

- **`module-ia/` Módulo de IA aplicada a SQL (7 notebooks)**:
	- [01 – Prompting Efectivo](./module-ia/01_prompting_efectivo.ipynb)
	- [02 – Explicación SQL con IA](./module-ia/02_explicacion_sql_con_ia.ipynb)
	- [03 – Refactor SQL Asistido](./module-ia/03_refactor_sql_asistido.ipynb)
	- [04 – Validación Resultados con IA](./module-ia/04_validacion_resultados_con_ia.ipynb)
	- [05 – Generación Datos Sintéticos](./module-ia/05_generacion_datos_sinteticos.ipynb)
	- [06 – Revisión AI Pair Programming](./module-ia/06_revision_ai_pair_programming.ipynb)
	- [07 – Ética y Gobernanza IA](./module-ia/07_etica_y_gobernanza_ia.ipynb)

- **`labs/` Laboratorios Prácticos (4 notebooks)**:
	- [01 – Dashboard Ventas Básico](./labs/01_dashboard_ventas_basico.ipynb)
	- [02 – Auditoría Calidad Datos](./labs/02_auditoria_calidad_datos.ipynb)
	- [03 – Optimizar Consultas Práctico](./labs/03_optimizar_consultas_practico.ipynb)
	- [04 – Mini ETL Fuentes](./labs/04_mini_etl_fuentes.ipynb)

- **`evaluation/` Evaluación y Certificación (3 rúbricas)**:
	- [01 – Rúbrica Junior](./evaluation/01_rubrica_junior.ipynb)
	- [02 – Rúbrica Intermedio](./evaluation/02_rubrica_intermedio.ipynb)
	- [03 – Rúbrica Senior](./evaluation/03_rubrica_senior.ipynb)

- **`resources/` Recursos de Referencia (4 notebooks + Diagrama ER)**:
	- [01 – Glosario](./resources/01_glosario.ipynb)
	- [02 – Recetario de Snippets](./resources/02_recetario_snippets.ipynb)
	- [03 – Prompts IA](./resources/03_prompts_ia.ipynb)
	- [04 – Checklist Calidad](./resources/04_checklist_calidad.ipynb)
	- [Diagrama ER](./resources/er_diagram.md)

## Configuración del Entorno

Antes de comenzar, asegúrate de tener tu entorno Python configurado para conectar a SQL Server.
Hemos preparado una guía paso a paso en:
👉 **[00_setup_environment.ipynb](./00_setup_environment.ipynb)**

Sigue ese notebook para instalar las librerías necesarias y probar tu conexión.

## Dataset Base

### Modelo de Datos (ER Diagram)

Puedes ver el diagrama detallado de relaciones aquí: [Ver Diagrama ER](./resources/er_diagram.md)

Archivo: `dataset_setup.sql` crea tablas:
- `dim_clientes` (clientes)
- `dim_productos` (productos)
- `dim_regiones` (regiones)
- `fact_ventas` (ventas)
- `fact_suscripciones` (suscripciones SaaS simplificadas)
- `fact_inventario` (stock e inventarios)

Cada notebook ejecutable asume que las tablas existen. Ejecuta primero el script en tu motor (SQL Server recomendado) o adapta a PostgreSQL/MySQL.

## Progresión y Objetivos

1. Fundamentos (Level 1): Sintaxis, joins, agregaciones, calidad de datos básica.
2. Analítica Intermedia (Level 2): CTEs, funciones de ventana, modelado dimensional, segmentación, KPIs.
3. Senior (Level 3): Performance, índices, planes de ejecución, particionamiento, transacciones, seguridad, observabilidad.
4. Módulo de IA: Prompting, explicación SQL, refactoring asistido, validación con IA, generación de datos sintéticos, ética.
5. Laboratorios: 4 prácticas integradores transversales.
6. Evaluación: 3 rúbricas para proyectos finales por nivel.
7. Recursos: 4 notebooks de referencia (glosario, recetario, prompts IA, checklist calidad) + Diagrama ER.

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

Cada nivel incluye rúbricas de evaluación detalladas en la carpeta `evaluation/`:
- `01_rubrica_junior.ipynb`: Criterios para proyecto nivel Junior (Level 1)
- `02_rubrica_intermedio.ipynb`: Criterios para proyecto nivel Intermedio (Level 2)
- `03_rubrica_senior.ipynb`: Criterios para proyecto nivel Senior (Level 3)

## Cómo Empezar

1. Abre y ejecuta `00_setup_environment.ipynb` para configurar tu entorno Python/SQL Server.
2. Ejecuta `dataset_setup.sql` en tu instancia SQL Server para crear las tablas del curso.
3. Abre `level01/01_introduccion_relacional.ipynb` y sigue el orden secuencial.
4. Completa cada proyecto capstone (`09_proyecto_cierre_junior.ipynb`, `10_proyecto_intermedio.ipynb`, `10_proyecto_senior.ipynb`) antes de avanzar al siguiente nivel.
5. Usa los recursos en `resources/` como apoyo constante durante el curso.

## Rutas sugeridas

- Ruta analista: `level01` → `level02` → `labs/01_dashboard_ventas_basico.ipynb` → `evaluation/01_rubrica_junior.ipynb`.
- Ruta desarrollador SQL: `level01` → `level02` → `level03/06_planes_ejecucion.ipynb` → `level03/07_query_tuning.ipynb` → `labs/03_optimizar_consultas_practico.ipynb`.
- Ruta mentor o formador: `00_setup_environment.ipynb` → `resources/` → rúbricas de `evaluation/` para planificar seguimiento.
