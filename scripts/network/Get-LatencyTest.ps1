<#
.SYNOPSIS
Tests latency to multiple endpoints using Test-NetConnection.
.DESCRIPTION
Pings multiple endpoints and returns one object per endpoint with address, port,
latency in milliseconds, and whether the connection succeeded. Read-only.
Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/network/Get-LatencyTest.ps1 -Endpoint @('google.com','microsoft.com','ejemplo.com') -Port 443
.EXAMPLE
./scripts/network/Get-LatencyTest.ps1 -Endpoint @('10.0.0.1','10.0.0.2') -Port 80 -TimeoutSeconds 5
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$Endpoint,

    [int]$Port = 443,

    [int]$TimeoutSeconds = 5
)

$results = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($ep in $Endpoint) {
    try {
        $result = Test-NetConnection -ComputerName $ep -Port $Port -WarningAction SilentlyContinue -ErrorAction Stop

        $results.Add([pscustomobject]@{
            Endpoint      = $ep
            Port          = $Port
            LatencyMs     = if ($result.Rtt) { [int]$result.Rtt } else { $null }
            Succeeded     = [bool]$result.TcpTestSucceeded
            PingSucceeded = [bool]$result.PingSucceeded
            RemoteAddress = $result.RemoteAddress
        })
    }
    catch {
        $results.Add([pscustomobject]@{
            Endpoint      = $ep
            Port          = $Port
            LatencyMs     = $null
            Succeeded     = $false
            PingSucceeded = $false
            RemoteAddress = $null
            Error         = $_.Exception.Message
        })
    }
}

$results | Sort-Object Endpoint
