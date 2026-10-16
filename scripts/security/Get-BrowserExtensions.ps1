<#
.SYNOPSIS
Lists installed Chrome and Edge extension folders without reading browsing history.
.EXAMPLE
./scripts/security/Get-BrowserExtensions.ps1 -Browser Both
#>
[CmdletBinding()]
param([ValidateSet('Both', 'Chrome', 'Edge')][string]$Browser = 'Both')

if (-not $IsWindows) { throw 'This script requires Windows.' }
$browsers = @(
    [pscustomobject]@{ Name = 'Chrome'; Root = Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data' },
    [pscustomobject]@{ Name = 'Edge'; Root = Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data' }
)
foreach ($item in $browsers) {
    if ($Browser -ne 'Both' -and $Browser -ne $item.Name) { continue }
    if (-not (Test-Path -LiteralPath $item.Root -PathType Container)) { continue }
    $profiles = @(Get-ChildItem -LiteralPath $item.Root -Directory | Where-Object { $_.Name -eq 'Default' -or $_.Name -like 'Profile *' })
    foreach ($profile in $profiles) {
        $extensionRoot = Join-Path $profile.FullName 'Extensions'
        if (-not (Test-Path -LiteralPath $extensionRoot -PathType Container)) { continue }
        foreach ($extension in Get-ChildItem -LiteralPath $extensionRoot -Directory) {
            [pscustomobject]@{
                Browser = $item.Name
                Profile = $profile.Name
                ExtensionId = $extension.Name
                Versions = @((Get-ChildItem -LiteralPath $extension.FullName -Directory).Name | Sort-Object)
            }
        }
    }
}
