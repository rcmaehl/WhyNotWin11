#include-once
#include <File.au3>

Func _ArchCheck()
	Select
		Case @CPUArch = "X64" And @OSArch = "IA64"
			ContinueCase
		Case @CPUArch = "X64" And @OSArch = "X64"
			Return True
		Case @CPUArch = "X64" And @OSArch = "X86"
			SetError(1, 0, False)
		Case Else
			SetError(2, 0, False)
	EndSelect
EndFunc

Func _BootCheck()
	Local $sFirmware = EnvGet("firmware_type")
	Switch $sFirmware
		Case "UEFI"
			Return True
		Case "Legacy"
			Return False
		Case Else
			SetError(1, 0, False)
	EndSwitch
EndFunc

Func _CPUNameCheck($sCPU)
	Select
		Case StringInStr($sCPU, "AMD")
			Local $iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			If @error Then
				SetError(1, 0, 0)
			EndIf
			For $iLine = 1 to $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", $iLine)
				Select
					Case @error = -1
						SetError(2, 0, False)
						ExitLoop
					Case $iLine = $iLines
						SetError(3, 0, False)
						ExitLoop
					Case StringInStr($sCPU, $sLine)
						Return True
						ExitLoop
				EndSelect
			Next
		Case StringInStr($sCPU, "Intel")
			Local $iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
			If @error Then
				SetError(1, 0, 0)
			EndIf
			For $iLine = 1 to $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt", $iLine)
				Select
					Case @error = -1
						SetError(2, 0, False)
						ExitLoop
					Case $iLine = $iLines
						SetError(3, 0, False)
						ExitLoop
					Case StringInStr($sCPU, $sLine)
						Return True
						ExitLoop
				EndSelect
			Next
		Case StringInStr($sCPU, "SnapDragon") Or StringInStr($sCPU, "Microsoft")
			Local $iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
			If @error Then
				SetError(1, 0, 0)
			EndIf
			For $iLine = 1 to $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt", $iLine)
				Select
					Case @error = -1
						SetError(2, 0, False)
						ExitLoop
					Case $iLine = $iLines
						SetError(3, 0, False)
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

Func _DirectXStartCheck()
	Local $aReturn[2]
	Local $hDXFile = _TempFile(@TempDir, "dxdiag")
	$aReturn[0] = $hDXFile
	$aReturn[1] = Run("dxdiag /whql:off /t " & $hDXFile)
	Return $aReturn
EndFunc

Func _GetDirectXCheck($aArray)
	If Not ProcessExists($aArray[1]) And FileExists($aArray[0]) Then
		Local $sDXFile = StringStripWS(StringStripCR(FileRead($aArray[0])), $STR_STRIPALL)
		Select
			Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "3") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:3") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM3")
				Return 2
			Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "2") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:2") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
				Return 1
			Case Not StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
				SetError(1, 0, False)
			Case StringInStr($sDXFile, "DDIVersion:12") And Not StringInStr($sDXFile, "DriverModel:WDDM2")
				SetError(1, 0, False)
			Case Else
				Return False
		EndSelect
		FileDelete($aArray[0])
	Else
		Return $aArray
	EndIf
EndFunc

Func _GPTCheck()
	Local $aDisks = _GetDiskInfo(1)
	Switch _GetDiskInfo(0)
		Case "GPT"
			If $aDisks[0] = $aDisks[1] Then
				Return True
			Else
				SetError($aDisks[1], $aDisks[0], True)
			EndIf
		Case Else
			Return False
	EndSwitch
EndFunc

Func _MemCheck()
	Local $aMem = DllCall("Kernel32.dll", "int", "GetPhysicallyInstalledSystemMemory", "int*", "")
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
		Return $aMem
	Else
		Return False
	EndIf
EndFunc

Func _SecureBootCheck()
	Local $sSecureBoot = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State", "UEFISecureBootEnabled")
	If @error Then $sSecureBoot = 999
	Switch $sSecureBoot
		Case 0
			Return True
		Case 1
			Return 2
		Case Else
			Return False
	EndSwitch
EndFunc

Func _SpaceCheck()
	Local $aDrives = DriveGetDrive($DT_FIXED)
	Local $iDrives = 0

	For $iLoop = 1 to $aDrives[0] Step 1
		If Round(DriveSpaceTotal($aDrives[$iLoop])/1024, 0) >= 64 Then $iDrives += 1
	Next

	If Round(DriveSpaceTotal("C:\")/1024, 0) >= 64 Then
		Return $iDrives
	Else
		SetError($iDrives, 0, 0)
	EndIf
EndFunc

Func _TPMCheck()
	Select
		Case Not IsAdmin() And _GetTPMInfo(0) = True
			Return True
		Case Not IsAdmin() And _GetTPMInfo <> True
			Return False
		Case _GetTPMInfo(0) = False
			ContinueCase
		Case _GetTPMInfo(1) = False
			Return False
		Case Not Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
			SetError(1, 0, False) ; Under Version 1.2
		Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 2.0
			Return True
		Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
			SetError(2, 0, False) ; Under Version 1.2 ????
		Case Else
			Return False
	EndSelect
EndFunc