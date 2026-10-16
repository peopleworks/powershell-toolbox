<#
.SYNOPSIS
Lists files with relative paths, sizes and optional SHA-256 hashes.
.EXAMPLE
./scripts/files/Get-DirectoryInventory.ps1 -Path ./release -IncludeHash | Export-Csv ./inventory.csv -NoTypeInformation
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })][string]$Path,
    [switch]$IncludeHash
)

$root = (Resolve-Path -LiteralPath $Path).ProviderPath
foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File) {
    if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
    [pscustomobject]@{
        RelativePath = [IO.Path]::GetRelativePath($root, $file.FullName)
        Bytes = $file.Length
        LastWriteUtc = $file.LastWriteTimeUtc.ToString('o')
        Sha256 = if ($IncludeHash) { (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash } else { $null }
    }
}
