<#
.SYNOPSIS
Lists the largest files under a directory.
.DESCRIPTION
Recursively scans -Path and returns one object per file with name, path, size in MB,
last write time, and owner. Useful for identifying space-consuming files.
Read-only: no file is modified. Supports -MinSizeMB to filter small files.
Requires read access to the directory tree.
.EXAMPLE
./scripts/files/Get-LargeFiles.ps1 -Path ./downloads -MinSizeMB 100
.EXAMPLE
./scripts/files/Get-LargeFiles.ps1 -Path C:\inetpub\logs -MinSizeMB 50 -Top 20
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$Path,

    [int]$MinSizeMB = 10,

    [int]$Top = 50
)

$minSizeBytes = $MinSizeMB * 1MB

Get-ChildItem -LiteralPath $Path -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -ge $minSizeBytes } |
    ForEach-Object {
        $owner = try { (Get-Acl -LiteralPath $_.FullName).Owner } catch { $null }
        [pscustomobject]@{
            Name        = $_.Name
            FullName    = $_.FullName
            SizeMB      = [math]::Round($_.Length / 1MB, 2)
            SizeBytes   = $_.Length
            LastWrite   = $_.LastWriteTime
            Owner       = $owner
        }
    } |
    Sort-Object SizeBytes -Descending |
    Select-Object -First $Top
