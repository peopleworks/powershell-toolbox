<#
.SYNOPSIS
Lists Azure network interfaces with their private IP and associated VM.
.DESCRIPTION
Queries Azure network interfaces and returns one object per NIC with name, resource
group, location, private IP address, and the virtual machine it is attached to.
Read-only. Requires the Az module and an authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzureNetworkInterface.ps1 -ResourceGroupName 'rg-ejemplo'
.EXAMPLE
./scripts/azure/Get-AzureNetworkInterface.ps1
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$nics = if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
} else {
    Get-AzNetworkInterface -ErrorAction SilentlyContinue
}

$nics |
    ForEach-Object {
        $vmName = if ($_.VirtualMachine) { $_.VirtualMachine.Id.Split('/')[-1] } else { '' }
        $ipConfig = $_.IpConfigurations | Select-Object -First 1

        [pscustomobject]@{
            NICName       = $_.Name
            ResourceGroup = $_.ResourceGroupName
            Location      = $_.Location
            PrivateIP     = $ipConfig.PrivateIpAddress
            AttachedVM    = $vmName
        }
    } |
    Sort-Object ResourceGroup, NICName
