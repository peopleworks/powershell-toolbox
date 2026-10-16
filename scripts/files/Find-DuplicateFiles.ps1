<#
.SYNOPSIS
Finds files with identical size and SHA-256 hash. It never deletes files.
.EXAMPLE
./scripts/files/Find-DuplicateFiles.ps1 -Path ./downloads
#>
[CmdletBinding()]
param([Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })][string]$Path)

$root = (Resolve-Path -LiteralPath $Path).ProviderPath
$files = @(Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object {
    -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint)
})
foreach ($sizeGroup in $files | Group-Object Length | Where-Object Count -gt 1) {
    $hashed = @($sizeGroup.Group | ForEach-Object {
        [pscustomobject]@{ Path = $_.FullName; Hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
    })
    foreach ($hashGroup in $hashed | Group-Object Hash | Where-Object Count -gt 1) {
        [pscustomobject]@{
            BytesEach = [long]$sizeGroup.Name
            Copies = $hashGroup.Count
            Sha256 = $hashGroup.Name
            Files = @($hashGroup.Group.Path | Sort-Object)
        }
    }
}
