# Matriz de Fuente Unica por Tema

Este documento define donde vive cada tipo de informacion para evitar duplicacion y mantenimiento paralelo en la documentacion del repositorio.

## Principio operativo

1. Cada tema debe tener una sola fuente de verdad.
2. El resto de documentos debe referenciar esa fuente, no copiar contenido completo.
3. Si cambia una regla tecnica, se actualiza primero su fuente de verdad y luego solo enlaces o resuenos breves en los demas documentos.

## Matriz

| Tema | Fuente unica | Documentos que solo referencian |
|---|---|---|
| Vision y alcance del proyecto | README.md | GUIDE-APROVECHAMIENTO.md, README-EJECUTIVO.md |
| Operacion del pipeline diario (M1-M7) | daily-automation/README.md | README.md, GUIDE-APROVECHAMIENTO.md |
| Catalogo de consultas DBA y playbooks de diagnostico | dba-globals/README.md | README.md, GUIDE-APROVECHAMIENTO.md |
| Ruta formativa SQL (estructura y progresion) | sql-course/README.md | README.md, sql-course/level01/README.md, sql-course/level02/README.md, sql-course/level03/README.md, sql-course/module-ia/README.md, sql-course/labs/README.md, sql-course/evaluation/README.md |
| Reglas de contribucion y estandares de cambios | CONTRIBUTING.md | README.md |
| Priorizacion tecnica por criticidad y riesgo | SCRIPT-PRIORITIZATION-MATRIX.md | GUIDE-APROVECHAMIENTO.md, STAGING-VALIDATION-CHECKLIST.md |
| Flujo de validacion previo a produccion | STAGING-VALIDATION-CHECKLIST.md | GUIDE-APROVECHAMIENTO.md, staging-baselines/README.md |
| Parametros baseline por entorno (M4 y Top Waits) | staging-baselines/M4-and-TopWaits-Profiles.md | STAGING-VALIDATION-CHECKLIST.md, staging-baselines/README.md |
| Contexto ejecutivo para stakeholders no tecnicos | README-EJECUTIVO.md | README.md |

## Reglas practicas para PRs de documentacion

1. Si un cambio introduce parametros o umbrales nuevos, actualizar primero la fuente unica del tema.
2. Si un documento secundario ya contiene ese detalle, reemplazarlo por referencia directa.
3. Evitar duplicar tablas de parametros en mas de un archivo.
4. Si hay conflicto entre documentos, prevalece la fuente unica declarada en esta matriz.

## Checklist rapido de consistencia

1. El tema modificado tiene una sola fuente de verdad identificada.
2. No quedaron valores tecnicos copiados en documentos secundarios.
3. Los enlaces cruzados apuntan al archivo correcto.
4. El cambio quedo registrado en devlog.md.
