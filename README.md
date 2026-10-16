# ⚡ PowerShell Toolbox

**81 scripts · 20 categorías · documentación en español e inglés · Licencia MIT**

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
| 🌐 **IIS** | [Get-IISWebsiteLogs](scripts/iis/Get-IISWebsiteLogs.ps1) | Analiza logs W3C de IIS por código de estado |
| 🌐 **IIS** | [Get-IISPerformanceSummary](scripts/iis/Get-IISPerformanceSummary.ps1) | Contadores de rendimiento de IIS |
| 🌐 **IIS** | [Get-IISErrorAnalysis](scripts/iis/Get-IISErrorAnalysis.ps1) | Análisis de errores 4xx y 5xx en logs de IIS |
| 🌐 **IIS** | [Get-IISAppPoolStatus](scripts/iis/Get-IISAppPoolStatus.ps1) | Estado de grupos de aplicaciones de IIS |
| 🌐 **IIS** | [Get-IISSiteBindings](scripts/iis/Get-IISSiteBindings.ps1) | Enlaces y sitios de IIS |
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
| 🗄️ **Base de datos** | [Get-SqlServerBackup](scripts/database/Get-SqlServerBackup.ps1) | Restaura BD de SQL Server desde backup nocturno (dbatools) |
| 🗄️ **Base de datos** | [Get-SqlServerBackupDia](scripts/database/Get-SqlServerBackupDia.ps1) | Restaura BD de SQL Server desde backup medio día (dbatools) |
| 🗄️ **Base de datos** | [Test-SqlServerConnection](scripts/database/Test-SqlServerConnection.ps1) | Prueba conectividad a SQL Server con dbatools |
| 🗄️ **Base de datos** | [Get-SqlServerDatabaseInfo](scripts/database/Get-SqlServerDatabaseInfo.ps1) | Info de bases de datos: estado, recuperación, tamaño |
| 🗄️ **Base de datos** | [Get-SqlServerAgentJobs](scripts/database/Get-SqlServerAgentJobs.ps1) | Trabajos de SQL Server Agent y último resultado |
| 🗄️ **Base de datos** | [Get-SqlServerBackupHistory](scripts/database/Get-SqlServerBackupHistory.ps1) | Historial de backups completos, diferenciales y de log |
| 🗄️ **Base de datos** | [Get-SqlServerIndexFragmentation](scripts/database/Get-SqlServerIndexFragmentation.ps1) | Fragmentación de índices y recomendación de rebuild |
| 🗄️ **Base de datos** | [Test-MySqlConnection](scripts/database/Test-MySqlConnection.ps1) | Prueba conexión a MySQL/MariaDB vía ODBC |
| 🗄️ **Base de datos** | [Test-PostgreSqlConnection](scripts/database/Test-PostgreSqlConnection.ps1) | Prueba conexión a PostgreSQL vía ODBC |
| 🗄️ **Base de datos** | [Test-OracleConnection](scripts/database/Test-OracleConnection.ps1) | Prueba conexión a Oracle vía ODBC |
| 🗄️ **Base de datos** | [Test-MongoDbConnection](scripts/database/Test-MongoDbConnection.ps1) | Prueba conexión a MongoDB con ping |
| 🗄️ **Base de datos** | [Test-RedisConnection](scripts/database/Test-RedisConnection.ps1) | Prueba conexión a Redis con PING |
| 🗄️ **Base de datos** | [Get-ElasticsearchHealth](scripts/database/Get-ElasticsearchHealth.ps1) | Salud de clúster de Elasticsearch |
| ☁️ **Azure** | [Test-AzureConnectivity](scripts/azure/Test-AzureConnectivity.ps1) | Verifica contexto y autenticación a Azure |
| ☁️ **Azure** | [Get-AzureVMStatus](scripts/azure/Get-AzureVMStatus.ps1) | Estado y tamaño de máquinas virtuales |
| ☁️ **Azure** | [Get-AzureStorageAccount](scripts/azure/Get-AzureStorageAccount.ps1) | Cuentas de almacenamiento, SKU y tipo |
| ☁️ **Azure** | [Get-AzureKeyVaultSecrets](scripts/azure/Get-AzureKeyVaultSecrets.ps1) | Secretos de Key Vault (sin mostrar valores) |
| ☁️ **Azure** | [Get-AzureAppService](scripts/azure/Get-AzureAppService.ps1) | App Services, estado y runtime |
| ☁️ **Azure** | [Get-AzureSqlDatabase](scripts/azure/Get-AzureSqlDatabase.ps1) | Bases de datos SQL de Azure |
| ☁️ **Azure** | [Get-AzureResourceGroup](scripts/azure/Get-AzureResourceGroup.ps1) | Grupos de recursos y ubicación |
| ☁️ **Azure** | [Get-AzureManagedDisk](scripts/azure/Get-AzureManagedDisk.ps1) | Discos gestionados y SKU |
| ☁️ **Azure** | [Get-AzureNetworkInterface](scripts/azure/Get-AzureNetworkInterface.ps1) | Interfaces de red e IP privada |
| ☁️ **Azure** | [Get-AzurePublicIP](scripts/azure/Get-AzurePublicIP.ps1) | Direcciones IP públicas |
| ☁️ **Azure** | [Get-AzureADUserSummary](scripts/azure/Get-AzureADUserSummary.ps1) | Usuarios de Azure AD |
| ☁️ **Azure** | [Get-AzureSubscriptionSummary](scripts/azure/Get-AzureSubscriptionSummary.ps1) | Suscripciones accesibles |
| ☁️ **Azure** | [Get-AzureResourceLock](scripts/azure/Get-AzureResourceLock.ps1) | Bloqueos de recursos |
| ☁️ **Azure** | [Get-AzureVMSizeRecommendation](scripts/azure/Get-AzureVMSizeRecommendation.ps1) | Tamaños de VM disponibles por ubicación |
| ☁️ **Azure** | [Get-AzureMetricSummary](scripts/azure/Get-AzureMetricSummary.ps1) | Métricas de Azure Monitor por recurso |
| ☁️ **Azure** | [Get-AzureActivityLog](scripts/azure/Get-AzureActivityLog.ps1) | Entradas del registro de actividad de Azure |
| ☁️ **AWS** | [Test-AWSConnectivity](scripts/aws/Test-AWSConnectivity.ps1) | Verifica conectividad e identidad de AWS |
| ☁️ **AWS** | [Get-AWSEC2Status](scripts/aws/Get-AWSEC2Status.ps1) | Estado de instancias EC2 de AWS |
| ☁️ **AWS** | [Get-AWSS3Bucket](scripts/aws/Get-AWSS3Bucket.ps1) | Cubos S3 de AWS con fecha de creación |
| 🐳 **Contenedores** | [Get-DockerContainerStatus](scripts/containers/Get-DockerContainerStatus.ps1) | Estado de contenedores Docker |
| 🐳 **Contenedores** | [Test-DockerConnectivity](scripts/containers/Test-DockerConnectivity.ps1) | Conectividad al demonio de Docker |
| 🏢 **Microsoft 365** | [Test-M365Connectivity](scripts/m365/Test-M365Connectivity.ps1) | Conectividad a Exchange Online / M365 |
| 🏢 **Microsoft 365** | [Get-ExchangeMailboxSummary](scripts/m365/Get-ExchangeMailboxSummary.ps1) | Buzones de Exchange Online |
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
