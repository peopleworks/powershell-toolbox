<#
.SYNOPSIS
Creates a WAV file with an installed Windows SAPI voice.
.DESCRIPTION
Run with Windows PowerShell 5.1, which includes System.Speech. Text is passed as a parameter and is not stored in this repository.
.EXAMPLE
powershell.exe -NoProfile -File ./scripts/media/Convert-TextToSpeech.ps1 -Text 'Hello there' -Output ./hello.wav
#>
#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Text,
    [Parameter(Mandatory)][string]$Output,
    [string]$Voice,
    [ValidateRange(-10, 10)][int]$Rate = 0,
    [switch]$Force
)

if ($PSVersionTable.PSEdition -ne 'Desktop') { throw 'Run this script with Windows PowerShell 5.1 (powershell.exe).' }
$target = [IO.Path]::GetFullPath($Output)
if (-not $target.EndsWith('.wav', [StringComparison]::OrdinalIgnoreCase)) { throw 'Output must end in .wav.' }
if (-not (Test-Path -LiteralPath (Split-Path -Parent $target) -PathType Container)) { throw 'Output directory does not exist.' }
if ((Test-Path -LiteralPath $target) -and -not $Force) { throw "Output exists: $target. Use -Force to replace it." }
Add-Type -AssemblyName System.Speech
$speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer
try {
    if ($Voice) { $speaker.SelectVoice($Voice) }
    $speaker.Rate = $Rate
    $speaker.SetOutputToWaveFile($target)
    $speaker.Speak($Text)
    $speaker.SetOutputToNull()
} finally { $speaker.Dispose() }
Get-Item -LiteralPath $target
