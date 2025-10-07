#include-once
#include <GUIConstants.au3>
#include <WinAPISysWin.au3>
#include <WinAPIShellEx.au3>
#include <Misc.au3>

; #DESCRIPTION# =================================================================================================================
; Title .........: Round GUI UDF
; AutoIt Version : 3.3.16.1
; Language ..... : English
; Description ...: Functions to create GUI controls with round corners
; Author ........: Nine
; Date ..........: 2025-03-15
; Modified ......: 2025-04-06
; Example .......; Yes
; ===============================================================================================================================

; #FUNCTIONS# ===================================================================================================================
; _RGUI_RoundLabel($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner, $bDrag = False)
; _RGUI_RoundButton($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner)
; _RGUI_RoundInput($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner, $iMargin, $iFlags = -1)
; _RGUI_RoundEdit($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner, $iMargin, $iFlags = -1)
; _RGUI_RoundGroup($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner, $iMargin)
; _RGUI_RoundScrollBar($iLeft, $iTop, $iSize, $nColor, $fCall, $idCtrl = 0)
; _RGUI_ScrollBarSet($idScroll, $nPos)
; _RGUI_ScrollBarDestroy()
; _RGUI_RoundRect($iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner)
; _RGUI_DrawLine($iX1, $iY1, $iX2, $iY2, $nColor)
; _RGUI_ButtonPress($idMin, $idMax, $nColor)
; _RGUI_ButtonReset(ByRef $idButton, $nColor)
; ===============================================================================================================================

Global $mScroll[]

Func _RGUI_RoundLabel($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner, $bDrag = False)
  If $iWidth = -1 Or $iHeight = -1 Then
    Local $idTmp = GUICtrlCreateLabel($sText, -1000, -1000, $iWidth, $iHeight)
    Local $aPos = ControlGetPos(_WinAPI_GetParent(GUICtrlGetHandle($idTmp)), "", $idTmp)
    If $iWidth = -1 Then $iWidth = $aPos[2] + 2 * $iCorner
    If $iHeight = -1 Then $iHeight = $aPos[3] + 2
    GUICtrlDelete($idTmp)
  EndIf
  _RGUI_RoundRect($iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner)
  Local $idLabel = GUICtrlCreateLabel($sText, $iLeft + $iCorner, $iTop + 1, $iWidth - 2 * $iCorner, $iHeight - 2, $SS_CENTER + $SS_CENTERIMAGE, $bDrag ? $GUI_WS_EX_PARENTDRAG : 0)
  GUICtrlSetBkColor(-1, $nBkColor)
  GUICtrlSetColor(-1, $nTextColor)
  Return $idLabel
EndFunc   ;==>_RGUI_RoundLabel

Func _RGUI_RoundButton($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner)
  If $iWidth = -1 Or $iHeight = -1 Then
    Local $idTmp = GUICtrlCreateLabel($sText, -1000, -1000, $iWidth, $iHeight)
    Local $aPos = ControlGetPos(_WinAPI_GetParent(GUICtrlGetHandle($idTmp)), "", $idTmp)
    If $iWidth = -1 Then $iWidth = $aPos[2] + 2 * $iCorner
    If $iHeight = -1 Then $iHeight = $aPos[3] + 2
    GUICtrlDelete($idTmp)
  EndIf
  _RGUI_RoundRect($iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner)
  Local $idLabel = GUICtrlCreateLabel($sText, $iLeft + $iCorner, $iTop + 1, $iWidth - 2 * $iCorner, $iHeight - 2, $SS_CENTER + $SS_CENTERIMAGE)
  GUICtrlSetBkColor(-1, $nBkColor)
  GUICtrlSetColor(-1, $nTextColor)
  Return $idLabel
EndFunc   ;==>_RGUI_RoundButton

Func _RGUI_RoundInput($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner, $iMargin, $iFlags = -1)
  _RGUI_RoundRect($iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner)
  Local $idInput = GUICtrlCreateInput($sText, $iLeft + $iCorner, $iTop + $iMargin, $iWidth - 2 * $iCorner, $iHeight - $iMargin, $iFlags, 0)
  GUICtrlSetBkColor(-1, $nBkColor)
  GUICtrlSetColor(-1, $nTextColor)
  Return $idInput
