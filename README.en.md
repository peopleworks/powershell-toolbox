# PowerShell Toolbox

**37 scripts · 15 categories · Spanish and English documentation**

![PowerShell Toolbox catalog preview](docs/preview.png)

A curated collection of standalone PowerShell scripts for files, networks, security, images, data, and automation. No installer or module is required.

**[Explore the interactive catalog](https://peopleworks.github.io/powershell-toolbox/)** · [Documentación en español](README.md) · [MIT license](LICENSE)

| Topic | Tools |
| --- | --- |
| Files | [Get-TextEncoding](scripts/files/Get-TextEncoding.ps1), [Get-DirectoryInventory](scripts/files/Get-DirectoryInventory.ps1), [Find-DuplicateFiles](scripts/files/Find-DuplicateFiles.ps1), [New-ArchiveFromDirectory](scripts/files/New-ArchiveFromDirectory.ps1), [Clean-TempFiles](scripts/files/Clean-TempFiles.ps1) |
| Network | [Get-TcpConnections](scripts/network/Get-TcpConnections.ps1), [Test-Endpoint](scripts/network/Test-Endpoint.ps1), [Get-DnsClientConfig](scripts/network/Get-DnsClientConfig.ps1) |
| Images | [Convert-HtmlToPng](scripts/web/Convert-HtmlToPng.ps1), [Compare-Png](scripts/images/Compare-Png.ps1), [Convert-DrawioToPng](scripts/images/Convert-DrawioToPng.ps1) |
| Security | [Test-GitStagedContent](scripts/security/Test-GitStagedContent.ps1), [Get-BrowserExtensions](scripts/security/Get-BrowserExtensions.ps1), [Get-BrowserPolicies](scripts/security/Get-BrowserPolicies.ps1), [Get-StartupEntries](scripts/system/Get-StartupEntries.ps1), [Get-CertificateExpiry](scripts/security/Get-CertificateExpiry.ps1), [Get-FirewallRules](scripts/security/Get-FirewallRules.ps1) |
| Code | [Find-DuplicateCSharpClasses](scripts/code/Find-DuplicateCSharpClasses.ps1) |
| Data | [Test-OdbcConnection](scripts/data/Test-OdbcConnection.ps1), [Get-CrystalReportInventory](scripts/reports/Get-CrystalReportInventory.ps1), [Test-SqlConnection](scripts/data/Test-SqlConnection.ps1) |
| Processes | [Wait-ProcessExit](scripts/system/Wait-ProcessExit.ps1), [Invoke-LoggedProcess](scripts/system/Invoke-LoggedProcess.ps1), [Wait-CommandSuccess](scripts/system/Wait-CommandSuccess.ps1), [Invoke-WithMutex](scripts/system/Invoke-WithMutex.ps1) |
| System | [Get-PendingReboot](scripts/system/Get-PendingReboot.ps1), [Get-ScheduledTaskSummary](scripts/system/Get-ScheduledTaskSummary.ps1), [Get-ServiceStatus](scripts/system/Get-ServiceStatus.ps1), [Get-ComputerHardware](scripts/system/Get-ComputerHardware.ps1) |
| Audio | [Convert-TextToSpeech](scripts/media/Convert-TextToSpeech.ps1) |
| Identity | [Get-LocalUserSummary](scripts/identity/Get-LocalUserSummary.ps1) |
| Events | [Get-WindowsEventErrors](scripts/events/Get-WindowsEventErrors.ps1) |
| Updates | [Get-WindowsHotfix](scripts/updates/Get-WindowsHotfix.ps1) |
| Backup | [Copy-BackupFiles](scripts/backup/Copy-BackupFiles.ps1) |
| Power | [Get-PowerStatus](scripts/power/Get-PowerStatus.ps1) |
| Printing | [Get-PrinterQueue](scripts/printing/Get-PrinterQueue.ps1) |
| IIS | [Get-IisSiteStatus](scripts/iis/Get-IisSiteStatus.ps1) |

## Quick start

Run from the repository root in PowerShell 7:

```powershell
./scripts/files/Get-TextEncoding.ps1 -Path ./README.md
./scripts/files/Get-DirectoryInventory.ps1 -Path ./examples -IncludeHash
./scripts/security/Test-GitStagedContent.ps1 -Repository .
New-Item -ItemType Directory -Force ./.local | Out-Null
./scripts/web/Convert-HtmlToPng.ps1 -Html ./examples/demo.html -Output ./.local/demo.png -Width 1200 -Height 630
./scripts/images/Compare-Png.ps1 -Reference ./examples/demo.png -Current ./.local/demo.png
```

For your own data sources:

```powershell
./scripts/data/Test-OdbcConnection.ps1 -Dsn ExampleDsn -Credential (Get-Credential)
./scripts/reports/Get-CrystalReportInventory.ps1 -Path ./reports -Output ./.local/inventory.json
```

Replace the example DSN and paths with your own. Create the output directory first. A report inventory can reveal table names, locations, and prompts; keep it private. `.local/` is ignored by Git. Never put credentials in scripts or shell history.

The scripts were adapted from working utilities and rewritten for general use. This repository contains no customer configuration, output, or data. The staged-content scan is heuristic and does not replace human review. Run `./tests/Smoke.ps1` for syntax and synthetic file, process, and image checks. See [CONTRIBUTING.md](CONTRIBUTING.md) before contributing.
