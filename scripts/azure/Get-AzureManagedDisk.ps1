<#
.SYNOPSIS
Lists Azure managed disks with their size and SKU.
.DESCRIPTION
Queries Azure managed disks and returns one object per disk with name, resource group,
location, size in GB, SKU, and disk state. Read-only. Requires the Az module and an
authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzureManagedDisk.ps1 -ResourceGroupName 'rg-ejemplo'
.EXAMPLE
./scripts/azure/Get-AzureManagedDisk.ps1
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$disks = if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    Get-AzDisk -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
} else {
    Get-AzDisk -ErrorAction SilentlyContinue
}

$disks |
    ForEach-Object {
        [pscustomobject]@{
            DiskName      = $_.Name
            ResourceGroup = $_.ResourceGroupName
            Location      = $_.Location
            SizeGB        = $_.DiskSizeGB
            SKU           = $_.Sku.Name
            DiskState     = $_.DiskState
        }
    } |
    Sort-Object ResourceGroup, DiskName