EndFunc   ;==>_RGUI_RoundInput

Func _RGUI_RoundEdit($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner, $iMargin, $iFlags = -1)
  _RGUI_RoundRect($iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner)
  Local $idEdit = GUICtrlCreateEdit($sText, $iLeft + $iCorner, $iTop + $iMargin, $iWidth - 2 * $iCorner, $iHeight - 2 * $iMargin, $iFlags, 0)
  GUICtrlSetBkColor(-1, $nBkColor)
  GUICtrlSetColor(-1, $nTextColor)
  Return $idEdit
EndFunc   ;==>_RGUI_RoundEdit

Func _RGUI_RoundGroup($sText, $nTextColor, $iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner, $iMargin)
  GUICtrlCreateGroup("", 0, 0, 0, 0)
  _RGUI_RoundRect($iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner)
  Local $idLabel = GUICtrlCreateLabel($sText, -1000, -1000, -1, -1, $SS_LEFTNOWORDWRAP)
  Local $aPos = ControlGetPos(_WinAPI_GetParent(GUICtrlGetHandle($idLabel)), "", $idLabel)
  $aPos[2] -= 8
  $aPos[3] = Int($aPos[3] / 2)
  GUICtrlSetPos(-1, $iLeft + $iCorner, $iTop - $aPos[3], $aPos[2] + 2 * $iMargin, $aPos[3] * 2)
  GUICtrlSetBkColor(-1, $nBkColor)
  GUICtrlSetColor(-1, $nTextColor)
  GUICtrlSetStyle(-1, $SS_CENTER + $SS_CENTERIMAGE)
  Return $idLabel
EndFunc   ;==>_RGUI_RoundGroup

Func _RGUI_RoundScrollBar($iLeft, $iTop, $iSize, $nColor, $fCall, $idCtrl = 0)
  _RGUI_RoundRect($iLeft, $iTop, 10, $iSize, $nColor, $nColor, 5)
  Local $idScroll = GUICtrlCreateLabel("", $iLeft + 2, $iTop + 5, 7, 60)
  GUICtrlSetBkColor(-1, 0xFFFFFF)

  Local $hProc = DllCallbackRegister(__RGUI_ScrollBarProc, 'lresult', 'hwnd;uint;wparam;lparam;uint_ptr;dword_ptr')
  _WinAPI_SetWindowSubclass(GUICtrlGetHandle($idScroll), DllCallbackGetPtr($hProc), $idScroll, $idCtrl)
  Local $aScroll = [$fCall, $hProc, $iTop + 5, $iTop + $iSize - 66]
  $mScroll[$idScroll] = $aScroll
  Return $idScroll
EndFunc   ;==>_RGUI_RoundScrollBar

Func _RGUI_ScrollBarSet($idScroll, $nPos)
  GUICtrlSetPos($idScroll, ControlGetPos(_WinAPI_GetParent(GUICtrlGetHandle($idScroll)), "", $idScroll)[0], (($mScroll[$idScroll])[3] - ($mScroll[$idScroll])[2]) * $nPos + ($mScroll[$idScroll])[2])
EndFunc   ;==>_RGUI_ScrollBarSet

Func _RGUI_ScrollBarDestroy()
  For $iKey In MapKeys($mScroll)
    _WinAPI_RemoveWindowSubclass(GUICtrlGetHandle($iKey), DllCallbackGetPtr(($mScroll[$iKey])[1]), $iKey)
    DllCallbackFree(($mScroll[$iKey])[1])
  Next
EndFunc   ;==>_RGUI_ScrollBarDestroy

