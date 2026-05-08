; AeroZoom by wandersick | https://tech.wandersick.com
;
; This is the redirector. See main script for more.

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; The following is only set in this script but not the scripts inside \Data in order to fix the Working Directory for them.
; Setup.ahk is not set too because the msi installer is one-file and would not see \Data
SetWorkingDir(A_ScriptDir) ; Ensures a consistent starting directory.

RegRoot := "HKCU\Software\WanderSick\AeroZoom"

; Missing component check
if !DirExist(A_WorkingDir "\Data") {
    MsgBox("Missing essential program files. Please reinstall.", "AeroZoom", "Iconx")
    ExitApp()
}

; Check if WizMouse is running
WizMouseChk := RegRead(RegRoot, "WizMouseChk", "")
if !WizMouseChk {
    if ProcessExist("WizMouse.exe") {
        MsgBox("WizMouse is found running on this system.`n`nWizMouse is only semi-compatible with AutoHotkey--the language AeroZoom is based on.`n`nFrom the WizMouse doc: ""Some users reported that rehooking may cause issues with AutoHotkey so now it can be disabled. Note that AutoHotkey (Add: AeroZoom) must be started AFTER WizMouse for them to work together correctly.""`n`nTo work around it, please use one of the following tip.`n`nTip 1: Clicking on any Ctrl/Shift/Alt/Left/Right/Middle/F/B button on the AeroZoom Panel restarts (brings back) AeroZoom.`n`nTip 2: (Since v3.2) Clicking the tray icon 3 times does it too.`n`nTip 3: Go to WizMouse's Settings and check 'Left click tray icon to enable/disable', so that left-clicking WizMouse's tray icon quickly disables WizMouse and enables AeroZoom, or vice versa.", "Notice (This message will be shown once only)", "Icon!")
    }
    RegWrite("1", "REG_SZ", RegRoot, "WizMouseChk")
}

OSver := RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "CurrentVersion", "")
if (OSver > 6) { ; if newer than vista
    ; Check if WMC is running
    WmcChk := RegRead(RegRoot, "WmcChk", "")
    if !WmcChk {
        if ProcessExist("ehshell.exe") {
            MsgBox("Windows Media Center is found running on this system.`n`nThere's a Windows bug that hides the cursor when both Windows Magnifier and Windows Media Center are running and in full screen. This version of AeroZoom provides a workaround--the 'Kill magnifier' hotkey Win+Shift+K to end the Magnifier process so that the cursor shows in such case.`n`nIf mouse is preferred over keyboard, we may also call the AeroZoom panel then press 'Kill'. An easier way of doing it is customize a hotkey action, e.g. the middle mouse button, so that we can just hold it to kill magnifier. To do that, go to 'Tool > Custom Hotkeys > Holding Middle' and set its action to 'Kill magnifier'.", "Notice (This message will be shown once only)", "Icon!")
        }
        RegWrite("1", "REG_SZ", RegRoot, "WmcChk")
    }
}

chkModRaw := RegRead(RegRoot, "Modifier", "")
isX64 := EnvGet("ProgramW6432") != ""

exeMap32 := Map(
    "0x1", "AeroZoom_Ctrl.exe",
    "0x2", "AeroZoom_Alt.exe",
    "0x3", "AeroZoom_Shift.exe",
    "0x4", "AeroZoom_Win.exe",
    "0x5", "AeroZoom_MouseL.exe",
    "0x6", "AeroZoom_MouseR.exe",
    "0x7", "AeroZoom_MouseM.exe",
    "0x8", "AeroZoom_MouseX1.exe",
    "0x9", "AeroZoom_MouseX2.exe"
)

exeMap64 := Map(
    "0x1", "AeroZoom_Ctrl_x64.exe",
    "0x2", "AeroZoom_Alt_x64.exe",
    "0x3", "AeroZoom_Shift_x64.exe",
    "0x4", "AeroZoom_Win_x64.exe",
    "0x5", "AeroZoom_MouseL_x64.exe",
    "0x6", "AeroZoom_MouseR_x64.exe",
    "0x7", "AeroZoom_MouseM_x64.exe",
    "0x8", "AeroZoom_MouseX1_x64.exe",
    "0x9", "AeroZoom_MouseX2_x64.exe"
)

selectedExe := isX64
    ? exeMap64.Get(chkModRaw, "AeroZoom_MouseL_x64.exe")
    : exeMap32.Get(chkModRaw, "AeroZoom_MouseL.exe")

Run('"' A_WorkingDir '\Data\' selectedExe '"')
ExitApp()
