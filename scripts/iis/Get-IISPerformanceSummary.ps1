<#
.SYNOPSIS
Returns IIS performance counters summary for web sites and application pools.
.DESCRIPTION
Reads Windows performance counters related to IIS (ASP.NET Requests, Web Service,
Active Server Pages) and returns current values for requests/sec, errors/sec,
bytes throughput, and active requests. Read-only. Requires Windows (PowerShell 7)
and the counter names to exist on the machine.
.EXAMPLE
./scripts/iis/Get-IISPerformanceSummary.ps1
.EXAMPLE
./scripts/iis/Get-IISPerformanceSummary.ps1 -Counter '\ASP.NET Applications(__Total__)\Requests/Sec'
#>
[CmdletBinding()]
param(
    [string[]]$Counter
)

$defaultCounters = @(
    '\Web Service(_Total)\Get Requests/sec',
    '\Web Service(_Total)\Post Requests/sec',
    '\Web Service(_Total)\Total Bytes Sent/sec',
    '\Web Service(_Total)\Total Bytes Received/sec',
    '\ASP.NET Applications(__Total__)\Requests/Sec',
    '\ASP.NET Applications(__Total__)\Errors Total/Sec'
)

$counters = if ($PSBoundParameters.ContainsKey('Counter')) { $Counter } else { $defaultCounters }

$results = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($c in $counters) {
    try {
        $sample = Get-Counter -Counter $c -SampleInterval 1 -MaxSamples 1 -ErrorAction Stop
        $value = $sample.CounterSamples.CookedValue
        $results.Add([pscustomobject]@{
            Counter     = $c
            Value       = [math]::Round($value, 2)
            Timestamp   = $sample.CounterSamples.Timestamp
            Status      = 'OK'
            Error       = $null
        })
    }
    catch {
        $results.Add([pscustomobject]@{
            Counter     = $c
            Value       = $null
            Timestamp   = $null
            Status      = 'Error'
            Error       = $_.Exception.Message
        })
    }
}

$results | Sort-Object Counter
