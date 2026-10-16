<#
.SYNOPSIS
Lists SQL Server Agent jobs with their last run status.
.DESCRIPTION
Queries msdb through dbatools and returns one object per SQL Server Agent job with
name, enabled state, last run date, last run outcome, and next scheduled run. Read-only:
no jobs are created, modified, started, or stopped. Requires the dbatools module and
permissions to read msdb.
.EXAMPLE
./scripts/database/Get-SqlServerAgentJobs.ps1 -SqlInstance SqlProd
.EXAMPLE
./scripts/database/Get-SqlServerAgentJobs.ps1 -SqlInstance SqlProd -EnabledOnly -JobName '*Backup*'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SqlInstance,

    [switch]$EnabledOnly,

    [string]$JobName = '*',

    [pscredential]$SqlCredential
)

if (-not (Get-Module -ListAvailable dbatools)) {
    throw 'El modulo dbatools no esta instalado. Instalelo con: Install-Module dbatools -Scope CurrentUser'
}

$splat = @{ SqlInstance = $SqlInstance; ErrorAction = 'Stop' }
if ($PSBoundParameters.ContainsKey('SqlCredential')) { $splat.SqlCredential = $SqlCredential }

$jobs = Get-DbaAgentJob @splat | Where-Object { $_.Name -like $JobName }

if ($EnabledOnly) {
    $jobs = $jobs | Where-Object { [bool]$_.IsEnabled }
}

$jobs |
    ForEach-Object {
        [pscustomobject]@{
            JobName        = $_.Name
            Enabled        = [bool]$_.IsEnabled
            LastRunDate    = $_.LastRunDate
            LastRunOutcome = $_.LastRunOutcome
            NextRunDate    = $_.NextRunDate
            Category       = $_.Category
            Description    = $_.Description
            SqlInstance    = $SqlInstance
        }
    } |
    Sort-Object JobName
