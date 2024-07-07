#include-once

#include <Array.au3>
#include <StringConstants.au3>

#include "GetDiskInfo.au3"

Func _GetBIOSInfo($iFlag = 0)
	Local Static $sSMBIOSBIOSVersion

	If Not $sSMBIOSBIOSVersion <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\.\root\cimv2') ;
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_BIOS')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sSMBIOSBIOSVersion = $Obj_Item.SMBIOSBIOSVersion
			Next
		Else
			Return 0
		EndIf
	EndIf
	Switch $iFlag
		Case 0
			Return StringStripWS(String($sSMBIOSBIOSVersion), $STR_STRIPTRAILING)
		Case Else
			Return 0
	EndSwitch		
EndFunc   ;==>_GetBIOSInfo

Func _GetCPUInfo($iFlag = 0)
	Local Static $sCores
	Local Static $sThreads
	Local Static $vName
	Local Static $sSpeed
	Local Static $sArch
	Local Static $sCPUs
	Local Static $sVersion
	Local Static $sFamily

	If Not $vName <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\.\root\cimv2') ;
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_Processor')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sCores = $Obj_Item.NumberOfCores
				$sThreads = $Obj_Item.NumberOfLogicalProcessors
				$vName = $Obj_Item.Name
				$sSpeed = $Obj_Item.MaxClockSpeed
				$sArch = $Obj_Item.AddressWidth
				$sVersion = $Obj_Item.Caption
				$sFamily = $Obj_Item.Caption
			Next

			$Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_ComputerSystem')
			For $Obj_Item In $Col_Items
				$sCPUs = $Obj_Item.NumberOfProcessors
			Next
			$sCores *= $sCPUs
			$sThreads *= $sCPUs
		Else
			Return 0
		EndIf
		If StringInStr($vName, "@") Then
			$vName = StringSplit($vName, "@", $STR_NOCOUNT)
			$sSpeed = StringRegExpReplace($vName[1], "[^[:digit:]]", "") & "0"
			$vName = $vName[0]
		EndIf
		If StringRegExp($sFamily, "[^0-9]") Then
				$sFamily = StringRegExp($sFamily, "Family\s\d+\sModel", $STR_REGEXPARRAYMATCH)[0]
				$sFamily = StringRegExpReplace($sFamily, "[^0-9]", "")
		EndIf
	EndIf
	Switch $iFlag
		Case 0
			Return String($sCores)
		Case 1
			Return String($sThreads)
		Case 2
			Return StringStripWS(String($vName), $STR_STRIPTRAILING)
		Case 3
			Return Number($sSpeed)
		Case 4
			Return Number($sArch)
		Case 5
			Return String($sVersion)
		Case 6
			Return $sFamily
		Case Else
			Return 0
	EndSwitch
EndFunc   ;==>_GetCPUInfo

Func _GetDiskInfo($iFlag = 0)
	Local Static $sType
	Local Static $aDisks[2]

	If Not $sType <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\.\root\cimv2') ;
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_DiskPartition where BootPartition=True')

			$aDisks[0] = 0
			$aDisks[1] = 0
			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$aDisks[0] += 1
				$sType = $Obj_Item.Type
				If StringLeft($sType, 3) = "GPT" Then $aDisks[1] += 1
			Next
			If $aDisks[0] > 0 Then $sType = "GPT"
		Else
			$aDisks[0] = 0
			$aDisks[1] = "?"
			Return $aDisks
		EndIf
	EndIf
	Switch $iFlag
		Case 0
			Return StringLeft($sType, 3)
		Case 1
			Return $aDisks
		Case Else
			Return 0
	EndSwitch
EndFunc   ;==>_GetDiskInfo

Func _GetDiskProperties($iFlag = 0)
	; Desc ......... : Call _GetDiskInfoFromWmi() to get the disk and partition informations. The selected information will be returned.
	; Parameters ... : $iFlag = 0 => Init WMI data.
	; .............. : $iFlag = 1 => Return array with disk information.
	; .............. : $iFlag = 2 => Return array with partition information.
	; .............. : $iFlag = 3 => Return information of disk with system (Windows) partition.
	; .............. : $iFlag = 4 => Return information of system (Windows) partition.
	; On error ..... : Return SetError(1, 1, "Error_WmiFailed"), if WMI failed.
	; .............. : Return SetError(1, 2, "Error_IncorrectFlag"), if $iFlag is unknown.
	; .............. : Return SetError(1, 3, "Error_NoDataReturned"), if not data can be returned.

	Local Static $aDiskArray
	Local Static $aPartitionArray
	Local Static $aSysDisk
	Local Static $aSysPartition

	#forcedef $DiskInfoWmi_TableHeader_No
	#forcedef $DiskInfoWmi_DiskType_Fixed

	; Get WMI data
	If ($aDiskArray = "") Or ($aPartitionArray = "") Then
		; Get disk datat for fixed (internal) disks.
		_GetDiskInfoFromWmi($aDiskArray, $aPartitionArray, $DiskInfoWmi_TableHeader_No, $DiskInfoWmi_DiskType_Fixed)
		If @error = 1 Then Return SetError(1, 1, "Error_WmiFailed")
	EndIf

	; Get sys disk and sys partition num
	If ($aSysDisk = "") Or ($aSysPartition = "") Then
		Local $iSysDisk = _ArraySearch($aDiskArray, "True", 0, 0, 0, 0, 1, 11) ; Row 11 = IsSysDisk
		$aSysDisk = _ArrayExtract($aDiskArray, $iSysDisk, $iSysDisk)
		Local $iSysPartition = _ArraySearch($aPartitionArray, "True", 0, 0, 0, 0, 1, 12) ; Row 12 = IsSysPartition
		$aSysPartition = _ArrayExtract($aPartitionArray, $iSysPartition, $iSysPartition)
	EndIf

	; Return data based on $iFlag or exit function
	Switch $iFlag
		Case 0
			; Exit function after init WMI data
			Return
		Case 1
			; Return array with disk information.
			Return $aDiskArray
		Case 2
			; Return array with partition information.
			Return $aPartitionArray
		Case 3
			; Return information of disk with system (Windows) partition.
			Return $aSysDisk
		Case 4
			; Return information of system (Windows) partition.
			Return $aSysPartition
		Case Else
			; If $iFlag was incorrect...
			Return SetError(1, 2, "Error_IncorrectFlag")
	EndSwitch

	; If no data returned before...
	SetError(1, 3, "Error_NoDataReturned")
