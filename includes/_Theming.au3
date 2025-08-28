#include-once

#include <Array.au3>
#include <GDIPlus.au3>
#include <WinAPISysWin.au3>
#include <WinAPIShellEx.au3>
#include <WindowsConstants.au3>

#include "ResourcesEX.au3"

Global Const $GDIP_COLORCURVEEFFECT = "{DD6A0022-58E4-4a67-9D9B-D48EB881A53D}"
Global Const $tagCOLORCURVEEFFECTPARAMS = "int type;int channel;int value"

Global Enum $iAdjustExposure = 0, $iAdjustDensity, $iAdjustContrast, $iAdjustHighlight, $iAdjustShadow, _ ;http://msdn.microsoft.com/en-us/library/windows/desktop/ms534098(v=vs.85).aspx
		$iAdjustMidtone, $iAdjustWhiteSaturation, $iAdjustBlackSaturation
Global Enum $iCurveChannelAll = 0, $iCurveChannelRed, $iCurveChannelGreen, $iCurveChannelBlue ;http://msdn.microsoft.com/en-us/library/windows/desktop/ms534100(v=vs.85).aspx
Global $tColorCurve = DllStructCreate($tagCOLORCURVEEFFECTPARAMS), $iType = $iAdjustExposure, $iChannel = $iCurveChannelAll

;######################################################################################################################################
; #FUNCTION# ====================================================================================================================
; Name ..........: _GDIPlus_GraphicsGetDPIRatio
; Description ...:
; Syntax ........: _GDIPlus_GraphicsGetDPIRatio([$iDPIDef = 96])
; Parameters ....: $iDPIDef             - [optional] An integer value. Default is 96.
; Return values .: None
; Author ........: UEZ
; Modified ......:
; Remarks .......: Requires #AutoIt3Wrapper_Res_HiDpi=Y
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/159612-dpi-resolution-problem/?hl=%2Bdpi#entry1158317
; Example .......: No
; ===============================================================================================================================
Func _GDIPlus_GraphicsGetDPIRatio($iDPIDef = 96)
	_GDIPlus_Startup()
	Local $hGfx = _GDIPlus_GraphicsCreateFromHWND(0)
	If @error Then Return SetError(1, @extended, 0)
	#forcedef $__g_hGDIPDll

	Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipGetDpiX", "handle", $hGfx, "float*", 0)

	If @error Then Return SetError(2, @extended, 0)
	Local $iDPI = $aResult[2]
	Local $aResults[2] = [$iDPIDef / $iDPI, $iDPI / $iDPIDef]
	_GDIPlus_GraphicsDispose($hGfx)
	_GDIPlus_Shutdown()
	Return $aResults
EndFunc   ;==>_GDIPlus_GraphicsGetDPIRatio

Func _GDIPlus_ColorCurve($tColorCurve, $iType, $iChannel, $iValue)
	If Not IsDllStruct($tColorCurve) Then Return SetError(1, @error, 0)
	DllStructSetData($tColorCurve, "type", $iType)
	DllStructSetData($tColorCurve, "channel", $iChannel)
	DllStructSetData($tColorCurve, "value", $iValue)
	Local $pEffect = _GDIPlus_EffectCreate($GDIP_COLORCURVEEFFECT)
	If @error Then Return SetError(2, @error, 0)
	_GDIPlus_EffectsSetParameters($pEffect, $tColorCurve)
	If @error Then Return SetError(3, @error, 0)
	Return $pEffect
EndFunc   ;==>_GDIPlus_ColorCurve

Func _GDIPlus_EffectsSetParameters($pEffectObject, $tEffectParameters, $iSizeAdj = 1)
	Local $aSize = DllCall($__g_hGDIPDll, "uint", "GdipGetEffectParameterSize", "ptr", $pEffectObject, "uint*", 0)
	Local $iSize = $aSize[2] * $iSizeAdj
	Local $aResult = DllCall($__g_hGDIPDll, "uint", "GdipSetEffectParameters", "ptr", $pEffectObject, "struct*", $tEffectParameters, "uint", $iSize)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetError($aResult[0], 0, $aResult[3])
