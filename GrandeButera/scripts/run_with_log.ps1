param(
    [Parameter(Mandatory = $true)]
    [string]$BatPath,

    [Parameter(Mandatory = $true)]
    [string]$LogPath
)

$ErrorActionPreference = "Continue"
$logDir = Split-Path -Parent $LogPath
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
}

Write-Host "Menjalankan script:" $BatPath
Write-Host "Log disimpan di:" $LogPath
Write-Host ""

# Use cmd.exe and merge stderr inside cmd so Windows PowerShell does not wrap Flutter warnings as NativeCommandError.
$cmd = '"' + $BatPath + '" --inner 2>&1'
cmd.exe /d /s /c $cmd | Tee-Object -FilePath $LogPath
$exitCode = $LASTEXITCODE
if ($null -eq $exitCode) { $exitCode = 0 }
exit $exitCode
