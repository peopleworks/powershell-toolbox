<#
.SYNOPSIS
Analyzes IIS log files and returns error requests (4xx and 5xx) grouped by URL.
.DESCRIPTION
Reads IIS W3C log files from -LogPath, filters 4xx and 5xx status codes, and returns
one object per URL with error count, status codes seen, and first/last occurrence.
Read-only: no log file is modified. Requires read access to the IIS log directory.
Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/iis/Get-IISErrorAnalysis.ps1 -LogPath 'C:\inetpub\logs\LogFiles\W3SVC1' -HoursBack 24
.EXAMPLE
./scripts/iis/Get-IISErrorAnalysis.ps1 -LogPath 'C:\inetpub\logs\LogFiles\W3SVC1' -MinErrors 5
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$LogPath,

    [int]$HoursBack = 24,

    [int]$MinErrors = 1
)

$cutoff = (Get-Date).AddHours(-$HoursBack)

$logFiles = Get-ChildItem -LiteralPath $LogPath -Filter '*.log' -File -ErrorAction SilentlyContinue

$errors = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($file in $logFiles) {
    $content = Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue
    foreach ($line in $content) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) { continue }

        $fields = $line -split '\s+'
        if ($fields.Count -lt 12) { continue }

        $status = [int]$fields[6]
        if ($status -lt 400) { continue }

        $dateTime = [datetime]::Parse("$($fields[0]) $($fields[1])")
        if ($dateTime -lt $cutoff) { continue }

        $errors.Add([pscustomobject]@{
            DateTime   = $dateTime
            CSMethod   = $fields[3]
            CSUriStem  = $fields[4]
            ScStatus   = $status
            ScSubStatus = [int]$fields[7]
            IP         = $fields[2]
            UserAgent  = if ($fields.Count -gt 15) { $fields[15] } else { '' }
            LogFile    = $file.Name
        })
    }
}

$errors |
    Group-Object CSUriStem |
    Where-Object { $_.Count -ge $MinErrors } |
    ForEach-Object {
        $group = $_.Group
        [pscustomobject]@{
            Url             = $_.Name
            ErrorCount      = $group.Count
            StatusCodes     = ($group.ScStatus | Sort-Object -Unique) -join ', '
            FirstOccurrence = ($group | Sort-Object DateTime | Select-Object -First 1).DateTime
            LastOccurrence  = ($group | Sort-Object DateTime -Descending | Select-Object -First 1).DateTime
            SampleIPs       = ($group.IP | Sort-Object -Unique | Select-Object -First 5) -join ', '
        }
    } |
    Sort-Object ErrorCount -Descending
