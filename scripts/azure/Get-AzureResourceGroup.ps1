<#
.SYNOPSIS
Lists Azure resource groups with their location and provisioning state.
.DESCRIPTION
Queries Azure resource groups and returns one object per group with name, location,
provisioning state, and managed-by information. Read-only. Requires the Az module
and an authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzureResourceGroup.ps1
.EXAMPLE
./scripts/azure/Get-AzureResourceGroup.ps1 -ResourceGroupName 'rg-ejemplo'
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$groups = if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
} else {
    Get-AzResourceGroup -ErrorAction SilentlyContinue
}

$groups |
    ForEach-Object {
        [pscustomobject]@{
            GroupName         = $_.ResourceGroupName
            Location          = $_.Location
            ProvisioningState = $_.ProvisioningState
            ManagedBy         = $_.ManagedBy
        }
    } |
    Sort-Object GroupName
