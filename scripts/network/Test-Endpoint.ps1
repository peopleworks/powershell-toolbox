<#
.SYNOPSIS
Checks DNS, TCP and HTTP without sending credentials or printing response bodies.
.EXAMPLE
./scripts/network/Test-Endpoint.ps1 -Uri https://example.org/ -TimeoutSeconds 5
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][uri]$Uri,
    [ValidateRange(1, 120)][int]$TimeoutSeconds = 10
)

if ($Uri.Scheme -notin @('http', 'https') -or $Uri.UserInfo) {
    throw 'Use an HTTP(S) URI without embedded credentials.'
}
$dnsCount = 0; $tcpMs = $null; $status = $null; $stage = 'DNS'; $errorText = $null
try {
    $addresses = [System.Net.Dns]::GetHostAddresses($Uri.Host)
    $dnsCount = $addresses.Count
    $stage = 'TCP'
    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $watch = [Diagnostics.Stopwatch]::StartNew()
        $connection = $client.ConnectAsync($Uri.Host, $Uri.Port)
        if (-not $connection.Wait($TimeoutSeconds * 1000)) { throw 'TCP timeout.' }
        [void]$connection.GetAwaiter().GetResult()
        $watch.Stop()
        $tcpMs = $watch.ElapsedMilliseconds
    } finally { $client.Dispose() }
    $stage = 'HTTP'
    $response = Invoke-WebRequest -Uri $Uri -Method Get -TimeoutSec $TimeoutSeconds -MaximumRedirection 0 -SkipHttpErrorCheck
    $status = [int]$response.StatusCode
    $stage = 'Complete'
} catch {
    $errorText = $_.Exception.Message
}
[pscustomobject]@{
    Host = $Uri.Host
    Port = $Uri.Port
    Scheme = $Uri.Scheme
    DnsAddresses = $dnsCount
    TcpMilliseconds = $tcpMs
    HttpStatus = $status
    Stage = $stage
    Error = $errorText
}
