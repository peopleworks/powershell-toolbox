<#
.SYNOPSIS
Lists Azure Active Directory users with their display name and sign-in status.
.DESCRIPTION
Queries Microsoft Graph through the Az module and returns one object per user with
user principal name, display name, account enabled state, and creation date.
Read-only. Requires the Az module, an authenticated Azure context, and
Directory.Read.All permissions (or equivalent).
.EXAMPLE
./scripts/azure/Get-AzureADUserSummary.ps1 -UserName 'usuario_ejemplo'
.EXAMPLE
./scripts/azure/Get-AzureADUserSummary.ps1
#>
[CmdletBinding()]
param(
    [string]$UserName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$users = if ($PSBoundParameters.ContainsKey('UserName')) {
    Get-AzADUser -UserPrincipalName $UserName -ErrorAction SilentlyContinue
} else {
    Get-AzADUser -All:$true -ErrorAction SilentlyContinue
}

$users |
    ForEach-Object {
        [pscustomobject]@{
            UserPrincipalName = $_.UserPrincipalName
            DisplayName       = $_.DisplayName
            Enabled           = [bool]$_.AccountEnabled
            CreatedDate       = $_.CreatedDateTime
            UserType          = $_.UserType
        }
    } |
    Sort-Object DisplayName
