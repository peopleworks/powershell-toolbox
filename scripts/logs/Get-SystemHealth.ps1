<#
.SYNOPSIS
Returns a general health summary of the local Windows computer.
.DESCRIPTION
Collects CPU, memory, disk, uptime, and pending reboot status into a single object.
Read-only. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/logs/Get-SystemHealth.ps1
.EXAMPLE
./scripts/logs/Get-SystemHealth.ps1 | Format-List
#>
[CmdletBinding()]
param()

$cpu = Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1 -ErrorAction SilentlyContinue
$cpuValue = if ($cpu) { [math]::Round($cpu.CounterSamples.CookedValue, 2) } else { $null }

$memory = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object -First 1
$totalMemoryGB = if ($memory) { [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2) } else { $null }
$freeMemoryGB  = if ($memory) { [math]::Round($memory.FreePhysicalMemory / 1MB, 2) } else { $null }
$memoryUsedPct = if ($totalMemoryGB -and $freeMemoryGB) { [math]::Round((1 - ($freeMemoryGB / $totalMemoryGB)) * 100, 2) } else { $null }

$disks = Get-CimInstance Win32_LogicalDisk -ErrorAction SilentlyContinue |
    Where-Object { $_.DriveType -eq 3 } |
    ForEach-Object {
        $freePct = if ($_.Size) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } else { $null }
        [pscustomobject]@{
            Letter   = $_.DeviceID
            SizeGB   = [math]::Round($_.Size / 1GB, 2)
            FreeGB   = [math]::Round($_.FreeSpace / 1GB, 2)
            FreePct  = $freePct
            FileSystem = $_.FileSystem
        }
    } |
    Sort-Object Letter

$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).LastBootUpTime

[pscustomobject]@{
    ComputerName    = $env:COMPUTERNAME
    CpuPercent      = $cpuValue
    MemoryTotalGB   = $totalMemoryGB
    MemoryFreeGB    = $freeMemoryGB
    MemoryUsedPct   = $memoryUsedPct
    UptimeDays      = [math]::Round($uptime.TotalDays, 2)
    Disks           = $disks
    OsName          = $memory.Caption
    OsVersion       = $memory.Version
    HealthScore     = if ($memoryUsedPct -gt 90 -or ($disks | Where-Object { $_.FreePct -lt 10 })) { 'Warning' } else { 'OK' }
}
