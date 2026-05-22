# M4 y Top Waits por Perfil de Entorno

Este documento propone perfiles iniciales para staging.

## Perfil pequeño

- Uso esperado: OLTP liviano o mixto con bajo volumen.
- Ventana objetivo: 60-120 minutos.

Parámetros sugeridos:

- M4 `@ResidualMinFragmentationPercent = 12`
- M4 `@ResidualMinPageCount = 500`
- M4 `@ResidualFillFactor = 85`
- Top Waits `@TopWaits = 10`
- Top Waits `@TopQueries = 5`

## Perfil mediano

- Uso esperado: OLTP/mixto con carga moderada.
- Ventana objetivo: 45-90 minutos.

Parámetros sugeridos:

- M4 `@ResidualMinFragmentationPercent = 15`
- M4 `@ResidualMinPageCount = 1000`
- M4 `@ResidualFillFactor = 80`
- Top Waits `@TopWaits = 10`
- Top Waits `@TopQueries = 5`

## Perfil grande

- Uso esperado: alto volumen y sensibilidad a log/IO.
- Ventana objetivo: 30-60 minutos.

Parámetros sugeridos:

- M4 `@ResidualMinFragmentationPercent = 20`
- M4 `@ResidualMinPageCount = 5000`
- M4 `@ResidualFillFactor = 80`
- Top Waits `@TopWaits = 15`
- Top Waits `@TopQueries = 10`

## Regla rápida de ajuste

1. Si hay presión de log o bloqueo, subir primero `@ResidualMinPageCount`.
2. Si queda fragmentación crítica en tablas clave, bajar `@ResidualMinFragmentationPercent` en 2-3 puntos.
3. Cambiar un solo parámetro por iteración para mantener trazabilidad.

## Snippet de parametrización para M4

```sql
-- Ajustar dentro de dbo.Tarea_M4_V2 según perfil
DECLARE @ResidualMinFragmentationPercent FLOAT = 15.0;
DECLARE @ResidualMinPageCount INT = 1000;
DECLARE @ResidualFillFactor TINYINT = 80;
```

## Snippet de parametrización para Top Waits

```sql
-- Ajustar dentro del script Top Server Waits and Most Impactful Queries
DECLARE @TopWaits INT = 10;
DECLARE @TopQueries INT = 5;
```

## Validación mínima recomendada

1. Ejecutar 2 corridas consecutivas con el mismo perfil.
2. Verificar que la duración total de mantenimiento queda dentro de la ventana.
3. Verificar que la señal de waits no oculte incidentes reales del entorno.
4. Guardar evidencia de resultados y parámetros usados.