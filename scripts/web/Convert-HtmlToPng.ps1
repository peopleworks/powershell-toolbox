<#
.SYNOPSIS
Captures a local HTML file as a PNG using headless Edge or Chrome.
.EXAMPLE
./scripts/web/Convert-HtmlToPng.ps1 -Html ./page.html -Width 1200 -Height 800
.EXAMPLE
./scripts/web/Convert-HtmlToPng.ps1 -Html ./page.html -Output ./page.png -Scale 2 -Force
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$Html,
    [string]$Output,
    [ValidateRange(1, 10000)][int]$Width = 1280,
    [ValidateRange(1, 10000)][int]$Height = 720,
    [ValidateRange(0.1, 4)][double]$Scale = 1,
    [string]$BrowserPath,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$htmlPath = (Resolve-Path -LiteralPath $Html).ProviderPath
if (-not $Output) { $Output = [System.IO.Path]::ChangeExtension($htmlPath, '.png') }
$outputPath = [System.IO.Path]::GetFullPath($Output)
if ((Test-Path -LiteralPath $outputPath) -and -not $Force) {
    throw "Output already exists: $outputPath. Use -Force to replace it."
}
$outputDirectory = Split-Path -Parent $outputPath
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    throw "Output directory does not exist: $outputDirectory"
}

if ($BrowserPath) {
    $browser = (Resolve-Path -LiteralPath $BrowserPath -ErrorAction Stop).ProviderPath
} else {
    $candidates = @(
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
    )
    $browser = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1
    if (-not $browser) {
        foreach ($commandName in @('msedge', 'chrome', 'chromium')) {
            $command = Get-Command $commandName -ErrorAction SilentlyContinue
            if ($command) { $browser = $command.Source; break }
        }
    }
}
if (-not $browser) { throw 'Edge or Chrome was not found. Pass -BrowserPath.' }

$profile = Join-Path ([System.IO.Path]::GetTempPath()) ('powershell-toolbox-' + [guid]::NewGuid().ToString('N'))
$arguments = @(
    '--headless=new', '--disable-gpu', '--hide-scrollbars', '--no-first-run',
    "--user-data-dir=$profile", "--force-device-scale-factor=$Scale",
    "--window-size=$Width,$Height", "--screenshot=$outputPath",
    ([System.Uri]$htmlPath).AbsoluteUri
)
try {
    & $browser @arguments | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
        throw "Browser did not create the PNG (exit code $LASTEXITCODE)."
    }
    Get-Item -LiteralPath $outputPath
} finally {
    if (Test-Path -LiteralPath $profile) {
        Remove-Item -LiteralPath $profile -Recurse -Force -ErrorAction SilentlyContinue
    }
}
