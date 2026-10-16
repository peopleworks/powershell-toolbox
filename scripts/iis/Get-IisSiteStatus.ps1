<#
.SYNOPSIS
Reports IIS sites and application pools status on Windows.
.DESCRIPTION
Uses the WebAdministration module to list IIS sites and application pools with their
state, physical path, bindings and port. Read-only: no site or pool is started,
stopped or recycled. Requires Windows, IIS and the WebAdministration module.
.EXAMPLE
./scripts/iis/Get-IisSiteStatus.ps1
.EXAMPLE
./scripts/iis/Get-IisSiteStatus.ps1 -SiteName 'Sitio_Ejemplo' -IncludeAppPools
#>
[CmdletBinding()]
param(
    [string]$SiteName,

    [switch]$IncludeAppPools
)

if (-not (Get-Module -ListAvailable WebAdministration)) {
    throw 'El modulo WebAdministration no esta disponible. Instale IIS o importe el modulo manualmente.'
}

Import-Module WebAdministration -ErrorAction Stop

$sites = Get-Website -ErrorAction SilentlyContinue

if ($PSBoundParameters.ContainsKey('SiteName')) {
    $sites = $sites | Where-Object { $_.Name -like $SiteName }
}

$result = $sites |
    ForEach-Object {
        $bindings = if ($_.Bindings) { $_.Bindings -join ', ' } else { '' }
        [pscustomobject]@{
            SiteName      = $_.Name
            State         = $_.State
            PhysicalPath  = $_.PhysicalPath
            Bindings      = $bindings
            ApplicationPool = $_.applicationPool
        }
    } |
    Sort-Object SiteName

if ($IncludeAppPools) {
    $pools = Get-Item IIS:\AppPools\* -ErrorAction SilentlyContinue |
        ForEach-Object {
            [pscustomobject]@{
                PoolName    = $_.Name
                State       = $_.state
                PipelineMode = $_.managedPipelineMode
            }
        } |
        Sort-Object PoolName

    [pscustomobject]@{
        Sites    = $result
        AppPools = $pools
    }
}
else {
    $result
}
