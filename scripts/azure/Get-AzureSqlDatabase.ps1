<#
.SYNOPSIS
Lists Azure SQL databases with their edition and status.
.DESCRIPTION
Queries Azure SQL databases and returns one object per database with name, server,
resource group, edition, service objective, status, and collation. Read-only.
Requires the Az module and an authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzureSqlDatabase.ps1 -ResourceGroupName 'rg-ejemplo' -ServerName 'sql-ejemplo'
.EXAMPLE
./scripts/azure/Get-AzureSqlDatabase.ps1 -ServerName 'sql-ejemplo'
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName,

    [string]$ServerName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$databases = if ($PSBoundParameters.ContainsKey('ServerName')) {
    Get-AzSqlDatabase -ServerName $ServerName -ErrorAction SilentlyContinue
} else {
    Get-AzSqlDatabase -ErrorAction SilentlyContinue
}

if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    $databases = $databases | Where-Object { $_.ResourceGroupName -eq $ResourceGroupName }
}

$databases |
    ForEach-Object {
        [pscustomobject]@{
            DatabaseName  = $_.DatabaseName
            ServerName    = $_.ServerName
            ResourceGroup = $_.ResourceGroupName
            Location      = $_.Location
            Edition       = $_.Edition
            ServiceObjective = $_.RequestedServiceObjectiveName
            Status        = $_.Status
            Collation     = $_.Collation
        }
    } |
    Sort-Object ResourceGroup, DatabaseName
