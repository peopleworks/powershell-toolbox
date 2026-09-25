$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).ProviderPath
$scripts = @(Get-ChildItem -LiteralPath (Join-Path $root 'scripts') -Filter '*.ps1' -Recurse -File)
foreach ($script in $scripts) {
    $tokens = $null; $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) { throw "Parse error in $($script.Name): $($errors[0])" }
}

$testDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('powershell-toolbox-test-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $testDirectory)
$created = @()
try {
    $utf8File = Join-Path $testDirectory 'utf8.txt'; $created += $utf8File
    [System.IO.File]::WriteAllText($utf8File, 'café', [System.Text.UTF8Encoding]::new($false))
    $utf8 = & (Join-Path $root 'scripts/files/Get-TextEncoding.ps1') -Path $utf8File
    if ($utf8.Encoding -ne 'UTF-8 (no BOM)') { throw 'UTF-8 identification failed.' }

    $legacyFile = Join-Path $testDirectory 'legacy.txt'; $created += $legacyFile
    [System.IO.File]::WriteAllBytes($legacyFile, [byte[]]@(0xE9))
    $legacy = & (Join-Path $root 'scripts/files/Get-TextEncoding.ps1') -Path $legacyFile
    if ($legacy.Encoding -ne 'Unknown') { throw 'Invalid UTF-8 was guessed as a known encoding.' }

    if ($IsWindows) {
        Add-Type -AssemblyName System.Drawing
        $beforePath = Join-Path $testDirectory 'before.png'; $created += $beforePath
        $afterPath = Join-Path $testDirectory 'after.png'; $created += $afterPath
        $diffPath = Join-Path $testDirectory 'diff.png'; $created += $diffPath
        $before = [System.Drawing.Bitmap]::new(2, 2)
        $after = [System.Drawing.Bitmap]::new(2, 2)
        try {
            $before.SetPixel(1, 1, [System.Drawing.Color]::Blue)
            $after.SetPixel(1, 1, [System.Drawing.Color]::Red)
            $before.Save($beforePath, [System.Drawing.Imaging.ImageFormat]::Png)
            $after.Save($afterPath, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally { $before.Dispose(); $after.Dispose() }
        $comparison = & (Join-Path $root 'scripts/images/Compare-Png.ps1') -Reference $beforePath -Current $afterPath -Diff $diffPath
        if ($comparison.DifferentPixels -ne 1 -or $comparison.Bounds.Left -ne 1 -or $comparison.Bounds.Top -ne 1) {
            throw 'PNG comparison returned incorrect metrics.'
        }
        if (-not (Test-Path -LiteralPath $diffPath -PathType Leaf)) { throw 'Visual diff was not created.' }
    }

    "OK: parsed $($scripts.Count) scripts; encoding and image checks passed."
} finally {
    foreach ($file in $created) {
        if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file -Force }
    }
    Remove-Item -LiteralPath $testDirectory -Force
}
