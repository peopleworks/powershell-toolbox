<#
.SYNOPSIS
Reports the status and start mode of Windows services.
.DESCRIPTION
Queries Win32_Service and returns one object per service with name, display name,
current state, start mode and account used to start it. Read-only: no service is
started, stopped or reconfigured. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/system/Get-ServiceStatus.ps1 -Name '*spooler*'
.EXAMPLE
./scripts/system/Get-ServiceStatus.ps1 -Status Running -StartType Auto
#>
[CmdletBinding()]
param(
    [string]$Name = '*',

    [ValidateSet('Running', 'Stopped', 'Stopping', 'StartPending', 'StopPending', 'ContinuePending', 'PausePending')]
    [string]$Status,

    [ValidateSet('Auto', 'Manual', 'Disabled')]
    [string]$StartType
)

$services = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue

if ($Name -ne '*') {
    $services = $services | Where-Object { $_.Name -like $Name }
}
if ($PSBoundParameters.ContainsKey('Status')) {
    $services = $services | Where-Object { $_.State -eq $Status }
}
if ($PSBoundParameters.ContainsKey('StartType')) {
    $services = $services | Where-Object { $_.StartMode -eq $StartType }
}

$services |
    ForEach-Object {
        [pscustomobject]@{
            Name        = $_.Name
            DisplayName = $_.DisplayName
            Status      = $_.State
            StartType   = $_.StartMode
            StartName   = $_.StartName
            PathName    = $_.PathName
        }
    } |
    Sort-Object Name
