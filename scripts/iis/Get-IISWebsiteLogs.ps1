<#
.SYNOPSIS
Analyzes IIS W3C log files and returns a summary of requests by status code.
.DESCRIPTION
Reads IIS log files (W3C format) from -LogPath and returns one object per HTTP status
code with count, bytes transferred, and sample URLs. Read-only: no log file is modified.
Requires read access to the IIS log directory. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/iis/Get-IISWebsiteLogs.ps1 -LogPath 'C:\inetpub\logs\LogFiles\W3SVC1' -Top 10
.EXAMPLE
./scripts/iis/Get-IISWebsiteLogs.ps1 -LogPath 'C:\inetpub\logs\LogFiles\W3SVC1' -StatusCode 500
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$LogPath,

    [int]$Top = 10,

    [int]$StatusCode
)

$logFiles = Get-ChildItem -LiteralPath $LogPath -Filter '*.log' -File -ErrorAction SilentlyContinue

$entries = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($file in $logFiles) {
    $content = Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue
    foreach ($line in $content) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) { continue }

        $fields = $line -split '\s+'
        if ($fields.Count -lt 12) { continue }

        $status = [int]$fields[6]
        if ($PSBoundParameters.ContainsKey('StatusCode') -and $status -ne $StatusCode) { continue }

        $entries.Add([pscustomobject]@{
            Date        = $fields[0]
            Time        = $fields[1]
            SIP         = $fields[2]
            CSMethod    = $fields[3]
            CSUriStem   = $fields[4]
            CSUriQuery  = $fields[5]
            ScStatus    = $status
            ScSubStatus = [int]$fields[7]
            ScWin32Status = [int]$fields[8]
            TimeTaken   = [int]$fields[9]
            BytesSent   = [int]$fields[10]
            BytesRecv   = [int]$fields[11]
            LogFile     = $file.Name
        })
    }
}

$entries |
    Group-Object ScStatus |
    ForEach-Object {
        $group = $_.Group
        [pscustomobject]@{
            StatusCode      = $_.Name
            RequestCount    = $group.Count
            TotalBytesSent  = ($group | Measure-Object BytesSent -Sum).Sum
            AvgTimeTakenMs  = [math]::Round(($group | Measure-Object TimeTaken -Average).Average, 2)
            SampleUrls      = ($group | Select-Object -First $Top -ExpandProperty CSUriStem) -join '; '
        }
    } |
    Sort-Object StatusCode
