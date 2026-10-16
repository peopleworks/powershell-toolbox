<#
.SYNOPSIS
Lists certificates that are expired or expire soon in a Windows certificate store.
.DESCRIPTION
Opens a local certificate store read-only and reports certificates whose NotAfter date is
within -DaysAhead days (default 30). No private keys are exported and no store is modified.
Use -StoreLocation LocalMachine only when running as administrator; CurrentUser does not
require elevation. Requires Windows and .NET (available in PowerShell 7 on Windows).
.EXAMPLE
./scripts/security/Get-CertificateExpiry.ps1 -StoreLocation CurrentUser -StoreName My -DaysAhead 30
.EXAMPLE
./scripts/security/Get-CertificateExpiry.ps1 -StoreLocation LocalMachine -StoreName My -ExcludeExpired
#>
[CmdletBinding()]
param(
    [ValidateSet('LocalMachine', 'CurrentUser')]
    [string]$StoreLocation = 'CurrentUser',

    [string]$StoreName = 'My',

    [int]$DaysAhead = 30,

    [switch]$ExcludeExpired
)

$location = [System.Security.Cryptography.X509Certificates.StoreLocation]::Parse($StoreLocation)
$store = [System.Security.Cryptography.X509Certificates.X509Store]::new($StoreName, $location)
try {
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
    $now = Get-Date
    $cutoff = $now.AddDays($DaysAhead)

    $store.Certificates |
        Where-Object { $_.NotAfter -le $cutoff } |
        Where-Object { -not $ExcludeExpired -or $_.NotAfter -gt $now } |
        ForEach-Object {
            [pscustomobject]@{
                Subject           = $_.Subject
                Thumbprint        = $_.Thumbprint
                NotBefore         = $_.NotBefore
                NotAfter          = $_.NotAfter
                DaysUntilExpiry   = [math]::Round(($_.NotAfter - $now).TotalDays, 2)
                IsExpired         = $_.NotAfter -lt $now
                WillExpireSoon    = $_.NotAfter -le $cutoff
                StoreLocation     = $StoreLocation
                StoreName         = $StoreName
            }
        } |
        Sort-Object NotAfter
}
finally {
    $store.Close()
}
