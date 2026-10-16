<#
.SYNOPSIS
Restores SQL Server databases from a mid-day backup to a destination server.
.DESCRIPTION
Adapted from the IBEROFARMACOS mid-day backup routine. Uses dbatools Copy-DbaDatabase
to restore one or more databases from a shared mid-day backup path to a destination
instance with WITH REPLACE and compressed backups. Read-only on the source; writes to
the destination server and shared path. Requires the dbatools module and access to the
shared backup path. All server, database, and path values are parameters with fictional
examples; replace them with your own before running.
.EXAMPLE
./scripts/database/Get-SqlServerBackupDia.ps1 -Source DBSERVER -Destination APPSERVER4 -SharedPath '\\10.0.20.3\c$\Backup\MedioDia\DBSERVER\EXACTUS\FULL\' -Databases @('EXACTUS','BIServer')
.EXAMPLE
./scripts/database/Get-SqlServerBackupDia.ps1 -Source SqlProd -Destination SqlDr -SharedPath '\\backups\sql\midday\' -Databases @('AppDb') -Compress:$false
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Destination,

    [Parameter(Mandatory = $true)]
    [string]$SharedPath,

    [Parameter(Mandatory = $true)]
    [string[]]$Databases,

    [switch]$Compress = $true,

    [switch]$WithReplace = $true
)

if (-not (Get-Module -ListAvailable dbatools)) {
    throw 'El modulo dbatools no esta instalado. Instalelo con: Install-Module dbatools -Scope CurrentUser'
}

$advancedParams = @{}
if ($Compress) { $advancedParams.CompressBackup = $true }

$results = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($database in $Databases) {
    $message = "Restore $database from mid-day $SharedPath to $Destination"

    if (-not $PSCmdlet.ShouldProcess($message, "Restore database")) {
        $results.Add([pscustomobject]@{ Database = $database; Action = 'Skipped (WhatIf)'; Status = 'WhatIf'; Detail = '' })
        continue
    }

    try {
        $splat = @{
            Source            = $Source
            Destination       = $Destination
            Database          = $database
            BackupRestore     = $true
            SharedPath        = $SharedPath
            WithReplace       = $WithReplace
            AdvancedBackupParams = $advancedParams
        }

        Copy-DbaDatabase @splat -ErrorAction Stop

        $results.Add([pscustomobject]@{ Database = $database; Action = 'Restore'; Status = 'Success'; Detail = "$database restored from $Source to $Destination" })
    }
    catch {
        $results.Add([pscustomobject]@{ Database = $database; Action = 'Restore'; Status = 'Failed'; Detail = $_.Exception.Message })
    }
}

$results | Sort-Object Database
