<#
.SYNOPSIS
Lists Windows Defender firewall rules with their state and scope.
.DESCRIPTION
Queries Get-NetFirewallRule (NetSecurity module) and returns one object per rule with
name, display name, enabled state, direction, profile, action and ports. Read-only: no
rule is created, modified or removed. Requires Windows and the NetSecurity module
(PowerShell 7).
.EXAMPLE
./scripts/security/Get-FirewallRules.ps1 -EnabledOnly -Direction Inbound
.EXAMPLE
./scripts/security/Get-FirewallRules.ps1 -Profile Private
#>
[CmdletBinding()]
param(
    [switch]$EnabledOnly,

    [ValidateSet('Inbound', 'Outbound')]
    [string]$Direction,

    [ValidateSet('Domain', 'Private', 'Public', 'Any')]
    [string]$Profile
)

$rules = Get-NetFirewallRule -ErrorAction SilentlyContinue

if ($EnabledOnly) {
    $rules = $rules | Where-Object { [bool]$_.Enabled }
}
if ($PSBoundParameters.ContainsKey('Direction')) {
    $rules = $rules | Where-Object { $_.Direction -eq $Direction }
}
if ($PSBoundParameters.ContainsKey('Profile') -and $Profile -ne 'Any') {
    $rules = $rules | Where-Object { $_.Profile -eq $Profile }
}

$rules |
    ForEach-Object {
        [pscustomobject]@{
            Name       = $_.Name
            DisplayName = $_.DisplayName
            Enabled    = [bool]$_.Enabled
            Direction  = $_.Direction
            Profile    = $_.Profile
            Action     = $_.Action
            LocalPort  = if ($_.LocalPort) { $_.LocalPort -join ', ' } else { '' }
            RemotePort = if ($_.RemotePort) { $_.RemotePort -join ', ' } else { '' }
            Protocol   = $_.Protocol
        }
    } |
    Sort-Object Direction, Name
