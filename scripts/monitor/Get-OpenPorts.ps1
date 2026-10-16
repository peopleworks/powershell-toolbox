<#
.SYNOPSIS
Lists open TCP and UDP ports on the local computer.
.DESCRIPTION
Queries current TCP connections and UDP listeners and returns one object per port
with protocol, local port, remote address, state, and owning process. Read-only.
Useful for identifying unexpected exposed services. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/monitor/Get-OpenPorts.ps1 -LocalPort 80,443,8080
.EXAMPLE
./scripts/monitor/Get-OpenPorts.ps1 -ExcludeLocal
#>
[CmdletBinding()]
param(
    [int[]]$LocalPort,

    [switch]$ExcludeLocal
)

$tcp = Get-NetTCPConnection -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Listen' }

if ($PSBoundParameters.ContainsKey('LocalPort')) {
    $tcp = $tcp | Where-Object { $LocalPort -contains $_.LocalPort }
}
if ($ExcludeLocal) {
    $tcp = $tcp | Where-Object { $_.LocalAddress -notin @('127.0.0.1','::1') -and $_.LocalAddress -notlike '169.254.*' }
}

$udp = Get-NetUDPEndpoint -ErrorAction SilentlyContinue

if ($PSBoundParameters.ContainsKey('LocalPort')) {
    $udp = $udp | Where-Object { $LocalPort -contains $_.LocalPort }
}
if ($ExcludeLocal) {
    $udp = $udp | Where-Object { $_.LocalAddress -notin @('127.0.0.1','::1') -and $_.LocalAddress -notlike '169.254.*' }
}

$results = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($c in $tcp) {
    $results.Add([pscustomobject]@{
        Protocol     = 'TCP'
        LocalPort    = $c.LocalPort
        LocalAddress = $c.LocalAddress
        RemotePort   = $c.RemotePort
        RemoteAddress= $c.RemoteAddress
        State        = $c.State
        ProcessName  = if ($c.OwningProcess) { (Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue).ProcessName } else { '' }
        OwningProcess= $c.OwningProcess
    })
}

foreach ($u in $udp) {
    $results.Add([pscustomobject]@{
        Protocol     = 'UDP'
        LocalPort    = $u.LocalPort
        LocalAddress = $u.LocalAddress
        RemotePort   = $null
        RemoteAddress= $null
        State        = 'Listen'
        ProcessName  = if ($u.OwningProcess) { (Get-Process -Id $u.OwningProcess -ErrorAction SilentlyContinue).ProcessName } else { '' }
        OwningProcess= $u.OwningProcess
    })
}

$results | Sort-Object Protocol, LocalPort
