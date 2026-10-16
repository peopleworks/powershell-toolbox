<#
.SYNOPSIS
Lists secrets in an Azure Key Vault without revealing their values.
.DESCRIPTION
Queries an Azure Key Vault and returns one object per secret with name, version,
enabled state, creation date, and expiration date. Secret values are never returned.
Read-only. Requires the Az module, an authenticated Azure context, and read
permissions on the Key Vault.
.EXAMPLE
./scripts/azure/Get-AzureKeyVaultSecrets.ps1 -VaultName 'kv-ejemplo'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$secrets = Get-AzKeyVaultSecret -VaultName $VaultName -ErrorAction SilentlyContinue

$secrets |
    ForEach-Object {
        [pscustomobject]@{
            SecretName     = $_.Name
            Version        = $_.Version
            Enabled        = [bool]$_.Attributes.Enabled
            Created        = $_.Attributes.Created
            Updated        = $_.Attributes.Updated
            Expires        = $_.Attributes.Expires
            VaultName      = $VaultName
        }
    } |
    Sort-Object SecretName
