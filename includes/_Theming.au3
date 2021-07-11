;######################################################################################################################################
; #FUNCTION# ====================================================================================================================
; Name ..........: _GDIPlus_GraphicsGetDPIRatio
; Description ...:
; Syntax ........: _GDIPlus_GraphicsGetDPIRatio([$iDPIDef = 96])
; Parameters ....: $iDPIDef             - [optional] An integer value. Default is 96.
; Return values .: None
; Author ........: UEZ
; Modified ......:
; Remarks .......:
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

Func _SetBkIcon($ControlID, $iBackground, $sIcon, $iIndex, $iWidth, $iHeight)

	Local Static $STM_SETIMAGE = 0x0172
	Local $hDC, $hBackDC, $hBackSv, $hBitmap, $hImage, $hIcon, $hBkIcon

	$hIcon = _WinAPI_ShellExtractIcon($sIcon, $iIndex, $iWidth, $iHeight)

	$hDC = _WinAPI_GetDC(0)
	$hBackDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBitmap = _WinAPI_CreateSolidBitmap(0, $iBackground, $iWidth, $iHeight)
	$hBackSv = _WinAPI_SelectObject($hBackDC, $hBitmap)
	_WinAPI_DrawIconEx($hBackDC, 0, 0, $hIcon, 0, 0, 0, 0, $DI_NORMAL)

	$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	$hBkIcon = DllCall($__g_hGDIPDll, 'int', 'GdipCreateHICONFromBitmap', 'hWnd', $hImage, 'int*', 0)
	$hBkIcon = $hBkIcon[2]
	_GDIPlus_ImageDispose($hImage)

	GUICtrlSendMsg($ControlID, $STM_SETIMAGE, $IMAGE_ICON, _WinAPI_CopyIcon($hBkIcon))
	_WinAPI_RedrawWindow(GUICtrlGetHandle($ControlID))

	_WinAPI_SelectObject($hBackDC, $hBackSv)
	_WinAPI_DeleteDC($hBackDC)
	_WinAPI_ReleaseDC(0, $hDC)
	_WinAPI_DeleteObject($hBkIcon)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteObject($hIcon)

	Return SetError(0, 0, 1)
EndFunc   ;==>_SetBkIcon

Func _SetBkSelfIcon($ControlID, $iBackground, $sIcon, $iIndex, $iWidth, $iHeight)

	Local Static $STM_SETIMAGE = 0x0172
	Local $hDC, $hBackDC, $hBackSv, $hBitmap, $hImage, $hIcon, $hBkIcon

	$hIcon = _Resource_GetAsIcon($iIndex, "RC_DATA", $sIcon)

	$hDC = _WinAPI_GetDC(0)
	$hBackDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBitmap = _WinAPI_CreateSolidBitmap(0, $iBackground, $iWidth, $iHeight)
	$hBackSv = _WinAPI_SelectObject($hBackDC, $hBitmap)
	_WinAPI_DrawIconEx($hBackDC, 0, 0, $hIcon, 0, 0, 0, 0, $DI_NORMAL)

	$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	$hBkIcon = DllCall($__g_hGDIPDll, 'int', 'GdipCreateHICONFromBitmap', 'hWnd', $hImage, 'int*', 0)
	$hBkIcon = $hBkIcon[2]
	_GDIPlus_ImageDispose($hImage)

	GUICtrlSendMsg($ControlID, $STM_SETIMAGE, $IMAGE_ICON, _WinAPI_CopyIcon($hBkIcon))
	_WinAPI_RedrawWindow(GUICtrlGetHandle($ControlID))

	_WinAPI_SelectObject($hBackDC, $hBackSv)
	_WinAPI_DeleteDC($hBackDC)
	_WinAPI_ReleaseDC(0, $hDC)
	_WinAPI_DeleteObject($hBkIcon)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteObject($hIcon)

	Return SetError(0, 0, 1)
EndFunc   ;==>_SetBkSelfIcon

Func _SetTheme()
	Local $aColors[4]

	Local $dText = _WinAPI_GetSysColor($COLOR_WINDOWTEXT)
	Local $dWindow = _WinAPI_GetSysColor($COLOR_WINDOW)
	Local $bLTheme = RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
	If @error Then $bLTheme = True

	$aColors[0] = 0xF8F8F8 ; Backgrounds
	$aColors[1] = $dText ;Text
	$aColors[2] = 0xE6E6E6 ; Sidebar
	$aColors[3] = 0xF2F2F2 ; Footer

	Select
		Case FileExists(@ScriptDir & "\theme.def")
			$aColors[0] = IniRead(@ScriptDir & "\theme.def", "Colors", "Background", $aColors[0])
			$aColors[1] = IniRead(@ScriptDir & "\theme.def", "Colors", "Text", $aColors[1])
			$aColors[2] = IniRead(@ScriptDir & "\theme.def", "Colors", "Sidebar", $aColors[2])
			$aColors[3] = IniRead(@ScriptDir & "\theme.def", "Colors", "Footer", $aColors[3])
		Case $dWindow = 0x000000
			ContinueCase
		Case $dWindow = 0xFFFFFF And Not $bLTheme
			$aColors[0] = 0x070707
			$aColors[1] = 0xFFFFFF
			$aColors[2] = 0x191919
			$aColors[3] = 0x0D0D0D
		Case 0xFFFFFF > $dWindow > 0x000000
			$aColors[0] = $dWindow + 0xF8F8F9
			$aColors[1] = $dText
			$aColors[2] = $dWindow + 0xE6E6E7
			$aColors[3] = $dWindow + 0xF2F2F3
		Case $bLTheme
			;;;
		Case Else
			;;;
	EndSelect
	Return $aColors
EndFunc   ;==>_SetTheme