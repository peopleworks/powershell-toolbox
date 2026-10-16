<#
.SYNOPSIS
Detects possible HTTP attack patterns from IIS W3C log files.
.DESCRIPTION
Reads IIS log files and flags IPs with an abnormal number of requests within a time
window, suspicious user agents, or repeated 4xx/5xx status codes. This helps identify
possible scraping, brute-force login attempts, or denial-of-service patterns.
Read-only: no log file is modified. Requires read access to the IIS log directory.
Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/monitor/Test-HttpAttack.ps1 -LogPath 'C:\inetpub\logs\LogFiles\W3SVC1' -HoursBack 24 -MaxRequestsPerIp 500
.EXAMPLE
./scripts/monitor/Test-HttpAttack.ps1 -LogPath 'C:\inetpub\logs\LogFiles\W3SVC1' -MaxRequestsPerIp 100 -SuspiciousUserAgents @('sqlmap','nikto','masscan')
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$LogPath,

    [int]$HoursBack = 24,

    [int]$MaxRequestsPerIp = 500,

    [string[]]$SuspiciousUserAgents = @('sqlmap','nikto','masscan','dirbuster','acunetix')
)

$cutoff = (Get-Date).AddHours(-$HoursBack)

$logFiles = Get-ChildItem -LiteralPath $LogPath -Filter '*.log' -File -ErrorAction SilentlyContinue

$entries = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($file in $logFiles) {
    $content = Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue
    foreach ($line in $content) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) { continue }

        $fields = $line -split '\s+'
        if ($fields.Count -lt 16) { continue }

        $dateTime = [datetime]::Parse("$($fields[0]) $($fields[1])")
        if ($dateTime -lt $cutoff) { continue }

        $entries.Add([pscustomobject]@{
            DateTime    = $dateTime
            Sip         = $fields[2]
            CsMethod    = $fields[3]
            CsUriStem   = $fields[4]
            ScStatus    = [int]$fields[6]
            CsUserAgent = if ($fields.Count -gt 15) { $fields[15] } else { '' }
            LogFile     = $file.Name
        })
    }
}

$byIp = $entries | Group-Object Sip

$alerts = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($ipGroup in $byIp) {
    $ip = $ipGroup.Name
    $requests = $ipGroup.Group
    $count = $requests.Count
    $suspiciousUas = $requests | Where-Object {
        foreach ($ua in $SuspiciousUserAgents) {
            if ($_.CsUserAgent -like "*$ua*") { $true }
        }
    }

    $clientErrors = ($requests | Where-Object { $_.ScStatus -ge 400 -and $_.ScStatus -lt 500 }).Count
    $serverErrors = ($requests | Where-Object { $_.ScStatus -ge 500 }).Count

    $reasons = [System.Collections.Generic.List[string]]::new()
    if ($count -gt $MaxRequestsPerIp) { $reasons.Add("High request count: $count in $HoursBack hours") }
    if ($suspiciousUas) { $reasons.Add("Suspicious user agents: $($suspiciousUas.CsUserAgent -join ', ')") }
    if ($clientErrors -gt 50) { $reasons.Add("Many 4xx errors: $clientErrors") }
    if ($serverErrors -gt 20) { $reasons.Add("Many 5xx errors: $serverErrors") }

    if ($reasons.Count -gt 0) {
        $alerts.Add([pscustomobject]@{
            SourceIp          = $ip
            RequestCount      = $count
            ClientErrors      = $clientErrors
            ServerErrors      = $serverErrors
            SuspiciousUserAgents = ($suspiciousUas.CsUserAgent | Sort-Object -Unique) -join '; '
            Reasons           = $reasons -join '; '
            FirstSeen         = ($requests | Sort-Object DateTime | Select-Object -First 1).DateTime
            LastSeen          = ($requests | Sort-Object DateTime -Descending | Select-Object -First 1).DateTime
            Severity          = if ($count -gt $MaxRequestsPerIp * 2) { 'High' } elseif ($count -gt $MaxRequestsPerIp) { 'Medium' } else { 'Low' }
        })
    }
}

$alerts | Sort-Object RequestCount -Descending
