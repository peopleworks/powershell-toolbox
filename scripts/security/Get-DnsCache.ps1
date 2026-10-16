<#
.SYNOPSIS
Returns the local DNS resolver cache entries.
.DESCRIPTION
Queries the local DNS cache and returns one object per entry with name, type, data,
and remaining TTL. Useful for diagnosing DNS resolution issues. Read-only.
Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/security/Get-DnsCache.ps1
.EXAMPLE
./scripts/security/Get-DnsCache.ps1 -EntryName 'ejemplo.com'
#>
[CmdletBinding()]
param(
    [string]$EntryName
)

$dnsCache = Get-DnsClientCache -ErrorAction SilentlyContinue

if ($PSBoundParameters.ContainsKey('EntryName')) {
    $dnsCache = $dnsCache | Where-Object { $_.Entry -like "*$EntryName*" }
}

$dnsCache |
    Select-Object Entry, RecordName, RecordType, Data, TimeToLive, Status |
    Sort-Object Entry
