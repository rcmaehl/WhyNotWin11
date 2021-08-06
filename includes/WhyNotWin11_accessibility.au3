#include-once

;Script For accessibility
;made by Mateo Cedillo
#include "kbc.au3"
#include "reader.au3"
#include "_WMIC.au3"
#include "_Translations.au3"

#include <AutoItConstants.au3>

Global $LastResult = ""
If FileExists("Config") Then
	DirCreate(@ScriptDir & "\Config")
	;This folder will be used to store the settings.
EndIf

firstlaunch()

Func firstlaunch()
	Local $accessibility = IniRead(@ScriptDir & "\config\config.st", "accessibility", "Enable enhanced accessibility", "")
	Select
		Case $accessibility = "yes"
			accessibility()
		Case $accessibility = ""
			ConfigureAccessibility()
	EndSelect
EndFunc   ;==>firstlaunch

;The next func is to activate the improved accessibility, made exclusively and only for people with disability.
Func ConfigureAccessibility()
	Local $Question = MsgBox(4, _Translate(@MUILang, "Enable enhanced accessibility?"), _Translate(@MUILang, "This new Enhanced Accessibility functionality is designed for the visually impaired, in which most of the program interface can be used by voice and keyboard shortcuts. Activate?"))
	If $Question == 6 Then
		IniWrite(@ScriptDir & "\config\config.st", "accessibility", "Enable enhanced accessibility", "Yes")
		accessibility()
	Else
		IniWrite(@ScriptDir & "\config\config.st", "accessibility", "Enable enhanced accessibility", "No")
	EndIf
EndFunc   ;==>ConfigureAccessibility

Func accessibility()
	Local $sRead = IniRead(@ScriptDir & "\config\config.st", "accessibility", "Enable enhanced accessibility", "")
	Select
		Case $sRead = "Yes"
			SetKeys()
		Case $sRead = "No"
			Unsetkeys()
	EndSelect
EndFunc   ;==>accessibility

Func SetKeys()
	HotKeySet("^+1", "sayInfo")
	HotKeySet("^+2", "sayInfo")
	HotKeySet("^+3", "sayInfo")
	HotKeySet("^+4", "sayInfo")
	HotKeySet("^+5", "sayInfo")
	HotKeySet("^+6", "sayInfo")
	HotKeySet("^+7", "sayInfo")
	HotKeySet("^+c", "SayInfo")
EndFunc   ;==>SetKeys

Func Unsetkeys()
	HotKeySet("^+1")
	HotKeySet("^+2")
	HotKeySet("^+3")
	HotKeySet("^+4")
	HotKeySet("^+5")
	HotKeySet("^+6")
	HotKeySet("^+7")
	HotKeySet("^+c")
EndFunc   ;==>Unsetkeys

