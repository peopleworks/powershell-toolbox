<#
.SYNOPSIS
Lists Azure virtual machines with their power state and size.
.DESCRIPTION
Queries Azure VMs through the Az module and returns one object per VM with name,
resource group, location, power state, size, and provisioning state. Read-only.
Requires the Az module and an authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzureVMStatus.ps1 -ResourceGroupName 'rg-ejemplo'
.EXAMPLE
./scripts/azure/Get-AzureVMStatus.ps1
#>
[CmdletBinding()]
param(
    [string]$ResourceGroupName
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$vms = if ($PSBoundParameters.ContainsKey('ResourceGroupName')) {
    Get-AzVM -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
} else {
    Get-AzVM -ErrorAction SilentlyContinue
}

$vms |
    ForEach-Object {
        $vmDetail = Get-AzVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name -Status -ErrorAction SilentlyContinue
        $powerState = ($vmDetail.Statuses | Where-Object { $_.Code -like 'PowerState/*' } | Select-Object -First 1).DisplayStatus

        [pscustomobject]@{
            VMName           = $_.Name
            ResourceGroup    = $_.ResourceGroupName
            Location         = $_.Location
            VMSize           = $_.HardwareProfile.VmSize
            PowerState       = $powerState
            ProvisioningState = $_.ProvisioningState
        }
    } |
    Sort-Object ResourceGroup, VMName
