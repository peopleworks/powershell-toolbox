<#
.SYNOPSIS
Inventories Windows Run keys and selected scheduled tasks for startup review.
.DESCRIPTION
Read-only. A listed item is not evidence of malware. Output can reveal local paths; keep exports private.
.EXAMPLE
./scripts/system/Get-StartupEntries.ps1 -TaskPattern 'powershell|wscript|AppData'
#>
[CmdletBinding()]
param([string]$TaskPattern = 'powershell|pwsh|wscript|cscript|AppData|chrome|msedge')

if (-not $IsWindows) { throw 'This script requires Windows.' }
foreach ($key in @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
)) {
    if (-not (Test-Path -LiteralPath $key)) { continue }
    $item = Get-ItemProperty -LiteralPath $key
    foreach ($property in $item.PSObject.Properties) {
        if ($property.Name -like 'PS*') { continue }
        [pscustomobject]@{ Type = 'RunKey'; Name = $property.Name; Command = [string]$property.Value; Location = $key }
    }
}
if (Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue) {
    foreach ($task in Get-ScheduledTask -ErrorAction SilentlyContinue) {
        $commands = @($task.Actions | ForEach-Object { "$($_.Execute) $($_.Arguments)" })
        if (($commands -join ' ') -notmatch $TaskPattern) { continue }
        [pscustomobject]@{
            Type = 'ScheduledTask'
            Name = $task.TaskName
            Command = $commands -join '; '
            Location = $task.TaskPath
        }
    }
}
