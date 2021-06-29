#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=.\assets\windows11-logo.ico
#AutoIt3Wrapper_Outfile=WhyNotWin11_x86.exe
#AutoIt3Wrapper_Outfile_x64=WhyNotWin11.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Res_Comment=New Edition by Amirhosseinhpv ( https://hpv.im/ ), a Fork of Robert Maehl work
#AutoIt3Wrapper_Res_Description=Detection Script to help identify why your PC is not Windows 11 Release Ready
#AutoIt3Wrapper_Res_Fileversion=2.3.1.0
#AutoIt3Wrapper_Res_ProductName=WhyNotWin11
#AutoIt3Wrapper_Res_ProductVersion=2.3.1
#AutoIt3Wrapper_Res_CompanyName=Developed by Amirhosseinhpv in BlackSwan
#AutoIt3Wrapper_Res_LegalCopyright=Amirhossein Hosseinpour, using LGPL 3 License
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_Res_Icon_Add=assets\git.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\pp.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\dis.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\web.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\blackswan.ico
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#OnAutoItStartRegister "OnAutoItStart"

Global $aResults[11][3]
Global $sVersion = "2.3.1.0"
Global $MUILang = @MUILang ; $MUILang=0&429 ~> Force Persian
Global $__Restart = False
Global $aOutput[2] = ["", ""]
If @OSVersion = 'WIN_10' Then DllCall("User32.dll", "bool", "SetProcessDpiAwarenessContext", "HWND", "DPI_AWARENESS_CONTEXT" - 1)
$prevLang = RegRead("HKEY_CURRENT_USER\Software\WhyNotWin11", "Language")
If $prevLang <> @error And $prevLang <> "" Then
	$MUILang = $prevLang
EndIf
Global $LANG_FOLDER = Not @Compiled ? @ScriptDir & "\Langs\" : @LocalAppDataDir & "\WhyNotWin11\Langs\"
Global $LANG_FILE = $LANG_FOLDER & $MUILang & ".lang"
Global $isRTL = _GetTranslationRTL() == "true" ? True : False

#include <File.au3>
#include <Misc.au3>
#include <Array.au3>
#include <String.au3>
#include <GDIPlus.au3>
#include <WinAPIGDI.au3>
#include <WinAPISys.au3>
#include <WinAPISysWin.au3>
#include <EditConstants.au3>
#include <FontConstants.au3>
#include <GUIConstantsEx.au3>
#include <AutoItConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>

#include ".\Includes\_WMIC.au3"
#include ".\Includes\_Checks.au3"

Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)


ExtractFiles()

Switch @OSVersion
	Case "WIN_7", "WIN_VISTA", "WIN_XP", "WIN_XPe"
		MsgBox($MB_ICONWARNING, _Translate("Not Supported"), @OSVersion & " " & _Translate("Not Supported"))
	Case Else

EndSwitch

If $CmdLine[0] > 0 Then
	$iParams = $CmdLine[0]
	For $iLoop = 1 To $iParams Step 1
		Switch $CmdLine[1]
			Case "/?", "/h", "/help"
				MsgBox(0, "Help and Flags", _
						"Checks PC for Windows 11 Release Compatibility" & @CRLF & _
						@CRLF & _
						"WhyNotWin11 [/format FORMAT FILENAME] [/silent]" & @CRLF & _
						@CRLF & _
						@TAB & "/format" & @TAB & "Export Results in an Available format, can be used" & @CRLF & _
						@TAB & "       " & @TAB & "without the /silent flag for both GUI and file" & @CRLF & _
						@TAB & "       " & @TAB & "output. Requires a filename if used." & @CRLF & _
						@TAB & "formats" & @TAB & "TXT" & @CRLF & _
						@TAB & "/silent" & @TAB & "Don't Display the GUI. Compatible Systems will Exit" & @CRLF & _
						@TAB & "       " & @TAB & "with ERROR_SUCCESS." & @CRLF & _
						@CRLF & _
						"All flags can be shortened to just the first character (e.g. /s)" & @CRLF)
				Exit 0
			Case "/s", "/silent"
				ChecksOnly()
				_ArrayDelete($CmdLine, 1)
				ContinueLoop
			Case "/f", "/format"
				Select
					Case UBound($CmdLine) <= 3
						MsgBox(0, "Invalid", "Missing FILENAME paramter for /format." & @CRLF)
						Exit 1
					Case UBound($CmdLine) <= 2
						MsgBox(0, "Invalid", "Missing FORMAT paramter for /format." & @CRLF)
						Exit 1
					Case Else
						Switch $CmdLine[2]
							Case "TXT"
								$aOutput[0] = $CmdLine[2]
								$aOutput[1] = $CmdLine[3]
								_ArrayDelete($CmdLine, 1 - 3)
							Case Else
								MsgBox(0, "Invalid", "Missing FORMAT paramter for /format." & @CRLF)
								Exit 1
						EndSwitch
				EndSelect
			Case Else
				MsgBox(0, "Invalid", 'Invalid switch - "' & $CmdLine[$iLoop] & "." & @CRLF)
				Exit 1
		EndSwitch
	Next
Else
	Main()
EndIf

