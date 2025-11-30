-- Este material fue revisado y enriquecido parcialmente mediante asistencia de IA (OpenAI y Claude); la validación y decisiones editoriales finales son humanas.
/*
Script: Get Triggers Info
Propósito: Enumerar triggers con esquema/tabla, fechas de creación y modificación.
Entradas: Permisos de lectura.
Salidas: Nombre de trigger, esquema de tabla, tabla, fechas.
Catálogos: sys.triggers y funciones OBJECT_*.
Seguridad/Impacto: Solo lectura.
Uso: Ejecutar en la base objetivo.
*/
-- Obtener información sobre desencadenadores

SELECT
    name AS 'NombreDesencadenador',
    OBJECT_SCHEMA_NAME(object_id) AS 'EsquemaTabla',
    OBJECT_NAME(parent_id) AS 'NombreTabla',
    create_date AS 'FechaCreacion',
    modify_date AS 'FechaEdicion'
FROM sys.triggers
ORDER BY name;