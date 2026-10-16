# ⚡ PowerShell Toolbox

**37 scripts · 15 categorías · documentación en español e inglés · Licencia MIT**

Una colección curada de scripts de PowerShell para tareas de automatización diaria: inspeccionar archivos, diagnosticar redes, revisar seguridad, administrar usuarios, respaldar datos, monitorear energía, impresión, IIS y mucho más. Cada herramienta se ejecuta por separado; no hay instalador ni módulo obligatorio.

[🇺🇸 English documentation](README.en.md) · [📄 Licencia MIT](LICENSE) · [🤝 Cómo contribuir](CONTRIBUTING.md)

---

## 📦 Catálogo de herramientas

| Categoría | Script | Para qué sirve |
|---|---|---|
| 📁 **Archivos** | [Get-TextEncoding](scripts/files/Get-TextEncoding.ps1) | Identifica BOM y valida UTF-8 |
| 📁 **Archivos** | [Get-DirectoryInventory](scripts/files/Get-DirectoryInventory.ps1) | Lista archivos, tamaños y hashes opcionales |
| 📁 **Archivos** | [Find-DuplicateFiles](scripts/files/Find-DuplicateFiles.ps1) | Encuentra copias idénticas sin borrarlas |
| 📁 **Archivos** | [New-ArchiveFromDirectory](scripts/files/New-ArchiveFromDirectory.ps1) | Crea ZIP incluidos archivos ocultos |
| 📁 **Archivos** | [Clean-TempFiles](scripts/files/Clean-TempFiles.ps1) | Borra archivos temporales antiguos con `-WhatIf` |
| 🌐 **Red** | [Get-TcpConnections](scripts/network/Get-TcpConnections.ps1) | Lista conexiones TCP como objetos |
| 🌐 **Red** | [Test-Endpoint](scripts/network/Test-Endpoint.ps1) | Comprueba DNS, TCP y HTTP |
| 🌐 **Red** | [Get-DnsClientConfig](scripts/network/Get-DnsClientConfig.ps1) | Configuración DNS de adaptadores de red |
| 🖼️ **Imágenes** | [Convert-HtmlToPng](scripts/web/Convert-HtmlToPng.ps1) | Captura HTML local con Edge o Chrome |
| 🖼️ **Imágenes** | [Compare-Png](scripts/images/Compare-Png.ps1) | Cuenta cambios píxel a píxel |
| 🖼️ **Imágenes** | [Convert-DrawioToPng](scripts/images/Convert-DrawioToPng.ps1) | Exporta diagramas `.drawio` en lote |
| 🔐 **Seguridad** | [Test-GitStagedContent](scripts/security/Test-GitStagedContent.ps1) | Revisa posibles secretos en el índice de Git |
| 🔐 **Seguridad** | [Get-BrowserExtensions](scripts/security/Get-BrowserExtensions.ps1) | Lista extensiones de Chrome y Edge |
| 🔐 **Seguridad** | [Get-BrowserPolicies](scripts/security/Get-BrowserPolicies.ps1) | Lee políticas de Chrome y Edge |
| 🔐 **Seguridad** | [Get-CertificateExpiry](scripts/security/Get-CertificateExpiry.ps1) | Certificados expirados o por vencer |
| 🔐 **Seguridad** | [Get-FirewallRules](scripts/security/Get-FirewallRules.ps1) | Reglas del firewall de Windows |
| 👤 **Identidad** | [Get-LocalUserSummary](scripts/identity/Get-LocalUserSummary.ps1) | Usuarios locales, estado, logon y grupos |
| 📋 **Eventos** | [Get-WindowsEventErrors](scripts/events/Get-WindowsEventErrors.ps1) | Errores del Visor de eventos en un periodo |
| 🔄 **Actualizaciones** | [Get-WindowsHotfix](scripts/updates/Get-WindowsHotfix.ps1) | Parches instalados en Windows |
| 💾 **Respaldo** | [Copy-BackupFiles](scripts/backup/Copy-BackupFiles.ps1) | Copia de archivos con registro de ejecución |
| 🔋 **Energía** | [Get-PowerStatus](scripts/power/Get-PowerStatus.ps1) | Batería, plan de energía y dispositivos USB |
| 🖨️ **Impresión** | [Get-PrinterQueue](scripts/printing/Get-PrinterQueue.ps1) | Impresoras y trabajos pendientes |
| 🌐 **IIS** | [Get-IisSiteStatus](scripts/iis/Get-IisSiteStatus.ps1) | Sitios y grupos de aplicaciones de IIS |
| 💻 **Sistema** | [Get-PendingReboot](scripts/system/Get-PendingReboot.ps1) | Detecta si Windows requiere reinicio |
| 💻 **Sistema** | [Get-ScheduledTaskSummary](scripts/system/Get-ScheduledTaskSummary.ps1) | Estado y última ejecución de tareas programadas |
| 💻 **Sistema** | [Get-ServiceStatus](scripts/system/Get-ServiceStatus.ps1) | Estado y modo de inicio de servicios |
| 💻 **Sistema** | [Get-ComputerHardware](scripts/system/Get-ComputerHardware.ps1) | Inventario de hardware (memoria, CPU, disco) |
| 💻 **Sistema** | [Get-StartupEntries](scripts/system/Get-StartupEntries.ps1) | Revisa entradas Run y tareas programadas |
| 💻 **Sistema** | [Invoke-LoggedProcess](scripts/system/Invoke-LoggedProcess.ps1) | Ejecuta con logs separados y timeout |
| ⏳ **Procesos** | [Wait-ProcessExit](scripts/system/Wait-ProcessExit.ps1) | Espera sin cerrar procesos |
| ⏳ **Procesos** | [Wait-CommandSuccess](scripts/system/Wait-CommandSuccess.ps1) | Reintenta una comprobación |
| ⏳ **Procesos** | [Invoke-WithMutex](scripts/system/Invoke-WithMutex.ps1) | Serializa tareas entre procesos |
| 💻 **Código** | [Find-DuplicateCSharpClasses](scripts/code/Find-DuplicateCSharpClasses.ps1) | Señala nombres de clases C# repetidos |
| 📊 **Datos** | [Test-OdbcConnection](scripts/data/Test-OdbcConnection.ps1) | Comprueba un DSN sin imprimir credenciales |
| 📊 **Datos** | [Test-SqlConnection](scripts/data/Test-SqlConnection.ps1) | Prueba de conexión ODBC a SQL Server |
| 📊 **Datos** | [Get-CrystalReportInventory](scripts/reports/Get-CrystalReportInventory.ps1) | Censa metadatos de reportes `.rpt` |
| 🔊 **Audio** | [Convert-TextToSpeech](scripts/media/Convert-TextToSpeech.ps1) | Crea WAV con voz SAPI de Windows |

