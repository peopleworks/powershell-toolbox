<#
.SYNOPSIS
Tests connectivity to a MySQL or MariaDB server through ODBC.
.DESCRIPTION
Opens an ODBC connection using the MySQL ODBC driver and runs a simple SELECT 1 query.
Returns success, server version, and elapsed time. Read-only: no changes are made to
the server. Requires the MySQL ODBC driver installed and configured. Use -Credential
for authentication; never store passwords in scripts or command history.
.EXAMPLE
./scripts/database/Test-MySqlConnection.ps1 -Server mysql.example.com -Port 3306 -Database ExampleDb -User example_user
.EXAMPLE
./scripts/database/Test-MySqlConnection.ps1 -Server localhost -Port 3306 -Database ExampleDb -User example_user -Credential (Get-Credential)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Server,

    [int]$Port = 3306,

    [string]$Database,

    [Parameter(Mandatory = $true)]
    [string]$User,

    [pscredential]$Credential,

    [int]$TimeoutSeconds = 10
)

$password = if ($Credential) { $Credential.GetNetworkCredential().Password } else { '' }

$connString = "Driver={MySQL ODBC 8.0 Driver};Server=$Server;Port=$Port;Uid=$User;Pwd=$password;"
if ($Database) { $connString += "Database=$Database;" }

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$connection = [System.Data.Odbc.OdbcConnection]::new($connString)

try {
    $connection.ConnectionTimeout = $TimeoutSeconds
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = 'SELECT VERSION()'
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