EndFunc   ;==>_GetDiskProperties

Func _GetGPUInfo($iFlag = 0)
	Local Static $sName
	Local Static $sMemory

	If Not $sName <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\.\root\cimv2') ;
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_VideoController')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				Switch $Obj_Item.Name
					Case "Citrix Indirect Display Adapter"
						ContinueCase
					Case "DisplayLink USB Device"
						ContinueCase
					Case "Microsoft Remote Display Adapter"
						ContinueLoop
					Case Else
						$sName &= $Obj_Item.Name & ", "
						$sMemory = $Obj_Item.AdapterRAM
				EndSwitch
			Next
		Else
			Return 0
		EndIf
	EndIf
	Switch $iFlag
		Case 0
			Return StringTrimRight(String($sName), 2)
		Case 1
			Return StringStripWS(String($sMemory), $STR_STRIPTRAILING)
		Case Else
			Return 0
	EndSwitch
EndFunc   ;==>_GetGPUInfo

Func _GetMotherboardInfo($iFlag = 0)
	Local Static $sManufacturer
	Local Static $sProduct

	If Not $sManufacturer <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\.\root\cimv2') ;
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_Baseboard')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sManufacturer = $Obj_Item.Manufacturer
				$sProduct = $Obj_Item.Product
			Next
		Else
			Return 0
		EndIf
		Switch $sManufacturer
			Case "ASUSTek COMPUTER INC."
				$sManufacturer = "ASUS"
			Case "Gigabyte Technology Co., Ltd"
				$sManufacturer = "Gigabyte"
			Case "Microsoft Corporation"
				$sManufacturer = "Microsoft"
			Case "Micro-Star International Co., Ltd."
				$sManufacturer = "MSI"
			Case "Oracle Corporation"
				$sManufacturer = "Oracle"
			Case Else
				;;;
		EndSwitch
	EndIf
	Switch $iFlag
		Case 0
			Return String($sManufacturer)
		Case 1
			Return String($sProduct)
		Case Else
			Return 0
	EndSwitch
EndFunc

Func _GetTPMInfo($iFlag = 0)
	Local Static $sActivated
	Local Static $sEnabled
	Local Static $sVersion
	Local Static $sName
	Local Static $sPresent
	Local Static $sStatus
	If IsAdmin() Then
		Local $Obj_WMIService, $Col_Items
		If Not $sActivated <> "" Then
			$Obj_WMIService = ObjGet('winmgmts:\\.\root\cimv2\Security\MicrosoftTPM') ;
			If (IsObj($Obj_WMIService)) And (Not @error) Then
				$Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_TPM')
				For $Obj_Item In $Col_Items
					$sActivated = $Obj_Item.IsActivated_InitialValue
					$sEnabled = $Obj_Item.IsEnabled_InitialValue
					$sVersion = $Obj_Item.SpecVersion
				Next
			Else
				Return 0
			EndIf
		EndIf
		Switch $iFlag
			Case 0
				Return String($sActivated)
			Case 1
				Return String($sEnabled)
			Case 2
				Return String($sVersion)
			Case Else
				Return 0
		EndSwitch
	Else
		If Not $sPresent <> "" Then
			$Obj_WMIService = ObjGet('winmgmts:\\.\root\cimv2') ;
			If (IsObj($Obj_WMIService)) And (Not @error) Then
				$Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_PNPEntity where Service="TPM"')
				For $Obj_Item In $Col_Items
					$sName = $Obj_Item.Name
					$sPresent = $Obj_Item.Present
					$sStatus = $Obj_Item.Status
				Next
			Else
				Return 0
			EndIf
		EndIf
		Switch $iFlag
			Case 0
				ContinueCase
			Case 1
				If $sName <> "" Then Return 1
			Case 2
				Return StringRegExp($sName, "\d+\.\d+", $STR_REGEXPARRAYMATCH)[0]
			Case 3
				Return $sStatus
			Case Else
				Return 0
		EndSwitch
	EndIf
EndFunc   ;==>_GetTPMInfo
