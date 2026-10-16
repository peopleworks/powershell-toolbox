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

    $emptyFile = Join-Path $testDirectory 'empty.txt'; $created += $emptyFile
    [System.IO.File]::WriteAllBytes($emptyFile, [byte[]]@())
    $empty = & (Join-Path $root 'scripts/files/Get-TextEncoding.ps1') -Path $emptyFile
    if ($empty.Encoding -ne 'Unknown') { throw 'Empty file was assigned an encoding.' }

    $first = Join-Path $testDirectory 'first.txt'; $created += $first
    $second = Join-Path $testDirectory 'second.txt'; $created += $second
    [IO.File]::WriteAllText($first, 'same content')
    [IO.File]::WriteAllText($second, 'same content')
    $duplicates = @(& (Join-Path $root 'scripts/files/Find-DuplicateFiles.ps1') -Path $testDirectory)
    if (-not ($duplicates | Where-Object { $_.Copies -eq 2 -and $first -in $_.Files -and $second -in $_.Files })) {
        throw 'Duplicate-file scan missed identical files.'
    }
    $inventory = @(& (Join-Path $root 'scripts/files/Get-DirectoryInventory.ps1') -Path $testDirectory -IncludeHash)
    if (-not ($inventory | Where-Object { $_.RelativePath -eq 'first.txt' -and $_.Sha256.Length -eq 64 })) {
        throw 'Directory inventory did not produce a hash.'
    }
    $archive = "$testDirectory.zip"; $created += $archive
    & (Join-Path $root 'scripts/files/New-ArchiveFromDirectory.ps1') -Path $testDirectory -Output $archive | Out-Null
    if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) { throw 'ZIP archive was not created.' }

    $classOne = Join-Path $testDirectory 'One.cs'; $created += $classOne
    $classTwo = Join-Path $testDirectory 'Two.cs'; $created += $classTwo
    [IO.File]::WriteAllText($classOne, 'public class Shared { }')
    [IO.File]::WriteAllText($classTwo, 'internal class Shared { }')
    $classes = @(& (Join-Path $root 'scripts/code/Find-DuplicateCSharpClasses.ps1') -Path $testDirectory)
    if (-not ($classes | Where-Object { $_.Class -eq 'Shared' -and $_.Occurrences -eq 2 })) {
        throw 'Duplicate-class scan missed the synthetic class.'
    }

    $wait = & (Join-Path $root 'scripts/system/Wait-CommandSuccess.ps1') -Check { $true } -TimeoutSeconds 0
    if (-not $wait.Succeeded -or $wait.Attempts -ne 1) { throw 'Command retry failed its immediate-success case.' }
    $mutexValue = & (Join-Path $root 'scripts/system/Invoke-WithMutex.ps1') -Name toolbox-smoke -Action { 'mutex-ok' }
    if ($mutexValue -ne 'mutex-ok') { throw 'Mutex did not run the action.' }
    $processResult = & (Join-Path $root 'scripts/system/Invoke-LoggedProcess.ps1') -FilePath (Get-Command pwsh).Source -ArgumentList @('-NoProfile', '-Command', 'Write-Output process-ok') -OutputDirectory $testDirectory
    $created += $processResult.StandardOutput, $processResult.StandardError
    if ($processResult.ExitCode -ne 0 -or (Get-Content -LiteralPath $processResult.StandardOutput -Raw) -notmatch 'process-ok') {
        throw 'Process logging did not capture stdout.'
    }

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

    "OK: parsed $($scripts.Count) scripts; synthetic file, process and image checks passed."
} finally {
    foreach ($file in $created) {
        if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file -Force }
    }
    Remove-Item -LiteralPath $testDirectory -Force
}
