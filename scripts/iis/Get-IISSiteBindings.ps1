<#
.SYNOPSIS
Lists IIS websites with their bindings, physical path, and state.
.DESCRIPTION
Uses the WebAdministration module to list IIS sites with protocol, binding
information, physical path, and current state. Read-only: no site is modified.
Requires Windows, IIS, and the WebAdministration module.
.EXAMPLE
./scripts/iis/Get-IISSiteBindings.ps1
.EXAMPLE
./scripts/iis/Get-IISSiteBindings.ps1 -SiteName 'Sitio_Ejemplo'
#>
[CmdletBinding()]
param(
    [string]$SiteName
)

if (-not (Get-Module -ListAvailable WebAdministration)) {
    throw 'El modulo WebAdministration no esta disponible. Instale IIS o importe el modulo manualmente.'
}

Import-Module WebAdministration -ErrorAction Stop

$sites = Get-Website -ErrorAction SilentlyContinue

if ($PSBoundParameters.ContainsKey('SiteName')) {
    $sites = $sites | Where-Object { $_.Name -eq $SiteName }
}

$sites |
    ForEach-Object {
        $bindings = if ($_.Bindings) { $_.Bindings } else { @() }

        foreach ($b in $bindings) {
            [pscustomobject]@{
                SiteName   = $_.Name
                State      = $_.State
                Protocol   = $b.protocol
                Binding    = $b.bindingInformation
                PhysicalPath = $_.PhysicalPath
                Port       = if ($b.bindingInformation -match ':(\d+):') { $matches[1] } else { '' }
            }
        }
    } |
    Sort-Object SiteName, Port
