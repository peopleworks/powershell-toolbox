# ⚡ PowerShell Toolbox

**100 scripts · 20 categories · Spanish and English documentation · MIT License**

A curated collection of standalone PowerShell scripts for daily automation: inspecting files, diagnosing networks, reviewing security, managing users, backing up data, monitoring power, printing, IIS, and much more. Each tool runs independently; no installer or module is required.

[🇪🇸 Documentación en español](README.md) · [📄 MIT License](LICENSE) · [🤝 Contributing](CONTRIBUTING.md)

---

## 📦 Tool catalog

| Category | Script | What it does |
|---|---|---|
| 📁 **Files** | [Get-TextEncoding](scripts/files/Get-TextEncoding.ps1) | Identifies BOM and validates UTF-8 |
| 📁 **Files** | [Get-DirectoryInventory](scripts/files/Get-DirectoryInventory.ps1) | Lists files, sizes, and optional hashes |
| 📁 **Files** | [Find-DuplicateFiles](scripts/files/Find-DuplicateFiles.ps1) | Finds identical copies without deleting them |
| 📁 **Files** | [New-ArchiveFromDirectory](scripts/files/New-ArchiveFromDirectory.ps1) | Creates ZIP including hidden files |
| 📁 **Files** | [Clean-TempFiles](scripts/files/Clean-TempFiles.ps1) | Deletes old temp files with `-WhatIf` |
| 🌐 **Network** | [Get-TcpConnections](scripts/network/Get-TcpConnections.ps1) | Lists TCP connections as objects |
| 🌐 **Network** | [Test-Endpoint](scripts/network/Test-Endpoint.ps1) | Checks DNS, TCP and HTTP |
| 🌐 **Network** | [Get-DnsClientConfig](scripts/network/Get-DnsClientConfig.ps1) | DNS configuration of network adapters |
| 🖼️ **Images** | [Convert-HtmlToPng](scripts/web/Convert-HtmlToPng.ps1) | Captures local HTML with Edge or Chrome |
| 🖼️ **Images** | [Compare-Png](scripts/images/Compare-Png.ps1) | Counts pixel-to-pixel changes |
| 🖼️ **Images** | [Convert-DrawioToPng](scripts/images/Convert-DrawioToPng.ps1) | Exports `.drawio` diagrams in batch |
| 🔐 **Security** | [Test-GitStagedContent](scripts/security/Test-GitStagedContent.ps1) | Reviews possible secrets in the Git index |
| 🔐 **Security** | [Get-BrowserExtensions](scripts/security/Get-BrowserExtensions.ps1) | Lists Chrome and Edge extensions |
| 🔐 **Security** | [Get-BrowserPolicies](scripts/security/Get-BrowserPolicies.ps1) | Reads Chrome and Edge policies |
| 🔐 **Security** | [Get-CertificateExpiry](scripts/security/Get-CertificateExpiry.ps1) | Expired or soon-to-expire certificates |
| 🔐 **Security** | [Get-FirewallRules](scripts/security/Get-FirewallRules.ps1) | Windows firewall rules |
| 👤 **Identity** | [Get-LocalUserSummary](scripts/identity/Get-LocalUserSummary.ps1) | Local users, state, logon and groups |
| 📋 **Events** | [Get-WindowsEventErrors](scripts/events/Get-WindowsEventErrors.ps1) | Event Viewer errors in a time window |
| 🔄 **Updates** | [Get-WindowsHotfix](scripts/updates/Get-WindowsHotfix.ps1) | Installed Windows patches |
| 💾 **Backup** | [Copy-BackupFiles](scripts/backup/Copy-BackupFiles.ps1) | Filtered file copy with execution log |
| 🔋 **Power** | [Get-PowerStatus](scripts/power/Get-PowerStatus.ps1) | Battery, power plan and USB devices |
| 🖨️ **Printing** | [Get-PrinterQueue](scripts/printing/Get-PrinterQueue.ps1) | Printers and pending print jobs |
| 🌐 **IIS** | [Get-IisSiteStatus](scripts/iis/Get-IisSiteStatus.ps1) | IIS sites and application pools |
| 🌐 **IIS** | [Get-IISWebsiteLogs](scripts/iis/Get-IISWebsiteLogs.ps1) | Analyze IIS W3C logs by status code |
| 🌐 **IIS** | [Get-IISPerformanceSummary](scripts/iis/Get-IISPerformanceSummary.ps1) | IIS performance counters |
| 🌐 **IIS** | [Get-IISErrorAnalysis](scripts/iis/Get-IISErrorAnalysis.ps1) | 4xx and 5xx error analysis in IIS logs |
| 🌐 **IIS** | [Get-IISAppPoolStatus](scripts/iis/Get-IISAppPoolStatus.ps1) | IIS application pool state |
| 🌐 **IIS** | [Get-IISSiteBindings](scripts/iis/Get-IISSiteBindings.ps1) | IIS site bindings and physical paths |
| 💻 **System** | [Get-PendingReboot](scripts/system/Get-PendingReboot.ps1) | Detects if Windows requires a reboot |
| 💻 **System** | [Get-ScheduledTaskSummary](scripts/system/Get-ScheduledTaskSummary.ps1) | Scheduled task state and last run |
| 💻 **System** | [Get-ServiceStatus](scripts/system/Get-ServiceStatus.ps1) | Service state and start mode |
| 💻 **System** | [Get-ComputerHardware](scripts/system/Get-ComputerHardware.ps1) | Hardware inventory (memory, CPU, disk) |
| 💻 **System** | [Get-StartupEntries](scripts/system/Get-StartupEntries.ps1) | Reviews Run entries and scheduled tasks |
| 💻 **System** | [Invoke-LoggedProcess](scripts/system/Invoke-LoggedProcess.ps1) | Runs with separate logs and timeout |
| ⏳ **Processes** | [Wait-ProcessExit](scripts/system/Wait-ProcessExit.ps1) | Waits without closing processes |
| ⏳ **Processes** | [Wait-CommandSuccess](scripts/system/Wait-CommandSuccess.ps1) | Retries a check until success |
| ⏳ **Processes** | [Invoke-WithMutex](scripts/system/Invoke-WithMutex.ps1) | Serializes tasks across processes |
| 💻 **Code** | [Find-DuplicateCSharpClasses](scripts/code/Find-DuplicateCSharpClasses.ps1) | Flags duplicate C# class names |
| 📊 **Data** | [Test-OdbcConnection](scripts/data/Test-OdbcConnection.ps1) | Checks a DSN without printing credentials |
| 📊 **Data** | [Test-SqlConnection](scripts/data/Test-SqlConnection.ps1) | ODBC connectivity test to SQL Server |
| 📊 **Data** | [Get-CrystalReportInventory](scripts/reports/Get-CrystalReportInventory.ps1) | Inventories `.rpt` report metadata |
| 🗄️ **Database** | [Get-SqlServerBackup](scripts/database/Get-SqlServerBackup.ps1) | Restores SQL Server databases from nightly backup (dbatools) |
| 🗄️ **Database** | [Get-SqlServerBackupDia](scripts/database/Get-SqlServerBackupDia.ps1) | Restores SQL Server databases from mid-day backup (dbatools) |
| 🗄️ **Database** | [Test-SqlServerConnection](scripts/database/Test-SqlServerConnection.ps1) | Tests SQL Server connectivity with dbatools |
| 🗄️ **Database** | [Get-SqlServerDatabaseInfo](scripts/database/Get-SqlServerDatabaseInfo.ps1) | Database info: state, recovery model, size |
| 🗄️ **Database** | [Get-SqlServerAgentJobs](scripts/database/Get-SqlServerAgentJobs.ps1) | SQL Server Agent jobs and last run outcome |
| 🗄️ **Database** | [Get-SqlServerBackupHistory](scripts/database/Get-SqlServerBackupHistory.ps1) | Full, differential, and log backup history |
| 🗄️ **Database** | [Get-SqlServerIndexFragmentation](scripts/database/Get-SqlServerIndexFragmentation.ps1) | Index fragmentation and rebuild/reorganize advice |
| 🗄️ **Database** | [Test-MySqlConnection](scripts/database/Test-MySqlConnection.ps1) | Tests MySQL/MariaDB connectivity via ODBC |
| 🗄️ **Database** | [Test-PostgreSqlConnection](scripts/database/Test-PostgreSqlConnection.ps1) | Tests PostgreSQL connectivity via ODBC |
| 🗄️ **Database** | [Test-OracleConnection](scripts/database/Test-OracleConnection.ps1) | Tests Oracle connectivity via ODBC |
| 🗄️ **Database** | [Test-MongoDbConnection](scripts/database/Test-MongoDbConnection.ps1) | Tests MongoDB connectivity with ping |
| 🗄️ **Database** | [Test-RedisConnection](scripts/database/Test-RedisConnection.ps1) | Tests Redis connectivity with PING |
| 🗄️ **Database** | [Get-ElasticsearchHealth](scripts/database/Get-ElasticsearchHealth.ps1) | Elasticsearch cluster health status |
| ☁️ **Azure** | [Test-AzureConnectivity](scripts/azure/Test-AzureConnectivity.ps1) | Verifies Azure context and authentication |
| ☁️ **Azure** | [Get-AzureVMStatus](scripts/azure/Get-AzureVMStatus.ps1) | VM state and size |
| ☁️ **Azure** | [Get-AzureStorageAccount](scripts/azure/Get-AzureStorageAccount.ps1) | Storage accounts, SKU, and kind |
| ☁️ **Azure** | [Get-AzureKeyVaultSecrets](scripts/azure/Get-AzureKeyVaultSecrets.ps1) | Key Vault secrets (without revealing values) |
| ☁️ **Azure** | [Get-AzureAppService](scripts/azure/Get-AzureAppService.ps1) | App Services, state, and runtime |
| ☁️ **Azure** | [Get-AzureSqlDatabase](scripts/azure/Get-AzureSqlDatabase.ps1) | Azure SQL databases |
| ☁️ **Azure** | [Get-AzureResourceGroup](scripts/azure/Get-AzureResourceGroup.ps1) | Resource groups and location |
| ☁️ **Azure** | [Get-AzureManagedDisk](scripts/azure/Get-AzureManagedDisk.ps1) | Managed disks and SKU |
| ☁️ **Azure** | [Get-AzureNetworkInterface](scripts/azure/Get-AzureNetworkInterface.ps1) | Network interfaces and private IP |
| ☁️ **Azure** | [Get-AzurePublicIP](scripts/azure/Get-AzurePublicIP.ps1) | Public IP addresses |
| ☁️ **Azure** | [Get-AzureADUserSummary](scripts/azure/Get-AzureADUserSummary.ps1) | Azure AD users |
| ☁️ **Azure** | [Get-AzureSubscriptionSummary](scripts/azure/Get-AzureSubscriptionSummary.ps1) | Accessible subscriptions |
| ☁️ **Azure** | [Get-AzureResourceLock](scripts/azure/Get-AzureResourceLock.ps1) | Resource locks |
| ☁️ **Azure** | [Get-AzureVMSizeRecommendation](scripts/azure/Get-AzureVMSizeRecommendation.ps1) | Available VM sizes by location |
| ☁️ **Azure** | [Get-AzureMetricSummary](scripts/azure/Get-AzureMetricSummary.ps1) | Azure Monitor metrics by resource |
| ☁️ **Azure** | [Get-AzureActivityLog](scripts/azure/Get-AzureActivityLog.ps1) | Azure Activity Log entries |
| ☁️ **AWS** | [Test-AWSConnectivity](scripts/aws/Test-AWSConnectivity.ps1) | Verify AWS connectivity and identity |
| ☁️ **AWS** | [Get-AWSEC2Status](scripts/aws/Get-AWSEC2Status.ps1) | AWS EC2 instance state |
| ☁️ **AWS** | [Get-AWSS3Bucket](scripts/aws/Get-AWSS3Bucket.ps1) | AWS S3 buckets with creation date |
| 🐳 **Containers** | [Get-DockerContainerStatus](scripts/containers/Get-DockerContainerStatus.ps1) | Docker container status |
| 🐳 **Containers** | [Test-DockerConnectivity](scripts/containers/Test-DockerConnectivity.ps1) | Docker daemon connectivity |
| 🏢 **Microsoft 365** | [Test-M365Connectivity](scripts/m365/Test-M365Connectivity.ps1) | Exchange Online / M365 connectivity |
| 🏢 **Microsoft 365** | [Get-ExchangeMailboxSummary](scripts/m365/Get-ExchangeMailboxSummary.ps1) | Exchange Online mailboxes |
| 🔊 **Audio** | [Convert-TextToSpeech](scripts/media/Convert-TextToSpeech.ps1) | Creates WAV with Windows SAPI voice |
| 📊 **Monitor** | [Test-HttpAttack](scripts/monitor/Test-HttpAttack.ps1) | Detect HTTP attack patterns from IIS logs |
| 📊 **Monitor** | [Get-PortScanDetection](scripts/monitor/Get-PortScanDetection.ps1) | Detect possible port scanning activity |
| 📊 **Monitor** | [Test-BruteForceAttempt](scripts/monitor/Test-BruteForceAttempt.ps1) | Detect brute-force login attempts |
| 📊 **Monitor** | [Get-SuspiciousProcess](scripts/monitor/Get-SuspiciousProcess.ps1) | Processes with suspicious characteristics |
| 📊 **Monitor** | [Get-OpenPorts](scripts/monitor/Get-OpenPorts.ps1) | Open TCP/UDP ports on local computer |
| 📊 **Monitor** | [Test-FailedLogins](scripts/monitor/Test-FailedLogins.ps1) | Failed login events from Security log |
| 📊 **Monitor** | [Get-NetworkAnomaly](scripts/monitor/Get-NetworkAnomaly.ps1) | Anomalous network connections |
| 📋 **Logs** | [Get-WindowsEventAnalysis](scripts/logs/Get-WindowsEventAnalysis.ps1) | Analyze Windows events by source and level |
| 📋 **Logs** | [Get-IisLogHourlySummary](scripts/logs/Get-IisLogHourlySummary.ps1) | Hourly summary of IIS W3C logs |
| 📋 **Logs** | [Get-FirewallLogAnalysis](scripts/logs/Get-FirewallLogAnalysis.ps1) | Analyze Windows Defender firewall logs |
| 📋 **Logs** | [Get-SystemHealth](scripts/logs/Get-SystemHealth.ps1) | System health summary (CPU, memory, disk) |
| 📋 **Logs** | [Get-LogErrorTrend](scripts/logs/Get-LogErrorTrend.ps1) | Error trend by hour |
| 📋 **Logs** | [Get-EventLogSummary](scripts/logs/Get-EventLogSummary.ps1) | Event log summary by source |
| 📊 **Data** | [Get-CsvSummary](scripts/data/Get-CsvSummary.ps1) | CSV file summary (columns, rows, nulls) |
| 📄 **Reports** | [Get-HealthReport](scripts/reports/Get-HealthReport.ps1) | Consolidated system health report |
| 💻 **System** | [Get-AutoStartAnalysis](scripts/system/Get-AutoStartAnalysis.ps1) | Windows auto-start entries analysis |
| 🔐 **Security** | [Get-DnsCache](scripts/security/Get-DnsCache.ps1) | Local DNS resolver cache entries |
| 🌐 **Network** | [Get-LatencyTest](scripts/network/Get-LatencyTest.ps1) | Latency test to multiple endpoints |
| 📁 **Files** | [Get-LargeFiles](scripts/files/Get-LargeFiles.ps1) | Largest files under a directory |

