<#
.SYNOPSIS
Analyzes Windows Defender firewall logs for blocked connections.
.DESCRIPTION
Reads the Windows Defender firewall log file and returns one object per source IP
with connection count, ports targeted, and action (block/allow). Helps identify
possible reconnaissance or unwanted traffic.
Read-only: no log file is modified. Requires Windows (PowerShell 7) and read access
to the firewall log path (typically %windir%\System32\LogFiles\Firewall\pfirewall.log).
.EXAMPLE
./scripts/logs/Get-FirewallLogAnalysis.ps1 -LogPath '$env:windir\System32\LogFiles\Firewall\pfirewall.log' -HoursBack 24
.EXAMPLE
./scripts/logs/Get-FirewallLogAnalysis.ps1 -Action Block -MinConnections 10
#>
[CmdletBinding()]
param(
    [string]$LogPath = '$env:windir\System32\LogFiles\Firewall\pfirewall.log',

    [int]$HoursBack = 24,

    [ValidateSet('Allow', 'Block')]
    [string]$Action = 'Block',

    [int]$MinConnections = 1
)

$resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LogPath)
if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
    Write-Warning "No se encontró el archivo de log del firewall: $resolvedPath"
    return
}

$cutoff = (Get-Date).AddHours(-$HoursBack)

$entries = [System.Collections.Generic.List[pscustomobject]]::new()

Get-Content -LiteralPath $resolvedPath -ErrorAction SilentlyContinue |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith('#') } |
    ForEach-Object {
        $fields = $_ -split '\s+'
        if ($fields.Count -lt 10) { return }

        $dateTime = [datetime]::Parse("$($fields[0]) $($fields[1])")
        if ($dateTime -lt $cutoff) { return }

        $entries.Add([pscustomobject]@{
            DateTime   = $dateTime
            Action     = $fields[2]
            Protocol   = $fields[3]
            SrcIP      = $fields[4]
            DstIP      = $fields[5]
            SrcPort    = [int]$fields[6]
            DstPort    = [int]$fields[7]
            Size       = [int]$fields[8]
            Flags      = $fields[9]
        })
    }

$filtered = $entries | Where-Object { $_.Action -eq $Action }

$filtered |
    Group-Object SrcIP |
    Where-Object { $_.Count -ge $MinConnections } |
    ForEach-Object {
        $group = $_.Group
        [pscustomobject]@{
            SourceIp         = $_.Name
            ConnectionCount  = $group.Count
            TargetPorts      = ($group.DstPort | Sort-Object -Unique | Select-Object -First 20) -join ', '
            Protocols        = ($group.Protocol | Sort-Object -Unique) -join ', '
            FirstSeen        = ($group | Sort-Object DateTime | Select-Object -First 1).DateTime
            LastSeen         = ($group | Sort-Object DateTime -Descending | Select-Object -First 1).DateTime
            Severity         = if ($group.Count -gt 100) { 'High' } elseif ($group.Count -gt 20) { 'Medium' } else { 'Low' }
        }
    } |
    Sort-Object ConnectionCount -Descending
