<#
.SYNOPSIS
Compares two PNG files pixel by pixel and optionally writes a visual diff.
.EXAMPLE
./scripts/images/Compare-Png.ps1 -Reference ./before.png -Current ./after.png -Diff ./diff.png
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })][string]$Reference,
    [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })][string]$Current,
    [string]$Diff,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
if (-not $IsWindows -and $PSVersionTable.PSEdition -eq 'Core') {
    throw 'System.Drawing image comparison requires Windows.'
}
Add-Type -AssemblyName System.Drawing

if (-not ('PowerShellToolboxImageDiff' -as [type])) {
    Add-Type -ReferencedAssemblies @([System.Drawing.Bitmap].Assembly.Location, [System.Drawing.Color].Assembly.Location) -TypeDefinition @'
using System;
using System.Drawing;

public static class PowerShellToolboxImageDiff {
    public static long[] Compare(Bitmap reference, Bitmap current, Bitmap diff) {
        long changed = 0;
        int maxDelta = 0, minX = reference.Width, minY = reference.Height, maxX = -1, maxY = -1;
        for (int y = 0; y < reference.Height; y++) {
            for (int x = 0; x < reference.Width; x++) {
                Color a = reference.GetPixel(x, y), b = current.GetPixel(x, y);
                int delta = Math.Max(Math.Max(Math.Abs(a.R - b.R), Math.Abs(a.G - b.G)),
                    Math.Max(Math.Abs(a.B - b.B), Math.Abs(a.A - b.A)));
                if (delta > 0) {
                    changed++;
                    maxDelta = Math.Max(maxDelta, delta);
                    minX = Math.Min(minX, x); maxX = Math.Max(maxX, x);
                    minY = Math.Min(minY, y); maxY = Math.Max(maxY, y);
                    if (diff != null) diff.SetPixel(x, y, Color.Red);
                } else if (diff != null) {
                    int gray = (a.R + a.G + a.B) / 6 + 128;
                    diff.SetPixel(x, y, Color.FromArgb(gray, gray, gray));
                }
            }
        }
        return new long[] { changed, maxDelta, minX, minY, maxX, maxY };
    }
}
'@
}

$referencePath = (Resolve-Path -LiteralPath $Reference).ProviderPath
$currentPath = (Resolve-Path -LiteralPath $Current).ProviderPath
$diffPath = $null
if ($Diff) {
    $diffPath = [System.IO.Path]::GetFullPath($Diff)
    if ($diffPath -eq $referencePath -or $diffPath -eq $currentPath) {
        throw 'Diff output must differ from both input files.'
    }
    if ((Test-Path -LiteralPath $diffPath) -and -not $Force) {
        throw "Diff already exists: $diffPath. Use -Force to replace it."
    }
    if (-not (Test-Path -LiteralPath (Split-Path -Parent $diffPath) -PathType Container)) {
        throw 'Diff output directory does not exist.'
    }
}

$a = $null; $b = $null; $mask = $null
try {
    $a = [System.Drawing.Bitmap]::new($referencePath)
    $b = [System.Drawing.Bitmap]::new($currentPath)
    if ($a.Width -ne $b.Width -or $a.Height -ne $b.Height) {
        throw "Image dimensions differ: $($a.Width)x$($a.Height) versus $($b.Width)x$($b.Height)."
    }
    if ($diffPath) { $mask = [System.Drawing.Bitmap]::new($a.Width, $a.Height) }
    $result = [PowerShellToolboxImageDiff]::Compare($a, $b, $mask)
    if ($mask) { $mask.Save($diffPath, [System.Drawing.Imaging.ImageFormat]::Png) }
    $bounds = if ($result[0] -gt 0) {
        [pscustomobject]@{ Left = $result[2]; Top = $result[3]; Right = $result[4]; Bottom = $result[5] }
    } else { $null }
    [pscustomobject]@{
        Reference = $referencePath
        Current = $currentPath
        Width = $a.Width
        Height = $a.Height
        DifferentPixels = $result[0]
        PercentDifferent = [math]::Round(100.0 * $result[0] / ($a.Width * $a.Height), 3)
        MaxChannelDelta = $result[1]
        Bounds = $bounds
        Diff = $diffPath
    }
} finally {
    if ($mask) { $mask.Dispose() }
    if ($b) { $b.Dispose() }
    if ($a) { $a.Dispose() }
}
