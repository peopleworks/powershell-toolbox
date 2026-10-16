<#
.SYNOPSIS
Retries a Boolean check until it succeeds or the timeout expires.
.EXAMPLE
./scripts/system/Wait-CommandSuccess.ps1 -Check { Test-Path ./ready.flag } -TimeoutSeconds 30
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][scriptblock]$Check,
    [ValidateRange(0, 86400)][int]$TimeoutSeconds = 60,
    [ValidateRange(1, 60)][int]$IntervalSeconds = 2
)

$watch = [Diagnostics.Stopwatch]::StartNew()
$attempts = 0; $success = $false; $lastError = $null
do {
    $attempts++
    try {
        $success = [bool](& $Check)
        $lastError = $null
    } catch {
        $success = $false
        $lastError = $_.Exception.Message
    }
    if ($success -or $watch.Elapsed.TotalSeconds -ge $TimeoutSeconds) { break }
    Start-Sleep -Seconds $IntervalSeconds
} while ($true)
[pscustomobject]@{
    Succeeded = $success
    Attempts = $attempts
    ElapsedSeconds = [math]::Round($watch.Elapsed.TotalSeconds, 2)
    LastError = $lastError
}
