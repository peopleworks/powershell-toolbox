<#
.SYNOPSIS
Inventories Crystal Reports files using an installed Crystal Reports runtime.
.DESCRIPTION
Reads report metadata only. The optional JSON output may reveal report names,
database table locations, and prompts; keep generated inventories private.
.EXAMPLE
./scripts/reports/Get-CrystalReportInventory.ps1 -Path ./reports
.EXAMPLE
./scripts/reports/Get-CrystalReportInventory.ps1 -Path ./reports -Output ./private/inventory.json
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })][string]$Path,
    [string]$Output
)

$ErrorActionPreference = 'Stop'
try {
    Add-Type -AssemblyName CrystalDecisions.CrystalReports.Engine -ErrorAction Stop
} catch {
    throw 'Crystal Reports runtime is unavailable. Install the matching runtime and use PowerShell with the same architecture (x86 or x64).'
}

$root = (Resolve-Path -LiteralPath $Path).ProviderPath.TrimEnd('\', '/')
$reports = @(Get-ChildItem -LiteralPath $root -Filter '*.rpt' -Recurse -File | Sort-Object FullName)
$inventory = @(foreach ($file in $reports) {
    $document = [CrystalDecisions.CrystalReports.Engine.ReportDocument]::new()
    $relativePath = $file.FullName.Substring($root.Length).TrimStart('\', '/')
    try {
        $document.Load($file.FullName, [CrystalDecisions.Shared.OpenReportMethod]::OpenReportByTempCopy)
        $parameters = @($document.DataDefinition.ParameterFields | ForEach-Object {
            [pscustomobject]@{ Name = $_.Name; Type = [string]$_.ParameterValueKind; Prompt = $_.PromptText }
        })
        $tables = @($document.Database.Tables | ForEach-Object {
            [pscustomobject]@{ Name = $_.Name; Location = $_.Location }
        })
        [pscustomobject]@{
            Report = $relativePath
            Parameters = $parameters
            Tables = $tables
            SubreportCount = $document.Subreports.Count
            Error = $null
        }
    } catch {
        [pscustomobject]@{
            Report = $relativePath
            Parameters = @()
            Tables = @()
            SubreportCount = 0
            Error = $_.Exception.Message
        }
    } finally {
        try { $document.Close() } catch { }
        $document.Dispose()
    }
})

if ($Output) {
    $outputPath = [System.IO.Path]::GetFullPath($Output)
    $outputDirectory = Split-Path -Parent $outputPath
    if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
        throw "Output directory does not exist: $outputDirectory"
    }
    ConvertTo-Json -InputObject @($inventory) -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding utf8
}
$inventory
