# SQL Course: De Junior a Senior con Enfoque de Negocio

Curso estructurado de SQL con 47 notebooks Jupyter organizados progresivamente desde fundamentos hasta temas avanzados de performance y administración (DBA), más 1 notebook de configuración inicial (`00_setup_environment.ipynb`).

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

- `module-ia/` Módulo de IA aplicada a SQL (7 notebooks)
- `labs/` Laboratorios prácticos (4 notebooks)
- `evaluation/` Evaluación y Certificación (3 rúbricas)
- `resources/` Recursos de referencia (4 notebooks + Diagrama ER)

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
