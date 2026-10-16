<#
.SYNOPSIS
Exports one diagram or a directory of .drawio files to PNG using draw.io Desktop.
.EXAMPLE
./scripts/images/Convert-DrawioToPng.ps1 -Path ./diagrams -OutputDirectory ./exports
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ })][string]$Path,
    [Parameter(Mandatory)][string]$OutputDirectory,
    [ValidateRange(100, 10000)][int]$Width = 2400,
    [ValidateRange(0, 100)][int]$Border = 10,
    [string]$DrawioPath,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$inputItem = Get-Item -LiteralPath $Path
$files = if ($inputItem.PSIsContainer) {
    @(Get-ChildItem -LiteralPath $inputItem.FullName -Filter '*.drawio' -File | Sort-Object Name)
} else {
    if ($inputItem.Extension -ne '.drawio') { throw 'Input file must have a .drawio extension.' }
    @($inputItem)
}
if ($files.Count -eq 0) { throw 'No .drawio files found.' }
$outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
if (-not (Test-Path -LiteralPath $outputRoot -PathType Container)) { throw "Output directory does not exist: $outputRoot" }
if ($DrawioPath) {
    $drawio = (Resolve-Path -LiteralPath $DrawioPath).ProviderPath
} else {
    $command = Get-Command drawio -ErrorAction SilentlyContinue
    $candidates = @(
        "$env:ProgramFiles\draw.io\draw.io.exe",
        "${env:ProgramFiles(x86)}\draw.io\draw.io.exe",
        "$env:LOCALAPPDATA\Programs\draw.io\draw.io.exe"
    )
    $drawio = if ($command) { $command.Source } else {
        $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1
    }
}
if (-not $drawio) { throw 'draw.io Desktop was not found. Pass -DrawioPath.' }

foreach ($file in $files) {
    $target = Join-Path $outputRoot ($file.BaseName + '.png')
    if ((Test-Path -LiteralPath $target) -and -not $Force) { throw "Output exists: $target. Use -Force to replace it." }
    & $drawio --export --format png --width $Width --border $Border --output $target $file.FullName | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $target -PathType Leaf)) {
        throw "draw.io failed to export $($file.Name) (exit code $LASTEXITCODE)."
    }
    Get-Item -LiteralPath $target
}
