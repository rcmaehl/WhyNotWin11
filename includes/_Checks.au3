#include-once
#include <File.au3>
#include <Memory.au3>
#include <WinAPISys.au3>
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

Func _CPUCheck($sCPU, $iFamily, $iModel, $iStepping, $sWinFU = False)

	Local $PF_ARM_V81_ATOMIC_INSTRUCTIONS_AVAILABLE = 34

	If $sWinFU Then
		Local $sReg = RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators\" & $sWinFU, "RedReason")
		If @error Then
			SetError(1, 0, False)
		Else
			Return Not StringInStr($sReg, "CpuFms")
		EndIf
	EndIf

	Local $sPSF1, $sCP4030
	Local $aFile, $ListFile

	; Microsoft Hardware Readiness PS Script Values
	Switch RegRead("HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0", "VendorIdentifier")
		Case "Qualcomm Technologies Inc"
			If Not _WinAPI_IsProcessorFeaturePresent($PF_ARM_V81_ATOMIC_INSTRUCTIONS_AVAILABLE) Then
				$sCP4030 = RegRead("HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0", "CP 4030")
				If BitAND(BitShift($sCP4030, 20), 0xF) >= 2 Then Return True
				Return False
			EndIf
		Case "GenuineIntel"
			If $iFamily >= 6 And $iModel <= 95 And Not ($iFamily = 6 And $iModel = 85) Then
				Return False
			ElseIf $iFamily = 6 And ($iModel = 142 Or $iModel = 158) And $iStepping = 9 Then
				$sPSF1 = RegRead("HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0", "Platform Specific Field 1")
				If (($iModel = 142 And Not $sPSF1 = 16) Or ($iModel = 158 And Not $sPSF1 = 8)) Then Return False
			EndIf
		Case "AuthenticAMD"
			If $iFamily < 23 Or $iFamily = 23 And ($iModel = 1 Or $iModel = 17) Then Return False
	EndSwitch

	Return True

	#cs
	; Borrowed from mq1n
	Select
		Case StringInStr($sCPU, "AMD")
			If $iFamily >= 25 Then Return True
			If StringInStr($sCPU, "1600") And $iStepping = 2 Then Return True ; 1600AF
			$ListFile = "\WhyNotWin11\SupportedProcessorsAMD.txt"
		Case StringInStr($sCPU, "Intel")
			If $iFamily = 6 Then
				Select
					Case StringRegExp(String($iModel), "(1[6-9][0-9]|2[0-9]{2})")
						ContinueCase
					Case $iModel = 142 And StringRegExp(String($iStepping), "1[0-9]")
						ContinueCase
					Case $iModel = 158 And StringRegExp(String($iStepping), "1[0-9]")
						Return True
				EndSelect
			EndIf
			$ListFile = "\WhyNotWin11\SupportedProcessorsIntel.txt"
		Case StringInStr($sCPU, "SnapDragon") Or StringInStr($sCPU, "Microsoft")
			$ListFile = "\WhyNotWin11\SupportedProcessorsQualcomm.txt"
	EndSelect
	
	If $ListFile = Null Then
		Return SetError(1, 0, False)
	Else
		$aFile = FileReadToArray(@LocalAppDataDir & $ListFile)
		If @error Then Return SetError(2, 0, False)
		; Pad Array to increase search accuracy
		For $iLoop = 0 To UBound($aFile) - 1
			If StringInStr($sCPU & " ", $aFile[$iLoop] & " ") Then Return True
		Next
		Return SetError(3, 0, False)
	EndIf

	If $ListFile = Null Then
		Return SetError(1, 0, False)
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
				Case StringInStr($sCPU & " ", $sLine & " ")
					Return True
					ExitLoop
			EndSelect
		Next
	EndIf
	#ce

EndFunc   ;==>_CPUCheck

Func _CPUCoresCheck($iCores, $iThreads, $sWinFU = False)

	If $sWinFU Then
		Local $sReg = RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators\" & $sWinFU, "RedReason")
		If @error Then
			Return SetError(1, 0, False)
		Else
			Return Not StringInStr($sReg, "Cpu")
		EndIf
	EndIf

	If $iCores >= 2 Or $iThreads >= 2 Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_CPUCoresCheck

Func _CPUSpeedCheck($sWinFU = False)

	If $sWinFU Then
		Local $sReg = RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators\" & $sWinFU, "RedReason")
		If @error Then
			Return SetError(1, 0, False)
		Else
			Return Not StringInStr($sReg, "Cpu")
		EndIf
	EndIf

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
	If Not IsArray($aArray) Then
		;;;
	Elseif TimerDiff($aArray[2]) > 120000 Then
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

