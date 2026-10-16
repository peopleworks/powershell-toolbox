<#
.SYNOPSIS
Lists AWS S3 buckets with their creation date and region.
.DESCRIPTION
Queries AWS S3 and returns one object per bucket with name, creation date, and
region. Read-only: no buckets are created, modified, or deleted. Requires the AWS
Tools for PowerShell and configured credentials.
.EXAMPLE
./scripts/aws/Get-AWSS3Bucket.ps1 -Region us-east-1
#>
[CmdletBinding()]
param(
    [string]$Region = 'us-east-1'
)

if (-not (Get-Module -ListAvailable AWS.Tools.S3)) {
    throw 'El modulo AWS.Tools.S3 no esta instalado. Instale con: Install-Module AWS.Tools.Installer -Scope CurrentUser'
}

try {
    $buckets = Get-S3Bucket -Region $Region -ErrorAction Stop

    $buckets |
        ForEach-Object {
            [pscustomobject]@{
                BucketName    = $_.BucketName
                CreationDate  = $_.CreationDate
                Region        = $Region
            }
        } |
        Sort-Object BucketName
}
catch {
    Write-Error $_.Exception.Message
}
