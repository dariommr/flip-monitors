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

## 3. Configure the script

Open [flip-monitors.ps1](./flip-monitors.ps1) in a text editor and update:

```powershell
$cmm = "C:\path\to\ControlMyMonitor.exe"
$monitorName = "DP1"
```

Set `$cmm` to the executable's actual path and `$monitorName` to the unique
identifier you found in the previous step.

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
2. Create a shortcut to `flip-monitors.ahk` in that folder. You can do this by
   right-clicking the `.ahk` file, choosing **Create shortcut**, then moving
   the shortcut into the Startup folder.
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