Func _GPUNameCheck($sGPU)

	Local $aGPUIDs[0]

	If StringInStr($sGPU, ", ") Then ; Split multiple GPUs
		$aGPUIDs = StringSplit($sGPU, ", ", $STR_ENTIRESPLIT + $STR_NOCOUNT)
	Else
		Redim $aGPUIDs[1]
		$aGPUIDs[0] = $sGPU
	EndIf

	For $iLoop = 0 To UBound($aGPUIDs) - 1 Step 1
		Select
			Case StringRegExp($sGPU, ".*(RX|Vega|VII|AI).*") ; Modern AMD Dedicated GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*(Xe|UHD|Iris Plus|Iris Pro Graphics P?5(5|8)(0|5)[^0]|Iris Graphics 5(4|5)0[^0]|HD Graphics P?[5-9][0-9](5|0)[^0]).*") ; Modern Intel iGPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*\s(A|B)([3-6]|(3|5|7)[0-9])0.*") ; Modern Intel Dedicated GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*(GTX (9|10|16|(Titan (X|V)))|RTX| Super|Max-Q).*") ; Modern Nvidia GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*GeForce (9(6-8)(0|5)M|MX(150|[2-9][0-9]0[^0])).*") ; Modern Nvidia Mobile GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*Quadro (M|P|GV|T).*") ; Modern Nvidia Workstation GPUs (incl Mobile)
				ContinueCase
			Case StringRegExp($sGPU, ".*Nvidia T(4|6|10)00.*"); TU117 Naming...
				ContinueCase
			Case StringRegExp($sGPU, ".*[^Fire].Pro (W(X|[5-9][0-9]00)|5(3|5|7)00).*") ; Modern AMD Workstation GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*Pro (4|5)[5-8](0|5)[^0].*") ; Modern AMD Mobile Workstation GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*Radeon (HD (779|877)0[^M]*|R7 (2|3)60|R9 380|R9 285|R9 (2|3)90|R9 295|R9 (Fury|Nano)|53(0|5)|Pro (Duo|SSG)).*") ; Older AMD Dedicated GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*Radeon (R9 M2(80|95)X|R9 M3(85|90)X|R9 M395[X]*|R9 M4(70|85)|5(40|50)|6(20|25|30)).*") ; Older AMD Mobile GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*FirePro W(4300|(5|[7-9])100).*") ; Older AMD Workstation GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*Tegra (K1|T1(24|32|86|94)[^0]|X1|T21(0|4)[^0]|T23(4|9)[^0]|T241[^0]|T2(5|6)4[^0]|X2).*") ; Nvidia ARM GPUs
				ContinueCase
			Case StringRegExp($sGPU, ".*(Xavier|Orin) ((AG|N)X|Nano).*") ; Nvidia ARM GPUs Continued
				ContinueCase
			Case StringRegExp($sGPU, ".*(VirtualBox|Hyper-V|VMware|Citrix).*") ; Virtual GPUs
				Return SetError(0, 0, True)
			Case Else
				;;;
		EndSelect
	Next

	Return SetError(0, 0, False)
EndFunc   ;==>_GPUNameCheck

Func _GPUHWIDCheck($sGPU)

	Local $iEnd
	Local $aGPU
	Local $aIDs
	Local $iMatch
	Local $iStart
	Local $aGPUIDs[0]

	Local $aReturn[3] = [0, 0, False] ; Error, Extended, Return
	
	If StringInStr($sGPU, ", ") Then ; Split multiple GPUs
		$aGPUIDs = StringSplit($sGPU, ", ", $STR_ENTIRESPLIT + $STR_NOCOUNT)
	Else
		Redim $aGPUIDs[1]
		$aGPUIDs[0] = $sGPU
	EndIf

	For $iLoop = 0 To UBound($aGPUIDs) - 1 Step 1
		$aGPU = StringSplit($sGPU, "&", $STR_NOCOUNT)
		If UBound($aGPU) < 2 Then ContinueLoop

		If Not IsArray($aIDs) Then
			$aIDs = FileReadToArray(@LocalAppDataDir & "\WhyNotWin11\PCI.ids")
			If @error Then
				$aReturn[0] = 0
				$aReturn[1] = 3
				ExitLoop
			EndIf
		EndIf

		$iStart = _ArraySearch($aIDs, "^" & StringReplace($aGPU[0], "PCI\VEN_", ""), 0, 0, 0, 3)
		$iEnd = _ArraySearch($aIDs, "^[0-9a-f]", $iStart+1, 0, 0, 3)
		$iMatch = _ArraySearch($aIDs, "^" & @TAB & StringLower(StringReplace($aGPU[1], "DEV_", "")), $iStart+1, $iEnd, 0, 3)
		If @error Then ContinueLoop

		If $iMatch Then
			If _GPUNameCheck($aIDs[$iMatch]) Then $aReturn[2] = True
		EndIf
	Next
	Return SetError($aReturn[0], $aReturn[1], $aReturn[2])
