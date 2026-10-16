<#
.SYNOPSIS
Tests connectivity to AWS and reports the current authenticated identity.
.DESCRIPTION
Verifies that the AWS Tools for PowerShell are installed and that credentials are
configured. Returns the account ID, user ARN, and region. Read-only: no changes are
made to AWS. Requires the AWS.Tools.Installer module or AWS.Tools.Common, and
configured AWS credentials (aws configure or environment variables).
.EXAMPLE
./scripts/aws/Test-AWSConnectivity.ps1 -Region us-east-1
#>
[CmdletBinding()]
param(
    [string]$Region = 'us-east-1'
)

if (-not (Get-Module -ListAvailable AWS.Tools.Common)) {
    throw 'El modulo AWS.Tools.Common no esta instalado. Instale con: Install-Module AWS.Tools.Installer -Scope CurrentUser'
}

try {
    Set-AWSRegion -RegionName $Region -ErrorAction Stop | Out-Null
    $identity = Get-AWSAccount -ErrorAction Stop

    [pscustomobject]@{
        Region        = $Region
        AccountId     = $identity.Account
        UserArn       = $identity.UserArn
        Authenticated = $true
        Message       = 'Conectado a AWS.'
    }
}
catch {
    [pscustomobject]@{
        Region        = $Region
        AccountId     = $null
        UserArn       = $null
        Authenticated = $false
        Message       = 'No se pudo autenticar con AWS. Configure sus credenciales.'
        ErrorMessage  = $_.Exception.Message
    }
}
