<#
.SYNOPSIS
Lists processes with suspicious characteristics for manual review.
.DESCRIPTION
Queries running processes and flags those with unusual names, running from temp
folders, missing company information, or with high CPU/memory usage. Returns one
object per suspicious process. Read-only: no process is terminated.
Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/monitor/Get-SuspiciousProcess.ps1 -MinCpu 10 -MinMemoryMB 100
.EXAMPLE
./scripts/monitor/Get-SuspiciousProcess.ps1 -TempFolderOnly
#>
[CmdletBinding()]
param(
    [double]$MinCpu = 5,

    [int]$MinMemoryMB = 50,

    [switch]$TempFolderOnly
)

$suspiciousNames = @('svchost.exe','lsass.exe','spoolsv.exe','explorer.exe','winlogon.exe','services.exe')

$processes = Get-Process -ErrorAction SilentlyContinue

$results = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($p in $processes) {
    try {
        $path = $p.Path
        $company = (Get-ItemProperty -LiteralPath $path -ErrorAction SilentlyContinue).CompanyName
        $cpu = $p.CPU
        $memoryMB = [math]::Round($p.PM / 1MB, 2)
        $nameLower = $p.ProcessName.ToLower()

        $reasons = [System.Collections.Generic.List[string]]::new()

        if ($TempFolderOnly -and $path -and ($path -like '*Temp*' -or $path -like '*temp*')) {
            $reasons.Add('Running from temp folder')
        }

        if ($path -and -not $company) {
            $reasons.Add('Missing company information')
        }

        if ($suspiciousNames -contains $nameLower -and $path -and $path -notlike '*Windows*') {
            $reasons.Add('System-like name outside Windows folder')
        }

        if ($cpu -ge $MinCpu) {
            $reasons.Add("High CPU: $([math]::Round($cpu,2))%")
        }

        if ($memoryMB -ge $MinMemoryMB) {
            $reasons.Add("High memory: $memoryMB MB")
        }

        if ($reasons.Count -gt 0) {
            $results.Add([pscustomobject]@{
                ProcessName   = $p.ProcessName
                Id            = $p.Id
                Path          = $path
                Company       = $company
                CpuPercent    = [math]::Round($cpu, 2)
                MemoryMB      = $memoryMB
                StartTime     = $p.StartTime
                Reasons       = $reasons -join '; '
                Severity      = if ($reasons.Count -ge 3) { 'High' } elseif ($reasons.Count -eq 2) { 'Medium' } else { 'Low' }
            })
        }
    }
    catch {
        # Skip processes we cannot inspect
    }
}

$results | Sort-Object CpuPercent -Descending
