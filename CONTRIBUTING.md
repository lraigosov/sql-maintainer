# Guía de contribución - SQL Maintainer

¡Gracias por tu interés en contribuir al proyecto SQL Maintainer! Este documento proporciona directrices para colaborar de manera efectiva.

---

## Tabla de contenidos

- [Código de conducta](#código-de-conducta)
- [Cómo contribuir](#cómo-contribuir)
- [Estándares de código](#estándares-de-código)
- [Proceso de pull request](#proceso-de-pull-request)
- [Reportar problemas](#reportar-problemas)
- [Estructura del proyecto](#estructura-del-proyecto)

---

## Código de conducta

- Sé respetuoso y profesional en todas las interacciones
- Acepta críticas constructivas con buena disposición
- Enfócate en lo que es mejor para la comunidad
- Muestra empatía hacia otros miembros de la comunidad

---

## Cómo contribuir

### Tipos de contribuciones bienvenidas

1. **Corrección de errores** — Fixes de bugs en scripts SQL o PowerShell
2. **Nuevas características** — Scripts adicionales de mantenimiento o monitoreo
3. **Mejoras de rendimiento** — Optimización de consultas existentes
4. **Documentación** — Mejoras en README, comentarios, ejemplos
5. **Pruebas** — Casos de prueba, validaciones, escenarios de uso
6. **Traducciones** — Documentación en otros idiomas

### Antes de empezar

1. **Revisa issues existentes** — Verifica si alguien ya está trabajando en algo similar
2. **Crea un issue** — Describe tu propuesta antes de comenzar a codificar
3. **Espera feedback** — Permite que los mantenedores revisen tu propuesta

---

## Estándares de código

### SQL Scripts

```sql
-- ✅ Buenas prácticas

-- Usar comentarios descriptivos al inicio
-- Incluir manejo de errores con TRY/CATCH cuando sea apropiado
-- Verificar existencia antes de crear/eliminar objetos
-- Usar nombres descriptivos para variables y objetos
-- Indentación consistente (4 espacios o 1 tab)

-- Ejemplo:
IF OBJECT_ID('[dbo].[MiProcedimiento]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[MiProcedimiento];
END
GO

CREATE PROCEDURE [dbo].[MiProcedimiento]
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Lógica del procedimiento aquí
    
END;
GO
```

**Convenciones:**
- Usar `[corchetes]` para nombres de objetos
- MAYÚSCULAS para palabras clave SQL: `SELECT`, `FROM`, `WHERE`
- Incluir `GO` después de cada batch
- Verificar compatibilidad con SQL Server 2016+

### PowerShell Scripts

```powershell
# ✅ Buenas prácticas

# Incluir ayuda basada en comentarios (.SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE)
# Usar [CmdletBinding()] para funciones avanzadas
# Validar parámetros con [Parameter(Mandatory=$true)]
# Manejar errores con Try/Catch
# Usar nombres de funciones con Verbo-Sustantivo (Get-Data, Set-Configuration)

# Ejemplo:
<#
.SYNOPSIS
    Descripción breve
.DESCRIPTION
    Descripción detallada
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerInstance
)

try {
    # Lógica aquí
}
catch {
    Write-Error "Error: $_"
}
```

**Convenciones:**
- Usar `PascalCase` para funciones y parámetros
- Usar `$camelCase` para variables locales
- Incluir validación de entrada
- Proveer mensajes informativos con `Write-Host` o `Write-Verbose`

### Documentación (Markdown)

```markdown
✅ Buenas prácticas:
- Usar títulos jerárquicos (# ## ###)
- Incluir tabla de contenidos con enlaces
- Usar bloques de código con el lenguaje especificado: ```sql, ```powershell
- Envolver nombres de archivos en backticks: `archivo.sql`
- Incluir ejemplos prácticos y casos de uso
```

---

## Proceso de pull request

### 1. Fork y clona el repositorio

```powershell
git clone https://github.com/TU_USUARIO/sql-maintainer.git
cd sql-maintainer
```

### 2. Crea una rama para tu cambio

```powershell
git checkout -b feature/descripcion-breve
# O para fixes:
git checkout -b fix/descripcion-del-bug
```

**Convenciones de nombres de ramas:**
- `feature/nombre-feature` — Para nuevas funcionalidades
- `fix/descripcion-bug` — Para correcciones
- `docs/tema` — Para cambios solo en documentación
- `refactor/componente` — Para refactorizaciones

### 3. Realiza tus cambios

- Mantén los commits pequeños y enfocados
- Usa mensajes de commit descriptivos:
  ```
  feat: Agregar script de purga de tablas de auditoría
  fix: Corregir umbral de fragmentación en M3
  docs: Actualizar README con ejemplos de MAXDOP
  ```

### 4. Prueba tus cambios

- **SQL Scripts:** Prueba en un entorno de staging/desarrollo
- **PowerShell:** Ejecuta con `-WhatIf` si aplica
- **Documentación:** Verifica enlaces y formato

### 5. Commit y push

```powershell
git add .
git commit -m "feat: Descripción clara del cambio"
git push origin feature/tu-rama
```

### 6. Abre un Pull Request

- Incluye una descripción clara de los cambios
- Referencia issues relacionados: `Closes #123`
- Adjunta capturas de pantalla si aplica
- Lista los cambios principales:
  ```markdown
  ## Cambios
  - Agregado script X para...
  - Modificado procedimiento Y para mejorar...
  - Documentado parámetro Z en README
  
  ## Pruebas
  - Probado en SQL Server 2019
  - Validado con base de datos de 50GB
  ```

### 7. Revisión de código

- Los mantenedores revisarán tu PR
- Responde a comentarios y realiza ajustes si se solicitan
- Una vez aprobado, se hará merge a la rama principal

---

## Reportar problemas

### Antes de reportar un bug

1. Busca en issues existentes
2. Asegúrate de estar usando la última versión
3. Verifica que no sea un problema de configuración local

### Cómo reportar un bug

Incluye:

```markdown
**Descripción del problema:**
[Descripción clara y concisa]

**Pasos para reproducir:**
1. Ejecutar script X
2. Con parámetros Y
3. Ver error Z

**Comportamiento esperado:**
[Qué debería suceder]

**Comportamiento actual:**
[Qué está sucediendo]

**Entorno:**
- Versión de SQL Server: [ej. 2019]
- Edición: [Standard/Enterprise]
- SO del servidor: [Windows Server 2022]
- Versión de PowerShell: [7.4]

**Logs/Mensajes de error:**
```sql
-- Pegar mensaje de error aquí
```

**Capturas de pantalla:**
[Si aplica]
```

### Solicitar una nueva funcionalidad

```markdown
**Problema que resuelve:**
[Describe el problema o necesidad]

**Solución propuesta:**
[Cómo lo resolverías]

**Alternativas consideradas:**
[Otras opciones que evaluaste]

**Contexto adicional:**
[Información relevante]
```

---

## Estructura del proyecto

```
sql-maintainer/
├── diario_automatico/          # Pipeline de mantenimiento diario
│   ├── PM Daily - Task_M1_V2 - Initial Review.sql
│   ├── PM Daily - Task_M2_V2 - Initial Rebuild.sql
│   ├── ...
│   ├── Setup-SQLAgentJobs.ps1  # Script de automatización
│   └── README.md               # Documentación del pipeline
├── DBA-Globales/               # Consultas globales de análisis
│   ├── ...consultas varias.sql
├── .gitignore
├── CONTRIBUTING.md             # Este archivo
└── README.md                   # README principal (si existe)
```

### Agregar nuevos scripts

**Para scripts SQL:**
1. Coloca en la carpeta apropiada (diario_automatico/ o DBA-Globales/)
2. Usa nombres descriptivos en inglés si es en diario_automatico/
3. Incluye comentarios explicativos al inicio
4. Documenta en el README de la carpeta correspondiente

**Para scripts PowerShell:**
1. Incluye ayuda basada en comentarios completa
2. Agrega ejemplos de uso
3. Documenta en README

---

## Preguntas frecuentes

**P: ¿Puedo contribuir si no tengo experiencia con SQL Server?**
R: ¡Sí! Documentación, pruebas, y reportar issues son contribuciones muy valiosas.

**P: ¿Cuánto tiempo toma que revisen mi PR?**
R: Típicamente dentro de 3-5 días hábiles. Para cambios urgentes, menciona en el PR.

**P: ¿Puedo trabajar en múltiples issues al mismo tiempo?**
R: Es mejor enfocarte en uno a la vez para facilitar la revisión.

**P: ¿Debo actualizar la documentación con cada cambio?**
R: Sí, siempre que tu cambio afecte funcionalidad visible para el usuario.

---

## Recursos útiles

- [Documentación oficial de SQL Server](https://docs.microsoft.com/sql/)
- [Guía de estilo T-SQL](https://www.sqlstyle.guide/)
- [PowerShell Best Practices](https://poshcode.gitbook.io/powershell-practice-and-style/)
- [Markdown Guide](https://www.markdownguide.org/)

---

## Licencia

Al contribuir, aceptas que tus contribuciones se licencien bajo la misma licencia que el proyecto.

---

## Contacto

Si tienes preguntas sobre cómo contribuir, abre un issue con la etiqueta `question`.

¡Gracias por contribuir! 🎉
