#include-once
#include <File.au3>
#include "_WMIC.au3"

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
				SetError(2, 0, False)
			Case Else
				Return False
		EndSelect
		FileDelete($aArray[0])
	Else
		Return $aArray
	EndIf
EndFunc   ;==>_GetDirectXCheck

Func _GPTCheck($iFlag)
	; Desc ......... : Call _GetDiskInfoFromWmi() to get the disk and partition informations. The selected information will be returned.
	; Parameters ... : $iFlag = 0 => Return init type of system disk.
	; .............. : $iFlag = 1 => Return count of internal GPT disks.
	; .............. : $iFlag = 2 => Return count of all internal disks.
	; .............. : $iFlag = 3 => Return array with all disk. (Columns: DiskNum | InitType | CheckResult)
	; On error ..... : SetError(1, 1, "Error_CheckFailed")

	; Vars
	Local Static $aDisks
	If (Not $aDisks) Then
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
			For $i = 0 To UBound($aDisks) - 1
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

Func _SpaceCheck($iFlag)
	; Desc ......... : Call _GetDiskInfoFromWmi() to get the disk and partition informations. The selected information will be returned.
	; Parameters ... : $iFlag = 0 => Return if system disk and system partition ready.
	; .............. : $iFlag = 1 => Number of system disk.
	; .............. : $iFlag = 2 => Return size of system disk in GB.
	; .............. : $iFlag = 3 => Letter of system partition.
	; .............. : $iFlag = 4 => Return size of system partition in GB.
	; .............. : $iFlag = 5 => Return count of internal Win11 ready disks.
	; .............. : $iFlag = 6 => Return count of all internal disks.
	; .............. : $iFlag = 7 => Return array with all disk. (Columns: DiskNum | Size (GB) | CheckResult)
	; On error ..... : SetError(1, 1, "Error_CheckFailed")

	; Ini tvars
	Local Static $bInitDone = False
	Local Static $iDiskSize
	Local Static $iPartitionSize
	Local Static $aDisks
	Local $aReturnDiskArray[0][3]
	_ArrayAdd($aReturnDiskArray, "Disk" & "|" & "Size (GB)" & "|" & "Check result")

	; Init data
	If (Not $bInitDone = True) Then
		; Check for error by retriving disk data
		_GetDiskProperties(4)
		If @error = 1 Then Return SetError(1, 1, "Error_CheckFailed")

		; Get size (Arrays form _GetDiskProperties are 2D-Arrays.) & vars
		$iDiskSize = Round(_GetDiskProperties(3)[0][8] / 1024 / 1024 / 1024)
		$iPartitionSize = Round(_GetDiskProperties(4)[0][9] / 1024 / 1024 / 1024)
		$aDisks = _GetDiskProperties(1)
	EndIf

	; Return data based on $iFlag
	Switch $iFlag
		Case 0
			; Return readiness state
			Return ($iDiskSize >= 64 And $iPartitionSize >= 64) ? True : False
		Case 1
			; Return number of System disk
			Return _GetDiskProperties(3)[0][0] ; (Array form _GetDiskProperties is a 2D-Array.)
		Case 2
			; Return size of disk
			Return $iDiskSize
		Case 3
			; Return letter of system partition
			Return _GetDiskProperties(4)[0][6] ; (Array form _GetDiskProperties is a 2D-Array.)
		Case 4
			; Return size of partiton
			Return $iPartitionSize
		Case 5
			; Count Disk with sie >= 64 GB.
			Local $iDiskCount = 0
			For $i = 0 To UBound($aDisks) - 1
				If $aDisks[$i][8] >= 64 Then
					$iDiskCount += 1
				EndIf
			Next
			Return $iDiskCount
		Case 6
			; Return count of internal disks
			Return UBound($aDisks)
		Case 7
			; Return array with all disk inf format Number|Syze|Result
			For $i = 0 To UBound($aDisks) - 1
				Local $sDiskRow = $aDisks[$i][0] & "|" & Round(_GetDiskProperties(3)[$i][8] / 1024 / 1024 / 1024) & "|" & (($aDisks[$i][8] >= 64) ? "True" : "False")
				_ArrayAdd($aReturnDiskArray, $sDiskRow)
			Next
			Return $aReturnDiskArray
		Case Else
			; $iFlag unknown
			Return SetError(1, 1, "Error_CheckFailed")
	EndSwitch
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
