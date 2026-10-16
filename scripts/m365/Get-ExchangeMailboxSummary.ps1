<#
.SYNOPSIS
Lists Exchange Online mailboxes with their size and item count.
.DESCRIPTION
Queries Exchange Online and returns one object per mailbox with display name,
primary SMTP address, total size in MB, item count, and whether it is a shared
mailbox. Read-only: no mailbox is modified. Requires the Exchange Online Management
module and an authenticated session.
.EXAMPLE
./scripts/m365/Get-ExchangeMailboxSummary.ps1 -Mailbox 'usuario_ejemplo@ejemplo.com'
.EXAMPLE
./scripts/m365/Get-ExchangeMailboxSummary.ps1 -MaxResults 50
#>
[CmdletBinding()]
param(
    [string]$Mailbox = '*',

    [int]$MaxResults = 100
)

if (-not (Get-Module -ListAvailable ExchangeOnlineManagement)) {
    throw 'El modulo ExchangeOnlineManagement no esta instalado. Instalelo con: Install-Module ExchangeOnlineManagement -Scope CurrentUser'
}

try {
    $mailboxes = Get-Mailbox -Identity $Mailbox -ResultSize $MaxResults -ErrorAction Stop

    $mailboxes |
        ForEach-Object {
            $stats = Get-MailboxStatistics -Identity $_.PrimarySmtpAddress -ErrorAction SilentlyContinue | Select-Object -First 1

            [pscustomobject]@{
                DisplayName   = $_.DisplayName
                PrimarySMTP   = $_.PrimarySmtpAddress
                TotalSizeMB   = if ($stats) { [math]::Round($stats.TotalItemSize.Value.ToMB(), 2) } else { 0 }
                ItemCount     = if ($stats) { $stats.ItemCount } else { 0 }
                IsShared      = [bool]($_.RecipientTypeDetails -eq 'SharedMailbox')
                RecipientType = $_.RecipientTypeDetails
            }
        } |
        Sort-Object DisplayName
}
catch {
    Write-Error $_.Exception.Message
}
