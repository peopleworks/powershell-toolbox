<#
.SYNOPSIS
Retrieves error and warning events from Windows event logs within a time window.
.DESCRIPTION
Queries Get-WinEvent for System and Application logs (configurable) and returns one
object per matching event with time, ID, level, source and message. Read-only: no
event log is modified or cleared. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/events/Get-WindowsEventErrors.ps1 -LogName System -HoursBack 24
.EXAMPLE
./scripts/events/Get-WindowsEventErrors.ps1 -LogName Application -EntryType Error -Source 'MiServicio' -MaxEvents 50
#>
[CmdletBinding()]
param(
    [ValidateSet('System', 'Application', 'Security', 'Setup')]
    [string[]]$LogName = @('System', 'Application'),

    [int]$HoursBack = 24,

    [ValidateSet('Error', 'Warning', 'Information')]
    [string[]]$EntryType,

    [string]$Source,

    [int]$MaxEvents = 100
)

$startTime = (Get-Date).AddHours(-$HoursBack)

$filter = @{
    LogName      = $LogName
    StartTime    = $startTime
    MaxEvents    = $MaxEvents
}

if ($PSBoundParameters.ContainsKey('EntryType')) {
    $levels = $EntryType | ForEach-Object {
        switch ($_ ) {
            'Error'      { 2 }
            'Warning'    { 3 }
            'Information' { 4 }
            default       { 2 }
        }
    }
    $filter['Level'] = $levels
}

try {
    $events = Get-WinEvent @filter -ErrorAction Stop
}
catch {
    Write-Warning "No se pudieron leer los registros de eventos: $($_.Exception.Message)"
    return
}

$events |
    Where-Object {
        if ($PSBoundParameters.ContainsKey('Source') -and $_.ProviderName -notlike "*$Source*") {
            $false
        } else {
            $true
        }
    } |
    ForEach-Object {
        [pscustomobject]@{
            TimeCreated = $_.TimeCreated
            Id          = $_.Id
            Level       = $_.LevelDisplayName
            Source      = $_.ProviderName
            Message     = $_.Message
            Computer    = $_.MachineName
            Log         = $_.LogName
        }
    } |
    Sort-Object TimeCreated -Descending