Func ChecksOnly()

	Local $aDirectX[2]

	$aResults[0][0] = _ArchCheck()
	$aResults[0][1] = @error
	$aResults[0][2] = @extended

	$aResults[1][0] = _BootCheck()
	$aResults[1][1] = @error
	$aResults[1][2] = @extended

	$aResults[2][0] = _CPUNameCheck(_GetCPUInfo(2))
	$aResults[2][1] = @error
	$aResults[2][2] = @extended

	$aResults[3][0] = _CPUCoresCheck()
	$aResults[3][1] = @error
	$aResults[3][2] = @extended

	$aResults[4][0] = _CPUSpeedCheck()
	$aResults[4][1] = @error
	$aResults[4][2] = @extended

	$aDirectX = _DirectXStartCheck()

	$aResults[6][0] = _GPTCheck()
	$aResults[6][1] = @error
	$aResults[6][2] = @extended

	$aResults[7][0] = _MemCheck()
	$aResults[7][1] = @error
	$aResults[7][2] = @extended

	$aResults[8][0] = _SecureBootCheck()
	$aResults[8][1] = @error
	$aResults[8][2] = @extended

	$aResults[9][0] = _SpaceCheck()
	$aResults[9][1] = @error
	$aResults[9][2] = @extended

	$aResults[10][0] = _TPMCheck()
	$aResults[10][1] = @error
	$aResults[10][2] = @extended

	Local $iErr
	Local $iExt

	While 1

		$aDirectX = _GetDirectXCheck($aDirectX)
		$iErr = @error ; Preserve Values against IsArray()
		$iExt = @extended
		If Not IsArray($aDirectX) Then
			$aResults[5][0] = $aDirectX
			$aResults[5][1] = $iErr
			$aResults[5][2] = $iExt
			ExitLoop
		EndIf

		Sleep(100)

	WEnd

	_ArrayDisplay($aResults)

EndFunc   ;==>ChecksOnly