Func _RGUI_RoundRect($iLeft, $iTop, $iWidth, $iHeight, $nColor, $nBkColor, $iCorner)
  GUICtrlCreateGraphic($iLeft, $iTop, $iWidth, $iHeight)
  If $nBkColor = -2 Then
    GUICtrlSetGraphic(-1, $GUI_GR_COLOR, $nColor)
    GUICtrlSetGraphic(-1, $GUI_GR_NOBKCOLOR)
  Else
    GUICtrlSetGraphic(-1, $GUI_GR_COLOR, $nColor, $nBkColor)
  EndIf
  GUICtrlSetGraphic(-1, $GUI_GR_MOVE, 0, $iCorner)
  GUICtrlSetGraphic(-1, $GUI_GR_BEZIER, $iCorner, 0, 0, 0, $iCorner, 0)
  GUICtrlSetGraphic(-1, $GUI_GR_LINE, $iWidth - $iCorner, 0)
  GUICtrlSetGraphic(-1, $GUI_GR_BEZIER, $iWidth, $iCorner, $iWidth, 0, $iWidth, $iCorner)
  GUICtrlSetGraphic(-1, $GUI_GR_LINE, $iWidth, $iHeight - $iCorner)
  GUICtrlSetGraphic(-1, $GUI_GR_BEZIER, $iWidth - $iCorner, $iHeight, $iWidth, $iHeight, $iWidth - $iCorner, $iHeight)
  GUICtrlSetGraphic(-1, $GUI_GR_LINE, $iCorner, $iHeight)
  GUICtrlSetGraphic(-1, $GUI_GR_BEZIER + $GUI_GR_CLOSE, 0, $iHeight - $iCorner, 0, $iHeight, 0, $iHeight - $iCorner)
  GUICtrlSetState(-1, $GUI_DISABLE)
EndFunc   ;==>_RGUI_RoundRect

Func _RGUI_DrawLine($iX1, $iY1, $iX2, $iY2, $nColor)
  GUICtrlCreateGraphic($iX1, $iY1, $iX2 - $iX1 + 1, $iY2 - $iY1 + 1)
  GUICtrlSetGraphic(-1, $GUI_GR_COLOR, $nColor, $nColor)
  GUICtrlSetGraphic(-1, $GUI_GR_LINE, $iX2 - $iX1, $iY2 - $iY1)
  GUICtrlSetState(-1, $GUI_DISABLE)
EndFunc   ;==>_RGUI_DrawLine

Func _RGUI_ButtonPress($idMin, $idMax, $nColor)
  Local Static $tPoint = DllStructCreate($tagPOINT)
  $tPoint.X = MouseGetPos(0)
  $tPoint.Y = MouseGetPos(1)
  Local $idCtrl = _WinAPI_GetDlgCtrlID(_WinAPI_WindowFromPoint($tPoint))
  If $idCtrl < $idMin Or $idCtrl > $idMax Then Return 0
  GUICtrlSetColor($idCtrl, $nColor)
  Return $idCtrl
EndFunc   ;==>_RGUI_ButtonPress

Func _RGUI_ButtonReset(ByRef $idButton, $nColor)
  If $idButton Then $idButton = GUICtrlSetColor($idButton, $nColor) - 1
EndFunc   ;==>_RGUI_ButtonReset

; #INTERNALS# ===================================================================================================================
Func __RGUI_ScrollBarProc($hWnd, $iMsg, $wParam, $lParam, $iID, $iData)
  If $iMsg <> $WM_LBUTTONDOWN Then Return _WinAPI_DefSubclassProc($hWnd, $iMsg, $wParam, $lParam)
  Local $iOpt = Opt("MouseCoordMode", 2)
  Local $iTop = ($mScroll[$iID])[2]
  Local $iBottom = ($mScroll[$iID])[3]
  Local $iY = MouseGetPos(1)
  Local $aPos = ControlGetPos(_WinAPI_GetParent($hWnd), "", $iID)
  Local $iY1 = $iY, $iY2
  While _IsPressed("01")
    $iY2 = MouseGetPos(1)
    If $iY1 = $iY2 Then ContinueLoop
    $iY1 = $iY2
    $iY2 = $aPos[1] + MouseGetPos(1) - $iY
    If $iY2 < $iTop Then $iY2 = $iTop
    If $iY2 > $iBottom Then $iY2 = $iBottom
    GUICtrlSetPos($iID, $aPos[0], $iY2)
    ($mScroll[$iID])[0]($iID, ($iY2 - $iTop) / ($iBottom - $iTop), $iData)
  WEnd
  Opt("MouseCoordMode", $iOpt)
  Return _WinAPI_DefSubclassProc($hWnd, $iMsg, $wParam, $lParam)
EndFunc   ;==>__RGUI_ScrollBarProc