---

## 🚀 Quick start

Run from the repository root in **PowerShell 7**:

```powershell
# 1. Inspect a text file
./scripts/files/Get-TextEncoding.ps1 -Path ./README.md

# 2. Directory inventory with hashes
./scripts/files/Get-DirectoryInventory.ps1 -Path ./examples -IncludeHash

# 3. Check for staged credentials in Git
./scripts/security/Test-GitStagedContent.ps1 -Repository .

# 4. Create an image capture from HTML
New-Item -ItemType Directory -Force ./.local | Out-Null
./scripts/web/Convert-HtmlToPng.ps1 -Html ./examples/demo.html -Output ./.local/demo.png -Width 1200 -Height 630

# 5. Compare two PNG images
./scripts/images/Compare-Png.ps1 -Reference ./examples/demo.png -Current ./.local/demo.png
```

Examples with your own data (example values, replace them):

```powershell
./scripts/data/Test-OdbcConnection.ps1 -Dsn ExampleDsn -Credential (Get-Credential)
./scripts/reports/Get-CrystalReportInventory.ps1 -Path ./reports -Output ./.local/inventory.json
```

> `ExampleDsn`, `./reports` and `./.local` are example values. Create the output directory before exporting. Inventory files can reveal table names, locations, and prompts; keep them private. `.local/` is ignored by Git. **Never put credentials in scripts or shell history.**

