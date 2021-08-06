#include-once
#include <StringConstants.au3>

Func _GetCPUInfo($iFlag = 0)
	Local Static $sCores
	Local Static $sThreads
	Local Static $vName
	Local Static $sSpeed
	Local Static $sArch
	Local Static $sCPUs
	Local Static $sVersion

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
				$sVersion = $Obj_Item.Version
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
		Case 5
			Return String($sVersion)
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

Func _GetGPUInfo($iFlag = 0)
	Local Static $sName
	Local Static $sMemory

	If Not $sName <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\.\root\cimv2') ;
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_VideoController')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				If $Obj_Item.Name = "Citrix Indirect Display Adapter" Then ContinueLoop
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
