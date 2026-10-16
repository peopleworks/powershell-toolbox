<#
.SYNOPSIS
Returns an hourly summary of IIS W3C log requests.
.DESCRIPTION
Reads IIS log files from -LogPath and returns one object per hour with request count,
status code breakdown, bytes transferred, and average response time. Read-only.
Requires read access to the IIS log directory. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/logs/Get-IisLogHourlySummary.ps1 -LogPath 'C:\inetpub\logs\LogFiles\W3SVC1' -HoursBack 24
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$LogPath,

    [int]$HoursBack = 24
)

$cutoff = (Get-Date).AddHours(-$HoursBack)

$logFiles = Get-ChildItem -LiteralPath $LogPath -Filter '*.log' -File -ErrorAction SilentlyContinue

$entries = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($file in $logFiles) {
    $content = Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue
    foreach ($line in $content) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) { continue }

        $fields = $line -split '\s+'
        if ($fields.Count -lt 12) { continue }

        $dateTime = [datetime]::Parse("$($fields[0]) $($fields[1])")
        if ($dateTime -lt $cutoff) { continue }

        $hourKey = $dateTime.ToString('yyyy-MM-dd HH')

        $entries.Add([pscustomobject]@{
            Hour       = $hourKey
            DateTime   = $dateTime
            ScStatus   = [int]$fields[6]
            TimeTaken  = [int]$fields[9]
            BytesSent  = [int]$fields[10]
        })
    }
}

$entries |
    Group-Object Hour |
    ForEach-Object {
        $group = $_.Group
        [pscustomobject]@{
            Hour              = $_.Name
            RequestCount      = $group.Count
            Status2xx         = ($group | Where-Object { $_.ScStatus -ge 200 -and $_.ScStatus -lt 300 }).Count
            Status3xx         = ($group | Where-Object { $_.ScStatus -ge 300 -and $_.ScStatus -lt 400 }).Count
            Status4xx         = ($group | Where-Object { $_.ScStatus -ge 400 -and $_.ScStatus -lt 500 }).Count
            Status5xx         = ($group | Where-Object { $_.ScStatus -ge 500 }).Count
            TotalBytesSent    = ($group | Measure-Object BytesSent -Sum).Sum
            AvgTimeTakenMs    = [math]::Round(($group | Measure-Object TimeTaken -Average).Average, 2)
        }
    } |
    Sort-Object Hour