---

## 🧩 Design and principles

- Inspection tools return **PowerShell objects**, ready to pipe into `Where-Object`, `Export-Csv`, and `ConvertTo-Json`.
- Tools that write files require an explicit output path and avoid overwriting unless `-Force` is used.
- Examples use **fictitious names**; no passwords, tokens, private domains, or customer data are included.
- Each script declares its own requirements and includes a reproducible usage example.
- `./tests/Smoke.ps1` validates the syntax of all 37 scripts and runs synthetic cases.

---

## ✅ Checks and contributions

```powershell
./tests/Smoke.ps1
```

The test checks the syntax of all 37 scripts and runs synthetic cases for files, processes, privacy, and images.

Before proposing a tool:

1. Parameterize paths, servers, DSNs, and users. Examples must use fictitious names.
2. Do not include passwords, tokens, connection strings, private domains, customer data, or results generated with them.
3. Document system requirements and write effects. Prefer PowerShell object output.
4. Run `./tests/Smoke.ps1` and manually review the files you are about to commit.
5. Run `./scripts/security/Test-GitStagedContent.ps1 -Repository . -FailOnFindings` after `git add`. Human review is still required.

See [CONTRIBUTING.md](CONTRIBUTING.md) before contributing.

---

<div align="center">

**PowerShell Toolbox** · Practical automation, no dependencies · [MIT License](LICENSE)

</div>
