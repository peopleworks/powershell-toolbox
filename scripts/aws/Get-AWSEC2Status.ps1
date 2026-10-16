<#
.SYNOPSIS
Lists AWS EC2 instances with their state and type.
.DESCRIPTION
Queries AWS EC2 and returns one object per instance with instance ID, type, state,
private IP, public IP, and launch time. Read-only: no instances are started, stopped,
or terminated. Requires the AWS Tools for PowerShell and configured credentials.
.EXAMPLE
./scripts/aws/Get-AWSEC2Status.ps1 -Region us-east-1
.EXAMPLE
./scripts/aws/Get-AWSEC2Status.ps1 -Region us-east-1 -InstanceId 'i-0ejemplo123'
#>
[CmdletBinding()]
param(
    [string]$Region = 'us-east-1',

    [string]$InstanceId
)

if (-not (Get-Module -ListAvailable AWS.Tools.EC2)) {
    throw 'El modulo AWS.Tools.EC2 no esta instalado. Instale con: Install-Module AWS.Tools.Installer -Scope CurrentUser'
}

$splat = @{ Region = $Region; ErrorAction = 'Stop' }
if ($InstanceId) { $splat.InstanceId = $InstanceId }

try {
    $instances = Get-EC2Instance @splat

    $instances.Instances |
        ForEach-Object {
            $privateIp = ($_.NetworkInterfaces | Where-Object { $_.Attachment.Status -eq 'attached' } | Select-Object -First 1).PrivateIpAddress
            $publicIp = $_.NetworkInterfaces | Where-Object { $_.Association.PublicIp } | Select-Object -First 1 -ExpandProperty Association.PublicIpAddress

            [pscustomobject]@{
                InstanceId   = $_.InstanceId
                InstanceType = $_.InstanceType
                State        = $_.State.Name
                PrivateIP    = $privateIp
                PublicIP     = $publicIp
                LaunchTime   = $_.LaunchTime
                Region       = $Region
            }
        } |
        Sort-Object InstanceId
}
catch {
    Write-Error $_.Exception.Message
}
