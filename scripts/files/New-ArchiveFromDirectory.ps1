<#
.SYNOPSIS
Creates a ZIP from a directory, including hidden files.
.EXAMPLE
./scripts/files/New-ArchiveFromDirectory.ps1 -Path ./release -Output ./release.zip
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })][string]$Path,
    [Parameter(Mandatory)][string]$Output,
    [switch]$IncludeBaseDirectory,
    [switch]$Force
)

$source = (Resolve-Path -LiteralPath $Path).ProviderPath.TrimEnd('\', '/')
$target = [IO.Path]::GetFullPath($Output)
if (-not $target.EndsWith('.zip', [StringComparison]::OrdinalIgnoreCase)) { throw 'Output must end in .zip.' }
$sourcePrefix = $source + [IO.Path]::DirectorySeparatorChar
if ($target.StartsWith($sourcePrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Output must be outside the source directory.'
}
if (-not (Test-Path -LiteralPath (Split-Path -Parent $target) -PathType Container)) { throw 'Output directory does not exist.' }
if (Test-Path -LiteralPath $target) {
    if (-not $Force) { throw "Output exists: $target. Use -Force to replace it." }
    Remove-Item -LiteralPath $target -Force
}
Add-Type -AssemblyName System.IO.Compression.ZipFile
[IO.Compression.ZipFile]::CreateFromDirectory(
    $source, $target, [IO.Compression.CompressionLevel]::Optimal, [bool]$IncludeBaseDirectory
)
Get-Item -LiteralPath $target
