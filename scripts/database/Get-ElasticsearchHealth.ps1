<#
.SYNOPSIS
Returns the health status of an Elasticsearch cluster.
.DESCRIPTION
Calls the _cluster/health endpoint of an Elasticsearch instance and returns cluster
name, status (green/yellow/red), number of nodes, and pending tasks. Read-only: no
changes are made to the cluster. Requires network access to the Elasticsearch port
(default 9200). Use -Credential when basic authentication is enabled.
.EXAMPLE
./scripts/database/Get-ElasticsearchHealth.ps1 -Server elastic.example.com -Port 9200
.EXAMPLE
./scripts/database/Get-ElasticsearchHealth.ps1 -Server localhost -Port 9200 -User elastic -Credential (Get-Credential)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Server,

    [int]$Port = 9200,

    [string]$User,

    [pscredential]$Credential,

    [int]$TimeoutSeconds = 10
)

$uri = "http://${Server}:${Port}/_cluster/health"

try {
    $splat = @{ Uri = $uri; Method = 'Get'; TimeoutSec = $TimeoutSeconds; ErrorAction = 'Stop' }

    if ($Credential) {
        $splat.Credential = $Credential
    } elseif ($User) {
        $splat.Credential = [pscredential]::new($User, (Read-Host -AsSecureString -Prompt "Password for $User"))
    }

    $response = Invoke-RestMethod @splat

    [pscustomobject]@{
        Server       = $Server
        Port         = $Port
        ClusterName  = $response.cluster_name
        Status       = $response.status
        TimedOut     = $response.timed_out
        Nodes        = $response.number_of_nodes
        DataNodes    = $response.number_of_data_nodes
        PendingTasks = $response.pending_tasks
        ActiveShards = $response.active_shards
        Relocating   = $response.relocating_shards
        Unassigned   = $response.unassigned_shards
        ErrorMessage = $null
    }
}
catch {
    [pscustomobject]@{
        Server       = $Server
        Port         = $Port
        ClusterName  = $null
        Status       = $null
        TimedOut     = $null
        Nodes        = $null
        DataNodes    = $null
        PendingTasks = $null
        ActiveShards = $null
        Relocating   = $null
        Unassigned   = $null
        ErrorMessage = $_.Exception.Message
    }
}
