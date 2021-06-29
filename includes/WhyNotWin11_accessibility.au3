;Script For accessibility
;made by Mateo Cedillo
#include "_Checks.au3"
#include "kbc.au3"
#include "reader.au3"
#include "_WMIC.au3"
$LastResult = ""
If FileExists("Config") then
DirCreate("Config")
;This folder will be used to store the settings.
EndIf
firstlaunch()
Func firstlaunch()
$accessibility = iniRead ("config\config.st", "accessibility", "Enable enanced accessibility", "")
select
case $accessibility ="yes"
accessibility()
case $accessibility =""
ConfigureAccessibility()
EndSelect
EndFunc
;The next func is to activate the improved accessibility, made exclusively and only for people with disability.
func ConfigureAccessibility()
$Question=MsgBox(4, _Translate("Enable enanced accessibility?"), _Translate("This new Enhanced Accessibility functionality is designed for the visually impaired, in which most of the program interface can be used by voice and keyboard shortcuts. Activate?"))
if $question == 6 then
IniWrite("config\config.st", "accessibility", "Enable enanced accessibility", "Yes")
else
IniWrite("config\config.st", "accessibility", "Enable enanced accessibility", "No")
endif
endfunc
Func accessibility()
$sRead = iniRead ("config\config.st", "accessibility", "Enable enanced accessibility", "")
select
case $sRead ="Yes"
SetKeys()
case $sRead ="No"
Unsetkeys()
EndSelect
EndFunc
func SetKeys()
HotKeySet("^+1", "sayInfo")
HotKeySet("^+2", "sayInfo")
HotKeySet("^+3", "sayInfo")
HotKeySet("^+4", "sayInfo")
HotKeySet("^+5", "sayInfo")
HotKeySet("^+6", "sayInfo")
HotKeySet("^+7", "sayInfo")
HotKeySet("^+c", "SayInfo")
EndFunc
Func Unsetkeys()
hotkeyset("^+1")
hotkeyset("^+2")
hotkeyset("^+3")
hotkeyset("^+4")
hotkeyset("^+5")
hotkeyset("^+6")
hotkeyset("^+7")
hotkeyset("^+c")
EndFunc
Func SayInfo()
Switch @HotKeyPressed
Case "^+1"
$sFirmware = EnvGet("firmware_type")
Switch $sFirmware
Case "UEFI"
speaking("Firmware: " &$sFirmware &@crlf &_Translate("Status: ") &_Translate("Acceptable"))
$lastResult = "Firmware: " &$sFirmware &@crlf &_Translate("Status: ") &_Translate("Acceptable")
Case "Legacy"
$lastResult = "Firmware: " &$sFirmware &@crlf &_Translate("Status: ") &_Translate("Not acceptable")
speaking("Firmware: " &$sFirmware &@crlf &_Translate("Status: ") &_Translate("Not acceptable"))
Case Else
$lastResult = "Firmware: " &$sFirmware &@crlf &_Translate("Status: ") &_Translate("Cannot be determined")
speaking("Firmware: " &$sFirmware &@crlf &_Translate("Status: ") &_Translate("Cannot be determined"))
EndSwitch
Case "^+2"
$lastResult = _Translate("CPU compatibility: ")
Speaking(_Translate("CPU compatibility: "))
Select
Case StringInStr(_GetCPUInfo(2), "AMD")
$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
If @error Then
$lastresult &= _Translate("Unable to Check List")
Speaking(_Translate("Unable to Check List"))
EndIf
For $iLine = 1 to $iLines Step 1
$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", $iLine)
Select
Case @error = -1
$lastresult &= _Translate("Error Accessing List")
speaking(_Translate("Error Accessing List"))
ExitLoop
Case $iLine = $iLines
$lastresult &= _Translate("Not Currently Listed as Compatible")
speaking(_Translate("Not Currently Listed as Compatible"))
ExitLoop
Case StringInStr(_GetCPUInfo(2), $sLine)
$lastresult &= _Translate("Acceptable") &", " &_Translate("Listed as Compatible")
Speaking(_Translate("Acceptable") &", " &_Translate("Listed as Compatible"))
ExitLoop
EndSelect
Next
Case StringInStr(_GetCPUInfo(2), "Intel")
$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
If @error Then
$lastresult &= _Translate("Unable to Check List")
speaking(_Translate("Unable to Check List"))
EndIf
For $iLine = 1 to $iLines Step 1
$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt", $iLine)
Select
Case @error = -1
$lastResult &= _Translate("Error Accessing List")
speaking(_Translate("Error Accessing List"))
ExitLoop
Case $iLine = $iLines
$LastResult &= _Translate("Not Currently Listed as Compatible")
Speaking(_Translate("Not Currently Listed as Compatible"))
ExitLoop
Case StringInStr(_GetCPUInfo(2), $sLine)
$lastresult &= _Translate("Acceptable") &", " &_Translate("Listed as Compatible")
Speaking(_Translate("Acceptable") &", " &_Translate("Listed as Compatible"))
ExitLoop
EndSelect
Next
Case StringInStr(_GetCPUInfo(2), "SnapDragon") Or StringInStr(_GetCPUInfo(2), "Microsoft")
$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
If @error Then
$lastresult &= _Translate("Unable to Check List")
speaking(_Translate("Unable to Check List"))
EndIf
For $iLine = 1 to $iLines Step 1
$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt", $iLine)
Select
Case @error = -1
$lastresult &= _Translate("Error Accessing List")
speaking(_Translate("Error Accessing List"))
ExitLoop
Case $iLine = $iLines
$lastresult &= _Translate("Not Currently Listed as Compatible")
Speaking(_Translate("Not Currently Listed as Compatible"))
ExitLoop
Case StringInStr(_GetCPUInfo(2), $sLine)
$lastresult &= _Translate("Acceptable") &", " &_Translate("Listed as Compatible")
Speaking(_Translate("Acceptable") &", " &_Translate("Listed as Compatible"))
ExitLoop
EndSelect
Next
Case Else
$lastresult &= _Translate("Cannot be determined")
Speaking(_Translate("Cannot be determined"))
EndSelect
$lastresult &= @crlf &_Translate("CPU information: ")
Speaking(_Translate("CPU information: "))
If _GetCPUInfo(0) >= 2 Or _GetCPUInfo(1) >= 2 Then
$lastresult &= _Translate("Compatibility: ") &_Translate("Acceptable")
Speaking(_Translate("Compatibility: ") &_Translate("Acceptable"))
Else
$lastresult &= _Translate("Compatibility: ") &_Translate("Not compatible")
speaking(_Translate("Compatibility: ") &_Translate("Not compatible"))
EndIf
$lastresult &= _GetCPUInfo(0) & " " & _Translate("Cores") & @CRLF & _GetCPUInfo(1) & " " & _Translate("Threads")
Speaking(_GetCPUInfo(0) & " " & _Translate("Cores") & @CRLF & _GetCPUInfo(1) & " " & _Translate("Threads"))
If _GetCPUInfo(3) >= 1000 Then
$lastresult &= @crlf &"Cores: " &_Translate("Acceptable") &_GetCPUInfo(3) & " MHz"
Speaking("Cores: " &_Translate("Acceptable") &_GetCPUInfo(3) & " MHz")
Else
$lastresult &= @crlf &"Cores: " &_Translate("Not compatible") &_GetCPUInfo(3) & " MHz"
speaking("Cores: " &_Translate("Not compatible") &_GetCPUInfo(3) & " MHz")
EndIf
Case "^+3"
$aDisks = _GetDiskInfo(1)
Switch _GetDiskInfo(0)
Case "GPT"
If $aDisks[0] = $aDisks[1] Then
$lastresult = "GPT: OK"
Speaking("GPT: OK")
Else
$lastresult = "GPT: " &_Translate("Not compatible")
Speaking("GPT: " &_Translate("Not compatible"))
EndIf
$lastresult = _Translate("GPT Detected") & @CRLF & $aDisks[1] & "/" & $aDisks[0] & " " & _Translate("Drive(s) Meet Requirements")
Speaking(_Translate("GPT Detected") & @CRLF & $aDisks[1] & "/" & $aDisks[0] & " " & _Translate("Drive(s) Meet Requirements"))
Case Else
$lastresult = _Translate("Compatibility: ") &_Translate("Not compatible") &@crlf &_Translate("GPT Not Detected")
speaking(_Translate("Compatibility: ") &_Translate("Not compatible") &@crlf &_Translate("GPT Not Detected"))
EndSwitch
Case "^+4"
$aMem = DllCall("Kernel32.dll", "int", "GetPhysicallyInstalledSystemMemory", "int*", "")
If @error Then
$aMem = MemGetStats()
$aMem = Round($aMem[1]/1048576, 1)
$aMem = Ceiling($aMem)
Else
$aMem = Round($aMem[1]/1048576, 1)
EndIf
If $aMem = 0 Then
$aMem = MemGetStats()
$aMem = $aMem[1]
$aMem = Ceiling($aMem)
EndIf
If $aMem >= 4 Then
$lastresult = "Memory: " &_Translate("Compatibility: ") &_Translate("Acceptable") &@crlf &"Sice: "&$aMem & " GB"
Speaking("Memory: " &_Translate("Compatibility: ") &_Translate("Acceptable") &@crlf &"Sice: "&$aMem & " GB")
Else
$lastresult = "Memory: " &_Translate("Compatibility: ") &_Translate("Not compatible") &@crlf &"Sice: " &$aMem & " GB"
speaking("Memory: " &_Translate("Compatibility: ") &_Translate("Not compatible") &@crlf &"Sice: " &$aMem & " GB")
EndIf
Case "^+5"
$sSecureBoot = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State", "UEFISecureBootEnabled")
If @error Then $sSecureBoot = 999
Switch $sSecureBoot
Case 0
$lastresult = _Translate("Secure Boot") &": " &_Translate("Status: ") &"OK, " &_Translate("Supported")
speaking(_Translate("Secure Boot") &": " &_Translate("Status: ") &"OK, " &_Translate("Supported"))
Case 1
$lastresult = _Translate("Secure Boot") &": " &_Translate("Status: ") &"OK, " &_Translate("Enabled")
speaking(_Translate("Secure Boot") &": " &_Translate("Status: ") &"OK, " &_Translate("Enabled"))
Case Else
$lastresult = _Translate("Secure Boot") &": " &_Translate("Status: ") &"X, " &_Translate("Disabled / Not Detected")
speaking(_Translate("Secure Boot") &": " &_Translate("Status: ") &"X, " &_Translate("Disabled / Not Detected"))
EndSwitch
Case "^+6"
$aDrives = DriveGetDrive($DT_FIXED)
$iDrives = 0
For $iLoop = 1 to $aDrives[0] Step 1
If Round(DriveSpaceTotal($aDrives[$iLoop])/1024, 0) >= 64 Then $iDrives += 1
Next
If Round(DriveSpaceTotal("C:\")/1024, 0) >= 64 Then
$lastresult = "Disk: OK"
Speaking("Disk: OK")
Else
$lastresult = "disk " &_Translate("Compatibility: ") &_Translate("Not compatible")
speaking("disk " &_Translate("Compatibility: ") &_Translate("Not compatible"))
EndIf
$lastresult &= @crlf &_translate("Total size") &": " &Round(DriveSpaceTotal("C:\")/1024, 0) & " GB C:\" & @CRLF & $iDrives & " " & _Translate("Drive(s) Meet Requirements")
Speaking(_translate("Total size") &": " &Round(DriveSpaceTotal("C:\")/1024, 0) & " GB C:\" & @CRLF & $iDrives & " " & _Translate("Drive(s) Meet Requirements"))
Case "^+7"
Select
Case Not IsAdmin() And _GetTPMInfo(0) = True
$lastresult = "Tpm: OK" &@crlf &"TPM 2.0 " &_Translate("Detected")
Speaking("Tpm: OK" &@crlf &"TPM 2.0 " &_Translate("Detected"))
Case Not IsAdmin() And _GetTPMInfo <> True
$lastresult = "Tpm: X" &@crlf &_Translate("TPM Missing / Disabled")
Speaking("Tpm: X" &@crlf &_Translate("TPM Missing / Disabled"))
Case _GetTPMInfo(0) = False
ContinueCase
Case _GetTPMInfo(1) = False
$lastresult = "Tpm: X" &@crlf &_Translate("TPM Missing / Disabled")
Speaking("Tpm: X" &@crlf &_Translate("TPM Missing / Disabled"))
Case Not Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
$lastresult = "Tpm: X" &@crlf &"TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Not Supported")
Speaking("Tpm: X" &@crlf &"TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Not Supported"))
Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 2.0
$lastresult = "Tpm: OK" &@crlf &"TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Detected")
Speaking("Tpm: OK" &@crlf &"TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Detected"))
Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
Speaking("Tpm: OK" &@crlf &"TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Detected"))
Speaking("Tpm: X" &@crlf &"TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Detected"))
Case Else
$lastresult = "Tpm: X" &@crlf &_GetTPMInfo(0) & " " & _GetTPMInfo(1) & " " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0])
Speaking("Tpm: X" &@crlf &_GetTPMInfo(0) & " " & _GetTPMInfo(1) & " " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]))
EndSelect
Case "^+c"
ClipPut($LastResult)
speaking(_translate("The compatibility results were copied to the clipboard."))
EndSwitch
EndFunc