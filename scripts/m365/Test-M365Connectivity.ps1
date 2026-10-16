<#
.SYNOPSIS
Tests connectivity to Microsoft 365 / Exchange Online.
.DESCRIPTION
Verifies that the Exchange Online Management module is installed and that a user is
authenticated to Microsoft 365. Returns the connected user and organization.
Read-only: no changes are made to Microsoft 365. Requires the Exchange Online
Management module (`Install-Module ExchangeOnlineManagement`) and an authenticated
session (`Connect-ExchangeOnline`).
.EXAMPLE
./scripts/m365/Test-M365Connectivity.ps1
#>
[CmdletBinding()]
param()

if (-not (Get-Module -ListAvailable ExchangeOnlineManagement)) {
    throw 'El modulo ExchangeOnlineManagement no esta instalado. Instalelo con: Install-Module ExchangeOnlineManagement -Scope CurrentUser'
}

try {
    $session = Get-PSSession | Where-Object { $_.Name -like '*ExchangeOnline*' } | Select-Object -First 1

    if (-not $session) {
        [pscustomobject]@{
            Connected     = $false
            User          = $null
            Organization  = $null
            Message       = 'No hay sesion de Exchange Online activa. Ejecute Connect-ExchangeOnline.'
        }
        return
    }

    [pscustomobject]@{
        Connected     = $true
        User          = $session.ConfigurationName
        Organization  = $null
        Message       = 'Conectado a Microsoft 365 / Exchange Online.'
    }
}
catch {
    [pscustomobject]@{
        Connected     = $false
        User          = $null
        Organization  = $null
        Message       = 'No se pudo verificar la conexion a Microsoft 365.'
        ErrorMessage  = $_.Exception.Message
    }
}
