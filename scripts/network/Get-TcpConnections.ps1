<#
.SYNOPSIS
Lists Windows TCP connections as objects that can be filtered or exported.
.EXAMPLE
./scripts/network/Get-TcpConnections.ps1 -State Established | Export-Csv ./connections.csv -NoTypeInformation
#>
[CmdletBinding()]
param(
    [ValidateSet('Established', 'Listen', 'All')]
    [string]$State = 'Established',
    [switch]$IncludeProcessName
)

if (-not $IsWindows -and $PSVersionTable.PSEdition -eq 'Core') {
    throw 'This script requires Windows and Get-NetTCPConnection.'
}
if (-not (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue)) {
    throw 'Get-NetTCPConnection is unavailable on this computer.'
}

$connections = if ($State -eq 'All') {
    Get-NetTCPConnection -ErrorAction Stop
} else {
    Get-NetTCPConnection -State $State -ErrorAction Stop
}

$processNames = @{}
foreach ($connection in $connections) {
    $name = $null
    if ($IncludeProcessName -and $connection.OwningProcess -gt 0) {
        $pidValue = [int]$connection.OwningProcess
        if (-not $processNames.ContainsKey($pidValue)) {
            $process = Get-Process -Id $pidValue -ErrorAction SilentlyContinue
            $processNames[$pidValue] = if ($process) { $process.ProcessName } else { $null }
        }
        $name = $processNames[$pidValue]
    }
    [pscustomobject]@{
        LocalAddress = $connection.LocalAddress
        LocalPort = $connection.LocalPort
        RemoteAddress = $connection.RemoteAddress
        RemotePort = $connection.RemotePort
        State = [string]$connection.State
        ProcessId = $connection.OwningProcess
        ProcessName = $name
    }
}
