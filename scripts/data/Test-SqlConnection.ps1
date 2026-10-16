<#
.SYNOPSIS
Tests connectivity to a SQL Server database through an ODBC DSN and runs a sample query.
.DESCRIPTION
Opens an ODBC connection using -ConnectionString (or -Dsn with -Database) and executes
-Query, returning success, row count and elapsed time. Connection strings must not
contain passwords in scripts or command history; use -Credential when available. Read-only
on the database: prefer SELECT queries. Requires an ODBC driver for SQL Server.
.EXAMPLE
./scripts/data/Test-SqlConnection.ps1 -Dsn 'ExampleSqlDsn' -Database 'ExampleDb' -Query 'SELECT COUNT(*) AS total FROM dbo.Clientes'
.EXAMPLE
./scripts/data/Test-SqlConnection.ps1 -ConnectionString 'DSN=ExampleSqlDsn;Database=ExampleDb;' -Query 'SELECT 1'
#>
[CmdletBinding()]
param(
    [string]$Dsn,

    [string]$Database,

    [Parameter(Mandatory = $true)]
    [string]$Query,

    [string]$ConnectionString,

    [int]$TimeoutSeconds = 30
)

if (-not $ConnectionString) {
    if (-not $Dsn) { throw 'Specify -ConnectionString or -Dsn.' }
    $parts = @("DSN=$Dsn")
    if ($Database) { $parts += "Database=$Database" }
    $ConnectionString = $parts -join ';'
}

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$connection = [System.Data.Odbc.OdbcConnection]::new($ConnectionString)
try {
    $connection.ConnectionTimeout = $TimeoutSeconds
    $connection.Open()

    $command = $connection.CreateCommand()
    $command.CommandText = $Query
    $command.CommandTimeout = $TimeoutSeconds

    $adapter = [System.Data.Odbc.OdbcDataAdapter]::new($command)
    $table = [System.Data.DataTable]::new()
    [void]$adapter.Fill($table)

    $stopwatch.Stop()

    [pscustomobject]@{
        Success          = $true
        Message          = 'Connection and query succeeded.'
        RowsReturned     = $table.Rows.Count
        Columns          = ($table.Columns.Count)
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        Query            = $Query
        Dsn              = $Dsn
        Database         = $Database
    }
}
catch {
    $stopwatch.Stop()
    [pscustomobject]@{
        Success          = $false
        Message          = $_.Exception.Message
        RowsReturned     = 0
        Columns          = 0
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        Query            = $Query
        Dsn              = $Dsn
        Database         = $Database
    }
}
finally {
    if ($connection) { $connection.Close(); $connection.Dispose() }
}
