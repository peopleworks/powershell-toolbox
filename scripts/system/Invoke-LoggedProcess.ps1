<#
.SYNOPSIS
Runs a process with separate stdout and stderr logs and a timeout.
.DESCRIPTION
The command line is never written to logs. A process still running at the timeout is terminated.
.EXAMPLE
./scripts/system/Invoke-LoggedProcess.ps1 -FilePath dotnet -ArgumentList @('--info') -OutputDirectory ./.local/logs
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$FilePath,
    [string[]]$ArgumentList = @(),
    [Parameter(Mandatory)][string]$OutputDirectory,
    [string]$WorkingDirectory = (Get-Location).Path,
    [ValidateRange(1, 86400)][int]$TimeoutSeconds = 300
)

$ErrorActionPreference = 'Stop'
$outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
[void][IO.Directory]::CreateDirectory($outputRoot)
$stamp = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8)
$stdoutPath = Join-Path $outputRoot "$stamp.stdout.log"
$stderrPath = Join-Path $outputRoot "$stamp.stderr.log"
$startInfo = [Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = $FilePath
$startInfo.WorkingDirectory = (Resolve-Path -LiteralPath $WorkingDirectory).ProviderPath
$startInfo.UseShellExecute = $false
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true
foreach ($argument in $ArgumentList) { [void]$startInfo.ArgumentList.Add($argument) }
$process = [Diagnostics.Process]::new()
$process.StartInfo = $startInfo
$watch = [Diagnostics.Stopwatch]::StartNew()
try {
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    $finished = $process.WaitForExit($TimeoutSeconds * 1000)
    if (-not $finished) {
        $process.Kill($true)
        $process.WaitForExit()
    }
    [IO.File]::WriteAllText($stdoutPath, $stdout.GetAwaiter().GetResult())
    [IO.File]::WriteAllText($stderrPath, $stderr.GetAwaiter().GetResult())
    [pscustomobject]@{
        ExitCode = if ($finished) { $process.ExitCode } else { $null }
        TimedOut = -not $finished
        ElapsedSeconds = [math]::Round($watch.Elapsed.TotalSeconds, 2)
        StandardOutput = $stdoutPath
        StandardError = $stderrPath
    }
} finally {
    $process.Dispose()
}
