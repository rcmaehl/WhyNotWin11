#include-once

#include <FileConstants.au3>

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
	Local $aFonts[4] = [8.5, 10, 18, 24]

	$aFonts[0] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Font", "Small", $aFonts[0])
	$aFonts[1] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Font", "Medium", $aFonts[1])
	$aFonts[2] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Font", "Large", $aFonts[2])
	$aFonts[3] = IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Font", "Extra Large", $aFonts[3])

	Return $aFonts
EndFunc   ;==>_GetTranslationFonts

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
	_INIUnicode(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang")
	Return IniRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & $iMUI & ".lang", "Strings", $sString, $sString)
EndFunc   ;==>_Translate