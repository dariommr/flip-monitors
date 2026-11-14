param(
    [string]$MonitorName = "DP1",
    [int]$InputA = 15,
    [int]$InputB = 18,
    [switch]$StartHotkey
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ps1File = Join-Path $scriptDir "flip-monitors.ps1"
$ahkFile = Join-Path $scriptDir "flip-monitor.ahk"
$startupFolder = [Environment]::GetFolderPath("Startup")

Write-Host "Installing ControlMyMonitor..."
$installDir = Join-Path $env:USERPROFILE "Tools\ControlMyMonitor"
$zipPath = Join-Path $env:TEMP "controlmymonitor.zip"
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

try {
    Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/controlmymonitor.zip" -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
}
catch {
    throw "Failed to download or extract ControlMyMonitor. Check internet access and retry."
}

$cmm = (Resolve-Path (Join-Path $installDir "ControlMyMonitor.exe")).Path
Write-Host "ControlMyMonitor found at: $cmm"

Write-Host "Installing AutoHotkey v2..."
$tempDir = Join-Path $env:TEMP "flip-monitors"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$ahkInstaller = Join-Path $tempDir "ahk-v2.exe"
$ahkInstallDir = Join-Path ${env:ProgramFiles} "AutoHotkey"

try {
    Invoke-WebRequest -Uri "https://www.autohotkey.com/download/ahk-v2.exe" -OutFile $ahkInstaller
}
catch {
    throw "Failed to download AutoHotkey v2. Check internet access and retry."
}

$installArgs = @('/S', "/D=$ahkInstallDir")
Start-Process -FilePath $ahkInstaller -ArgumentList $installArgs -Wait -NoNewWindow

$ahkExe = Join-Path $ahkInstallDir "AutoHotkey.exe"
if (-not (Test-Path $ahkExe)) {
    throw "AutoHotkey was not found at: $ahkExe"
}

Write-Host "AutoHotkey installed at: $ahkExe"

$ps1Content = @"
`$cmm = "$cmm"
`$monitorName = "$MonitorName"

# SwitchValue reads VCP 60 and sets the other input in a single invocation.
& `$cmm /SwitchValue `$monitorName 60 $InputA $InputB
if (`$LASTEXITCODE -ne 0) {
    throw "ControlMyMonitor failed to switch input for '`$monitorName' (exit code `$LASTEXITCODE)."
}
"@

Set-Content -Path $ps1File -Value $ps1Content -Encoding UTF8

$ahkContent = @"
#Requires AutoHotkey v2.0

^!1::
{
    Run('powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "$ps1File"', , "Hide")
}
"@

Set-Content -Path $ahkFile -Value $ahkContent -Encoding UTF8

Copy-Item -Path $ahkFile -Destination (Join-Path $startupFolder "flip-monitor.ahk") -Force

Write-Host ""
Write-Host "Setup complete."
Write-Host "PowerShell script: $ps1File"
Write-Host "AutoHotkey script: $ahkFile"
Write-Host "Startup folder: $startupFolder"
Write-Host "Monitor name: $MonitorName"
Write-Host "Input values: $InputA / $InputB"

if ($StartHotkey) {
    Write-Host "Starting AutoHotkey hotkey..."
    Start-Process -FilePath $ahkExe -ArgumentList "`"$ahkFile`"" -NoNewWindow
}
