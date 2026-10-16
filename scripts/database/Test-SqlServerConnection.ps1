<#
.SYNOPSIS
Tests connectivity to a SQL Server instance using dbatools.
.DESCRIPTION
Uses dbatools Connect-DbaInstance to verify connectivity to a SQL Server instance and
returns version, edition, and whether the instance is reachable. Read-only: no changes
are made to the server. Requires the dbatools module. Use -SqlCredential when
authentication is needed; never store passwords in scripts or command history.
.EXAMPLE
./scripts/database/Test-SqlServerConnection.ps1 -SqlInstance SqlProd
.EXAMPLE
./scripts/database/Test-SqlServerConnection.ps1 -SqlInstance SqlProd -Database ExampleDb -SqlCredential (Get-Credential)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SqlInstance,

    [string]$Database,

    [pscredential]$SqlCredential
)

if (-not (Get-Module -ListAvailable dbatools)) {
    throw 'El modulo dbatools no esta instalado. Instalelo con: Install-Module dbatools -Scope CurrentUser'
}

$splat = @{ SqlInstance = $SqlInstance; ErrorAction = 'Stop' }
if ($Database) { $splat.Database = $Database }
if ($PSBoundParameters.ContainsKey('SqlCredential')) { $splat.SqlCredential = $SqlCredential }

try {
    $instance = Connect-DbaInstance @splat

    [pscustomobject]@{
        SqlInstance   = $SqlInstance
        Database      = $Database
        Reachable     = $true
        Version       = $instance.Version
        Edition       = $instance.Edition
        ProductLevel  = $instance.ProductLevel
        IsClustered   = $instance.IsClustered
        ErrorMessage  = $null
    }
}
catch {
    [pscustomobject]@{
        SqlInstance   = $SqlInstance
        Database      = $Database
        Reachable     = $false
        Version       = $null
        Edition       = $null
        ProductLevel  = $null
        IsClustered   = $null
        ErrorMessage  = $_.Exception.Message
    }
}
