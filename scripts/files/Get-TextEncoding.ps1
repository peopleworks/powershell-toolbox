<#
.SYNOPSIS
Identifies Unicode byte order marks and validates UTF-8 text files.
.DESCRIPTION
Reports an encoding only when it can be identified from a BOM or valid UTF-8 bytes.
An unmarked legacy file is reported as Unknown rather than guessed.
.EXAMPLE
./scripts/files/Get-TextEncoding.ps1 -Path ./notes.txt
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$Path
)

$resolved = (Resolve-Path -LiteralPath $Path).ProviderPath
$bytes = [System.IO.File]::ReadAllBytes($resolved)
$encoding = 'Unknown'
$hasBom = $false
$note = ''

if ($bytes.Length -ge 4 -and $bytes[0] -eq 0x00 -and $bytes[1] -eq 0x00 -and $bytes[2] -eq 0xFE -and $bytes[3] -eq 0xFF) {
    $encoding = 'UTF-32 BE'; $hasBom = $true
} elseif ($bytes.Length -ge 4 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE -and $bytes[2] -eq 0x00 -and $bytes[3] -eq 0x00) {
    $encoding = 'UTF-32 LE'; $hasBom = $true
} elseif ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $encoding = 'UTF-8'; $hasBom = $true
} elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
    $encoding = 'UTF-16 BE'; $hasBom = $true
} elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
    $encoding = 'UTF-16 LE'; $hasBom = $true
} else {
    try {
        $strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
        [void]$strictUtf8.GetString($bytes)
        if ($bytes -contains 0) {
            $note = 'Contains NUL bytes; binary data or unmarked UTF-16 is possible.'
        } else {
            $encoding = 'UTF-8 (no BOM)'
        }
        if ($bytes.Length -eq 0) {
            $encoding = 'Unknown'
            $note = 'Empty file; encoding cannot be determined.'
        } elseif ($encoding -ne 'Unknown' -and -not ($bytes | Where-Object { $_ -gt 0x7F } | Select-Object -First 1)) {
            $note = 'ASCII-only bytes are also valid in many legacy encodings.'
        }
    } catch [System.Text.DecoderFallbackException] {
        $note = 'Invalid UTF-8; a legacy encoding or binary data is possible.'
    }
}

[pscustomobject]@{
    Path = $resolved
    Encoding = $encoding
    HasBom = $hasBom
    Bytes = $bytes.Length
    Note = $note
}
