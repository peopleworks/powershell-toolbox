<#
.SYNOPSIS
Analyzes Windows auto-start entries (Run keys and scheduled tasks).
.DESCRIPTION
Reviews Run/RunOnce registry keys and scheduled tasks to identify programs that
start automatically. Returns one object per entry with name, path, and location.
Read-only: no entry is modified. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/system/Get-AutoStartAnalysis.ps1
#>
[CmdletBinding()]
param()

$runKeys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
)

$entries = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($keyPath in $runKeys) {
    if (Test-Path -LiteralPath $keyPath) {
        $items = Get-ItemProperty -LiteralPath $keyPath -ErrorAction SilentlyContinue
        if ($items) {
            $items.PSObject.Properties | Where-Object { $_.Name -notin @('PSPath','PSParentPath','PSChildName','PSDrive','PSProvider') } |
                ForEach-Object {
                    $entries.Add([pscustomobject]@{
                        Name       = $_.Name
                        Path       = $_.Value
                        Location   = $keyPath
                        Type       = 'Registry Run Key'
                    })
                }
        }
    }
}

try {
    $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue |
        Where-Object { [bool]($_.Settings.Enabled) } |
        Select-Object -First 50

    foreach ($task in $tasks) {
        $entries.Add([pscustomobject]@{
            Name       = $task.TaskName
            Path       = $task.Actions | ForEach-Object { $_.Execute } -join '; '
            Location   = $task.FolderPath
            Type       = 'Scheduled Task'
        })
    }
}
catch {
    # Skip if scheduled tasks module not available
}

$entries | Sort-Object Location, Name
