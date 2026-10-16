<#
.SYNOPSIS
Returns error trend from Windows event logs grouped by hour.
.DESCRIPTION
Queries System and Application logs for Error events and groups them by hour
within -HoursBack. Returns one object per hour with error count and top event IDs.
Read-only. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/logs/Get-LogErrorTrend.ps1 -HoursBack 24
.EXAMPLE
./scripts/logs/Get-LogErrorTrend.ps1 -HoursBack 48 -LogName Application
#>
[CmdletBinding()]
param(
    [ValidateSet('System', 'Application')]
    [string[]]$LogName = @('System', 'Application'),

    [int]$HoursBack = 24
)

$startTime = (Get-Date).AddHours(-$HoursBack)

$events = Get-WinEvent -LogName $LogName -Level 2 -StartTime $startTime -ErrorAction SilentlyContinue

$events |
    ForEach-Object {
        $hourKey = $_.TimeCreated.ToString('yyyy-MM-dd HH')
        [pscustomobject]@{
            Hour     = $hourKey
            EventId  = $_.Id
            Source   = $_.ProviderName
            LogName  = $_.LogName
        }
    } |
    Group-Object Hour |
    ForEach-Object {
        $group = $_.Group
        [pscustomobject]@{
            Hour           = $_.Name
            ErrorCount     = $group.Count
            TopEventIds    = ($group.EventId | Group-Object | Sort-Object Count -Descending | Select-Object -First 5 -ExpandProperty Name) -join ', '
            Sources        = ($group.Source | Sort-Object -Unique) -join ', '
            LogNames       = ($group.LogName | Sort-Object -Unique) -join ', '
        }
    } |
    Sort-Object Hour
