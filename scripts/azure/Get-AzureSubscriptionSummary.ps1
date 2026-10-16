<#
.SYNOPSIS
Lists Azure subscriptions accessible to the authenticated user.
.DESCRIPTION
Queries Azure subscriptions and returns one object per subscription with name,
ID, state, and tenant ID. Read-only. Requires the Az module and an authenticated
Azure context.
.EXAMPLE
./scripts/azure/Get-AzureSubscriptionSummary.ps1
#>
[CmdletBinding()]
param()

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$subscriptions = Get-AzSubscription -ErrorAction SilentlyContinue

$subscriptions |
    ForEach-Object {
        [pscustomobject]@{
            SubscriptionName = $_.Name
            SubscriptionId   = $_.Id
            State            = $_.State
            TenantId         = $_.TenantId
        }
    } |
    Sort-Object SubscriptionName
