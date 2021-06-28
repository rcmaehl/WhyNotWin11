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
	Local $aReturn[2]

	$aReturn[1] = _TempFile()
	$aReturn[0] = Run("powershell -Command $env:firmware_type | Out-File -FilePath " & $aReturn[1], "", @SW_HIDE)
	If @error Then
		SetError(1, 0, 0)
	Else
		Return $aReturn
	EndIf
EndFunc

Func _CPUName($sCPU)
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