EndFunc   ;==>_GDIPlus_EffectsSetParameters

Func _SetBkIcon($ControlID, $sIcon, $iIndex, $iWidth, $iHeight)

    Local Static $STM_SETIMAGE = 0x0172
    Local $hBitmap, $hImage, $hIcon

    $hIcon = _WinAPI_ShellExtractIcon($sIcon, $iIndex, $iWidth, $iHeight)
    $hBitmap = _GDIPlus_BitmapCreateFromHICON32($hIcon)
	$hImage = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)

	_WinAPI_DeleteObject(GUICtrlSendMsg($ControlID, $STM_SETIMAGE, $IMAGE_BITMAP, $hImage))
EndFunc

#cs
Func _SetBkIcon($ControlID, $iForeground, $iBackground, $sIcon, $iIndex, $iWidth, $iHeight)

    Local Static $STM_SETIMAGE = 0x0172
    Local $hBitmap, $hGfx, $hImage, $hIcon, $hBkIcon

    $hIcon = _WinAPI_ShellExtractIcon($sIcon, $iIndex, $iWidth, $iHeight)
    $hImage = _GDIPlus_BitmapCreateFromHICON32($hIcon)

    Local $r = BitShift(BitAND($iForeground, 0xFF0000), 16), $g = BitShift(BitAND($iForeground, 0xFF00), 8), $b = BitAND($iForeground, 0xFF)
    Local $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelRed, $r) ;GDI+ v1.1 is needed -> Win7+
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)
    $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelGreen, $g)
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)
    $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelBlue, $b)
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)

	$iBackground = "0x00" & Hex($iBackground, 6)
	$hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
	$hGfx = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsClear($hGfx, $iBackground)
	_GDIPlus_GraphicsDrawImageRect($hGfx, $hImage, 0, 0, $iWidth, $iHeight)
	_GDIPlus_ImageDispose($hImage)
	$hImage = _GDIPlus_ImageClone($hBitmap)
	_GDIPlus_GraphicsDispose($hGfx)
	_GDIPlus_ImageDispose($hBitmap)

    $hBkIcon = _GDIPlus_HICONCreateFromBitmap($hImage)
    GUICtrlSendMsg($ControlID, $STM_SETIMAGE, $IMAGE_ICON, $hBkIcon)
    _WinAPI_RedrawWindow(GUICtrlGetHandle($ControlID))

    _WinAPI_DeleteObject($hIcon)
    _WinAPI_DeleteObject($hBkIcon)
    _GDIPlus_ImageDispose($hImage)
    Return SetError(0, 0, 1)
EndFunc   ;==>_SetBkIcon
#ce

Func _SetBkSelfIcon($ControlID, $sIcon, $iIndex)

	Local Static $STM_SETIMAGE = 0x0172
	Local $hBitmap, $hImage, $hIcon

	$hIcon = _Resource_GetAsIcon($iIndex, "RC_DATA", $sIcon)
	$hBitmap = _GDIPlus_BitmapCreateFromHICON32($hIcon)
	$hImage = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)

	_WinAPI_DeleteObject(GUICtrlSendMsg($ControlID, $STM_SETIMAGE, $IMAGE_BITMAP, $hImage))

EndFunc

