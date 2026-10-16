<#
.SYNOPSIS
Waits for processes with a given name to exit; never terminates them.
.EXAMPLE
./scripts/system/Wait-ProcessExit.ps1 -Name msbuild -TimeoutSeconds 60
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Name,
    [ValidateRange(0, 86400)][int]$TimeoutSeconds = 60,
    [ValidateRange(1, 60)][int]$IntervalSeconds = 2
)

$watch = [Diagnostics.Stopwatch]::StartNew()
do {
    $running = @(Get-Process -Name $Name -ErrorAction SilentlyContinue)
    if ($running.Count -eq 0) { break }
    if ($watch.Elapsed.TotalSeconds -ge $TimeoutSeconds) { break }
    Start-Sleep -Seconds $IntervalSeconds
} while ($true)
[pscustomobject]@{
    Name = $Name
    Exited = $running.Count -eq 0
    RemainingProcessIds = @($running.Id)
    WaitedSeconds = [math]::Round($watch.Elapsed.TotalSeconds, 2)
}
