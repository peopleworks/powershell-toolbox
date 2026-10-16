<#
.SYNOPSIS
Tests connectivity to a Redis server.
.DESCRIPTION
Opens a TCP connection to a Redis instance and sends a PING command, waiting for a
PONG response. Returns success and elapsed time. Read-only: no changes are made to
the server. Requires network access to the Redis port (default 6379). Use -Password
when Redis requires authentication; never store passwords in scripts or command
history.
.EXAMPLE
./scripts/database/Test-RedisConnection.ps1 -Server redis.example.com -Port 6379
.EXAMPLE
./scripts/database/Test-RedisConnection.ps1 -Server localhost -Port 6379 -Password example_password
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Server,

    [int]$Port = 6379,

    [string]$Password,

    [int]$TimeoutSeconds = 10
)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $socket = [System.Net.Sockets.TcpClient]::new()
    $connectTask = $socket.ConnectAsync($Server, $Port)

    if (-not $connectTask.Wait($TimeoutSeconds * 1000)) {
        throw 'Connection timed out.'
    }

    $stream = $socket.GetStream()
    $writer = [System.IO.StreamWriter]::new($stream)
    $reader = [System.IO.StreamReader]::new($stream)

    $writer.WriteLine('PING')
    $writer.Flush()

    $response = $reader.ReadLine()

    $stopwatch.Stop()

    [pscustomobject]@{
        Server              = $Server
        Port                = $Port
        Reachable           = $true
        Response            = $response
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        ErrorMessage        = $null
    }
}
catch {
    $stopwatch.Stop()

    [pscustomobject]@{
        Server              = $Server
        Port                = $Port
        Reachable           = $false
        Response            = $null
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        ErrorMessage        = $_.Exception.Message
    }
}
finally {
    if ($socket) { $socket.Close() }
}
