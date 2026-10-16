<#
.SYNOPSIS
Detects possible port scan activity from network connections.
.DESCRIPTION
Analyzes current TCP connections and flags remote IPs connecting to many different
local ports within a short time, which may indicate a port scan. Returns one object
per suspicious source IP with the ports targeted and connection count.
Read-only. Requires Windows (PowerShell 7) and permissions to read TCP connections.
.EXAMPLE
./scripts/monitor/Get-PortScanDetection.ps1 -MinPorts 20
.EXAMPLE
./scripts/monitor/Get-PortScanDetection.ps1 -MinPorts 10 -ExcludeLocal
#>
[CmdletBinding()]
param(
    [int]$MinPorts = 20,

    [switch]$ExcludeLocal
)

$connections = Get-NetTCPConnection -ErrorAction SilentlyContinue

if ($ExcludeLocal) {
    $connections = $connections | Where-Object { $_.RemoteAddress -notin @('127.0.0.1','::1') -and $_.RemoteAddress -notlike '169.254.*' }
}

$bySource = $connections | Group-Object RemoteAddress

$alerts = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($sourceGroup in $bySource) {
    $ip = $sourceGroup.Name
    if ([string]::IsNullOrWhiteSpace($ip) -or $ip -eq '0.0.0.0') { continue }

    $conns = $sourceGroup.Group
    $ports = ($conns.LocalPort | Sort-Object -Unique)
    $portCount = $ports.Count

    if ($portCount -lt $MinPorts) { continue }

    $states = ($conns.State | Sort-Object -Unique) -join ', '

    $alerts.Add([pscustomobject]@{
        SourceIp         = $ip
        ConnectionCount  = $conns.Count
        UniquePorts      = $portCount
        TargetPorts      = ($ports | Select-Object -First 50) -join ', '
        States           = $states
        Severity         = if ($portCount -gt 100) { 'Critical' } elseif ($portCount -gt 50) { 'High' } elseif ($portCount -gt 20) { 'Medium' } else { 'Low' }
    })
}

$alerts | Sort-Object UniquePorts -Descending
