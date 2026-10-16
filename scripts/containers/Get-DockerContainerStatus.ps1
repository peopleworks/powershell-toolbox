<#
.SYNOPSIS
Lists Docker containers with their status and ports.
.DESCRIPTION
Queries Docker and returns one object per container with ID, name, image, state,
status, and exposed ports. Read-only: no container is created, started, stopped,
or removed. Requires Docker installed and the Docker daemon running.
.EXAMPLE
./scripts/containers/Get-DockerContainerStatus.ps1
.EXAMPLE
./scripts/containers/Get-DockerContainerStatus.ps1 -ContainerName 'mi-contenedor'
#>
[CmdletBinding()]
param(
    [string]$ContainerName
)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker no esta instalado o no esta en el PATH. Instale Docker Desktop o Docker Engine.'
}

try {
    $containers = docker ps --all --format '{{.ID}}|{{.Names}}|{{.Image}}|{{.State}}|{{.Status}}|{{.Ports}}' -ErrorAction Stop

    $containers |
        Where-Object {
            if ($ContainerName) { $_ -like "*$ContainerName*" } else { $true }
        } |
        ForEach-Object {
            $fields = $_ -split '\|'
            [pscustomobject]@{
                ContainerID = $fields[0]
                Name        = $fields[1]
                Image       = $fields[2]
                State       = $fields[3]
                Status      = $fields[4]
                Ports       = $fields[5]
            }
        } |
        Sort-Object Name
}
catch {
    Write-Error $_.Exception.Message
}