#cs
Func _SetBkSelfIcon($ControlID, $iForeground, $iBackground, $sIcon, $iIndex, $iWidth, $iHeight)

    Local Static $STM_SETIMAGE = 0x0172
    Local $hBitmap, $hGfx, $hImage, $hIcon, $hBkIcon

	$hIcon = _Resource_GetAsIcon($iIndex, "RC_DATA", $sIcon)
	$hImage = _GDIPlus_BitmapCreateFromHICON32($hIcon)

    Local $r = BitShift(BitAND($iForeground, 0xFF0000), 16), $g = BitShift(BitAND($iForeground, 0xFF00), 8), $b = BitAND($iForeground, 0xFF)
    Local $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelRed, $r) ;GDI+ v1.1 is needed -> Win7+
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)
    $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelGreen, $g)
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)
    $hEffect = _GDIPlus_EffectCreateColorCurve($GDIP_AdjustExposure, $GDIP_CurveChannelBlue, $b)
    _GDIPlus_BitmapApplyEffect($hImage, $hEffect)
    _GDIPlus_EffectDispose($hEffect)

    If $iBackground Then
		$iBackground = "0xFF" & Hex($iBackground, 6)
        $hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
        $hGfx = _GDIPlus_ImageGetGraphicsContext($hBitmap)
        _GDIPlus_GraphicsClear($hGfx, $iBackground)
        _GDIPlus_GraphicsDrawImageRect($hGfx, $hImage, 0, 0, $iWidth, $iHeight)
        _GDIPlus_ImageDispose($hImage)
        $hImage = _GDIPlus_ImageClone($hBitmap)
        _GDIPlus_GraphicsDispose($hGfx)
        _GDIPlus_ImageDispose($hBitmap)
    EndIf

    $hBkIcon = _GDIPlus_HICONCreateFromBitmap($hImage)
    GUICtrlSendMsg($ControlID, $STM_SETIMAGE, $IMAGE_ICON, $hBkIcon)
    _WinAPI_RedrawWindow(GUICtrlGetHandle($ControlID))

    _WinAPI_DeleteObject($hIcon)
    _WinAPI_DeleteObject($hBkIcon)
    _GDIPlus_ImageDispose($hImage)
    Return SetError(0, 0, 1)
EndFunc   ;==>_SetBkSelfIcon
#ce

