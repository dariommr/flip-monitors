$cmm = "C:\Users\Dario\Tools\ControlMyMonitor\ControlMyMonitor.exe"
$monitorName = "HDMI2"

# SwitchValue reads VCP 60 and sets the other input in a single invocation.
& $cmm /SwitchValue $monitorName 60 15 18
if ($LASTEXITCODE -ne 0) {
    throw "ControlMyMonitor failed to switch input for '$monitorName' (exit code $LASTEXITCODE)."
}
