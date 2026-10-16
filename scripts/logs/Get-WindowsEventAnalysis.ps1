<#
.SYNOPSIS
Analyzes Windows event logs and returns a summary of errors by source and level.
.DESCRIPTION
Queries System and Application event logs for Error and Warning entries within a
time window, returning one object per source with count, most recent event, and IDs.
Read-only: no event log is modified. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/logs/Get-WindowsEventAnalysis.ps1 -LogName System -HoursBack 24
.EXAMPLE
./scripts/logs/Get-WindowsEventAnalysis.ps1 -LogName Application -HoursBack 48 -Level Error
#>
[CmdletBinding()]
param(
    [ValidateSet('System', 'Application', 'Security')]
    [string]$LogName = 'System',

    [int]$HoursBack = 24,

    [ValidateSet('Error', 'Warning', 'Information')]
    [string]$Level = 'Error'
)

$startTime = (Get-Date).AddHours(-$HoursBack)

$levelMap = @{ 'Error' = 2; 'Warning' = 3; 'Information' = 4 }
$levelId = $levelMap[$Level]

try {
    $events = Get-WinEvent -LogName $LogName -Level $levelId -StartTime $startTime -ErrorAction Stop
}
catch {
    Write-Warning "No se pudo leer el registro '$LogName'."
    return
}

$events |
    Group-Object ProviderName |
    ForEach-Object {
        $group = $_.Group
        [pscustomobject]@{
            Source       = $_.Name
            EventCount   = $group.Count
            LatestEvent  = ($group | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated
            EventIds     = ($group.Id | Sort-Object -Unique) -join ', '
            LogName      = $LogName
            Level        = $Level
        }
    } |
    Sort-Object EventCount -Descending
