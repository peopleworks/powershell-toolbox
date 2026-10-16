<#
.SYNOPSIS
Detects possible brute-force login attempts from Windows security logs.
.DESCRIPTION
Reads the Windows Security event log for failed logon events (4625) and groups them
by source account and IP. Returns accounts with more than -MaxFailedAttempts failures
within -HoursBack hours, which may indicate a brute-force attack.
Read-only: no log is modified. Requires Windows (PowerShell 7) and read access to
the Security event log (typically administrator).
.EXAMPLE
./scripts/monitor/Test-BruteForceAttempt.ps1 -HoursBack 24 -MaxFailedAttempts 10
.EXAMPLE
./scripts/monitor/Test-BruteForceAttempt.ps1 -HoursBack 6 -MaxFailedAttempts 5 -Account 'usuario_ejemplo'
#>
[CmdletBinding()]
param(
    [int]$HoursBack = 24,

    [int]$MaxFailedAttempts = 10,

    [string]$Account
)

$startTime = (Get-Date).AddHours(-$HoursBack)

$filter = @{
    LogName   = 'Security'
    Id        = 4625
    StartTime = $startTime
    MaxEvents = 10000
}

try {
    $events = Get-WinEvent @filter -ErrorAction Stop
}
catch {
    Write-Warning 'No se pudo leer el registro de Seguridad. Ejecute como administrador.'
    return
}

$failures = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($evt in $events) {
    $xml = [xml]$evt.ToXml()
    $account = $xml.SelectSingleNode('//Data[@Name="TargetUserName"]')?.InnerText
    $ip = $xml.SelectSingleNode('//Data[@Name="IpAddress"]')?.InnerText

    if ($Account -and $account -ne $Account) { continue }

    $failures.Add([pscustomobject]@{
        TimeCreated = $evt.TimeCreated
        Account     = $account
        IpAddress   = $ip
        Workstation = $xml.SelectSingleNode('//Data[@Name="WorkstationName"]')?.InnerText
    })
}

$byAccount = $failures | Group-Object Account

$alerts = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($acctGroup in $byAccount) {
    $acct = $acctGroup.Name
    $fails = $acctGroup.Group
    $count = $fails.Count

    if ($count -lt $MaxFailedAttempts) { continue }

    $ips = ($fails.IpAddress | Sort-Object -Unique) -join ', '

    $alerts.Add([pscustomobject]@{
        Account            = $acct
        FailedAttempts     = $count
        SourceIps          = $ips
        FirstAttempt       = ($fails | Sort-Object TimeCreated | Select-Object -First 1).TimeCreated
        LastAttempt        = ($fails | Sort-Object TimeCreated -Descending | Select-Object -First 1).TimeCreated
        Severity           = if ($count -gt 50) { 'Critical' } elseif ($count -gt 20) { 'High' } elseif ($count -gt 10) { 'Medium' } else { 'Low' }
    })
}

$alerts | Sort-Object FailedAttempts -Descending
