<#
.SYNOPSIS
Lists installed printers and their pending print jobs on Windows.
.DESCRIPTION
Queries Win32_Printer and Win32_PrintJob and returns one object per printer with name,
status, port, location and number of pending jobs. Read-only: no print job is paused,
resumed or canceled. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/printing/Get-PrinterQueue.ps1
.EXAMPLE
./scripts/printing/Get-PrinterQueue.ps1 -PrinterName 'HP_LaserJet*' -IncludeJobs
#>
[CmdletBinding()]
param(
    [string]$PrinterName = '*',

    [switch]$IncludeJobs
)

$printers = Get-CimInstance Win32_Printer -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like $PrinterName }

$results = [System.Collections.Generic.List[pscustomobject]]::new()
foreach ($printer in $printers) {
    $pendingJobs = 0
    if ($IncludeJobs) {
        $jobs = Get-CimInstance Win32_PrintJob -Filter "Name = '$($printer.Name)'" -ErrorAction SilentlyContinue |
            Where-Object { $_.JobStatus -band 1 } # jobs not completed
        $pendingJobs = @($jobs).Count
    }

    $results.Add([pscustomobject]@{
        Name          = $printer.Name
        Status        = $printer.PrinterStatus
        WorkOffline   = [bool]$printer.WorkOffline
        PortName      = $printer.PortName
        Location      = $printer.Location
        Comment       = $printer.Comment
        PendingJobs   = $pendingJobs
        Default       = [bool]$printer.Default
        Shared        = [bool]$printer.Shared
    })
}
$results | Sort-Object Name
