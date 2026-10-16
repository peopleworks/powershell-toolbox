<#
.SYNOPSIS
Looks for likely secrets and local paths in the Git index before a commit.
.DESCRIPTION
Reads staged bytes, not working-tree files. Reports file, line and rule only; it never prints a matched value. This is a heuristic review aid, not a guarantee of privacy.
.EXAMPLE
./scripts/security/Test-GitStagedContent.ps1 -Repository . -FailOnFindings
#>
[CmdletBinding()]
param(
    [string]$Repository = '.',
    [switch]$FailOnFindings
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $Repository).ProviderPath
$inside = & git -C $root rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0 -or $inside -ne 'true') { throw "Not a Git repository: $root" }
$paths = @(& git -C $root -c core.quotepath=false ls-files --cached)
if ($LASTEXITCODE -ne 0) { throw 'Could not list staged files.' }
$rules = [ordered]@{
    PrivateKey = '-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'
    CredentialLiteral = '(?i)\b(?:api[_-]?key|client[_-]?secret|password|passwd|pwd|token)\b\s*[=:]\s*["''][^"'']{8,}["'']'
    UrlCredential = '(?i)https?://[^\s/@:]+:[^\s/@]+@'
    LocalProjectPath = '(?i)[A-Z]:\\Proyecto\\'
}
$findings = [Collections.Generic.List[object]]::new()
$scanned = 0
foreach ($path in $paths) {
    if ($path -match '(?i)\.(png|jpe?g|gif|ico|pdf|zip|exe|dll|rpt|dbf|woff2?)$') { continue }
    $size = & git -C $root cat-file -s ":$path" 2>$null
    if ($LASTEXITCODE -ne 0 -or [long]$size -gt 2MB) { continue }
    $content = (& git -C $root show ":$path") -join "`n"
    if ($LASTEXITCODE -ne 0) { throw "Could not read staged file: $path" }
    $scanned++
    $lines = $content -split "`n"
    for ($line = 0; $line -lt $lines.Length; $line++) {
        foreach ($rule in $rules.GetEnumerator()) {
            if ([regex]::IsMatch($lines[$line], $rule.Value)) {
                $findings.Add([pscustomobject]@{ File = $path; Line = $line + 1; Rule = $rule.Key })
            }
        }
    }
}
$result = [pscustomobject]@{
    Repository = $root
    FilesScanned = $scanned
    Findings = $findings.ToArray()
    Passed = $findings.Count -eq 0
}
$result
if ($FailOnFindings -and -not $result.Passed) { throw "$($findings.Count) finding(s) require review." }
