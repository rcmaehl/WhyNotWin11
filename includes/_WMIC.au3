#include-once
#include <StringConstants.au3>

Func _GetCPUInfo($iFlag = 0)
	Local Static $sCores
	Local Static $sThreads
	Local Static $vName
	Local Static $sSpeed
	Local Static $sArch
	Local Static $sCPUs

	If Not $vName <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2') ;
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_Processor')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sCores = $Obj_Item.NumberOfCores
				$sThreads = $Obj_Item.NumberOfLogicalProcessors
				$vName = $Obj_Item.Name
				$sSpeed = $Obj_Item.MaxClockSpeed
				$sArch = $Obj_Item.AddressWidth
			Next

			Local $CPUs
			#forceref $CPUs
			$Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_ComputerSystem')
			For $Obj_Item In $Col_Items
				$sCPUs = $Obj_Item.NumberOfProcessors
			Next
			$sCores *= $sCPUs
			$sThreads *= $sCPUs
		Else
			Return 0
		EndIf
	EndIf
	If StringInStr($vName, "@") Then
		$vName = StringSplit($vName, "@", $STR_NOCOUNT)
		$sSpeed = StringRegExpReplace($vName[1], "[^[:digit:]]", "") & "0"
		$vName = $vName[0]
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
		Case Else
			Return 0
	EndSwitch
EndFunc   ;==>_GetCPUInfo

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

	Static $aDiskArray
	Static $aPartitionArray

	; Get WMI data
	If (Not $aDiskArray) Or (Not $aPartitionArray) Then
		; Get disk datat for fixed (internal) disks.
		_GetDiskInfoFromWmi($aDiskArray, $aPartitionArray, $DiskInfoWmi_TableHeader_No, $DiskInfoWmi_DiskType_Fixed)
		If @error = 1 Then Return SetError(1, 1, "Error_WmiFailed")
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
			For $i = 0 To UBound($aDiskArray) - 1 Step 1
				; If windows is bootet from disk...
				If $aDiskArray[$i][11] = "True" Then
					; Return row as only neede row
					Return _ArrayExtract($aDiskArray, $i, $i)
				EndIf
			Next
		Case 4
			; Return information of system (Windows) partition.
			For $i = 0 To UBound($aPartitionArray) - 1 Step 1
				; If windows is bootet from partition...
				If $aPartitionArray[$i][12] = "True" Then
					; Rerturn only neede row
					Return _ArrayExtract($aPartitionArray, $i, $i)
				EndIf
			Next
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
		Local $Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2') ;
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_VideoController')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sName &= $Obj_Item.Name & ", "
				$sMemory = $Obj_Item.AdapterRAM
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

Func _GetTPMInfo($iFlag = 0)
	Local Static $sActivated
	Local Static $sEnabled
	Local Static $sVersion
	Local Static $sName
	Local Static $sPresent
	If IsAdmin() Then
		Local $Obj_WMIService, $Col_Items
		If Not $sActivated <> "" Then
			$Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2\Security\MicrosoftTPM') ;
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
			$Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2') ;
			If (IsObj($Obj_WMIService)) And (Not @error) Then
				$Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_PNPEntity where Service="TPM"')
				For $Obj_Item In $Col_Items
					$sName = $Obj_Item.Name
					$sPresent = $Obj_Item.Present
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
			Case Else
				Return 0
		EndSwitch
	EndIf
EndFunc   ;==>_GetTPMInfo
