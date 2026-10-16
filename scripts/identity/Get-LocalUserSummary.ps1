<#
.SYNOPSIS
Reports local users and their group memberships on a Windows computer.
.DESCRIPTION
Queries local user accounts and returns one object per user with name, full name,
enabled state, last logon and the local groups the user belongs to. Read-only:
no account is created, modified or deleted. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/identity/Get-LocalUserSummary.ps1
.EXAMPLE
./scripts/identity/Get-LocalUserSummary.ps1 -UserName 'usuario_ejemplo' -IncludeDisabled
#>
[CmdletBinding()]
param(
    [string]$UserName,

    [string]$GroupName,

    [switch]$IncludeDisabled
)

$users = Get-LocalUser -ErrorAction SilentlyContinue

if ($PSBoundParameters.ContainsKey('UserName')) {
    $users = $users | Where-Object { $_.Name -like $UserName }
}
if (-not $IncludeDisabled) {
    $users = $users | Where-Object { [bool]$_.Enabled }
}

$results = [System.Collections.Generic.List[pscustomobject]]::new()
foreach ($user in $users) {
    $groups = Get-LocalGroupMember -Member $user.Name -ErrorAction SilentlyContinue |
        Where-Object { $_.ObjectClass -eq 'Group' } |
        ForEach-Object { $_.Name } |
        Sort-Object |
        Select-Object -Unique

    if ($PSBoundParameters.ContainsKey('GroupName')) {
        $match = $groups | Where-Object { $_ -like $GroupName }
        if (-not $match) { continue }
    }

    $results.Add([pscustomobject]@{
        Name           = $user.Name
        FullName       = $user.FullName
        Enabled        = [bool]$user.Enabled
        LastLogon      = $user.LastLogon
        PasswordChange = $user.PasswordChange
        PasswordExpires = $user.PasswordExpires
        Groups         = ($groups -join '; ')
        Description    = $user.Description
    })
}
$results | Sort-Object Name
