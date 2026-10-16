<#
.SYNOPSIS
Lists Chrome and Edge policy values from current-user and machine registry keys.
.EXAMPLE
./scripts/security/Get-BrowserPolicies.ps1 | Format-Table
#>
[CmdletBinding()]
param()

if (-not $IsWindows) { throw 'This script requires Windows.' }
foreach ($browser in @('Google\Chrome', 'Microsoft\Edge')) {
    foreach ($scope in @('HKCU:', 'HKLM:')) {
        $key = "$scope\SOFTWARE\Policies\$browser"
        if (-not (Test-Path -LiteralPath $key)) { continue }
        $item = Get-ItemProperty -LiteralPath $key
        foreach ($property in $item.PSObject.Properties) {
            if ($property.Name -like 'PS*') { continue }
            [pscustomobject]@{
                Browser = if ($browser -like 'Google*') { 'Chrome' } else { 'Edge' }
                Scope = $scope
                Policy = $property.Name
                Value = $property.Value
            }
        }
    }
}
