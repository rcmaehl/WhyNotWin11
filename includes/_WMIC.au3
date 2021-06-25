#include-once

#include <StringConstants.au3>

Func _GetCPUInfo($iFlag = 0)
	Local Static $sCores
    Local Static $sThreads
	Local Static $sName

	If Not $sName <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2');
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_Processor')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sCores = $Obj_Item.NumberOfCores
				$sThreads = $Obj_Item.NumberOfLogicalProcessors
				$sName = $obj_Item.Name
				$sSocket = $Obj_Item.SocketDesignation
			Next
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
			Return StringStripWS(String($sSocket), $STR_STRIPTRAILING)
		Case Else
			Return 0
	EndSwitch
EndFunc

Func _GetGPUInfo($iFlag = 0)
    Local Static $sName
	Local Static $sMemory

	If Not $sName <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2');
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_VideoController')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sName &= $Obj_Item.Name & @CRLF
				$sMemory = $obj_Item.AdapterRAM
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
EndFunc

Func _GetMotherboardInfo($iFlag = 0)
    Local Static $sProduct
    Local Static $sManufacturer

	If Not $sProduct <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2');
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_BaseBoard')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sProduct = $Obj_Item.Product
				$sManufacturer = $Obj_Item.Manufacturer
			Next
		Else
			Return 0
		EndIf
	EndIf
	Switch $iFlag
		Case 0
			Return StringStripWS(String($sManufacturer), $STR_STRIPTRAILING)
		Case 1
			Return StringStripWS(String($sProduct), $STR_STRIPTRAILING)
		Case Else
			Return 0
	EndSwitch
EndFunc

Func _GetOSInfo($iFlag = 0)
	Local Static $sArch
    Local Static $sName
	Local Static $sLocale

	If Not $sArch <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2');
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_OperatingSystem')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sArch = $Obj_Item.OSArchitecture
				$sName = $Obj_Item.Name
				$sLocale = $Obj_Item.Locale
			Next
		Else
			Return 0
		EndIf
	EndIf
	Switch $iFlag
		Case 0
			Return String(StringSplit($sName, "|", $STR_NOCOUNT)[0])
		Case 1
			Return String($sArch)
		Case 2
			Return String($sLocale)
		Case Else
			Return 0
	EndSwitch
EndFunc

Func _GetRAMInfo($iFlag = 0)
    Local Static $sSpeed

	If Not $sSpeed <> "" Then
		Local $Obj_WMIService = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2');
		If (IsObj($Obj_WMIService)) And (Not @error) Then
			Local $Col_Items = $Obj_WMIService.ExecQuery('Select * from Win32_PhysicalMemory')

			Local $Obj_Item
			For $Obj_Item In $Col_Items
				$sSpeed = $Obj_Item.Speed
			Next
		Else
			Return 0
		EndIf
	EndIf
	Switch $iFlag
		Case 0
			Return String($sSpeed)
		Case Else
			Return 0
	EndSwitch
EndFunc
