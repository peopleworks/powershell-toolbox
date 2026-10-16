<#
.SYNOPSIS
Returns Azure Activity Log entries for a subscription or resource group.
.DESCRIPTION
Queries the Azure Activity Log and returns one object per entry with caller,
operation name, status, event timestamp, and resource. Read-only: no changes are
made to Azure. Requires the Az module, an authenticated Azure context, and
Reader permissions on the subscription or resource group.
.EXAMPLE
./scripts/azure/Get-AzureActivityLog.ps1 -ResourceGroupName 'rg-ejemplo' -HoursBack 24
.EXAMPLE
./scripts/azure/Get-AzureActivityLog.ps1 -HoursBack 48 -MaxEvents 100
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName,

    [int]$HoursBack = 24,

    [int]$MaxEvents = 200
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$startTime = (Get-Date).AddHours(-$HoursBack)

$splat = @{
    StartTime   = $startTime
    MaxEvents   = $MaxEvents
    ErrorAction = 'Stop'
}
if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    $splat.ResourceGroupName = $ResourceGroupName
}

try {
    $logs = Get-AzActivityLog @splat

    $logs |
        ForEach-Object {
            [pscustomobject]@{
                EventTimestamp = $_.EventTimestamp
                Caller         = $_.Caller
                OperationName  = $_.OperationName.Value
                Status         = $_.Status.Value
                ResourceGroup  = $_.ResourceGroupName
                Resource       = $_.ResourceId
                Level          = $_.Level
            }
        } |
        Sort-Object EventTimestamp -Descending
}
catch {
    Write-Error $_.Exception.Message
}
