<#
.SYNOPSIS
Returns a summary of Windows event logs by source and level.
.DESCRIPTION
Queries System, Application, and Setup logs and returns one object per source with
total events, error count, warning count, and most recent event time.
Read-only. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/logs/Get-EventLogSummary.ps1 -LogName System
.EXAMPLE
./scripts/logs/Get-EventLogSummary.ps1 -MaxSources 20
#>
[CmdletBinding()]
param(
    [ValidateSet('System', 'Application', 'Setup', 'Security')]
    [string[]]$LogName = @('System', 'Application'),

    [int]$MaxSources = 30
)

$startTime = (Get-Date).AddDays(-7)

$events = Get-WinEvent -LogName $LogName -StartTime $startTime -ErrorAction SilentlyContinue

$events |
    Group-Object ProviderName |
    Select-Object -First $MaxSources |
    ForEach-Object {
        $group = $_.Group
        [pscustomobject]@{
            Source           = $_.Name
            TotalEvents      = $group.Count
            Errors           = ($group | Where-Object { $_.Level -eq 2 }).Count
            Warnings         = ($group | Where-Object { $_.Level -eq 3 }).Count
            Informations     = ($group | Where-Object { $_.Level -eq 4 }).Count
            LatestEvent      = ($group | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated
            TopEventIds      = ($group.Id | Group-Object | Sort-Object Count -Descending | Select-Object -First 3 -ExpandProperty Name) -join ', '
        }
    } |
    Sort-Object TotalEvents -Descending