Func SayInfo()
	Switch @HotKeyPressed
		Case "^+1"
			Local $sFirmware = EnvGet("firmware_type")
			Switch $sFirmware
				Case "UEFI"
					speaking("Firmware: " & $sFirmware & @CRLF & _Translate(@MUILang, "Status: ") & _Translate(@MUILang, "Acceptable"))
					$LastResult = "Firmware: " & $sFirmware & @CRLF & _Translate(@MUILang, "Status: ") & _Translate(@MUILang, "Acceptable")
				Case "Legacy"
					$LastResult = "Firmware: " & $sFirmware & @CRLF & _Translate(@MUILang, "Status: ") & _Translate(@MUILang, "Not acceptable")
					speaking("Firmware: " & $sFirmware & @CRLF & _Translate(@MUILang, "Status: ") & _Translate(@MUILang, "Not acceptable"))
				Case Else
					$LastResult = "Firmware: " & $sFirmware & @CRLF & _Translate(@MUILang, "Status: ") & _Translate(@MUILang, "Cannot be determined")
					speaking("Firmware: " & $sFirmware & @CRLF & _Translate(@MUILang, "Status: ") & _Translate(@MUILang, "Cannot be determined"))
			EndSwitch
		Case "^+2"
			Local $iLines, $sLine
			$LastResult = _Translate(@MUILang, "CPU compatibility: ")
			Speaking(_Translate(@MUILang, "CPU compatibility: "))
			Select
				Case StringInStr(_GetCPUInfo(2), "AMD")
					$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
					If @error Then
						$LastResult &= _Translate(@MUILang, "Unable to Check List")
						Speaking(_Translate(@MUILang, "Unable to Check List"))
					EndIf
					For $iLine = 1 To $iLines Step 1
						$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", $iLine)
						Select
							Case @error = -1
								$LastResult &= _Translate(@MUILang, "Error Accessing List")
								speaking(_Translate(@MUILang, "Error Accessing List"))
								ExitLoop
							Case $iLine = $iLines
								$LastResult &= _Translate(@MUILang, "Not Currently Listed as Compatible")
								speaking(_Translate(@MUILang, "Not Currently Listed as Compatible"))
								ExitLoop
							Case StringInStr(_GetCPUInfo(2), $sLine)
								$LastResult &= _Translate(@MUILang, "Acceptable") & ", " & _Translate(@MUILang, "Listed as Compatible")
								Speaking(_Translate(@MUILang, "Acceptable") & ", " & _Translate(@MUILang, "Listed as Compatible"))
								ExitLoop
						EndSelect
					Next
				Case StringInStr(_GetCPUInfo(2), "Intel")
					$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
					If @error Then
						$LastResult &= _Translate(@MUILang, "Unable to Check List")
						speaking(_Translate(@MUILang, "Unable to Check List"))
					EndIf
					For $iLine = 1 To $iLines Step 1
						$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt", $iLine)
						Select
							Case @error = -1
								$LastResult &= _Translate(@MUILang, "Error Accessing List")
								speaking(_Translate(@MUILang, "Error Accessing List"))
								ExitLoop
							Case $iLine = $iLines
								$LastResult &= _Translate(@MUILang, "Not Currently Listed as Compatible")
								Speaking(_Translate(@MUILang, "Not Currently Listed as Compatible"))
								ExitLoop
							Case StringInStr(_GetCPUInfo(2), $sLine)
								$LastResult &= _Translate(@MUILang, "Acceptable") & ", " & _Translate(@MUILang, "Listed as Compatible")
								Speaking(_Translate(@MUILang, "Acceptable") & ", " & _Translate(@MUILang, "Listed as Compatible"))
								ExitLoop
						EndSelect
					Next
				Case StringInStr(_GetCPUInfo(2), "SnapDragon") Or StringInStr(_GetCPUInfo(2), "Microsoft")
					$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
					If @error Then
						$LastResult &= _Translate(@MUILang, "Unable to Check List")
						speaking(_Translate(@MUILang, "Unable to Check List"))
					EndIf
					For $iLine = 1 To $iLines Step 1
						$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt", $iLine)
						Select
							Case @error = -1
								$LastResult &= _Translate(@MUILang, "Error Accessing List")
								speaking(_Translate(@MUILang, "Error Accessing List"))
								ExitLoop
							Case $iLine = $iLines
								$LastResult &= _Translate(@MUILang, "Not Currently Listed as Compatible")
								Speaking(_Translate(@MUILang, "Not Currently Listed as Compatible"))
								ExitLoop
							Case StringInStr(_GetCPUInfo(2), $sLine)
								$LastResult &= _Translate(@MUILang, "Acceptable") & ", " & _Translate(@MUILang, "Listed as Compatible")
								Speaking(_Translate(@MUILang, "Acceptable") & ", " & _Translate(@MUILang, "Listed as Compatible"))
								ExitLoop
						EndSelect
					Next
				Case Else
					$LastResult &= _Translate(@MUILang, "Cannot be determined")
					Speaking(_Translate(@MUILang, "Cannot be determined"))
			EndSelect
			$LastResult &= @CRLF & _Translate(@MUILang, "CPU information: ")
			Speaking(_Translate(@MUILang, "CPU information: "))
			If _GetCPUInfo(0) >= 2 Or _GetCPUInfo(1) >= 2 Then
				$LastResult &= _Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Acceptable")
				Speaking(_Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Acceptable"))
			Else
				$LastResult &= _Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Not compatible")
				speaking(_Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Not compatible"))
			EndIf
			$LastResult &= _GetCPUInfo(0) & " " & _Translate(@MUILang, "Cores") & @CRLF & _GetCPUInfo(1) & " " & _Translate(@MUILang, "Threads")
			Speaking(_GetCPUInfo(0) & " " & _Translate(@MUILang, "Cores") & @CRLF & _GetCPUInfo(1) & " " & _Translate(@MUILang, "Threads"))
			If _GetCPUInfo(3) >= 1000 Then
				$LastResult &= @CRLF & "Cores: " & _Translate(@MUILang, "Acceptable") & _GetCPUInfo(3) & " MHz"
				Speaking("Cores: " & _Translate(@MUILang, "Acceptable") & _GetCPUInfo(3) & " MHz")
			Else
				$LastResult &= @CRLF & "Cores: " & _Translate(@MUILang, "Not compatible") & _GetCPUInfo(3) & " MHz"
				speaking("Cores: " & _Translate(@MUILang, "Not compatible") & _GetCPUInfo(3) & " MHz")
			EndIf
		Case "^+3"
			Local $aDisks = _GetDiskInfo(1)
			Switch _GetDiskInfo(0)
				Case "GPT"
					If $aDisks[0] = $aDisks[1] Then
						$LastResult = "GPT: OK"
						Speaking("GPT: OK")
					Else
						$LastResult = "GPT: " & _Translate(@MUILang, "Not compatible")
						Speaking("GPT: " & _Translate(@MUILang, "Not compatible"))
					EndIf
					$LastResult = _Translate(@MUILang, "GPT Detected") & @CRLF & $aDisks[1] & "/" & $aDisks[0] & " " & _Translate(@MUILang, "Drive(s) Meet Requirements")
					Speaking(_Translate(@MUILang, "GPT Detected") & @CRLF & $aDisks[1] & "/" & $aDisks[0] & " " & _Translate(@MUILang, "Drive(s) Meet Requirements"))
				Case Else
					$LastResult = _Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Not compatible") & @CRLF & _Translate(@MUILang, "GPT Not Detected")
					speaking(_Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Not compatible") & @CRLF & _Translate(@MUILang, "GPT Not Detected"))
			EndSwitch
		Case "^+4"
			Local $aMem = DllCall("Kernel32.dll", "int", "GetPhysicallyInstalledSystemMemory", "int*", "")
			If @error Then
				$aMem = MemGetStats()
				$aMem = Round($aMem[1] / 1048576, 1)
				$aMem = Ceiling($aMem)
			Else
				$aMem = Round($aMem[1] / 1048576, 1)
			EndIf
			If $aMem = 0 Then
				$aMem = MemGetStats()
				$aMem = $aMem[1]
				$aMem = Ceiling($aMem)
			EndIf
			If $aMem >= 4 Then
				$LastResult = "Memory: " & _Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Acceptable") & @CRLF & "Sice: " & $aMem & " GB"
				Speaking("Memory: " & _Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Acceptable") & @CRLF & "Sice: " & $aMem & " GB")
			Else
				$LastResult = "Memory: " & _Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Not compatible") & @CRLF & "Sice: " & $aMem & " GB"
				speaking("Memory: " & _Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Not compatible") & @CRLF & "Sice: " & $aMem & " GB")
			EndIf
		Case "^+5"
			Local $sSecureBoot = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State", "UEFISecureBootEnabled")
			If @error Then $sSecureBoot = 999
			Switch $sSecureBoot
				Case 0
					$LastResult = _Translate(@MUILang, "Secure Boot") & ": " & _Translate(@MUILang, "Status: ") & "OK, " & _Translate(@MUILang, "Supported")
					speaking(_Translate(@MUILang, "Secure Boot") & ": " & _Translate(@MUILang, "Status: ") & "OK, " & _Translate(@MUILang, "Supported"))
				Case 1
					$LastResult = _Translate(@MUILang, "Secure Boot") & ": " & _Translate(@MUILang, "Status: ") & "OK, " & _Translate(@MUILang, "Enabled")
					speaking(_Translate(@MUILang, "Secure Boot") & ": " & _Translate(@MUILang, "Status: ") & "OK, " & _Translate(@MUILang, "Enabled"))
				Case Else
					$LastResult = _Translate(@MUILang, "Secure Boot") & ": " & _Translate(@MUILang, "Status: ") & "X, " & _Translate(@MUILang, "Disabled / Not Detected")
					speaking(_Translate(@MUILang, "Secure Boot") & ": " & _Translate(@MUILang, "Status: ") & "X, " & _Translate(@MUILang, "Disabled / Not Detected"))
			EndSwitch
		Case "^+6"
			Local $aDrives = DriveGetDrive($DT_FIXED)
			Local $iDrives = 0
			For $iLoop = 1 To $aDrives[0] Step 1
				If Round(DriveSpaceTotal($aDrives[$iLoop]) / 1024, 0) >= 64 Then $iDrives += 1
			Next
			If Round(DriveSpaceTotal("C:\") / 1024, 0) >= 64 Then
				$LastResult = "Disk: OK"
				Speaking("Disk: OK")
			Else
				$LastResult = "disk " & _Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Not compatible")
				speaking("disk " & _Translate(@MUILang, "Compatibility: ") & _Translate(@MUILang, "Not compatible"))
			EndIf
			$LastResult &= @CRLF & _Translate(@MUILang, "Total size") & ": " & Round(DriveSpaceTotal("C:\") / 1024, 0) & " GB C:\" & @CRLF & $iDrives & " " & _Translate(@MUILang, "Drive(s) Meet Requirements")
			Speaking(_Translate(@MUILang, "Total size") & ": " & Round(DriveSpaceTotal("C:\") / 1024, 0) & " GB C:\" & @CRLF & $iDrives & " " & _Translate(@MUILang, "Drive(s) Meet Requirements"))
		Case "^+7"
			Select
				Case Not IsAdmin() And _GetTPMInfo(0) = True
					$LastResult = "Tpm: OK" & @CRLF & "TPM 2.0 " & _Translate(@MUILang, "Detected")
					Speaking("Tpm: OK" & @CRLF & "TPM 2.0 " & _Translate(@MUILang, "Detected"))
				Case Not IsAdmin() And _GetTPMInfo <> True
					$LastResult = "Tpm: X" & @CRLF & _Translate(@MUILang, "TPM Missing / Disabled")
					Speaking("Tpm: X" & @CRLF & _Translate(@MUILang, "TPM Missing / Disabled"))
				Case _GetTPMInfo(0) = False
					ContinueCase
				Case _GetTPMInfo(1) = False
					$LastResult = "Tpm: X" & @CRLF & _Translate(@MUILang, "TPM Missing / Disabled")
					Speaking("Tpm: X" & @CRLF & _Translate(@MUILang, "TPM Missing / Disabled"))
				Case Not Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
					$LastResult = "Tpm: X" & @CRLF & "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate(@MUILang, "Not Supported")
					Speaking("Tpm: X" & @CRLF & "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate(@MUILang, "Not Supported"))
				Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 2.0
					$LastResult = "Tpm: OK" & @CRLF & "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate(@MUILang, "Detected")
					Speaking("Tpm: OK" & @CRLF & "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate(@MUILang, "Detected"))
				Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
					Speaking("Tpm: OK" & @CRLF & "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate(@MUILang, "Detected"))
					Speaking("Tpm: X" & @CRLF & "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate(@MUILang, "Detected"))
				Case Else
					$LastResult = "Tpm: X" & @CRLF & _GetTPMInfo(0) & " " & _GetTPMInfo(1) & " " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0])
					Speaking("Tpm: X" & @CRLF & _GetTPMInfo(0) & " " & _GetTPMInfo(1) & " " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]))
			EndSelect
		Case "^+c"
			ClipPut($LastResult)
			speaking(_Translate(@MUILang, "The compatibility results were copied to the clipboard."))
	EndSwitch
EndFunc   ;==>SayInfo
