#Requires AutoHotkey v2.0

^!1::
{
    Run('powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Users\dario.menten\Documents\controlmymonitor\script\flip-monitors.ps1"', , "Hide")
}