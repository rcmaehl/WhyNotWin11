#include-once
#include <File.au3>
#include <WinAPIDiag.au3>

#include ".\_WMIC.au3"


Func _ArchCheck()
	Select
		Case @CPUArch = "X64" And @OSArch = "IA64"
			ContinueCase
		Case @CPUArch = "X64" And @OSArch = "X64"
			Return True
		Case @CPUArch = "X64" And @OSArch = "X86"
			Return SetError(1, 0, False)
		Case Else
			Return SetError(2, 0, False)
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
			Return SetError(1, $sFirmware, False)
	EndSwitch
EndFunc   ;==>_BootCheck

Func _CPUNameCheck($sCPU, $sVersion)
	Local $iLines, $sLine, $ListFile
	Select
		Case StringInStr($sCPU, "AMD")
			If StringInStr($sCPU, "1600") And StringInStr($sVersion, "Stepping 2") Then Return True ; 1600AF
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
					Return SetError(2, 0, False)
					ExitLoop
				Case $iLine = $iLines
					Return SetError(3, 0, False)
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
	Select
		Case _GetCPUInfo(3) >= 1000
			Return SetError(0, 0, True)
		Case RegRead("HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0", "~MHz") >= 1000
			Return SetError(0, 1, True)
		Case Else
			Return False
	EndSelect
EndFunc   ;==>_CPUSpeedCheck

Func _DirectXStartCheck()
	Local $aReturn[3]
	Local $hDXFile = _TempFile(@TempDir, "dxdiag")
	$aReturn[0] = $hDXFile
	$aReturn[1] = Run(@SystemDir & "\dxdiag.exe /whql:off /dontskip /t " & $hDXFile)
	$aReturn[2] = TimerInit()
	Return $aReturn
EndFunc   ;==>_DirectXStartCheck

Func _GetDirectXCheck(ByRef $aArray)
	If TimerDiff($aArray[2]) > 120000 Then
		FileDelete($aArray[0])
		Return SetError(0, 2, False)
	ElseIf Not ProcessExists($aArray[1]) Then
		Local $sDXFile = StringStripWS(StringStripCR(FileRead($aArray[0])), $STR_STRIPALL)
		Select
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "3") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:3") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM3")
				Return SetError(0, 2, True)
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "2") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:2") ; Non-English Languages
				ContinueCase
			Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
				Return SetError(0, 1, True)
			Case Not StringInStr($sDXFile, "FeatureLevels:12") Or Not StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
				Return SetError(1, 0, False)
			Case StringInStr($sDXFile, "DDIVersion:12") And Not StringInStr($sDXFile, "DriverModel:WDDM2")
				Return SetError(2, 0, False)
			Case Else
				Return SetError(0, 1, False)
		EndSelect
		FileDelete($aArray[0])
	Else
		Return $aArray
	EndIf
EndFunc   ;==>_GetDirectXCheck

Func _GPTCheck($aDisks)
	For $iLoop = 1 To UBound($aDisks) - 1
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
#cs
Func _GPTCheck($iFlag)
	; Desc ......... : Call _GetDiskInfoFromWmi() to get the disk and partition informations. The selected information will be returned.
	; Parameters ... : $iFlag = 0 => Return init type of system disk.
	; .............. : $iFlag = 1 => Return count of internal GPT disks.
	; .............. : $iFlag = 2 => Return count of all internal disks.
	; .............. : $iFlag = 3 => Return array with all disk. (Columns: DiskNum | InitType | CheckResult)
	; On error ..... : SetError(1, 1, "Error_CheckFailed")

	; Vars
	Local Static $aDisks
	If ($aDisks = Null) Then
		$aDisks = _GetDiskProperties(1) ; Array with all disks
		If @error = 1 Then Return SetError(1, 1, "Error_CheckFailed")
	EndIf
	Local $aReturnDiskArray[0][3]
	_ArrayAdd($aReturnDiskArray, "Disk" & "|" & "Type" & "|" & "Check result")

	; Return data based on $iFlag
	Switch $iFlag
		Case 0
			; Return data of system disk.
			Switch _GetDiskProperties(3)[0][9] ; 9 = Array field for DiskInitType
				Case "GPT"
					Return True
				Case "MBR"
					Return False
			EndSwitch
		Case 1
			; Count int. GPT disks
			Local $iDiskCount = 0
			For $i = 1 To UBound($aDisks) - 1
				If $aDisks[$i][9] = "GPT" Then
					$iDiskCount += 1
				EndIf
			Next
			Return $iDiskCount
		Case 2
			; Return count of all int. disks
			Return UBound($aDisks)
		Case 3
			; Return array with all disk in the format Number|Type|Result
			For $i = 0 To UBound($aDisks) - 1
				Local $sDiskRow = $aDisks[$i][0] & "|" & $aDisks[$i][9] & "|" & (($aDisks[$i][9] = "GPT") ? "True" : "False")
				_ArrayAdd($aReturnDiskArray, $sDiskRow)
			Next
			Return $aReturnDiskArray
	EndSwitch
EndFunc   ;==>_GPTCheck
#ce
Func _InternetCheck()
	Return _WinAPI_IsInternetConnected()
EndFunc

Func _MemCheck()
	Local Static $vMem

	If Not $vMem <> "" Then
		$vMem = DllCall(@SystemDir & "\Kernel32.dll", "int", "GetPhysicallyInstalledSystemMemory", "int*", "")
		If @error Then
			$vMem = MemGetStats()
			$vMem = Round($vMem[1] / 1048576, 1)
			$vMem = Ceiling($vMem)
		Else
			$vMem = Round($vMem[1] / 1048576, 1)
		EndIf
		If $vMem = 0 Then
			$vMem = MemGetStats()
			$vMem = Round($vMem[1] / 1048576, 1)
			$vMem = Ceiling($vMem)
		EndIf
	EndIf

	If $vMem >= 4 Then
		Return SetError($vMem, 0, True)
	Else
		Return SetError($vMem, 0, False)
	EndIf
EndFunc   ;==>_MemCheck

Func _SecureBootCheck()
	Local $sSecureBoot = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State", "UEFISecureBootEnabled")
	If @error Then $sSecureBoot = 999
	Switch $sSecureBoot
		Case 1
			Return SetError(0, 1, True)
		Case 0
			Return SetError(0, 0, True)
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
		If Round(DriveSpaceTotal($aDrives[$iLoop]) / 1024, 0) >= 60 Then $iDrives += 1
	Next

	If $iFree >= 64 Then
		Return SetError($iFree, $iDrives, True)
	Else
		Return SetError($iFree, $iDrives, False)
	EndIf
EndFunc   ;==>_SpaceCheck

Func _TPMCheck()
	Select
		Case _GetTPMInfo(0) = False
			ContinueCase
		Case _GetTPMInfo(1) = False
			Return SetError(0, 0, False)
		Case _GetTPMInfo(0) = True And _GetTPMInfo(3) <> "OK"
			Return SetError(3, 0 , False)
		Case _GetTPMInfo(0) = True And Number(_GetTPMInfo(2)) >= 2.0
			Return SetError(Number(_GetTPMInfo(2)), 0, True)
		Case _GetTPMInfo(0) = True And Number(_GetTPMInfo(2)) >= 1.2
			Return SetError(1, 0, False) ; Under Version 1.2
		Case _GetTPMInfo(0) = True And Not Number(_GetTPMInfo(2)) >= 1.2
			Return SetError(2, 0, False) ; Under Version 1.2 ????
		Case Else
			Return SetError(0, 0, False)
	EndSelect
EndFunc   ;==>_TPMCheck
