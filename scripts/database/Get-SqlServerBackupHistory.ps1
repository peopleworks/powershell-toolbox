<#
.SYNOPSIS
Returns the backup history of databases from msdb.
.DESCRIPTION
Queries msdb.backupset through dbatools and returns one object per database with the
most recent full, differential, and log backup dates and sizes. Read-only: no changes
are made to the server. Requires the dbatools module and permissions to read msdb.
.EXAMPLE
./scripts/database/Get-SqlServerBackupHistory.ps1 -SqlInstance SqlProd
.EXAMPLE
./scripts/database/Get-SqlServerBackupHistory.ps1 -SqlInstance SqlProd -Database ExampleDb -DaysBack 7
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SqlInstance,

    [string]$Database,

    [int]$DaysBack = 30,

    [pscredential]$SqlCredential
)

if (-not (Get-Module -ListAvailable dbatools)) {
    throw 'El modulo dbatools no esta instalado. Instalelo con: Install-Module dbatools -Scope CurrentUser'
}

$splat = @{ SqlInstance = $SqlInstance; ErrorAction = 'Stop' }
if ($PSBoundParameters.ContainsKey('SqlCredential')) { $splat.SqlCredential = $SqlCredential }

$cutoff = (Get-Date).AddDays(-$DaysBack)

$backups = Get-DbaBackupHistory @splat |
    Where-Object { $_.BackupStartDate -ge $cutoff } |
    Where-Object { $_.Type -in @('D', 'I', 'L') }

if ($Database) {
    $backups = $backups | Where-Object { $_.Database -eq $Database }
}

$backups |
    Group-Object Database |
    ForEach-Object {
        $db = $_.Name
        $full   = $_.Group | Where-Object { $_.Type -eq 'D' } | Sort-Object BackupStartDate -Descending | Select-Object -First 1
        $diff   = $_.Group | Where-Object { $_.Type -eq 'I' } | Sort-Object BackupStartDate -Descending | Select-Object -First 1
        $log    = $_.Group | Where-Object { $_.Type -eq 'L' } | Sort-Object BackupStartDate -Descending | Select-Object -First 1

        [pscustomobject]@{
            Database        = $db
            LastFullBackup  = $full.BackupStartDate
            FullSizeMB      = [math]::Round($full.BackupSize / 1MB, 2)
            LastDiffBackup  = $diff.BackupStartDate
            LastLogBackup   = $log.BackupStartDate
            SqlInstance     = $SqlInstance
        }
    } |
    Sort-Object Database
