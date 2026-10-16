<#
.SYNOPSIS
Tests connectivity to Azure and reports the current authenticated context.
.DESCRIPTION
Verifies that the Az module is installed and that a user is authenticated to Azure.
Returns the account, subscription, tenant, and environment. Read-only: no changes are
made to Azure. Requires the Az module (`Install-Module Az -Scope CurrentUser`) and an
authenticated context (`Connect-AzAccount`).
.EXAMPLE
./scripts/azure/Test-AzureConnectivity.ps1
#>
[CmdletBinding()]
param()

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$context = Get-AzContext -ErrorAction SilentlyContinue

if (-not $context) {
    [pscustomobject]@{
        Authenticated = $false
        Account       = $null
        Subscription  = $null
        Tenant        = $null
        Environment   = $null
        Message       = 'No hay contexto de Azure autenticado. Ejecute Connect-AzAccount.'
    }
    return
}

[pscustomobject]@{
    Authenticated = $true
    Account       = $context.Account.Id
    Subscription  = $context.Subscription.Name
    SubscriptionId = $context.Subscription.Id
    Tenant        = $context.Tenant.Id
    Environment   = $context.Environment.Name
    Message       = 'Conectado a Azure.'
}
