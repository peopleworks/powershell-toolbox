<#
.SYNOPSIS
Lists Active Directory users with their key properties.
.DESCRIPTION
Queries Active Directory and returns one object per user with samAccountName,
displayName, enabled state, email, and last logon date. Read-only: no user is
created, modified, or deleted. Requires the Active Directory module (RSAT) and
permissions to read AD users.
.EXAMPLE
./scripts/identity/Get-ADUserSummary.ps1 -Domain 'ejemplo.local'
.EXAMPLE
./scripts/identity/Get-ADUserSummary.ps1 -Filter 'enabled -eq $true' -Domain 'ejemplo.local'
#>
[CmdletBinding()]
param(
    [string]$Domain,

    [string]$Filter = '*',

    [int]$MaxResults = 100
)

if (-not (Get-Module -ListAvailable ActiveDirectory)) {
    throw 'El modulo ActiveDirectory no esta instalado. Instale las herramientas RSAT de Active Directory.'
}

$splat = @{ Filter = $Filter; Properties = @('SamAccountName','DisplayName','Enabled','EmailAddress','LastLogonDate'); ErrorAction = 'Stop' }
if ($Domain) { $splat.Server = $Domain }

try {
    $users = Get-ADUser @splat | Select-Object -First $MaxResults

    $users |
        ForEach-Object {
            [pscustomobject]@{
                SamAccountName = $_.SamAccountName
                DisplayName    = $_.DisplayName
                Enabled        = [bool]$_.Enabled
                EmailAddress   = $_.EmailAddress
                LastLogonDate  = $_.LastLogonDate
                Domain         = $Domain
            }
        } |
        Sort-Object SamAccountName
}
catch {
    Write-Error $_.Exception.Message
}
