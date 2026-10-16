<#
.SYNOPSIS
Reports DNS configuration of IP-enabled network adapters on Windows.
.DESCRIPTION
Queries Win32_NetworkAdapterConfiguration and returns one object per adapter with its
description, MAC address, DHCP state, IP addresses, DNS servers and DNS domain. Read-only.
Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/network/Get-DnsClientConfig.ps1
.EXAMPLE
./scripts/network/Get-DnsClientConfig.ps1 -InterfaceAlias 'Ethernet'
#>
[CmdletBinding()]
param(
    [string]$InterfaceAlias
)

$adapters = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" -ErrorAction SilentlyContinue

if ($PSBoundParameters.ContainsKey('InterfaceAlias')) {
    $adapters = $adapters | Where-Object { $_.Description -like "*$InterfaceAlias*" }
}

$adapters |
    ForEach-Object {
        [pscustomobject]@{
            Interface   = $_.Description
            Index       = $_.Index
            MacAddress  = $_.MACAddress
            DhcpEnabled = [bool]$_.DHCPEnabled
            IpAddress   = if ($_.IPAddress) { $_.IPAddress -join ', ' } else { '' }
            DnsServers  = if ($_.DNSServerSearchOrder) { $_.DNSServerSearchOrder -join ', ' } else { '' }
            DnsDomain   = $_.DNSDomain
        }
    } |
    Sort-Object Interface
