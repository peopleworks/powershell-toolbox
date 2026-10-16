<#
.SYNOPSIS
Tests connectivity to the Docker daemon.
.DESCRIPTION
Runs `docker version` and `docker info` to verify that Docker is installed and the
daemon is reachable. Returns server version, OS type, and number of containers and
images. Read-only: no changes are made to Docker. Requires Docker installed.
.EXAMPLE
./scripts/containers/Test-DockerConnectivity.ps1
#>
[CmdletBinding()]
param()

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker no esta instalado o no esta en el PATH.'
}

try {
    $version = docker version --format '{{.Server.Version}}' -ErrorAction Stop
    $info = docker info --format '{{.OSType}}|{{.Containers}}|{{.Images}}' -ErrorAction Stop

    $fields = $info -split '\|'

    [pscustomobject]@{
        DockerInstalled = $true
        ServerVersion   = $version
        OSType          = $fields[0]
        Containers      = [int]$fields[1]
        Images          = [int]$fields[2]
        Message         = 'Docker daemon reachable.'
    }
}
catch {
    [pscustomobject]@{
        DockerInstalled = $false
        ServerVersion   = $null
        OSType          = $null
        Containers      = $null
        Images          = $null
        Message         = 'Docker daemon not reachable.'
        ErrorMessage    = $_.Exception.Message
    }
}
