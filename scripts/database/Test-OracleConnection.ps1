<#
.SYNOPSIS
Tests connectivity to an Oracle database through ODBC.
.DESCRIPTION
Opens an ODBC connection using the Oracle ODBC driver and runs a simple query against
DUAL. Returns success and elapsed time. Read-only: no changes are made to the server.
Requires the Oracle ODBC driver installed and configured, and a valid TNS entry or
connection string. Use -Credential for authentication; never store passwords in scripts
or command history.
.EXAMPLE
./scripts/database/Test-OracleConnection.ps1 -TnsName ExampleOracle -User example_user
.EXAMPLE
./scripts/database/Test-OracleConnection.ps1 -TnsName ExampleOracle -User example_user -Credential (Get-Credential)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TnsName,

    [Parameter(Mandatory = $true)]
    [string]$User,

    [pscredential]$Credential,

    [int]$TimeoutSeconds = 10
)

$password = if ($Credential) { $Credential.GetNetworkCredential().Password } else { '' }

$connString = "Driver={Oracle in OraClient19Home1};Dbq=$TnsName;Uid=$User;Pwd=$password;"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$connection = [System.Data.Odbc.OdbcConnection]::new($connString)

try {
    $connection.ConnectionTimeout = $TimeoutSeconds
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = 'SELECT 1 FROM DUAL'
    $command.CommandTimeout = $TimeoutSeconds

    [void]$command.ExecuteScalar()

    $stopwatch.Stop()

    [pscustomobject]@{
        TnsName             = $TnsName
        User                = $User
        Reachable           = $true
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        ErrorMessage        = $null
    }
}
catch {
    $stopwatch.Stop()

    [pscustomobject]@{
        TnsName             = $TnsName
        User                = $User
        Reachable           = $false
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        ErrorMessage        = $_.Exception.Message
    }
}
finally {
    if ($connection) { $connection.Close(); $connection.Dispose() }
}
