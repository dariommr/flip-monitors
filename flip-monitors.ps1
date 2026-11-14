$cmm = "C:\Users\dario.menten\Documents\controlmymonitor\ControlMyMonitor.exe"
$monitorName = "DP1"

# SwitchValue reads VCP 60 and sets the other input in a single invocation.
& $cmm /SwitchValue $monitorName 60 15 18
if ($LASTEXITCODE -ne 0) {
    throw "ControlMyMonitor failed to switch input for '$monitorName' (exit code $LASTEXITCODE)."
}
