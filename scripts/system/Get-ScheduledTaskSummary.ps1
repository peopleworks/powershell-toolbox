<#
.SYNOPSIS
Summarizes Windows scheduled tasks: state, last run and next run.
.DESCRIPTION
Lists scheduled tasks with their current state, last run time and result, next run time,
and whether they are enabled. Requires Windows and the ScheduledTasks cmdlets (available
in PowerShell 7 on Windows). No task is created, modified or deleted.
.EXAMPLE
./scripts/system/Get-ScheduledTaskSummary.ps1
.EXAMPLE
./scripts/system/Get-ScheduledTaskSummary.ps1 -TaskName '*Update*' -IncludeDisabled
#>
[CmdletBinding()]
param(
    [string]$TaskName,

    [ValidateSet('Ready', 'Running', 'Queued', 'Disabled', 'Unknown')]
    [string]$State,

    [switch]$IncludeDisabled
)

$tasks = Get-ScheduledTask -ErrorAction SilentlyContinue

if ($PSBoundParameters.ContainsKey('TaskName')) {
    $tasks = $tasks | Where-Object { $_.TaskName -like $TaskName }
}
if ($PSBoundParameters.ContainsKey('State')) {
    $tasks = $tasks | Where-Object { $_.State -eq $State }
}
if (-not $IncludeDisabled) {
    $tasks = $tasks | Where-Object { [bool]($_.Settings.Enabled) }
}

$tasks |
    ForEach-Object {
        [pscustomobject]@{
            TaskName    = $_.TaskName
            FolderPath  = $_.FolderPath
            State       = $_.State
            LastRunTime = $_.LastRunTime
            LastResult  = $_.LastTaskResult
            NextRunTime = $_.NextRunTime
            Enabled     = [bool]($_.Settings.Enabled)
        }
    } |
    Sort-Object FolderPath, TaskName
