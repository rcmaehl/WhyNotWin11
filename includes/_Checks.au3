#include-once
#include <File.au3>
#include ".\_WMIC.au3"

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
EndFunc   ;==>_ArchCheck

Func _BootCheck()
	Local $sFirmware = EnvGet("firmware_type")
	Switch $sFirmware
		Case "UEFI"
			Return True
		Case "Legacy"
			Return False
		Case Else
			SetError(1, $sFirmware, False)
	EndSwitch
EndFunc   ;==>_BootCheck

Func _CPUNameCheck($sCPU)
	Local $iLines, $sLine, $ListFile
	Select
		Case StringInStr($sCPU, "AMD")
			$ListFile = "\WhyNotWin11\SupportedProcessorsAMD.txt"
		Case StringInStr($sCPU, "Intel")
			$ListFile = "\WhyNotWin11\SupportedProcessorsIntel.txt"
		Case StringInStr($sCPU, "SnapDragon") Or StringInStr($sCPU, "Microsoft")
			$ListFile = "\WhyNotWin11\SupportedProcessorsQualcomm.txt"
	EndSelect

	If $ListFile = Null Then
		Return False
	Else
		$iLines = _FileCountLines(@LocalAppDataDir & $ListFile)
		If @error Then Return SetError(1, 0, False)
		For $iLine = 1 To $iLines Step 1
			$sLine = FileReadLine(@LocalAppDataDir & $ListFile, $iLine)
			Select
				Case @error
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
	EndIf
EndFunc   ;==>_CPUNameCheck

Func _CPUCoresCheck($iCores, $iThreads)
	If $iCores >= 2 Or $iThreads >= 2 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_CPUCoresCheck

Func _CPUSpeedCheck()
	If _GetCPUInfo(3) >= 1000 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_CPUSpeedCheck

Func _DirectXStartCheck()
	Local $aReturn[2]
	Local $hDXFile = _TempFile(@TempDir, "dxdiag")
	$aReturn[0] = $hDXFile
	$aReturn[1] = Run(@SystemDir & "\dxdiag.exe /whql:off /t " & $hDXFile)
	Return $aReturn
EndFunc   ;==>_DirectXStartCheck

Func _GetDirectXCheck($aArray)
	If Not ProcessExists($aArray[1]) And FileExists($aArray[0]) Then
		Local $sDXFile = StringStripWS(StringStripCR(FileRead($aArray[0])), $STR_STRIPALL)
		Select
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "3") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:3") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM3")
				Return 2
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "2") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:2") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
				Return 1
			Case Not StringInStr($sDXFile, "FeatureLevels:12") Or Not StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
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
EndFunc   ;==>_GetDirectXCheck

Func _GPTCheck($aDisks)
	For $iLoop = 0 To UBound($aDisks) - 1
		If $aDisks[$iLoop][11] = "True" Then
			Switch $aDisks[$iLoop][9]
				Case "GPT"
					Return True
				Case Else
					Return SetError($aDisks[$iLoop][9], 0, False)
			EndSwitch
		EndIf
	Next
EndFunc   ;==>_GPTCheck

Func _MemCheck()
	Local Static $aMem

	If Not $aMem <> "" Then
		$aMem = DllCall(@SystemDir & "\Kernel32.dll", "int", "GetPhysicallyInstalledSystemMemory", "int*", "")
		If @error Then
			$aMem = MemGetStats()
			$aMem = Round($aMem[1] / 1048576, 1)
			$aMem = Ceiling($aMem)
		Else
			$aMem = Round($aMem[1] / 1048576, 1)
		EndIf
		If $aMem = 0 Then
			$aMem = MemGetStats()
			$aMem = Round($aMem[1] / 1048576, 1)
			$aMem = Ceiling($aMem)
		EndIf
	EndIf

	If $aMem >= 4 Then
		Return $aMem
	Else
		Return False
	EndIf
EndFunc   ;==>_MemCheck

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
EndFunc   ;==>_SecureBootCheck

Func _SpaceCheck()
	Local $sWindows = EnvGet("SystemDrive")

	Local $iFree = Round(DriveSpaceTotal($sWindows) / 1024, 0)
	Local $aDrives = DriveGetDrive($DT_FIXED)
	Local $iDrives = 0

	For $iLoop = 1 To $aDrives[0] Step 1
		If Round(DriveSpaceTotal($aDrives[$iLoop]) / 1024, 0) >= 64 Then $iDrives += 1
	Next

	If $iFree >= 64 Then
		Return SetError($iFree, $iDrives, True)
	Else
		Return SetError($iFree, $iDrives, False)
	EndIf
EndFunc   ;==>_SpaceCheck

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
EndFunc   ;==>_TPMCheck
