#include-once

#include <FileConstants.au3>
#include <WindowsConstants.au3>

Func _CacheTranslations($iMUI)
	_INIUnicode(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang")
	Return IniReadSection(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Strings")
EndFunc

Func _GetDescriptions($iMUI)
	Local $aDescriptions[11]

	$aDescriptions[0] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "Architecture", "The amount of data your CPU and OS can process at once. 32-Bit OS result requires a disk wipe and new Windows 11 install. 32-Bit CPU requires a CPU replacement.")
	$aDescriptions[1] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "Boot", "A method your motherboard uses to load Windows. Legacy results can be fixed on newer motherboards in your BIOS/UEFI settings. Refer to your motherboard manual.")
	$aDescriptions[2] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "CPU Name", "The CPU you have installed in your computer. Compatibility is subject to change. Requires physical replacement on Desktops; Not replaceable on Laptops.")
	$aDescriptions[3] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "CPU Cores", "The number of tasks your CPU can process at once. Requires physical replacement on Desktops; Not replaceable on Laptops.")
	$aDescriptions[4] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "CPU Speed", "The rate that your CPU processes tasks. Requires physical replacement on Desktops; Not replaceable on Laptops.")
	$aDescriptions[5] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "DirectX", "The version of DirectX DDI/Feature Level your card supports. This is separate from DirectX software version. 'DirectX 12 API' cards may fail this check.")
	$aDescriptions[6] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "Disk Type", "The format that your data is stored on your disk. Non-GPT results can be fixed using Microsoft's MBR2GPT tool.")
	$aDescriptions[7] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "RAM", "The amount of fast memory installed in your computer. Physically upgradeable in Desktops; Physically upgradeable in high end Laptops.")
	$aDescriptions[8] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "Secure Boot", "A method your motherboard uses to load Windows. If not detected, can be fixed on newer motherboards in your BIOS/UEFI settings. Refer to your motherboard manual.")
	$aDescriptions[9] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "Storage", "The amount of space for data on your disk. Physically upgradeable in high end Laptops.")
	$aDescriptions[10] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Descriptions", "TPM", "A security module used by Windows. All modern AMD CPUs contain one; Some modern Intel CPUs contain one. Check your BIOS/UEFI settings. Refer to your motherboard manual.")

	For $iLoop = 0 To 10
		$aDescriptions[$iLoop] = StringReplace($aDescriptions[$iLoop], ". ", "." & @CRLF)
		$aDescriptions[$iLoop] = StringReplace($aDescriptions[$iLoop], "; ", ";" & @CRLF)
		$aDescriptions[$iLoop] = StringReplace($aDescriptions[$iLoop], "\n", @CRLF)
	Next

	Return $aDescriptions
EndFunc   ;==>_GetDescriptions

Func _GetFile($sFile, $sFormat = $FO_READ)
	Local Const $hFileOpen = FileOpen($sFile, $sFormat)
	If $hFileOpen = -1 Then
		Return SetError(1, 0, '')
	EndIf
	Local Const $sData = FileRead($hFileOpen)
	FileClose($hFileOpen)
	Return $sData
EndFunc   ;==>_GetFile

Func _GetTranslationCredit()
	Return IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & @MUILang & ".lang", "MetaData", "Translator", "???")
EndFunc   ;==>_GetTranslationCredit

Func _GetTranslationFonts($iMUI)
	Local $aFonts[5] = [8.5, 10, 18, 24, ""]

	$aFonts[0] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Font", "Small", $aFonts[0])
	$aFonts[1] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Font", "Medium", $aFonts[1])
	$aFonts[2] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Font", "Large", $aFonts[2])
	$aFonts[3] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Font", "Extra Large", $aFonts[3])
	$aFonts[4] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Font", "Name", "Arial")

	Return $aFonts
EndFunc   ;==>_GetTranslationFonts

Func _GetTranslationRTL($iMUI)
	Local $sRTL = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "MetaData", "RTL", "False")
	If $sRTL = "True" Then Return $WS_EX_LAYOUTRTL

	Return -1
EndFunc   ;==>_GetTranslationRTL

Func _INIUnicode($sINI)
	If FileExists($sINI) = 0 Then
		Return FileClose(FileOpen($sINI, $FO_OVERWRITE + $FO_UNICODE))
	Else
		Local Const $iEncoding = FileGetEncoding($sINI)
		Local $fReturn = True
		If Not ($iEncoding = $FO_UNICODE) Then
			Local $sData = _GetFile($sINI, $iEncoding)
			If @error Then
				$fReturn = False
			EndIf
			_SetFile($sData, $sINI, $FO_APPEND + $FO_UNICODE)
		EndIf
		Return $fReturn
	EndIf
EndFunc   ;==>_INIUnicode

Func _SetFile($sString, $sFile, $iOverwrite = $FO_READ)
	Local Const $hFileOpen = FileOpen($sFile, $iOverwrite + $FO_APPEND)
	FileWrite($hFileOpen, $sString)
	FileClose($hFileOpen)
	If @error Then
		Return SetError(1, 0, False)
	EndIf
	Return True
EndFunc   ;==>_SetFile

Func _Translate($iMUI, $sString)
	Local $sReturn
	_INIUnicode(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang")
	$sReturn = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Strings", $sString, $sString)
	$sReturn = StringReplace($sReturn, "\n", @CRLF)
	Return $sReturn
EndFunc   ;==>_Translate
