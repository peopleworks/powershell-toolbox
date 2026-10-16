<#
.SYNOPSIS
Lists available VM sizes for a location with vCPU and memory info.
.DESCRIPTION
Queries Azure compute SKUs for a given location and returns one object per VM size
with name, vCPU count, memory in GB, and premium SSD support. Read-only. Useful for
planning VM deployments. Requires the Az module and an authenticated Azure context.
.EXAMPLE
./scripts/azure/Get-AzureVMSizeRecommendation.ps1 -Location 'eastus'
.EXAMPLE
./scripts/azure/Get-AzureVMSizeRecommendation.ps1 -Location 'eastus' -VMSizeFamily 'Standard_D'
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Location,

    [string]$VMSizeFamily
)

if (-not (Get-Module -ListAvailable Az)) {
    throw 'El modulo Az no esta instalado. Instalelo con: Install-Module Az -Scope CurrentUser'
}

$skus = Get-AzComputeSku -Location $Location -ErrorAction SilentlyContinue |
    Where-Object { $_.ResourceType -eq 'virtualMachines' }

if ($PSBoundParameters.ContainsKey('VMSizeFamily')) {
    $skus = $skus | Where-Object { $_.Name -like "$VMSizeFamily*" }
}

$skus |
    ForEach-Object {
        $vcpu = ($_.Capabilities | Where-Object { $_.Name -eq 'vCPUs' } | Select-Object -First 1).Value
        $memory = ($_.Capabilities | Where-Object { $_.Name -eq 'MemoryGB' } | Select-Object -First 1).Value
        $premium = ($_.Capabilities | Where-Object { $_.Name -eq 'PremiumIO' } | Select-Object -First 1).Value

        [pscustomobject]@{
            VMSize         = $_.Name
            Location       = $Location
            VCPU           = [int]$vcpu
            MemoryGB       = [double]$memory
            PremiumSSD     = [bool]($premium -eq 'Enabled')
        }
    } |
    Sort-Object MemoryGB -Descending
