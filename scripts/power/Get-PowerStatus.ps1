<#
.SYNOPSIS
Reports battery status, active power plan and optionally USB devices on Windows.
.DESCRIPTION
Queries Win32_Battery, Win32_PowerPlan and, when requested, Win32_PnPEntity for USB
devices. Returns one object with battery charge, AC status, active power plan and an
optional list of USB devices. Read-only. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/power/Get-PowerStatus.ps1
.EXAMPLE
./scripts/power/Get-PowerStatus.ps1 -IncludeUsb
#>
[CmdletBinding()]
param(
    [switch]$IncludeUsb
)

$battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1

$powerPlans = Get-CimInstance Win32_PowerPlan -ErrorAction SilentlyContinue |
    ForEach-Object {
        [pscustomobject]@{
            Name     = $_.ElementName
            IsActive = [bool]$_.IsActive
            Guid     = $_.InstanceID
        }
    } |
    Sort-Object IsActive -Descending

$usbDevices = if ($IncludeUsb) {
    Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue |
        Where-Object { $_.PNPDeviceID -like '*USB*' } |
        Select-Object -First 50 |
        ForEach-Object {
            [pscustomobject]@{
                Name   = $_.Name
                Device = $_.PNPDeviceID
                Status = $_.Status
            }
        }
} else {
    $null
}

[pscustomobject]@{
    Computer         = $env:COMPUTERNAME
    BatteryPresent   = [bool]($battery -ne $null)
    EstimatedCharge  = if ($battery) { [int]$battery.EstimatedChargeRemaining } else { $null }
    BatteryStatus    = if ($battery) { $battery.BatteryStatus } else { $null }
    ACOnline         = if ($battery) { [bool]($battery.BatteryStatus -eq 2) } else { $null }
    PowerPlans       = $powerPlans
    ActivePowerPlan  = ($powerPlans | Where-Object IsActive | Select-Object -First 1).Name
    UsbDevices       = $usbDevices
}
