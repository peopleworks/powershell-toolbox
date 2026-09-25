# PowerShell Toolbox

![PowerShell Toolbox preview](examples/demo.png)

A small collection of standalone PowerShell scripts for file inspection, connection diagnostics, and visual evidence. No installer or module is required.

**[Documentación en español](README.md)** · [MIT license](LICENSE)

| Tool | Purpose | Requirement |
| --- | --- | --- |
| [Get-TextEncoding](scripts/files/Get-TextEncoding.ps1) | Detect Unicode BOMs and validate UTF-8 without guessing legacy encodings | PowerShell 7+ |
| [Get-TcpConnections](scripts/network/Get-TcpConnections.ps1) | Exportable Windows TCP connection objects | Windows, `Get-NetTCPConnection` |
| [Convert-HtmlToPng](scripts/web/Convert-HtmlToPng.ps1) | Capture local HTML with headless Edge or Chrome | Edge or Chrome |
| [Compare-Png](scripts/images/Compare-Png.ps1) | Count changed pixels and optionally create a visual diff | Windows, PowerShell 7+ |
| [Test-OdbcConnection](scripts/data/Test-OdbcConnection.ps1) | Check a DSN, shell architecture, and connection time | Compatible ODBC driver |
| [Get-CrystalReportInventory](scripts/reports/Get-CrystalReportInventory.ps1) | Inventory `.rpt` parameters, tables, and subreports | Matching SAP Crystal Reports runtime |

## Quick start

Run from the repository root in PowerShell 7:

```powershell
./scripts/files/Get-TextEncoding.ps1 -Path ./README.md
./scripts/network/Get-TcpConnections.ps1 -State Established -IncludeProcessName |
    Select-Object -First 10
./scripts/web/Convert-HtmlToPng.ps1 -Html ./examples/demo.html -Width 1200 -Height 630
./scripts/images/Compare-Png.ps1 -Reference ./examples/demo.png -Current ./examples/demo.png
```

For your own data sources:

```powershell
./scripts/data/Test-OdbcConnection.ps1 -Dsn ExampleDsn -Credential (Get-Credential)
./scripts/reports/Get-CrystalReportInventory.ps1 -Path ./reports -Output ./.local/inventory.json
```

Replace the example DSN and paths with your own. Create the output directory first. A report inventory can reveal table names, locations, and prompts; keep it private. `.local/` is ignored by Git. Never put credentials in scripts or shell history.

The scripts were adapted from working utilities and rewritten for general use. This repository contains no customer configuration, output, or data. Run `./tests/Smoke.ps1` for syntax, encoding, and Windows image checks. See [CONTRIBUTING.md](CONTRIBUTING.md) before contributing.
