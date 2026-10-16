<#
.SYNOPSIS
Tests connectivity to a MongoDB server.
.DESCRIPTION
Attempts to connect to a MongoDB instance using the official MongoDB .NET driver and
runs a ping command against the admin database. Returns success, server version, and
elapsed time. Read-only: no changes are made to the server. Requires the MongoDB.Driver
NuGet package or module available in the session. Use -Credential for authentication;
never store passwords in scripts or command history.
.EXAMPLE
./scripts/database/Test-MongoDbConnection.ps1 -Server mongodb.example.com -Port 27017
.EXAMPLE
./scripts/database/Test-MongoDbConnection.ps1 -Server localhost -Port 27017 -User example_user -Credential (Get-Credential)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Server,

    [int]$Port = 27017,

    [string]$User,

    [pscredential]$Credential,

    [int]$TimeoutSeconds = 10
)

try {
    Add-Type -Path (Get-Module -ListAvailable MongoDB.Driver | Select-Object -First 1).Path -ErrorAction Stop
}
catch {
    throw 'El controlador MongoDB.Driver no esta disponible. Instale el paquete NuGet MongoDB.Driver o importe el modulo correspondiente.'
}

$password = if ($Credential) { $Credential.GetNetworkCredential().Password } else { '' }
$auth = if ($User) { "?username=$User&password=$password&authSource=admin" } else { '' }

$uri = "mongodb://${Server}:${Port}/${auth}"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $client = [MongoDB.Driver.MongoClient]::new($uri)
    $database = $client.GetDatabase('admin')
    $result = $database.RunCommand(@{ ping = 1 })

    $stopwatch.Stop()

    [pscustomobject]@{
        Server              = $Server
        Port                = $Port
        User                = $User
        Reachable           = $true
        PingResult          = $result
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        ErrorMessage        = $null
    }
}
catch {
    $stopwatch.Stop()

    [pscustomobject]@{
        Server              = $Server
        Port                = $Port
        User                = $User
        Reachable           = $false
        PingResult          = $null
        ElapsedMilliseconds = $stopwatch.ElapsedMilliseconds
        ErrorMessage        = $_.Exception.Message
    }
}
