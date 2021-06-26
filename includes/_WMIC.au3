#include-once

#include <StringConstants.au3>

Func _GetCPUInfo($iFlag = 0)
	Local Static $sCores
    Local Static $sThreads
	Local Static $sName
	Local Static $sSpeed
	Local Static $sArch

	If Not $sName <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2');
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_Processor')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sCores = $Obj_Item.NumberOfCores
				$sThreads = $Obj_Item.NumberOfLogicalProcessors
				$sName = $obj_Item.Name
				$sSpeed = $Obj_Item.MaxClockSpeed
				$sArch = $Obj_Item.AddressWidth
			Next
			
			Local $CPUs
			$Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_ComputerSystem')
			For $Obj_Item In $Col_Items
				$sCPUs = $Obj_Item.NumberOfProcessors
			Next
			$sCores *= $CPUs
			$sThreads *= $CPUs
		Else
			Return 0
		EndIf
	EndIf
	Switch $iFlag
		Case 0
			Return String($sCores)
		Case 1
			Return String($sThreads)
		Case 2
			Return StringStripWS(String($sName), $STR_STRIPTRAILING)
		Case 3
			Return String($sSpeed)
		Case 4
			Return Number($sArch)
		Case Else
			Return 0
	EndSwitch
EndFunc

Func _GetTPMInfo($iFlag = 0)
	Local Static $sActivated
    Local Static $sEnabled
	Local Static $sVersion

	If Not $sActivated <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2\Security\MicrosoftTPM');
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_TPM')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sActivated = $Obj_Item.IsActivated_InitialValue
				$sEnabled = $Obj_Item.IsEnabled_InitialValue
				$sVersion = $obj_Item.SpecVersion
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
EndFunc
