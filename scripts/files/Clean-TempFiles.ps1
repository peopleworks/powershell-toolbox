<#
.SYNOPSIS
Deletes temporary files older than a given age under a directory.
.DESCRIPTION
Recursively deletes files under -Path whose LastWriteTime is older than -MaxAgeDays.
It never deletes folders and never touches the system root; use -ExcludePattern to keep
specific names (for example 'WindowsUpdate' or '*.cab'). Supports -WhatIf to preview
deletions without removing anything. By default files are really deleted; document the
effect before scheduling. Requires write permission on -Path.
.EXAMPLE
./scripts/files/Clean-TempFiles.ps1 -Path $env:TEMP -MaxAgeDays 7 -WhatIf
.EXAMPLE
./scripts/files/Clean-TempFiles.ps1 -Path ./local/temp -MaxAgeDays 1 -ExcludePattern @('keep.me','*.lock')
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]$Path,

    [int]$MaxAgeDays = 7,

    [string[]]$ExcludePattern = @('WindowsUpdate', '*.cab'),

    [switch]$Force
)

$resolved = (Resolve-Path -LiteralPath $Path).ProviderPath
$root = [System.IO.Path]::GetPathRoot($resolved)
if ([string]::IsNullOrEmpty($root) -or $resolved -eq $root) {
    throw "Refusing to clean the system root '$root'."
}

$cutoff = (Get-Date).AddDays(-$MaxAgeDays)

Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $cutoff } |
    Where-Object {
        $exclude = $false
        foreach ($pattern in $ExcludePattern) {
            if ($_.Name -like $pattern) {
                $exclude = $true
                break
            }
        }
        -not $exclude
    } |
    ForEach-Object {
        $deleted = $false
        $reason  = ''

        if ($PSCmdlet.ShouldProcess($_.FullName, "Delete temporary file older than $MaxAgeDays days")) {
            try {
                $attributes = [System.IO.File]::GetAttributes($_.FullName)
                if (($attributes -band [System.IO.FileAttributes]::ReadOnly) -and -not $Force) {
                    $reason = 'Read-only; use -Force to delete.'
                } else {
                    Remove-Item -LiteralPath $_.FullName -Force:$Force -ErrorAction Stop
                    $deleted = $true
                }
            }
            catch {
                $reason = $_.Exception.Message
            }
        }

        [pscustomobject]@{
            Path       = $_.FullName
            Length     = $_.Length
            LastWriteTime = $_.LastWriteTime
            AgeDays    = [math]::Round(((Get-Date) - $_.LastWriteTime).TotalDays, 2)
            Deleted    = $deleted
            Reason     = $reason
            WhatIf     = $PSCmdlet.ShouldProcess($_.FullName)
        }
    }
