; Created by https://github.com/PolicyPuma4
; Official repository https://github.com/PolicyPuma4/JetBrains-Fleet-context-menu

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;@Ahk2Exe-Obey U_bits, = %A_PtrSize% * 8
;@Ahk2Exe-Obey U_type, = "%A_IsUnicode%" ? "Unicode" : "ANSI"
;@Ahk2Exe-ExeName %A_ScriptName~\.[^\.]+$%_%U_type%_%U_bits%

;@Ahk2Exe-SetMainIcon Fleet_1.ico

argument := a_args[1]

envget, localappdata, LOCALAPPDATA
app_name := "JetBrains Fleet context menu"
install_path := localappdata "\Programs\" app_name
executable_name := app_name ".exe"
executable_path := install_path "\" executable_name


is_subkey(key_path, key_name)
{
    loop, reg, % key_path, % "k"
    {
        if (a_loopregname = key_name)
            return true
    }
}


is_key_value(key_path, value_name)
{
    loop, reg, % key_path, % "v"
    {
        if (a_loopregname = value_name)
            return true
    }
}


if (argument = "/fleet")
{
    fleet_shortcut := localappdata "\JetBrains\Toolbox\scripts\fleet.cmd"
    if not fileexist(fleet_shortcut)
    {
        msgbox, % "Beep boop, I couldn't find Fleet 😱."
        exitapp
    }

    splitpath, % a_args[2],, working_directory
    if instr(fileexist(a_args[2]), "d")
    {
        working_directory := a_args[2]
    }

    run, % fleet_shortcut a_space """" a_args[2] """", % working_directory, % "hide"

    exitapp
}

if (argument = "/uninstall")
{
    regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce", % app_name, % """C:\Windows\system32\cmd.exe"" /c rmdir /q /s """ install_path """"

    regdelete, % "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" app_name
    regdelete, % "HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\" app_name
    regdelete, % "HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\" app_name
    regdelete, % "HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\" app_name

    msgbox, % "Restart your computer to complete the uninstallation 😭."

    exitapp
}

uninstall_message := "Hey it looks like you already have this awesome app installed! Uninstall your previous version before attempting to install again 🤖."

if fileexist(install_path)
{
    msgbox, % uninstall_message
    exitapp
}

check_subkeys := []
check_subkeys.Push(["HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", app_name])
check_subkeys.Push(["HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell", app_name])
check_subkeys.Push(["HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell", app_name])
check_subkeys.Push(["HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell", app_name])

loop, % check_subkeys.Length()
{
    if is_subkey(check_subkeys[a_index][1], check_subkeys[a_index][2])
    {
        msgbox, % uninstall_message
        exitapp
    }
}

if is_key_value("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce", app_name)
{
    msgbox, % uninstall_message
    exitapp
}

filecreatedir, % install_path
filecopy, % a_scriptfullpath, % executable_path

regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" app_name, % "DisplayIcon", % executable_path
regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" app_name, % "DisplayName", % app_name
regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" app_name, % "InstallLocation", % install_path
regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" app_name, % "UninstallString", % """" executable_path """ /uninstall"
regwrite, % "reg_dword", % "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" app_name, % "NoModify", 0x00000001
regwrite, % "reg_dword", % "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" app_name, % "NoRepair", 0x00000001

regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\" app_name,, % "Open in Fleet"
regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\" app_name, % "Icon", % executable_path
regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\" app_name "\command",, % """" executable_path """ /fleet ""`%V"""

regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\" app_name,, % "Open in Fleet"
regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\" app_name, % "Icon", % executable_path
regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\" app_name "\command",, % """" executable_path """ /fleet ""`%V"""

regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\" app_name,, % "Open in Fleet"
regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\" app_name, % "Icon", % executable_path
regwrite, % "reg_sz", % "HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\" app_name "\command",, % """" executable_path """ /fleet ""`%V"""

msgbox, % "Installation complete! you may delete this executable 🥳."

exitapp
