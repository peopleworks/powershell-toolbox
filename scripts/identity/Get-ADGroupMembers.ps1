<#
.SYNOPSIS
Lists members of an Active Directory group.
.DESCRIPTION
Queries Active Directory and returns one object per member of -GroupName with
name, samAccountName, object class, and distinguished name. Read-only: no group
or member is modified. Requires the Active Directory module (RSAT).
.EXAMPLE
./scripts/identity/Get-ADGroupMembers.ps1 -GroupName 'Administradores' -Domain 'ejemplo.local'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [string]$Domain
)

if (-not (Get-Module -ListAvailable ActiveDirectory)) {
    throw 'El modulo ActiveDirectory no esta instalado. Instale las herramientas RSAT de Active Directory.'
}

$splat = @{ Identity = $GroupName; Properties = @('Name','SamAccountName','ObjectClass','DistinguishedName'); ErrorAction = 'Stop' }
if ($Domain) { $splat.Server = $Domain }

try {
    $members = Get-ADGroupMember @splat -ErrorAction SilentlyContinue

    $members |
        ForEach-Object {
            [pscustomobject]@{
                Name             = $_.Name
                SamAccountName   = $_.SamAccountName
                ObjectClass      = $_.ObjectClass
                DistinguishedName = $_.DistinguishedName
                GroupName        = $GroupName
                Domain           = $Domain
            }
        } |
        Sort-Object Name
}
catch {
    Write-Error $_.Exception.Message
}
