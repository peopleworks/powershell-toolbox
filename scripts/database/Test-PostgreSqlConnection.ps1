<#
.SYNOPSIS
Tests connectivity to a PostgreSQL server through ODBC.
.DESCRIPTION
Opens an ODBC connection using the PostgreSQL ODBC driver and runs a simple
SELECT version() query. Returns success, server version, and elapsed time.
Read-only: no changes are made to the server. Requires the PostgreSQL ODBC driver
installed and configured. Use -Credential for authentication; never store passwords
in scripts or command history.
.EXAMPLE
./scripts/database/Test-PostgreSqlConnection.ps1 -Server postgres.example.com -Port 5432 -Database ExampleDb -User example_user
.EXAMPLE
./scripts/database/Test-PostgreSqlConnection.ps1 -Server localhost -Port 5432 -Database ExampleDb -User example_user -Credential (Get-Credential)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Server,

    [int]$Port = 5432,

    [string]$Database,

    [Parameter(Mandatory = $true)]
    [string]$User,

    [pscredential]$Credential,

    [int]$TimeoutSeconds = 10
)

$password = if ($Credential) { $Credential.GetNetworkCredential().Password } else { '' }

$connString = "Driver={PostgreSQL Unicode};Server=$Server;Port=$Port;Uid=$User;Pwd=$password;"
if ($Database) { $connString += "Database=$Database;" }

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$connection = [System.Data.Odbc.OdbcConnection]::new($connString)

try {
    $connection.ConnectionTimeout = $TimeoutSeconds
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = 'SELECT version()'
    $command.CommandTimeout = $TimeoutSeconds

    $version = $command.ExecuteScalar()

    $stopwatch.Stop()

    [pscustomobject]@{
        Server              = $Server
        Port                = $Port
        Database            = $Database
        User                = $User
        Reachable           = $true
        ServerVersion       = $version
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        ErrorMessage        = $null
    }
}
catch {
    $stopwatch.Stop()

    [pscustomobject]@{
        Server              = $Server
        Port                = $Port
        Database            = $Database
        User                = $User
        Reachable           = $false
        ServerVersion       = $null
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        ErrorMessage        = $_.Exception.Message
    }
}
finally {
    if ($connection) { $connection.Close(); $connection.Dispose() }
}