---

## 🚀 Prueba rápida

Desde la raíz del repositorio, en **PowerShell 7**:

```powershell
# 1. Inspeccionar un archivo de texto
./scripts/files/Get-TextEncoding.ps1 -Path ./README.md

# 2. Inventario de un directorio con hashes
./scripts/files/Get-DirectoryInventory.ps1 -Path ./examples -IncludeHash

# 3. Revisar si hay credenciales staged en Git
./scripts/security/Test-GitStagedContent.ps1 -Repository .

# 4. Crear una captura de imagen desde HTML
New-Item -ItemType Directory -Force ./.local | Out-Null
./scripts/web/Convert-HtmlToPng.ps1 -Html ./examples/demo.html -Output ./.local/demo.png -Width 1200 -Height 630

# 5. Comparar dos imágenes PNG
./scripts/images/Compare-Png.ps1 -Reference ./examples/demo.png -Current ./.local/demo.png
```

Ejemplos con tus propios datos (valores de ejemplo, reemplázalos):

```powershell
./scripts/data/Test-OdbcConnection.ps1 -Dsn ExampleDsn -Credential (Get-Credential)
./scripts/reports/Get-CrystalReportInventory.ps1 -Path ./reports -Output ./.local/inventory.json
```

> `ExampleDsn`, `./reports` y `./.local` son valores de ejemplo. Crea la carpeta de salida antes de exportar. Los archivos de inventario pueden contener nombres de tablas, ubicaciones y prompts: guárdalos fuera del repositorio o bajo `.local/`, que Git ignora. **No pongas contraseñas en scripts ni en el historial de comandos.**

---

## 🧩 Diseño y principios

- Las herramientas de inspección devuelven **objetos de PowerShell**, listos para encadenar con `Where-Object`, `Export-Csv` y `ConvertTo-Json`.
- Las herramientas que escriben archivos requieren una ruta de salida explícita y evitan sobrescribir salvo con `-Force`.
- Los ejemplos usan **nombres ficticios**; nunca se incluyen contraseñas, tokens, dominios privados ni datos de clientes.
- Cada script declara sus propios requisitos y tiene un ejemplo de uso reproducible.
- `./tests/Smoke.ps1` valida la sintaxis de todos los scripts y ejecuta casos sintéticos.

---

## ✅ Comprobación y contribuciones

```powershell
./tests/Smoke.ps1
```

La prueba comprueba la sintaxis de los 37 scripts y ejecuta casos sintéticos para archivos, procesos, privacidad e imágenes.

Antes de proponer una herramienta:

1. Usa parámetros para rutas, servidores, DSN y usuarios. Los ejemplos deben usar nombres ficticios.
2. No incluyas contraseñas, tokens, cadenas de conexión, dominios privados, datos de clientes ni resultados generados con ellos.
3. Documenta requisitos de sistema y efectos de escritura. Prefiere salida en objetos de PowerShell.
4. Ejecuta `./tests/Smoke.ps1` y revisa manualmente los archivos que vayas a confirmar.
5. Ejecuta `./scripts/security/Test-GitStagedContent.ps1 -Repository . -FailOnFindings` después de `git add`. La revisión humana sigue siendo necesaria.

Consulta [CONTRIBUTING.md](CONTRIBUTING.md) antes de contribuir.

---

<div align="center">

**PowerShell Toolbox** · Automatización práctica, sin dependencias · [MIT License](LICENSE)

</div>