Func ExtractFiles()
	If FileExists(@LocalAppDataDir & "\WhyNotWin11\langs\version") Then
		If _VersionCompare($sVersion, FileReadLine(@LocalAppDataDir & "\WhyNotWin11\langs\version", 1)) = 1 Then
			FileInstall(".\langs\0404.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0404.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0405.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0405.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0407.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0407.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0408.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0408.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0409.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0409.lang", $FC_OVERWRITE)
			FileInstall(".\langs\040C.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040C.lang", $FC_OVERWRITE)
			FileInstall(".\langs\040D.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040D.lang", $FC_OVERWRITE)
			FileInstall(".\langs\040E.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040E.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0411.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0411.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0412.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0412.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0413.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0413.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0416.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0416.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0419.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0419.lang", $FC_OVERWRITE)
			FileInstall(".\langs\041B.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\041B.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0804.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0804.lang", $FC_OVERWRITE)
			FileInstall(".\langs\1034.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1034.lang", $FC_OVERWRITE)
			FileInstall(".\langs\1036.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1036.lang", $FC_OVERWRITE)
			FileInstall(".\langs\1053.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1053.lang", $FC_OVERWRITE)
			FileInstall(".\langs\1055.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1055.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0429.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0429.lang", $FC_OVERWRITE)
			FileDelete(@LocalAppDataDir & "\WhyNotWin11\langs\version")
			FileWrite(@LocalAppDataDir & "\WhyNotWin11\langs\version", $sVersion)
		EndIf
	EndIf
	If FileExists(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt") Then
		If _VersionCompare($sVersion, FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", 1)) = 1 Then
			FileInstall(".\includes\SupportedProcessorsAMD.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", $FC_OVERWRITE)
			FileInstall(".\includes\SupportedProcessorsIntel.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt", $FC_OVERWRITE)
			FileInstall(".\includes\SupportedProcessorsQualcomm.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt", $FC_OVERWRITE)
		EndIf
	EndIf
	Select
		Case Not FileExists(@LocalAppDataDir & "\WhyNotWin11\")
			DirCreate(@LocalAppDataDir & "\WhyNotWin11\")
			ContinueCase
		Case Not FileExists(@LocalAppDataDir & "\WhyNotWin11\Langs\")
			DirCreate(@LocalAppDataDir & "\WhyNotWin11\Langs\")
			FileInstall(".\langs\0404.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0404.lang")
			FileInstall(".\langs\0405.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0405.lang")
			FileInstall(".\langs\0407.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0407.lang")
			FileInstall(".\langs\0408.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0408.lang")
			FileInstall(".\langs\0409.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0409.lang")
			FileInstall(".\langs\040C.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040C.lang")
			FileInstall(".\langs\040D.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040D.lang")
			FileInstall(".\langs\040E.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040E.lang")
			FileInstall(".\langs\0411.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0411.lang")
			FileInstall(".\langs\0412.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0412.lang")
			FileInstall(".\langs\0413.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0413.lang")
			FileInstall(".\langs\0416.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0416.lang")
			FileInstall(".\langs\0419.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0419.lang")
			FileInstall(".\langs\041B.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\041B.lang")
			FileInstall(".\langs\0804.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0804.lang")
			FileInstall(".\langs\1034.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1034.lang")
			FileInstall(".\langs\1036.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1036.lang")
			FileInstall(".\langs\1053.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1053.lang")
			FileInstall(".\langs\1055.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1055.lang")
			FileInstall(".\langs\0429.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0429.lang")
			FileWrite(@LocalAppDataDir & "\WhyNotWin11\langs\version", $sVersion)
			ContinueCase
		Case Not FileExists(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			FileInstall(".\includes\SupportedProcessorsAMD.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			FileInstall(".\includes\SupportedProcessorsIntel.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
			FileInstall(".\includes\SupportedProcessorsQualcomm.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
		Case Else
			;;;
	EndSelect
EndFunc   ;==>ExtractFiles

Func Main()

	$BKC = _WinAPI_GetSysColor($COLOR_WINDOW)

	$ex_style = $isRTL ? $WS_EX_LAYOUTRTL : -1

	$hGUI = GUICreate("WhyNotWin11", 800, 600, -1, -1, BitOR($WS_POPUP, $WS_BORDER), $ex_style)
	GUISetBkColor(_HighContrast(0xF8F8F8))

	GUISetFont(8.5 * _GDIPlus_GraphicsGetDPIRatio()[0], 0, "", "Tahoma")

	GUICtrlSetDefColor(_WinAPI_GetSysColor($COLOR_WINDOWTEXT))
	GUICtrlSetDefBkColor(_HighContrast(0xF8F8F8))

	; Top Most Interaction for Update Text
	$hUpdate = GUICtrlCreateLabel("", 5, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlSetCursor(-1, 0)

	; Top Most Interaction for Banner
	$hBanner = GUICtrlCreateLabel("", 5, 540, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	; Top Most Interaction for Closing Window
	$hExit = GUICtrlCreateLabel("", 760, 10, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 24 * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_MEDIUM)
	GUICtrlSetCursor(-1, 0)

	; Top Most Interaction for Change Lang
	$hLang = GUICtrlCreateLabel("", 725, 10, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 24 * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_MEDIUM)
	GUICtrlSetTip(-1, _Translate("Change Language"))
	GUICtrlSetCursor(-1, 0)
	$idContextmenu = GUICtrlCreateContextMenu($hLang)

	Local $numLangs = 1, $idLangSubmenu[2], $arrayLangIDS[2]
	Local $Lang_FirstItem = GUICtrlCreateDummy()
	$idLangSubmenu[1] = GUICtrlCreateMenuItem(_Translate("DEFAULT O.S. LANGUAGE"), $idContextmenu)
	$arrayLangIDS[1] = @MUILang
	GUICtrlCreateMenuItem("", $idContextmenu)
	Global Const $langs = _FileListToArrayRec($LANG_FOLDER, "*.lang", 29, 0, 0)
	For $i = 1 To UBound($langs) - 1 Step 1
		$curLang = $LANG_FOLDER & $langs[$i]
		$langName = IniRead($curLang, "MetaData", "Language", "")
		$langAuthor = IniRead($curLang, "MetaData", "Translator", "???")
		$langRTL = IniRead($curLang, "MetaData", "RTL", "false")
		If ($langName <> "") Then
			$numLangs += 1
			ReDim $idLangSubmenu[UBound($idLangSubmenu) + 1]
			ReDim $arrayLangIDS[UBound($arrayLangIDS) + 1]
			$idLangSubmenu[$numLangs] = GUICtrlCreateMenuItem($langName & ($langRTL == "true" ? " (RTL)" : ""), $idContextmenu)
			$arrayLangIDS[$numLangs] = StringReplace($langs[$i], ".lang", "")
			If $arrayLangIDS[$numLangs] == $MUILang Then
				GUICtrlSetState(-1, 1)
			EndIf
		EndIf
	Next
	Local $Lang_LastItem = GUICtrlCreateDummy()

	; Top Most Interaction for Socials
	$hGithub = GUICtrlCreateLabel("", 12, 100, 32, 32)
	GUICtrlSetTip(-1, "GitHub")
	GUICtrlSetCursor(-1, 0)

	$hDonate = GUICtrlCreateLabel("", 56, 100, 32, 32)
	GUICtrlSetTip(-1, _Translate("Donate"))
	GUICtrlSetCursor(-1, 0)

	$hDiscord = GUICtrlCreateLabel("", 12, 144, 32, 32)
	GUICtrlSetTip(-1, "Discord")
	GUICtrlSetCursor(-1, 0)

	$hLTT = GUICtrlCreateLabel("", 56, 144, 32, 32)
	GUICtrlSetTip(-1, "LTT")
	GUICtrlSetCursor(-1, 0)

	$hBSlGit = GUICtrlCreateLabel("", 35, 300, 32, 32)
	GUICtrlSetTip(-1, "Open Project in Github")
	GUICtrlSetCursor(-1, 0)


	; Allow Dragging of Whole Window
	GUICtrlCreateLabel("", 100, 0, 800, 600, -1, $GUI_WS_EX_PARENTDRAG)

	GUICtrlCreateLabel("", 0, 0, 100, 340, 0, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlCreateLabel("", 0, 340 + 30, 100, 300, 0, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	$hBlackSwan = GUICtrlCreateLabel("New Edition by" & @CRLF & "[amirhosseinhpv]", 0, 340, 100, 30, 0x01)
	GUICtrlSetTip(-1, "Amirhossein Hosseinpour")
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	_GDIPlus_Startup()
	Local $aIcons[5]
	If @Compiled Then
		$aIcons[0] = GUICtrlCreateIcon(@ScriptFullPath, 201, 12, 100, 32, 32)
		_SetBkIcon($aIcons[0], 0xE6E6E6, @ScriptFullPath, 201, 32, 32)
		$aIcons[1] = GUICtrlCreateIcon(@ScriptFullPath, 202, 56, 100, 32, 32)
		_SetBkIcon($aIcons[1], 0xE6E6E6, @ScriptFullPath, 202, 32, 32)
		$aIcons[2] = GUICtrlCreateIcon(@ScriptFullPath, 203, 12, 144, 32, 32)
		_SetBkIcon($aIcons[2], 0xE6E6E6, @ScriptFullPath, 203, 32, 32)
		$aIcons[3] = GUICtrlCreateIcon(@ScriptFullPath, 204, 56, 144, 32, 32)
		_SetBkIcon($aIcons[3], 0xE6E6E6, @ScriptFullPath, 204, 32, 32)
		$aIcons[4] = GUICtrlCreateIcon(@ScriptFullPath, 205, 35, 300, 32, 32)
		_SetBkIcon($aIcons[4], 0xE6E6E6, @ScriptFullPath, 205, 32, 32)
	Else
		GUICtrlCreateIcon("", -1, 12, 100, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, ".\assets\Git.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 56, 100, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, ".\assets\PP.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 12, 144, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, ".\assets\dis.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 56, 144, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, ".\assets\Web.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 35, 300, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, ".\assets\blackswan.ico", -1, 32, 32)
	EndIf
	_GDIPlus_Shutdown()

	$hBannerText = GUICtrlCreateLabel("", 5, 540, 90, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 8.5 * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	$sBannerURL = _SetBannerText($hBannerText, $hBanner)

	GUICtrlCreateLabel(_Translate("Check for Updates"), 5, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 8.5 * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	GUICtrlCreateLabel("WhyNotWin11", 10, 10, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlCreateLabel("v " & $sVersion, 10, 30, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	GUICtrlCreateLabel("", 100, 560, 700, 40)
	GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))

	If $MUILang <> 0409 Then
		GUICtrlCreateLabel(_Translate("Translation by") & " " & _GetTranslationCredit(), 110, 570, 350, 20, $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))
	EndIf

	GUICtrlCreateLabel(_GetCPUInfo(2), 470, 560, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))
	GUICtrlCreateLabel(_GetGPUInfo(0), 470, 580, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))


	GUICtrlCreateLabel(_Translate("Your Windows 11 Compatibility Results are Below"), 130, 10, 580, 30, -1, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetFont(-1, 15 * _GDIPlus_GraphicsGetDPIRatio()[0], 400, "", "", $CLEARTYPE_QUALITY)

	GUICtrlCreateLabel(_Translate("Now Reach WhyNotWin11 via https://www.whynotwin11.org/"), 130, 10 + 30 + 5, 640, 17, -1, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetFont(-1, 10 * _GDIPlus_GraphicsGetDPIRatio()[0])

	GUICtrlCreateLabel(_Translate("Results Based on Currently Known Requirements!"), 130, 10 + 30 + 5 + 17 + 5, 640, 20, -1, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetColor(-1, 0xE20012)
	GUICtrlSetFont(-1, 10 * _GDIPlus_GraphicsGetDPIRatio()[0])

	GUICtrlCreateLabel("×", 760, 10, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 24 * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_NORMAL)

	GUICtrlCreateLabel("🌐", 725, 10, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 20 * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_NORMAL)

	Local $hCheck[11][3]
	Local $hLabel[11] = ["Architecture (CPU + OS)", _
			"Boot Method", _
			"CPU Compatibility", _
			"CPU Core Count", _
			"CPU Frequency", _
			"DirectX + WDDM2", _
			"Disk Partition Type", _
			"RAM Installed", _
			"Secure Boot", _
			"Storage Available", _
			"TPM Version"]

	For $iRow = 0 To 10 Step 1
		; OK | X | ?
		$hCheck[$iRow][0] = GUICtrlCreateLabel("?", 130, 110 + $iRow * 40, 40, 40, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, 0xE6E6E6)

		; Title
		$hCheck[$iRow][1] = GUICtrlCreateLabel(" " & _Translate($hLabel[$iRow]), 170, 110 + $iRow * 40, 300, 40, $SS_CENTERIMAGE)
		GUICtrlSetFont(-1, 12 * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_NORMAL)

		; Description
		$hCheck[$iRow][2] = GUICtrlCreateLabel(_Translate("Checking..."), 470, 110 + $iRow * 40, 300, 40, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE)
		If $iRow = 0 Or $iRow = 3 Or $iRow = 6 Or $iRow = 9 Then GUICtrlSetStyle(-1, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetFont(-1, 10 * _GDIPlus_GraphicsGetDPIRatio()[0])
	Next

	$hDXFile = _TempFile(@TempDir, "dxdiag")
	Run("dxdiag /whql:off /t " & $hDXFile)

	Select
		Case @CPUArch = "X64" And @OSArch = "IA64"
			ContinueCase
		Case @CPUArch = "X64" And @OSArch = "X64"
			_GUICtrlSetDataEx($hCheck[0][0], "OK")
			_GUICtrlSetDataEx($hCheck[0][2], _Translate("64 Bit CPU") & @CRLF & _Translate("64 Bit OS"))

		Case @CPUArch = "X64" And @OSArch = "X86"
			_GUICtrlSetDataEx($hCheck[0][0], "!")
			_GUICtrlSetDataEx($hCheck[0][2], _Translate("64 Bit CPU") & @CRLF & _Translate("32 bit OS"))
		Case Else
			_GUICtrlSetDataEx($hCheck[0][0], "X")
			_GUICtrlSetDataEx($hCheck[0][2], _Translate("32 Bit CPU") & @CRLF & _Translate("32 Bit OS"))
	EndSelect

	$sFirmware = EnvGet("firmware_type")
	Switch $sFirmware
		Case "UEFI"
			_GUICtrlSetDataEx($hCheck[1][0], "OK")
			_GUICtrlSetDataEx($hCheck[1][2], $sFirmware)
		Case "Legacy"
			_GUICtrlSetDataEx($hCheck[1][0], "X")
			_GUICtrlSetDataEx($hCheck[1][2], $sFirmware)
		Case Else
			_GUICtrlSetDataEx($hCheck[1][0], "?", 0xF4C141)
			_GUICtrlSetDataEx($hCheck[1][2], $sFirmware)
	EndSwitch

	Select
		Case StringInStr(_GetCPUInfo(2), "AMD")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			If @error Then
				_GUICtrlSetDataEx($hCheck[2][0], "?")
				_GUICtrlSetDataEx($hCheck[2][0], _Translate("Unable to Check List"))
			EndIf
			For $iLine = 1 To $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", $iLine)
				Select
					Case @error = -1
						_GUICtrlSetDataEx($hCheck[2][0], "?")
						_GUICtrlSetDataEx($hCheck[2][2], _Translate("Error Accessing List"))
						ExitLoop
					Case $iLine = $iLines
						_GUICtrlSetDataEx($hCheck[2][0], "?")
						_GUICtrlSetDataEx($hCheck[2][2], _Translate("Not Currently Listed as Compatible"))
						ExitLoop
					Case StringInStr(_GetCPUInfo(2), $sLine)
						_GUICtrlSetDataEx($hCheck[2][0], "OK")
						_GUICtrlSetDataEx($hCheck[2][2], _Translate("Listed as Compatible"))
						ExitLoop
				EndSelect
			Next
		Case StringInStr(_GetCPUInfo(2), "Intel")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
			If @error Then
				_GUICtrlSetDataEx($hCheck[2][0], "?")
				_GUICtrlSetDataEx($hCheck[2][2], _Translate("Unable to Check List"))
			EndIf
			For $iLine = 1 To $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt", $iLine)
				Select
					Case @error = -1
						_GUICtrlSetDataEx($hCheck[2][0], "?")
						_GUICtrlSetDataEx($hCheck[2][2], _Translate("Error Accessing List"))
						ExitLoop
					Case $iLine = $iLines
						_GUICtrlSetDataEx($hCheck[2][0], "?")
						_GUICtrlSetDataEx($hCheck[2][2], _Translate("Not Currently Listed as Compatible"))
						ExitLoop
					Case StringInStr(_GetCPUInfo(2), $sLine)
						_GUICtrlSetDataEx($hCheck[2][0], "OK")
						_GUICtrlSetDataEx($hCheck[2][2], _Translate("Listed as Compatible"))
						ExitLoop
				EndSelect
			Next
		Case StringInStr(_GetCPUInfo(2), "SnapDragon") Or StringInStr(_GetCPUInfo(2), "Microsoft")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
			If @error Then
				_GUICtrlSetDataEx($hCheck[2][0], "?")
				_GUICtrlSetDataEx($hCheck[2][0], _Translate("Unable to Check List"))
			EndIf
			For $iLine = 1 To $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt", $iLine)
				Select
					Case @error = -1
						GUICtrlSetData($hCheck[2][0], "?")
						GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
						GUICtrlSetData($hCheck[2][2], _Translate("Error Accessing List"))
						ExitLoop
					Case $iLine = $iLines
						GUICtrlSetData($hCheck[2][0], "?")
						GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
						GUICtrlSetData($hCheck[2][2], _Translate("Not Currently Listed as Compatible"))
						ExitLoop
					Case StringInStr(_GetCPUInfo(2), $sLine)
						_GUICtrlSetDataEx($hCheck[2][0], "OK")
						_GUICtrlSetDataEx($hCheck[2][2], _Translate("Listed as Compatible"))
						ExitLoop
				EndSelect
			Next
		Case Else
			_GUICtrlSetDataEx($hCheck[2][0], "?")
	EndSelect

	If _GetCPUInfo(0) >= 2 Or _GetCPUInfo(1) >= 2 Then
		_GUICtrlSetDataEx($hCheck[3][0], "OK")
	Else
		_GUICtrlSetDataEx($hCheck[3][0], "X")
	EndIf
	_GUICtrlSetDataEx($hCheck[3][2], _GetCPUInfo(0) & " " & _Translate("Cores") & @CRLF & _GetCPUInfo(1) & " " & _Translate("Threads"))

	If _GetCPUInfo(3) >= 1000 Then
		_GUICtrlSetDataEx($hCheck[4][0], "OK")
		_GUICtrlSetDataEx($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	Else
		_GUICtrlSetDataEx($hCheck[4][0], "X")
		_GUICtrlSetDataEx($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	EndIf

	$aDisks = _GetDiskInfo(1)
	Switch _GetDiskInfo(0)
		Case "GPT"
			If $aDisks[0] = $aDisks[1] Then
				_GUICtrlSetDataEx($hCheck[6][0], "OK")
			Else
				_GUICtrlSetDataEx($hCheck[6][0], "!")
			EndIf
			_GUICtrlSetDataEx($hCheck[6][2], _Translate("GPT Detected") & @CRLF & $aDisks[1] & "/" & $aDisks[0] & " " & _Translate("Drive(s) Meet Requirements"))
		Case Else
			_GUICtrlSetDataEx($hCheck[6][0], "X")
			_GUICtrlSetDataEx($hCheck[6][2], _Translate("GPT Not Detected"))
	EndSwitch

	$aMem = DllCall("Kernel32.dll", "int", "GetPhysicallyInstalledSystemMemory", "int*", "")
	If @error Then
		$aMem = MemGetStats()
		$aMem = Round($aMem[1] / 1048576, 1)
		$aMem = Ceiling($aMem)
	Else
		$aMem = Round($aMem[1] / 1048576, 1)
	EndIf
	If $aMem = 0 Then
		$aMem = MemGetStats()
		$aMem = $aMem[1]
		$aMem = Ceiling($aMem)
	EndIf

	If $aMem >= 4 Then
		_GUICtrlSetDataEx($hCheck[7][0], "OK")
		_GUICtrlSetDataEx($hCheck[7][2], $aMem & " GB")
	Else
		_GUICtrlSetDataEx($hCheck[7][0], "X")
		_GUICtrlSetDataEx($hCheck[7][2], $aMem & " GB")
	EndIf

	$sSecureBoot = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State", "UEFISecureBootEnabled")
	If @error Then $sSecureBoot = 999
	Switch $sSecureBoot
		Case 0
			_GUICtrlSetDataEx($hCheck[8][0], "OK")
			_GUICtrlSetDataEx($hCheck[8][2], _Translate("Supported"))
		Case 1
			_GUICtrlSetDataEx($hCheck[8][0], "OK")
			_GUICtrlSetDataEx($hCheck[8][2], _Translate("Enabled"))
		Case Else
			_GUICtrlSetDataEx($hCheck[8][0], "X")
			_GUICtrlSetDataEx($hCheck[8][2], _Translate("Disabled / Not Detected"))
	EndSwitch


	$aDrives = DriveGetDrive($DT_FIXED)
	$iDrives = 0

	For $iLoop = 1 To $aDrives[0] Step 1
		If Round(DriveSpaceTotal($aDrives[$iLoop]) / 1024, 0) >= 64 Then $iDrives += 1
	Next


	If Round(DriveSpaceTotal("C:\") / 1024, 0) >= 64 Then
		_GUICtrlSetDataEx($hCheck[9][0], "OK")
	Else
		_GUICtrlSetDataEx($hCheck[9][0], "X")
	EndIf

	If $isRTL Then
		_GUICtrlSetDataEx($hCheck[9][2], "فضای درایو \:C برابر با " & Round(DriveSpaceTotal("C:\") / 1024, 0) & " گیگ" & @CRLF & $iDrives & " " & _Translate("Drive(s) Meet Requirements"))
	Else
		_GUICtrlSetDataEx($hCheck[9][2], Round(DriveSpaceTotal("C:\") / 1024, 0) & " GB C:\" & @CRLF & $iDrives & " " & _Translate("Drive(s) Meet Requirements"))
	EndIf

	Select
		Case Not IsAdmin() And _GetTPMInfo(0) = True
			_GUICtrlSetDataEx($hCheck[10][0], "OK")
			_GUICtrlSetDataEx($hCheck[10][2], "TPM 2.0 " & _Translate("Detected"))
		Case Not IsAdmin() And _GetTPMInfo <> True
			_GUICtrlSetDataEx($hCheck[10][0], "X")
			_GUICtrlSetDataEx($hCheck[10][2], _Translate("TPM Missing / Disabled"))
		Case _GetTPMInfo(0) = False
			ContinueCase
		Case _GetTPMInfo(1) = False
			_GUICtrlSetDataEx($hCheck[10][0], "X")
			_GUICtrlSetDataEx($hCheck[10][2], _Translate("TPM Missing / Disabled"))
		Case Not Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
			_GUICtrlSetDataEx($hCheck[10][0], "X")
			_GUICtrlSetDataEx($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Not Supported"))
		Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 2.0
			_GUICtrlSetDataEx($hCheck[10][0], "OK")
			_GUICtrlSetDataEx($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Detected"))
		Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
			_GUICtrlSetDataEx($hCheck[10][0], "X")
			_GUICtrlSetDataEx($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Detected"))
		Case Else
			_GUICtrlSetDataEx($hCheck[10][0], "X")
			_GUICtrlSetDataEx($hCheck[10][2], _GetTPMInfo(0) & " " & _GetTPMInfo(1) & " " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]))
	EndSelect

	GUISetState(@SW_SHOW, $hGUI)

	While 1
		$msg = GUIGetMsg()

		Switch $msg

			Case $GUI_EVENT_CLOSE, $hExit
				GUIDelete($hGUI)
				Exit

			Case $hLang
				MouseClick($MOUSE_CLICK_SECONDARY)

				; DirectX 12 takes a while. Grab the result once done
			Case Not ProcessExists("dxdiag.exe") And FileExists($hDXFile)
				$sDXFile = StringStripWS(StringStripCR(FileRead($hDXFile)), $STR_STRIPALL)
				Select
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "3") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:3") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM3")
						_GUICtrlSetDataEx($hCheck[5][0], "OK")
						_GUICtrlSetDataEx($hCheck[5][2], "DirectX 12 && WDDM 3")
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "2") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:2") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
						_GUICtrlSetDataEx($hCheck[5][0], "OK")
						_GUICtrlSetDataEx($hCheck[5][2], "DirectX 12 && WDDM 2")
					Case Not StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
						_GUICtrlSetDataEx($hCheck[5][0], "X")
						_GUICtrlSetDataEx($hCheck[5][2], _Translate("No DirectX 12, but WDDM2"))
					Case StringInStr($sDXFile, "DDIVersion:12") And Not StringInStr($sDXFile, "DriverModel:WDDM2")
						_GUICtrlSetDataEx($hCheck[5][0], "X")
						_GUICtrlSetDataEx($hCheck[5][2], _Translate("DirectX 12, but no WDDM2"))
					Case Else
						_GUICtrlSetDataEx($hCheck[5][0], "X")
						_GUICtrlSetDataEx($hCheck[5][2], _Translate("No DirectX 12 or WDDM2"))
				EndSelect
				FileDelete($hDXFile)

			Case $hBanner
				ShellExecute($sBannerURL)

			Case $hGithub
				ShellExecute("https://fcofix.org/WhyNotWin11")

			Case $hDonate
				ShellExecute("https://paypal.me/rhsky")

			Case $hDiscord
				ShellExecute("https://discord.gg/uBnBcBx")

			Case $hLTT
				ShellExecute("https://linustechtips.com/topic/1350354-windows-11-readiness-check-whynotwin11/")

			Case $hBSlGit
				ShellExecute("https://github.com/amirhosseinhpv/WhyNotWin11")

			Case $hBlackSwan
				ShellExecute("https://amirhosseinhpv.com/")

			Case $hUpdate
				Switch _GetLatestRelease($sVersion)
					Case -1
						MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate("Test Build?"), _Translate("You're running a newer build than publically Available!"), 10)
					Case 0
						Switch @error
							Case 0
								MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_TOPMOST, _Translate("Up to Date"), _Translate("You're running the latest build!"), 10)
							Case 1
								MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate("Unable to Check for Updates"), _Translate("Unable to load release data."), 10)
							Case 2
								MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate("Unable to Check for Updates"), _Translate("Invalid Data Received!"), 10)
							Case 3
								Switch @extended
									Case 0
										MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate("Unable to Check for Updates"), _Translate("Invalid Release Tags Received!"), 10)
									Case 1
										MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate("Unable to Check for Updates"), _Translate("Invalid Release Types Received!"), 10)
								EndSwitch
						EndSwitch
					Case 1
						If MsgBox($MB_YESNO + $MB_ICONINFORMATION + $MB_TOPMOST, _Translate("Update Available"), _Translate("An Update is Available, would you like to download it?"), 10) = $IDYES Then ShellExecute("https://fcofix.org/WhyNotWin11/releases")
				EndSwitch

			Case $Lang_FirstItem To $Lang_LastItem
				For $i = 1 To UBound($idLangSubmenu) - 1 Step 1
					If $msg = $idLangSubmenu[$i] Then
						$regWrite = RegWrite("HKEY_CURRENT_USER\Software\WhyNotWin11", "Language", "REG_SZ", $arrayLangIDS[$i])
						If $regWrite <> 1 Then
							MsgBox(262144, _Translate("Error"), _Translate("An error occurred writing into the registry."), 20, $hGUI)
							Return False
						Else
							MsgBox(262144, _Translate("Success"), _Translate("Language Changed, Click OK to restart."), 20, $hGUI)
							_ScriptRestart()
						EndIf



					EndIf
				Next
			Case Else

		EndSwitch
	WEnd
EndFunc   ;==>Main

Func _GetLatestRelease($sCurrent)

	Local $dAPIBin
	Local $sAPIJSON

	$dAPIBin = InetRead("https://api.fcofix.org/repos/rcmaehl/WhyNotWin11/releases")
	If @error Then Return SetError(1, 0, 0)
	$sAPIJSON = BinaryToString($dAPIBin)
	If @error Then Return SetError(2, 0, 0)

	Local $aReleases = _StringBetween($sAPIJSON, '"tag_name":"', '",')
	If @error Then Return SetError(3, 0, 0)
	Local $aRelTypes = _StringBetween($sAPIJSON, '"prerelease":', ',')
	If @error Then Return SetError(3, 1, 0)
	Local $aCombined[UBound($aReleases)][2]

	For $iLoop = 0 To UBound($aReleases) - 1 Step 1
		$aCombined[$iLoop][0] = $aReleases[$iLoop]
		$aCombined[$iLoop][1] = $aRelTypes[$iLoop]
	Next

	Return _VersionCompare($aCombined[0][0], $sCurrent)

EndFunc   ;==>_GetLatestRelease

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
	Local $aResult
	#forcedef $__g_hGDIPDll, $ghGDIPDll

	$aResult = DllCall($__g_hGDIPDll, "int", "GdipGetDpiX", "handle", $hGfx, "float*", 0)

	If @error Then Return SetError(2, @extended, 0)
	Local $iDPI = $aResult[2]
	Local $aResults[2] = [$iDPIDef / $iDPI, $iDPI / $iDPIDef]
	_GDIPlus_GraphicsDispose($hGfx)
	_GDIPlus_Shutdown()
	Return $aResults
EndFunc   ;==>_GDIPlus_GraphicsGetDPIRatio

Func _GetTranslationCredit()
	Return IniRead($LANG_FILE, "MetaData", "Translator", "???")
EndFunc   ;==>_GetTranslationCredit

Func _GetTranslationRTL()
	Return IniRead($LANG_FILE, "MetaData", "RTL", "false")
EndFunc   ;==>_GetTranslationRTL

Func _HighContrast($sColor)
	Local Static $sSysWin

	If Not $sSysWin <> "" Then $sSysWin = _WinAPI_GetSysColor($COLOR_WINDOW)

	If $sSysWin = 0 Then
		Return 16777215 - $sColor
	Else
		Return $sColor
	EndIf

EndFunc   ;==>_HighContrast

Func _SetBannerText($hBannerText, $hBanner)

	Local $bLinux = False
	Local $hModule = _WinAPI_GetModuleHandle("ntdll.dll")

	If _WinAPI_GetProcAddress($hModule, "wine_get_host_version") Then $bLinux = True

	Select
		Case $bLinux
			GUICtrlSetData($hBannerText, "i3 BEST WM")
			Return "https://archlinux.org/"
			GUICtrlSetCursor($hBannerText, 0)
			GUICtrlSetCursor($hBanner, 0)
		Case @LogonDomain <> @ComputerName And IsAdmin()
			GUICtrlSetData($hBannerText, "I'M FOR HIRE")
			Return "https://fcofix.org/rcmaehl/wiki/I'M-FOR-HIRE"
			GUICtrlSetCursor($hBannerText, 0)
			GUICtrlSetCursor($hBanner, 0)
		Case Else
			GUICtrlSetCursor($hBanner, 2)
	EndSelect

EndFunc   ;==>_SetBannerText

Func _SetBkIcon($ControlID, $iBackground, $sIcon, $iIndex, $iWidth, $iHeight)

	Local Static $STM_SETIMAGE = 0x0172
	Local $tIcon, $tID, $hDC, $hBackDC, $hBackSv, $hBitmap, $hImage, $hIcon, $hBkIcon

	$tIcon = DllStructCreate('hwnd')
	$tID = DllStructCreate('hwnd')
	$hIcon = DllCall('user32.dll', 'int', 'PrivateExtractIcons', 'str', $sIcon, 'int', $iIndex, 'int', $iWidth, 'int', $iHeight, 'ptr', DllStructGetPtr($tIcon), 'ptr', DllStructGetPtr($tID), 'int', 1, 'int', 0)
	If (@error) Or ($hIcon[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	$hIcon = DllStructGetData($tIcon, 1)
	$tIcon = 0
	$tID = 0

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

Func _Translate($sString)
	Return _WinAPI_OemToChar(IniRead($LANG_FILE, "Strings", $sString, $sString))
EndFunc   ;==>_Translate

#Region RESTART UDF
Func _ScriptRestart($fExit = 1)

	Local $Pid

	If Not $__Restart Then
		If @Compiled Then
			$Pid = Run(@ScriptFullPath & ' ' & $CmdLineRaw, @ScriptDir, Default, 1)
		Else
			$Pid = Run(@AutoItExe & ' "' & @ScriptFullPath & '" ' & $CmdLineRaw, @ScriptDir, Default, 1)
		EndIf
		If @error Then
			Return SetError(@error, 0, 0)
		EndIf
		StdinWrite($Pid, @AutoItPID)
	EndIf
	$__Restart = 1
	If $fExit Then
		Sleep(50)
		Exit
	EndIf
	Return 1
EndFunc   ;==>_ScriptRestart
Func OnAutoItStart()
	Sleep(50)
	Local $Pid = ConsoleRead(1)
	If @extended Then
		While ProcessExists($Pid)
			Sleep(100)
		WEnd
	EndIf
EndFunc   ;==>OnAutoItStart
#EndRegion RESTART UDF

Func _GUICtrlSetDataEx($ctrl = -1, $label = "", $bg = "")
	GUICtrlSetData($ctrl, $label)
	GUICtrlSetTip($ctrl, $label)
	If $bg = "" Then
		$bg = $GUI_BKCOLOR_TRANSPARENT
		If $label = "OK" Then
			$bg = 0x4CC355
		EndIf
		If $label = "X" Then
			$bg = 0xFA113D
		EndIf
		If $label = "?" Then
			$bg = 0xF4C141
		EndIf
		GUICtrlSetBkColor($ctrl, _HighContrast($bg))
	Else
		GUICtrlSetBkColor($ctrl, _HighContrast($bg))
	EndIf
EndFunc   ;==>_GUICtrlSetDataEx
