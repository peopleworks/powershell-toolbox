<#
.SYNOPSIS
Lists Azure App Services with their state and runtime.
.DESCRIPTION
Queries Azure App Services and returns one object per app with name, resource group,
location, state, default host name, and runtime version. Read-only. Requires the Az
module and an authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzureAppService.ps1 -ResourceGroupName 'rg-ejemplo'
.EXAMPLE
./scripts/azure/Get-AzureAppService.ps1
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$apps = if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    Get-AzWebApp -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
} else {
    Get-AzWebApp -ErrorAction SilentlyContinue
}

$apps |
    ForEach-Object {
        [pscustomobject]@{
            AppName       = $_.Name
            ResourceGroup = $_.ResourceGroupName
            Location      = $_.Location
            State         = $_.State
            DefaultHost   = $_.DefaultHostName
            Runtime       = $_.SiteConfig.LinuxFxVersion
        }
    } |
    Sort-Object ResourceGroup, AppName
