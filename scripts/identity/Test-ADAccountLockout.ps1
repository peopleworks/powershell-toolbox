<#
.SYNOPSIS
Checks if an Active Directory account is locked out.
.DESCRIPTION
Queries Active Directory for -SamAccountName and returns whether the account is
locked out, along with bad password count and last bad password date. Read-only:
no account is unlocked or modified. Requires the Active Directory module (RSAT).
.EXAMPLE
./scripts/identity/Test-ADAccountLockout.ps1 -SamAccountName 'usuario_ejemplo' -Domain 'ejemplo.local'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SamAccountName,

    [string]$Domain
)

if (-not (Get-Module -ListAvailable ActiveDirectory)) {
    throw 'El modulo ActiveDirectory no esta instalado. Instale las herramientas RSAT de Active Directory.'
}

$splat = @{ Identity = $SamAccountName; Properties = @('LockedOut','BadPasswordCount','BadLogonDate','Enabled'); ErrorAction = 'Stop' }
if ($Domain) { $splat.Server = $Domain }

try {
    $user = Get-ADUser @splat -ErrorAction Stop

    [pscustomobject]@{
        SamAccountName    = $SamAccountName
        LockedOut         = [bool]($user.LockedOut -eq $true)
        BadPasswordCount  = [int]$user.BadPasswordCount
        BadLogonDate      = $user.BadLogonDate
        Enabled           = [bool]$user.Enabled
        Domain            = $Domain
    }
}
catch {
    [pscustomobject]@{
        SamAccountName    = $SamAccountName
        LockedOut         = $null
        BadPasswordCount  = $null
        BadLogonDate      = $null
        Enabled           = $null
        Domain            = $Domain
        ErrorMessage      = $_.Exception.Message
    }
}
