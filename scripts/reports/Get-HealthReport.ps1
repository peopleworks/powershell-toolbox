<#
.SYNOPSIS
Generates a consolidated health report of the local computer.
.DESCRIPTION
Combines system health, pending reboot status, disk space, and recent event errors
into a single report object. Suitable for scheduled execution and automated review.
Read-only. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/reports/Get-HealthReport.ps1 | ConvertTo-Json -Depth 3
.EXAMPLE
./scripts/reports/Get-HealthReport.ps1 -OutputPath ./health_report.json
#>
[CmdletBinding()]
param(
    [string]$OutputPath
)

$health = & (Join-Path $PSScriptRoot '..\logs\Get-SystemHealth.ps1') -ErrorAction SilentlyContinue

$pendingReboot = & (Join-Path $PSScriptRoot '..\system\Get-PendingReboot.ps1') -ErrorAction SilentlyContinue

$eventErrors = Get-WinEvent -LogName System -Level 2 -StartTime ((Get-Date).AddHours(-24)) -MaxEvents 100 -ErrorAction SilentlyContinue

$lowDisks = if ($health.Disks) { $health.Disks | Where-Object { $_.FreePct -lt 15 } } else { $null }

$report = [pscustomobject]@{
    Generated       = Get-Date
    ComputerName    = $health.ComputerName
    OsName          = $health.OsName
    OsVersion       = $health.OsVersion
    CpuPercent      = $health.CpuPercent
    MemoryUsedPct   = $health.MemoryUsedPct
    UptimeDays      = $health.UptimeDays
    PendingReboot   = if ($pendingReboot) { $pendingReboot.PendingReboot } else { $false }
    PendingReasons  = if ($pendingReboot) { $pendingReboot.Reasons } else { $null }
    LowDiskDrives   = $lowDisks
    RecentErrors    = $eventErrors.Count
    OverallStatus   = 'OK'
}

if ($health.HealthScore -eq 'Warning' -or $lowDisks -or $pendingReboot.PendingReboot -eq $true -or $eventErrors.Count -gt 50) {
    $report.OverallStatus = 'Warning'
}

if ($OutputPath) {
    $report | ConvertTo-Json -Depth 4 | Out-File -FilePath $OutputPath -Encoding utf8
}

$report
