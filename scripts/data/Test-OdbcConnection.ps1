<#
.SYNOPSIS
Tests an ODBC DSN without printing credentials or database rows.
.EXAMPLE
./scripts/data/Test-OdbcConnection.ps1 -Dsn ExampleDsn
.EXAMPLE
$credential = Get-Credential
./scripts/data/Test-OdbcConnection.ps1 -Dsn ExampleDsn -Credential $credential
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Dsn,
    [pscredential]$Credential,
    [ValidateRange(1, 120)][int]$TimeoutSeconds = 10
)

$ErrorActionPreference = 'Stop'
$builder = [System.Data.Odbc.OdbcConnectionStringBuilder]::new()
$builder['DSN'] = $Dsn
$builder['Connection Timeout'] = $TimeoutSeconds
if ($Credential) {
    $builder['UID'] = $Credential.UserName
    $passwordPtr = [IntPtr]::Zero
    try {
        $passwordPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
        $builder['PWD'] = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPtr)
    } finally {
        if ($passwordPtr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPtr)
        }
    }
}

$connection = [System.Data.Odbc.OdbcConnection]::new($builder.ConnectionString)
try {
    $watch = [System.Diagnostics.Stopwatch]::StartNew()
    $connection.Open()
    $watch.Stop()
    [pscustomobject]@{
        Dsn = $Dsn
        Connected = $true
        PowerShellBits = [IntPtr]::Size * 8
        ElapsedMilliseconds = $watch.ElapsedMilliseconds
        ServerVersion = $connection.ServerVersion
    }
} finally {
    $connection.Dispose()
    $builder.Clear()
}
