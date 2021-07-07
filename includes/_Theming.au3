Func _CheckAppsUseLightTheme()
	Local $sUseLightTheme = RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
	If @error Then
		$sUseLightTheme = "1"
	EndIf
	Return Int($sUseLightTheme)
EndFunc   ;==>_CheckAppsUseLightTheme

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

Func _HighContrast($sColor)
	Local Static $sSysWin

	If Not $sSysWin <> "" Then $sSysWin = _WinAPI_GetSysColor($COLOR_WINDOW)

	Select
		Case $sSysWin = 0
			ContinueCase
		Case $sSysWin = 16777215 And Not _CheckAppsUseLightTheme()
			Return 16777215 - $sColor
		Case Else
			Return $sSysWin + $sColor + 1
	EndSelect

EndFunc   ;==>_HighContrast

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