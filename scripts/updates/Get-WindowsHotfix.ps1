<#
.SYNOPSIS
Lists installed Windows hotfixes and updates on the local computer.
.DESCRIPTION
Queries Win32_QuickFixEngineering and returns one object per installed hotfix with
identifier, description, installed by and installation date. Read-only: no hotfix
is installed, uninstalled or modified. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/updates/Get-WindowsHotfix.ps1
.EXAMPLE
./scripts/updates/Get-WindowsHotfix.ps1 -HotFixId 'KB50*' -InstalledAfter '2026-01-01'
#>
[CmdletBinding()]
param(
    [string]$HotFixId = '*',

    [datetime]$InstalledAfter,

    [string]$ComputerName = $env:COMPUTERNAME
)

$hotfixes = Get-CimInstance Win32_QuickFixEngineering -ComputerName $ComputerName -ErrorAction SilentlyContinue

if ($HotFixId -ne '*') {
    $hotfixes = $hotfixes | Where-Object { $_.HotFixID -like $HotFixId }
}
if ($PSBoundParameters.ContainsKey('InstalledAfter')) {
    $hotfixes = $hotfixes | Where-Object { $_.InstalledOn -ge $InstalledAfter }
}

$hotfixes |
    ForEach-Object {
        [pscustomobject]@{
            HotFixID      = $_.HotFixID
            Description   = $_.Description
            InstalledBy   = $_.InstalledBy
            InstalledOn   = $_.InstalledOn
            ComputerName  = $_.CSName
        }
    } |
    Sort-Object InstalledOn -Descending
