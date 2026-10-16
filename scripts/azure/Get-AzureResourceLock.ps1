<#
.SYNOPSIS
Lists Azure resource locks (CanNotDelete, ReadOnly) for a subscription or group.
.DESCRIPTION
Queries Azure management locks and returns one object per lock with name, type,
level, notes, and the resource it applies to. Read-only. Requires the Az module
and an authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzureResourceLock.ps1 -ResourceGroupName 'rg-ejemplo'
.EXAMPLE
./scripts/azure/Get-AzureResourceLock.ps1
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$locks = if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    Get-AzResourceLock -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
} else {
    Get-AzResourceLock -ErrorAction SilentlyContinue
}

$locks |
    ForEach-Object {
        [pscustomobject]@{
            LockName      = $_.Name
            LockType      = $_.Type
            Level         = $_.Level
            Notes         = $_.Notes
            ResourceGroup = $_.ResourceGroupName
        }
    } |
    Sort-Object ResourceGroup, LockName
