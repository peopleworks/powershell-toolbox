<#
.SYNOPSIS
Copies files from a source directory to a destination with a run log.
.DESCRIPTION
Recursively copies files from -Source to -Destination, optionally filtered by -Filter
and limited by file age (-MaxAgeDays). Creates a timestamped log under -LogPath with
each copied file, errors and a summary. Read-only on the source; writes only under
-Destination and -LogPath. Supports -WhatIf to preview without copying. Requires read
permission on -Source and write permission on -Destination and -LogPath.
.EXAMPLE
./scripts/backup/Copy-BackupFiles.ps1 -Source ./documentos -Destination ./backup/documentos -Filter '*.pdf' -WhatIf
.EXAMPLE
./scripts/backup/Copy-BackupFiles.ps1 -Source C:\datos\proyecto -Destination D:\respaldo\proyecto -MaxAgeDays 30 -LogPath ./backup/logs
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$Source,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Destination,

    [string]$Filter = '*.*',

    [int]$MaxAgeDays,

    [string]$LogPath = './backup/logs',

    [switch]$Force
)

$resolvedSource = (Resolve-Path -LiteralPath $Source).ProviderPath
$root = [System.IO.Path]::GetPathRoot($resolvedSource)
if ([string]::IsNullOrEmpty($root) -or $resolvedSource -eq $root) {
    throw "Refusing to back up the system root '$root'."
}

[void](New-Item -ItemType Directory -Force -Path $Destination)
[void](New-Item -ItemType Directory -Force -Path $LogPath)

$cutoff = if ($PSBoundParameters.ContainsKey('MaxAgeDays')) {
    (Get-Date).AddDays(-$MaxAgeDays)
} else {
    [datetime]::MinValue
}

$logFile = Join-Path $LogPath ("backup_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')
$entries = [System.Collections.Generic.List[string]]::new()
$copied = 0
$skipped = 0
$errors = [System.Collections.Generic.List[string]]::new()

$files = Get-ChildItem -LiteralPath $Source -File -Recurse -Filter $Filter -ErrorAction SilentlyContinue |
    Where-Object {
        if ($cutoff -ne [datetime]::MinValue -and $_.LastWriteTime -lt $cutoff) {
            $false
        } else {
            $true
        }
    }

foreach ($file in $files) {
    $relative = $file.FullName.Substring($resolvedSource.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar)
    $destFile = Join-Path $Destination $relative
    $destDir  = [System.IO.Path]::GetDirectoryName($destFile)

    $message = "Copy '$relative' -> '$destFile'"

    if (-not $PSCmdlet.ShouldProcess($destFile, "Copy file")) {
        $skipped++
        $entries.Add("SKIP $message")
        continue
    }

    try {
        [void](New-Item -ItemType Directory -Force -Path $destDir)
        Copy-Item -LiteralPath $file.FullName -Destination $destFile -Force:$Force -ErrorAction Stop
        $copied++
        $entries.Add("OK   $message")
    }
    catch {
        $errors.Add($_.Exception.Message)
        $entries.Add("ERR  $message : $($_.Exception.Message)")
    }
}

$summary = @"
Backup run: $(Get-Date)
Source: $resolvedSource
Destination: $Destination
Files copied: $copied
Files skipped: $skipped
Errors: $($errors.Count)
"@

$entries.Add("")
$entries.Add($summary)
$entries | Out-File -FilePath $logFile -Encoding utf8

[pscustomobject]@{
    Source       = $resolvedSource
    Destination  = $Destination
    LogFile      = $logFile
    Copied       = $copied
    Skipped      = $skipped
    Errors       = $errors.Count
    Summary      = $summary
}
