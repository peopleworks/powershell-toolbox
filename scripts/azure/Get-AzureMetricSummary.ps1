<#
.SYNOPSIS
Returns Azure Monitor metric values for a resource over a time window.
.DESCRIPTION
Queries Azure Monitor metrics and returns one object per metric namespace with
average, minimum, maximum, and total values over -TimeGrain. Read-only: no changes
are made to Azure. Requires the Az module, an authenticated Azure context, and
Monitoring Reader permissions on the resource.
.EXAMPLE
./scripts/azure/Get-AzureMetricSummary.ps1 -ResourceId '/subscriptions/.../resourceGroups/rg-ejemplo/providers/Microsoft.Web/sites/sitio-ejemplo' -MetricName 'CpuPercentage' -TimeGrain 'PT1M'
.EXAMPLE
./scripts/azure/Get-AzureMetricSummary.ps1 -ResourceId '/subscriptions/.../resourceGroups/rg-ejemplo/providers/Microsoft.Storage/storageAccounts/cuentaejemplo' -MetricName 'UsedCapacity' -TimeGrain 'PT1H'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceId,

    [Parameter(Mandatory = $true)]
    [string]$MetricName,

    [string]$TimeGrain = 'PT5M',

    [int]$HoursBack = 1,

    [pscredential]$Credential
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$endTime = Get-Date
$startTime = $endTime.AddHours(-$HoursBack)

try {
    $splat = @{
        ResourceId      = $ResourceId
        MetricNames     = $MetricName
        TimeGrain       = $TimeGrain
        StartTime       = $startTime
        EndTime         = $endTime
        Aggregation     = 'Average,Minimum,Maximum,Total'
        ErrorAction     = 'Stop'
    }
    if ($PSBoundParameters.ContainsKey('Credential')) { $splat.Credential = $Credential }

    $metrics = Get-AzMetric @splat

    $metrics.MetricValues |
        ForEach-Object {
            $data = $_.Data
            [pscustomobject]@{
                MetricName       = $MetricName
                TimeStamp        = $_.TimeStamp
                Average          = ($data | Where-Object { $_.Average }).Average
                Minimum          = ($data | Where-Object { $_.Minimum }).Minimum
                Maximum          = ($data | Where-Object { $_.Maximum }).Maximum
                Total            = ($data | Where-Object { $_.Total }).Total
                ResourceId       = $ResourceId
            }
        } |
        Sort-Object TimeStamp -Descending
}
catch {
    [pscustomobject]@{
        MetricName   = $MetricName
        TimeStamp    = $null
        Average      = $null
        Minimum      = $null
        Maximum      = $null
        Total        = $null
        ResourceId   = $ResourceId
        ErrorMessage = $_.Exception.Message
    }
}
