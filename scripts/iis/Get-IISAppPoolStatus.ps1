<#
.SYNOPSIS
Lists IIS application pools with their state and .NET version.
.DESCRIPTION
Uses the WebAdministration module to list application pools with state, .NET CLR
version, pipeline mode, and queue length. Read-only: no pool is started, stopped,
or recycled. Requires Windows, IIS, and the WebAdministration module.
.EXAMPLE
./scripts/iis/Get-IISAppPoolStatus.ps1
.EXAMPLE
./scripts/iis/Get-IISAppPoolStatus.ps1 -AppPoolName 'DefaultAppPool'
#>
[CmdletBinding()]
param(
    [string]$AppPoolName
)

if (-not (Get-Module -ListAvailable WebAdministration)) {
    throw 'El modulo WebAdministration no esta disponible. Instale IIS o importe el modulo manualmente.'
}

Import-Module WebAdministration -ErrorAction Stop

$pools = Get-Item IIS:\AppPools\* -ErrorAction SilentlyContinue

if ($PSBoundParameters.ContainsKey('AppPoolName')) {
    $pools = $pools | Where-Object { $_.Name -eq $AppPoolName }
}

$pools |
    ForEach-Object {
        [pscustomobject]@{
            PoolName      = $_.Name
            State         = $_.state
            PipelineMode  = $_.managedPipelineMode
            DotNetVersion = $_.managedRuntimeVersion
            QueueLength   = if ($_.QueueLength) { $_.QueueLength } else { 0 }
        }
    } |
    Sort-Object PoolName
