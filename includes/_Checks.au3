#include-once
#include <File.au3>

Func _ArchCheck()
	Select
		Case @CPUArch = "X64" And @OSArch = "IA64"
			ContinueCase
		Case @CPUArch = "X64" And @OSArch = "X64"
			Return True
		Case @CPUArch = "X64" And @OSArch = "X86"
			SetError(1, 0, 0)
		Case Else
			SetError(2, 0, 0)
	EndSelect
EndFunc

Func _BootCheck()
	$sFirmware = EnvGet("firmware_type")
	Switch $sFirmware
		Case "UEFI"
			Return True
		Case "Legacy"
			Return False
		Case Else
			SetError(1, 0, 0)
	EndSwitch
EndFunc

Func _CPUNameCheck($sCPU)
	Select
		Case StringInStr($sCPU, "AMD")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			If @error Then
				SetError(1, 0, 0)
			EndIf
			For $iLine = 1 to $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", $iLine)
				Select
					Case @error = -1
						SetError(2, 0, 0)
						ExitLoop
					Case $iLine = $iLines
						SetError(3, 0, 0)
						ExitLoop
					Case StringInStr($sCPU, $sLine)
						Return True
						ExitLoop
				EndSelect
			Next
		Case StringInStr($sCPU, "Intel")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
			If @error Then
				SetError(1, 0, 0)
			EndIf
			For $iLine = 1 to $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt", $iLine)
				Select
					Case @error = -1
						SetError(2, 0, 0)
						ExitLoop
					Case $iLine = $iLines
						SetError(3, 0, 0)
						ExitLoop
					Case StringInStr($sCPU, $sLine)
						Return True
						ExitLoop
				EndSelect
			Next
		Case StringInStr($sCPU, "SnapDragon") Or StringInStr($sCPU, "Microsoft")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
			If @error Then
				SetError(1, 0, 0)
			EndIf
			For $iLine = 1 to $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt", $iLine)
				Select
					Case @error = -1
						SetError(2, 0, 0)
						ExitLoop
					Case $iLine = $iLines
						SetError(3, 0, 0)
						ExitLoop
					Case StringInStr($sCPU, $sLine)
						Return True
						ExitLoop
				EndSelect
			Next
		Case Else
			Return False
	EndSelect
EndFunc

Func _CPUCoresCheck()
	If _GetCPUInfo(0) >= 2 Or _GetCPUInfo(1) >= 2 Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func _CPUSpeedCheck()
	If _GetCPUInfo(3) >= 1000 Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func _StartDirectXCheck()
	Local $aReturn[2]
	$hDXFile = _TempFile(@TempDir, "dxdiag")
	$aReturn[0] = $hDXFile
	$aReturn[1] = Run("dxdiag /whql:off /t " & $hDXFile)
	Return $aReturn
EndFunc