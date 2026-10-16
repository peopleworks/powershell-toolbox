<#
.SYNOPSIS
Returns a local hardware inventory summary for a Windows computer.
.DESCRIPTION
Queries WMI/CIM classes (Win32_ComputerSystem, Win32_Processor, Win32_PhysicalMemory,
Win32_BIOS, Win32_LogicalDisk) and returns one object with model, memory, processor,
BIOS and local fixed disks. Read-only. Requires Windows (PowerShell 7).
.EXAMPLE
./scripts/system/Get-ComputerHardware.ps1 | Format-List
#>
[CmdletBinding()]
param()

$computerSystem = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue | Select-Object -First 1
$processor      = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
$memoryBytes    = (Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object Capacity -Sum).Sum
$bios           = Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue | Select-Object -First 1

$disks = Get-CimInstance Win32_LogicalDisk -ErrorAction SilentlyContinue |
    Where-Object { $_.DriveType -eq 3 } |
    ForEach-Object {
        [pscustomobject]@{
            Letter    = $_.DeviceID
            SizeGB    = [math]::Round($_.Size / 1GB, 2)
            FreeGB    = [math]::Round($_.FreeSpace / 1GB, 2)
            FileSystem = $_.FileSystem
            DriveType = 'Local fixed disk'
        }
    } |
    Sort-Object Letter

[pscustomobject]@{
    Computer           = $env:COMPUTERNAME
    Manufacturer       = $computerSystem.Manufacturer
    Model              = $computerSystem.Model
    TotalMemoryGB      = [math]::Round(($memoryBytes / 1GB), 2)
    Processor          = $processor.Name
    ProcessorCores     = $processor.NumberOfCores
    LogicalProcessors  = $processor.NumberOfLogicalProcessors
    SystemType         = $computerSystem.SystemType
    BiosVersion        = $bios.SMBIOSBIOSVersion
    BiosSerialNumber   = $bios.SerialNumber
    Disks              = $disks
}
