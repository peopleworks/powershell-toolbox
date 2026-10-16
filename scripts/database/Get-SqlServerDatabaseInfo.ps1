<#
.SYNOPSIS
Returns information about databases on a SQL Server instance.
.DESCRIPTION
Queries sys.databases through dbatools and returns one object per database with name,
state, recovery model, compatibility level, size, and owner. Read-only: no changes are
made to the server. Requires the dbatools module.
.EXAMPLE
./scripts/database/Get-SqlServerDatabaseInfo.ps1 -SqlInstance SqlProd
.EXAMPLE
./scripts/database/Get-SqlServerDatabaseInfo.ps1 -SqlInstance SqlProd -Database ExampleDb
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
if ($PSBoundParameters.ContainsKey('SqlCredential')) { $splat.SqlCredential = $SqlCredential }

$databases = Get-DbaDatabase @splat

if ($Database) {
    $databases = $databases | Where-Object { $_.Name -eq $Database }
}

$databases |
    ForEach-Object {
        [pscustomobject]@{
            Name             = $_.Name
            State            = $_.State
            RecoveryModel    = $_.RecoveryModel
            CompatibilityLevel = $_.CompatibilityLevel
            SizeMB           = [math]::Round($_.Size / 1MB, 2)
            Owner            = $_.Owner
            CreateDate       = $_.CreateDate
            SqlInstance      = $SqlInstance
        }
    } |
    Sort-Object Name
