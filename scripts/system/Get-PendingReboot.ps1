<#
.SYNOPSIS
Reports whether a Windows computer requires a restart.
.DESCRIPTION
Inspects pending-file-rename operations, Windows Update and Component Based Servicing
registry markers to decide if a reboot is pending. The script is read-only: it does not
restart the computer nor change any setting. Requires Windows; run as administrator for
the most complete view of system-wide markers.
.EXAMPLE
./scripts/system/Get-PendingReboot.ps1
#>
[CmdletBinding()]
param()

$reasons = [System.Collections.Generic.List[string]]::new()

# Files queued for replacement at next boot (PendingFileRenameOperations).
$pfroPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
if (Test-Path -LiteralPath $pfroPath) {
    $pfro = Get-ItemProperty -LiteralPath $pfroPath -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue
    if ($pfro -and $pfro.PendingFileRenameOperations) {
        $reasons.Add('PendingFileRenameOperations: files queued for replacement at next boot.')
    }
}

# Windows Update / Automatic Update reboot-required marker.
$auPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'
if (Test-Path -LiteralPath $auPath) {
    $reboot = Get-ItemProperty -LiteralPath $auPath -Name 'RebootRequired' -ErrorAction SilentlyContinue
    if ($reboot -and $reboot.RebootRequired -eq 1) {
        $reasons.Add('Windows Update: reboot required marker present.')
    }
}

# Component Based Servicing markers.
foreach ($cbsPath in @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Pending'
)) {
    if (Test-Path -LiteralPath $cbsPath) {
        $reasons.Add("Component Based Servicing: pending servicing operations detected ($cbsPath).")
    }
}

$pending = $reasons.Count -gt 0
[pscustomobject]@{
    Computer    = $env:COMPUTERNAME
    PendingReboot = $pending
    Reasons     = $reasons
    Detail      = if ($pending) { $reasons -join '; ' } else { 'No reboot markers detected.' }
}