EndFunc

Func _InternetCheck()
	Return _WinAPI_IsInternetConnected()
EndFunc

Func _MemCheck($sWinFU = False)
	Local Static $vMem

	If $sWinFU Then
		Local $sReg = RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators\" & $sWinFU, "RedReason")
		If @error Then
			Return SetError(1, 0, False)
		Else
			Return Not StringInStr($sReg, "Memory")
		EndIf
	EndIf

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

Func _SecureBootCheck($sWinFU = False)

	If $sWinFU Then
		Local $sReg = RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators\" & $sWinFU, "RedReason")
		If @error Then
			Return SetError(1, 0, False)
		Else
			Return Not StringInStr($sReg, "UefiSecureBoot")
		EndIf
	EndIf

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

Func _SpaceCheck($sDrive = Null, $sWinFU = False)

	If $sWinFU Then
		Local $sReg = RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators\" & $sWinFU, "RedReason")
		If @error Then
			Return SetError(1, 0, False)
		Else
			Return Not StringInStr($sReg, "SystemDriveSize")
		EndIf
	EndIf

	Local $iDrives = 0

	Switch $sDrive
		Case -1
			For $iLoop = 0 To 25 Step 1
				If Round(__SpaceCheckPE($iLoop) / 1073741824, 0) >= 60 Then $iDrives += 1
			Next

			If $iDrives >= 1 Then
				Return SetError(-1, $iDrives, True)
			Else
				Return SetError(-1, $iDrives, False)
			EndIf
		Case Null
			$sDrive = EnvGet("SystemDrive")
			ContinueCase
		Case Else
			Local $iFree = Round(DriveSpaceTotal($sDrive) / 1024, 0)
			Local $aDrives = DriveGetDrive($DT_FIXED)

			For $iLoop = 1 To $aDrives[0] Step 1
				If Round(DriveSpaceTotal($aDrives[$iLoop]) / 1024, 0) >= 60 Then $iDrives += 1
			Next

			If $iFree >= 64 Then
				Return SetError($iFree, $iDrives, True)
			Else
				Return SetError($iFree, $iDrives, False)
			EndIf
	EndSwitch

EndFunc   ;==>_SpaceCheck

Func __SpaceCheckPE($iDisk)

	Local $sDescriptor = "\\.\PHYSICALDRIVE" & $iDisk
	Local Const $eIOCTL_DISK_GET_LENGTH_INFO = 0x0007405C

	Local $pBuffer = _MemGlobalAlloc(8, $GPTR)
	Local $iBytesReturned = 0
	Local $hFile = _WinAPI_CreateFile($sDescriptor, 2, 2, 2, 8)	; file exists, open for reading, OS file
	If @error Then Return SetError(-1, -1, False)

	Local $aCall = DllCall("kernel32.dll", "int", "DeviceIoControl", _
		"ptr", $hFile, _
		"dword", $eIOCTL_DISK_GET_LENGTH_INFO, _
		'ptr', 0, _
		'dword', 0, _
		'ptr', $pBuffer, _
		'dword', 8, _ 
		"dword*", $iBytesReturned, _
		"ptr", 0)
	Local $bErr = @error

	Local $iDiskSize = -1
	If Not @error And $aCall[0] Then
		Local $aSize = DllCall("msvcrt.dll", "int64:cdecl", "memcpy", _
			"int64*", 0, _
			"ptr", $pBuffer, _
			"int", 8)
		If Not @error Then $iDiskSize = $aSize[1]
	EndIf

	_MemGlobalFree($pBuffer)
	_WinAPI_CloseHandle($hFile)	; generates new @error
	If $bErr Or @error Then Return SetError(-2, -2, False)

	Return $iDiskSize
EndFunc

Func _TPMCheck($sWinFU = False)

	If $sWinFU Then
		Local $sReg = RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators\" & $sWinFU, "RedReason")
		If @error Then
			Return SetError(1, 0, False)
		Else
			Return Not StringInStr($sReg, "Tpm")
		EndIf
	EndIf

	Select
		Case _GetTPMInfo(0) = False
			ContinueCase
		Case _GetTPMInfo(1) = False
			Return SetError(0, 0, False)
		Case _GetTPMInfo(0) = True And _GetTPMInfo(3) <> "OK" And Not IsAdmin()
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
