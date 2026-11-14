# Flip monitor input source

`flip-monitors.ps1` switches the configured monitor between two input sources
using ControlMyMonitor's VCP feature 60 (Input Select).

> **Important:** Complete the setup on both computers connected to the monitor.
> Each computer needs its own copy of the utility and configured script/hotkey.
> This lets you switch the monitor input from either computer and switch back.

## 1. Download and extract ControlMyMonitor

Run these commands in PowerShell to download the ZIP and extract it under your
user profile:

```powershell
$installDir = Join-Path $env:USERPROFILE "Tools\ControlMyMonitor"
$zipPath = Join-Path $env:TEMP "controlmymonitor.zip"
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Invoke-WebRequest `
  -Uri "https://www.nirsoft.net/utils/controlmymonitor.zip" `
  -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
(Resolve-Path (Join-Path $installDir "ControlMyMonitor.exe")).Path
```

This downloads the [ControlMyMonitor ZIP archive](https://www.nirsoft.net/utils/controlmymonitor.zip)
from NirSoft and extracts it to `Tools\ControlMyMonitor` in your user profile.
The script's `$cmm` variable must point to the extracted `ControlMyMonitor.exe`.

## 2. Identify the monitor

1. Run `ControlMyMonitor.exe`.
2. Find the monitor whose input you want to switch.
3. Select it and press **Ctrl+M** to copy its monitor details. Use its **Monitor
   Name** if that name is unique. If it is not unique, use a unique **Monitor
   Device Name** or **Short Monitor ID** instead.

## Identify the input values

The values for VCP feature `60` vary by monitor. Find the value for each input
you want to switch between:

1. In ControlMyMonitor, select the monitor and locate the row with VCP code
   `60` (**Input Select**). Note its current **Value**.
2. Use the monitor's physical buttons or on-screen menu (OSD) to switch to the
   first input. Refresh ControlMyMonitor with **F5** and record the **Value**
   shown for VCP `60`.
3. Switch the monitor to the second input using its OSD, refresh again, and
   record the new VCP `60` value.
4. Use those two values as `InputA` and `InputB` when running the setup script,
   or in the `/SwitchValue` command. For example, if the displayed values are
   `15` and `18`, use `15` and `18`.

Keep the monitor identifier the same while checking both inputs. If the VCP
`60` row is unavailable or its value does not change, the monitor may not expose
input selection through DDC/CI; check the monitor settings and documentation.

## 3. Configure the script

Open [flip-monitors.ps1](./flip-monitors.ps1) in a text editor and update:

```powershell
$cmm = (Resolve-Path (Join-Path $installDir "ControlMyMonitor.exe")).Path
$monitorName = "DP1"
```

Set `$cmm` to the executable's resolved path from the install step and
`$monitorName` to the unique identifier you found in the previous step.

If you want to update the script automatically from PowerShell instead of
editing the file in a text editor, run:

```powershell
$ps1Path = Join-Path $PSScriptRoot "flip-monitors.ps1"
$cmm = (Resolve-Path (Join-Path $installDir "ControlMyMonitor.exe")).Path
$monitorName = "DP1"

$content = Get-Content $ps1Path -Raw
$content = $content -replace '\$cmm = ".*?"', "`$cmm = `"$cmm`""
$content = $content -replace '\$monitorName = ".*?"', "`$monitorName = `"$monitorName`""
Set-Content -Path $ps1Path -Value $content
```

This updates the actual `$cmm` line in [flip-monitors.ps1](./flip-monitors.ps1)
to the resolved executable path from the install step.

The same idea applies to the AutoHotkey file. Update the PowerShell path inside
`flip-monitor.ahk` to match your script location:

```powershell
$ahkPath = Join-Path $PSScriptRoot "flip-monitor.ahk"
$scriptPath = Join-Path $PSScriptRoot "flip-monitors.ps1"

(Get-Content $ahkPath) `
  -replace 'C:\\Users\\dario\\.menten\\Documents\\controlmymonitor\\script\\flip-monitors.ps1', $scriptPath |
  Set-Content $ahkPath
```

The final command switches VCP 60 between values `15` and `18`:

```powershell
& $cmm /SwitchValue $monitorName 60 15 18
```

These input values are monitor-specific. Check the monitor's **Input Select**
(VCP code `60`) in ControlMyMonitor and replace `15` and `18` with the two
values supported by your monitor. The first run switches to the other listed
value; subsequent runs toggle between them.

## 4. Set up the Ctrl+Alt+1 hotkey

1. Download and install **AutoHotkey v2** from the [official AutoHotkey
   website](https://www.autohotkey.com/).
2. In the same folder as `flip-monitors.ps1`, place the file named 
   `flip-monitor.ahk`.

The `^!1` hotkey means **Ctrl+Alt+1**. The script runs the PowerShell file from
the same folder as the `.ahk` file, so keep both files together.
You can use the AutoHotKey Dialog to create your own AHK file and assign the
hotkey you want.

4. Double-click `flip-monitor.ahk` to start the hotkey. AutoHotkey's tray icon
   indicates that it is running. Press **Ctrl+Alt+1** to switch the monitor
   input; exit the hotkey script from its tray icon when you no longer need it.

### Start the hotkey automatically with Windows

To run the hotkey script each time you sign in to Windows:

1. Press **Win+R**, enter `shell:startup`, and press **Enter** to open your
   personal Startup folder.
2. Copy the `.ahk` file into that folder:

```powershell
$startupFolder = [Environment]::GetFolderPath('Startup')
$ahkFile = Join-Path $PSScriptRoot "flip-monitor.ahk"
Copy-Item $ahkFile (Join-Path $startupFolder "flip-monitor.ahk")
```

   You can also open the Startup folder directly with:

```powershell
explorer "shell:startup"
```

3. Sign out and back in, or restart Windows. The AutoHotkey tray icon should
   appear, and **Ctrl+Alt+1** will be available.

To stop it starting automatically, remove the shortcut from the Startup folder.

## 5. Run the PowerShell script manually

Open PowerShell in the script's folder and run:

```powershell
.\flip-monitors.ps1
```

If PowerShell prevents the script from running, follow your organization's
execution-policy guidance rather than changing the machine-wide policy.

## [Alternative] Run the setup script

From PowerShell in the folder containing the project files, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-flip-monitors.ps1 -MonitorName "DP1" -InputA 15 -InputB 18 -StartHotkey
```

This script will:

- download and extract ControlMyMonitor
- download and install AutoHotkey v2 from the official installer
- update [flip-monitors.ps1](./flip-monitors.ps1) with the resolved executable path and monitor name
- update [flip-monitor.ahk](./flip-monitor.ahk) to point to the script in this folder
- copy the AutoHotkey file into your Startup folder so it runs on sign-in
- optionally start the hotkey immediately

Adjust the values for your monitor and the two supported input codes if needed.

