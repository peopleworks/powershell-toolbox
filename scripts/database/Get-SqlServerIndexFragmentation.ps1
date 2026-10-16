<#
.SYNOPSIS
Reports index fragmentation for a SQL Server database.
.DESCRIPTION
Queries sys.dm_db_index_physical_stats through dbatools and returns one object per
index with average fragmentation percentage, page count, and whether a rebuild or
reorganize is recommended. Read-only: no indexes are modified. Requires the dbatools
module and VIEW DATABASE STATE permission.
.EXAMPLE
./scripts/database/Get-SqlServerIndexFragmentation.ps1 -SqlInstance SqlProd -Database ExampleDb
.EXAMPLE
./scripts/database/Get-SqlServerIndexFragmentation.ps1 -SqlInstance SqlProd -Database ExampleDb -MinFragmentation 30
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SqlInstance,

    [Parameter(Mandatory = $true)]
    [string]$Database,

    [double]$MinFragmentation = 0,

    [pscredential]$SqlCredential
)

if (-not (Get-Module -ListAvailable dbatools)) {
    throw 'El modulo dbatools no esta instalado. Instalelo con: Install-Module dbatools -Scope CurrentUser'
}

$splat = @{ SqlInstance = $SqlInstance; Database = $Database; ErrorAction = 'Stop' }
if ($PSBoundParameters.ContainsKey('SqlCredential')) { $splat.SqlCredential = $SqlCredential }

$stats = Get-DbaDbIndex -SqlInstance $SqlInstance -Database $Database -ErrorAction Stop

$stats |
    Where-Object { $_.AvgFragmentation -ge $MinFragmentation } |
    ForEach-Object {
        $recommendation = if ($_.AvgFragmentation -ge 30) { 'REBUILD' } elseif ($_.AvgFragmentation -ge 10) { 'REORGANIZE' } else { 'NONE' }

        [pscustomobject]@{
            Schema          = $_.Schema
            Table           = $_.Table
            Index           = $_.Index
            AvgFragmentation = [math]::Round($_.AvgFragmentation, 2)
            PageCount       = $_.PageCount
            Recommendation  = $recommendation
            SqlInstance     = $SqlInstance
            Database        = $Database
        }
    } |
    Sort-Object AvgFragmentation -Descending
