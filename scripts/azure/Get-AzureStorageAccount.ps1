<#
.SYNOPSIS
Lists Azure storage accounts with their SKU and kind.
.DESCRIPTION
Queries Azure storage accounts and returns one object per account with name,
resource group, location, SKU, kind, and HTTPS status. Read-only. Requires the Az
module and an authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzureStorageAccount.ps1 -ResourceGroupName 'rg-ejemplo'
.EXAMPLE
./scripts/azure/Get-AzureStorageAccount.ps1
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$accounts = if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
} else {
    Get-AzStorageAccount -ErrorAction SilentlyContinue
}

$accounts |
    ForEach-Object {
        [pscustomobject]@{
            AccountName  = $_.StorageAccountName
            ResourceGroup = $_.ResourceGroupName
            Location     = $_.Location
            SKU          = $_.Sku.Name
            Kind         = $_.Kind
            HttpsEnabled = [bool]$_.EnableHttpsTrafficOnly
        }
    } |
    Sort-Object ResourceGroup, AccountName
