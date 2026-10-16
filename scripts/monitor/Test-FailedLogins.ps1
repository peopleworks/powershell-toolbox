<#
.SYNOPSIS
Returns failed login events from Windows security logs within a time window.
.DESCRIPTION
Reads the Windows Security event log for failed logon events (4625) and returns one
object per failure with time, account, source IP, and logon type. Read-only.
Requires Windows (PowerShell 7) and read access to the Security event log.
.EXAMPLE
./scripts/monitor/Test-FailedLogins.ps1 -HoursBack 24
.EXAMPLE
./scripts/monitor/Test-FailedLogins.ps1 -HoursBack 6 -MaxEvents 100
#>
[CmdletBinding()]
param(
    [int]$HoursBack = 24,

    [int]$MaxEvents = 500
)

$startTime = (Get-Date).AddHours(-$HoursBack)

$filter = @{
    LogName   = 'Security'
    Id        = 4625
    StartTime = $startTime
    MaxEvents = $MaxEvents
}

try {
    $events = Get-WinEvent @filter -ErrorAction Stop
}
catch {
    Write-Warning 'No se pudo leer el registro de Seguridad. Ejecute como administrador.'
    return
}

$events |
    ForEach-Object {
        $xml = [xml]$_.ToXml()
        [pscustomobject]@{
            TimeCreated  = $_.TimeCreated
            Account      = $xml.SelectSingleNode('//Data[@Name="TargetUserName"]')?.InnerText
            IpAddress    = $xml.SelectSingleNode('//Data[@Name="IpAddress"]')?.InnerText
            Port         = $xml.SelectSingleNode('//Data[@Name="IpPort"]')?.InnerText
            LogonType    = $xml.SelectSingleNode('//Data[@Name="LogonType"]')?.InnerText
            Workstation  = $xml.SelectSingleNode('//Data[@Name="WorkstationName"]')?.InnerText
        }
    } |
    Sort-Object TimeCreated -Descending
