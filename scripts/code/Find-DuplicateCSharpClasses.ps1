<#
.SYNOPSIS
Finds repeated C# class names as review candidates.
.DESCRIPTION
This text scan does not parse namespaces, comments or conditional compilation. Repeated names can be valid (for example, partial classes in different namespaces).
.EXAMPLE
./scripts/code/Find-DuplicateCSharpClasses.ps1 -Path ./src
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })][string]$Path
)

$root = (Resolve-Path -LiteralPath $Path).ProviderPath
$pattern = '(?m)^\s*(?:(?:public|internal|protected|private|sealed|abstract|partial|static)\s+)*class\s+([A-Za-z_]\w*)\b'
$definitions = foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.cs') {
    if ($file.FullName -match '[\\/](?:bin|obj)[\\/]') { continue }
    $text = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($match in [regex]::Matches($text, $pattern)) {
        [pscustomobject]@{ Name = $match.Groups[1].Value; File = $file.FullName }
    }
}
foreach ($group in $definitions | Group-Object Name | Where-Object Count -gt 1 | Sort-Object Name) {
    [pscustomobject]@{
        Class = $group.Name
        Occurrences = $group.Count
        Files = @($group.Group.File | Sort-Object -Unique)
    }
}
