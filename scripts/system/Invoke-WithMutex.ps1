<#
.SYNOPSIS
Serializes a script block across processes with a named mutex.
.EXAMPLE
./scripts/system/Invoke-WithMutex.ps1 -Name example-build -Action { dotnet build ./App.sln }
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$Name,
    [Parameter(Mandatory)][scriptblock]$Action,
    [ValidateRange(1, 86400)][int]$TimeoutSeconds = 300
)

$mutexName = if ($IsWindows) { "Local\PowerShellToolbox.$Name" } else { "PowerShellToolbox.$Name" }
$mutex = [Threading.Mutex]::new($false, $mutexName)
$acquired = $false
try {
    try {
        $acquired = $mutex.WaitOne($TimeoutSeconds * 1000)
    } catch [Threading.AbandonedMutexException] {
        $acquired = $true
    }
    if (-not $acquired) { throw "Timed out waiting for mutex: $Name" }
    & $Action
} finally {
    if ($acquired) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
