<#
.SYNOPSIS
Lists Azure public IP addresses with their allocation method and IP.
.DESCRIPTION
Queries Azure public IP addresses and returns one object per IP with name, resource
group, location, allocation method, and IP address. Read-only. Requires the Az module
and an authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzurePublicIP.ps1 -ResourceGroupName 'rg-ejemplo'
.EXAMPLE
./scripts/azure/Get-AzurePublicIP.ps1
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$ips = if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
} else {
    Get-AzPublicIpAddress -ErrorAction SilentlyContinue
}

$ips |
    ForEach-Object {
        [pscustomobject]@{
            IPName        = $_.Name
            ResourceGroup = $_.ResourceGroupName
            Location      = $_.Location
            Allocation    = $_.PublicIpAllocationMethod
            IPAddress     = $_.IpAddress
        }
    } |
    Sort-Object ResourceGroup, IPName