Func _SetTheme($sName = False)

	Local $aTheme[3]
	
	Local $sVer
	Local $dText = _WinAPI_GetSysColor($COLOR_WINDOWTEXT)
	Local $sFile = @ScriptDir & "\theme.def"
	Local $dWindow = _WinAPI_GetSysColor($COLOR_WINDOW)
	Local $bLTheme = RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
	If @error Then $bLTheme = True

	If $dWindow = 0x000000 Or ($dWindow = 0xFFFFFF And Not $bLTheme) Then
		$dText = 0xFFFFFF
		Local $aBgColors[5] = [0x070707, 0x191919, 0x0D0D0D, 0x070707, 0x070707] ; Background, Sidebar, Footer, Results, Settings
	Else
		Local $aBgColors[5] = [0xF8F8F8, 0xE6E6E6, 0xF2F2F2, 0xF8F8F8, 0xF8F8F8] ; Background, Sidebar, Footer, Results, Settings
	EndIf

	Local $aTxtColors[9] = [$dText, $dText, $dText, $dText, $dText, 0xADD8E6, $dText, $dText, $dText] ; Main, Name, Version, Header, Footer, Links, Checks, Results, Settings
	Local $aBgFiles[3] = [False, False, False] ; Sidebar, Background, Footer
		
	If $sName Then $sFile = @ScriptDir & "\" & $sName
	ClipPut($sFile)

	Select
		Case FileExists($sFile)
			$sVer = IniRead($sFile, "MetaData", "Version", "1")
			Switch Int($sVer)
				Case 1
					$aBgColors[0] = IniRead($sFile, "Colors", "Background", $aBgColors[0])
					$aBgColors[1] = IniRead($sFile, "Colors", "Sidebar", $aBgColors[1])
					$aBgColors[2] = IniRead($sFile, "Colors", "Footer", $aBgColors[2])
					$aBgColors[3] = IniRead($sFile, "Colors", "Background", $aBgColors[3])
					$aBgColors[4] = IniRead($sFile, "Colors", "Background", $aBgColors[4])
					$aTxtColors[0] = IniRead($sFile, "Colors", "Text", $aTxtColors[0])
					$aTxtColors[1] = IniRead($sFile, "Colors", "Text", $aTxtColors[0])
					$aTxtColors[2] = IniRead($sFile, "Colors", "Text", $aTxtColors[0])
					$aTxtColors[3] = IniRead($sFile, "Colors", "Text", $aTxtColors[0])
					$aTxtColors[4] = IniRead($sFile, "Colors", "Text", $aTxtColors[0])
					$aTxtColors[5] = IniRead($sFile, "Colors", "Text", $aTxtColors[0])
					$aTxtColors[6] = IniRead($sFile, "Colors", "Text", $aTxtColors[0])
					$aTxtColors[7] = IniRead($sFile, "Colors", "Text", $aTxtColors[0])
					$aTxtColors[8] = IniRead($sFile, "Colors", "Text", $aTxtColors[0])
				Case 2
					$aBgColors[0] = IniRead($sFile, "Backgrounds", "Main", $aBgColors[0])
					$aBgColors[1] = IniRead($sFile, "Backgrounds", "Sidebar", $aBgColors[1])
					$aBgColors[2] = IniRead($sFile, "Backgrounds", "Footer", $aBgColors[2])
					$aBgColors[3] = IniRead($sFile, "Backgrounds", "Results", $aBgColors[3])
					$aBgColors[4] = IniRead($sFile, "Backgrounds", "Settings", $aBgColors[4])
					$aTxtColors[0] = IniRead($sFile, "Text", "Main", $aTxtColors[0])
					$aTxtColors[1] = IniRead($sFile, "Text", "Name", $aTxtColors[1])
					$aTxtColors[2] = IniRead($sFile, "Text", "Version", $aTxtColors[2])
					$aTxtColors[3] = IniRead($sFile, "Text", "Header", $aTxtColors[3])
					$aTxtColors[4] = IniRead($sFile, "Text", "Footer", $aTxtColors[4])
					$aTxtColors[5] = IniRead($sFile, "Text", "Links", $aTxtColors[5])
					$aTxtColors[6] = IniRead($sFile, "Text", "Checks", $aTxtColors[6])
					$aTxtColors[7] = IniRead($sFile, "Text", "Results", $aTxtColors[7])
					$aTxtColors[8] = IniRead($sFile, "Text", "Settings", $aTxtColors[8])
					$aBgFiles[0] = IniRead($sFile, "Files", "Sidebar", $aBgFiles[0])
					$aBgFiles[1] = IniRead($sFile, "Files", "Background", $aBgFiles[1])
					$aBgFiles[2] = IniRead($sFile, "Files", "Footer", $aBgFiles[2])		
				Case Else
					;;;
			EndSwitch					
		;Case 0xFFFFFF > $dWindow > 0x000000 ; Custom Window Color...
			;$aColors[0] = $dWindow + 0xF8F8F8
			;$aColors[1] = $dText
			;$aColors[2] = $dWindow + 0xE6E6E6
			;$aColors[3] = $dWindow + 0xF2F2F2
		Case $bLTheme
			; Use Default Colors
		Case Else
			;;;
	EndSelect

	$aTheme[0] = $aBgColors
	$aTheme[1] = $aTxtColors
	$aTheme[2] = $aBgFiles

	Return $aTheme
EndFunc   ;==>_SetTheme

Func _WinAPI_DwmSetWindowAttributeExt($hWnd, $iAttribute, $iData)
    Switch $iAttribute
        Case 2, 3, 4, 6, 7, 8, 10, 11, 12, 33

        Case Else
            Return SetError(1, 0, 0)
    EndSwitch

    Local $aCall = DllCall('dwmapi.dll', 'long', 'DwmSetWindowAttribute', 'hwnd', $hWnd, 'dword', $iAttribute, _
            'dword*', $iData, 'dword', 4)
    If @error Then Return SetError(@error, @extended, 0)
    If $aCall[0] Then Return SetError(10, $aCall[0], 0)

    Return 1
EndFunc   ;==>_WinAPI_DwmSetWindowAttributeExt