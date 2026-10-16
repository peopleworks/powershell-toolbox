<#
.SYNOPSIS
Detects network anomalies: connections outside business hours or to unknown IPs.
.DESCRIPTION
Reviews current TCP connections and flags those outside -BusinessHours or to remote
IPs not in -TrustedSubnets. Returns one object per anomalous connection.
Read-only. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/monitor/Get-NetworkAnomaly.ps1 -BusinessHours @('08','09','10','11','12','13','14','15','16','17','18')
.EXAMPLE
./scripts/monitor/Get-NetworkAnomaly.ps1 -TrustedSubnets @('10.','192.168.','172.16.') -BusinessHours @('08'..'18')
#>
[CmdletBinding()]
param(
    [string[]]$BusinessHours = @('0','1','2','3','4','5','6','22','23'),

    [string[]]$TrustedSubnets = @('10.','192.168.','172.16.','127.0.0.1','::1')
)

$connections = Get-NetTCPConnection -ErrorAction SilentlyContinue |
    Where-Object { $_.State -eq 'Established' -and $_.RemoteAddress -notin @('127.0.0.1','::1') }

$anomalies = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($c in $connections) {
    $hour = (Get-Date).Hour.ToString('D2')
    $outsideHours = $BusinessHours -notcontains $hour

    $isTrusted = $false
    foreach ($subnet in $TrustedSubnets) {
        if ($c.RemoteAddress -like "$subnet*") { $isTrusted = $true; break }
    }

    if ($outsideHours -or -not $isTrusted) {
        $reasons = [System.Collections.Generic.List[string]]::new()
        if ($outsideHours) { $reasons.Add("Outside business hours ($hour:00)") }
        if (-not $isTrusted) { $reasons.Add("Remote IP outside trusted subnets") }

        $processName = if ($c.OwningProcess) { (Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue).ProcessName } else { '' }

        $anomalies.Add([pscustomobject]@{
            LocalPort      = $c.LocalPort
            RemoteAddress  = $c.RemoteAddress
            RemotePort     = $c.RemotePort
            ProcessName    = $processName
            OwningProcess  = $c.OwningProcess
            Reasons        = $reasons -join '; '
            Severity       = if ($outsideHours -and -not $isTrusted) { 'High' } else { 'Medium' }
        })
    }
}

$anomalies | Sort-Object Severity -Descending
