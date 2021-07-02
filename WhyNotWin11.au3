#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=.\assets\windows11-logo.ico
#AutoIt3Wrapper_Outfile=WhyNotWin11_x86.exe
#AutoIt3Wrapper_Outfile_x64=WhyNotWin11.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Detection Script to help identify why your PC isn't Windows 11 Release Ready
#AutoIt3Wrapper_Res_Fileversion=2.3.0.4
#AutoIt3Wrapper_Res_ProductName=WhyNotWin11
#AutoIt3Wrapper_Res_ProductVersion=2.3.0
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Icon_Add=assets\git.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\pp.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\dis.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\web.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\job.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\set.ico
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7 -v1 -v2 -v3
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $aResults[11][3]
Global $sVersion = "2.3.0.4"
Global $aOutput[2] = ["", ""]

FileChangeDir(@SystemDir)

If @OSVersion = 'WIN_10' Then DllCall(@SystemDir & "\User32.dll", "bool", "SetProcessDpiAwarenessContext", "HWND", "DPI_AWARENESS_CONTEXT" - 1)

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
#include <WinAPIShellEx.au3>
#include <GUIConstantsEx.au3>
#include <AutoItConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>

#include ".\Includes\_WMIC.au3"
#include ".\Includes\_Checks.au3"
#include ".\Includes\ResourcesEx.au3"

Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)
Switch @OSVersion
	Case "WIN_7", "WIN_VISTA", "WIN_XP", "WIN_XPe"
		MsgBox($MB_ICONWARNING, _Translate(@MUILang, "Not Supported"), @OSVersion & " " & _Translate(@MUILang, "Not Supported"))
	Case Else
		;;;
EndSwitch

If $CmdLine[0] > 0 Then ProcessCMDLine()
ExtractFiles()
Main()

Global $__g_hModule = _WinAPI_GetModuleHandle(@SystemDir & "\ntdll.dll")
If @OSBuild >= 22000 Or _WinAPI_GetProcAddress($__g_hModule, "wine_get_host_version") Then
	MsgBox($MB_ICONWARNING, _Translate(@MUILang, "Your Windows 11 Compatibility Results are Below"), _Translate(@MUILang, "You're running the latest build!"))
EndIf

Func ProcessCMDLine()
	Local $bCheck = False
	Local $iParams = $CmdLine[0]
	For $iLoop = 1 To $iParams Step 1
		Switch $CmdLine[1]
			Case "/?", "/h", "/help"
				MsgBox(0, "Help and Flags", _
						"Checks PC for Windows 11 Release Compatibility" & @CRLF & _
						@CRLF & _
						"WhyNotWin11 [/format FORMAT FILENAME [/silent]]" & @CRLF & _
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
				$bCheck = True
				_ArrayDelete($CmdLine, 1)
				If UBound($CmdLine) = 1 Then ExitLoop
				ContinueLoop
			Case "/f", "/format"
				Select
					Case UBound($CmdLine) <= 3
						MsgBox(0, "Invalid", "Missing FILENAME parameter for /format." & @CRLF)
						Exit 1
					Case UBound($CmdLine) <= 2
						MsgBox(0, "Invalid", "Missing FORMAT parameter for /format." & @CRLF)
						Exit 1
					Case Else
						Switch $CmdLine[2]
							Case "TXT"
								$aOutput[0] = $CmdLine[2]
								$aOutput[1] = $CmdLine[3]
								_ArrayDelete($CmdLine, "1-3")
							Case Else
								MsgBox(0, "Invalid", "Missing FORMAT parameter for /format." & @CRLF)
								Exit 1
						EndSwitch
				EndSelect
			Case Else
				If @Compiled Then ; support for running non-compiled script - mLipok
					MsgBox(0, "Invalid", 'Invalid switch - "' & $CmdLine[$iLoop] & "." & @CRLF)
					Exit 1
				EndIf
		EndSwitch
	Next
	If $bCheck Then ChecksOnly()
EndFunc   ;==>ProcessCMDLine

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

	If Not $aOutput[0] = "" Then ParseResults($aResults)

	For $iLoop = 0 To 10 Step 1
		If $aResults[$iLoop][0] = False Then Exit 0
	Next
	Exit 1

EndFunc   ;==>ChecksOnly

Func ExtractFiles()
	FileChangeDir(@ScriptDir)
	; This is need for uncompiled versions, relative path is not used once compiled
	If FileExists(@LocalAppDataDir & "\WhyNotWin11\langs\version") Then
		If _VersionCompare($sVersion, FileReadLine(@LocalAppDataDir & "\WhyNotWin11\langs\version", 1)) = 1 Then
			FileInstall(".\langs\0004.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0004.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0C01.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0C01.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0C0A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0401.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0401.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0404.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0404.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0405.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0405.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0407.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0407.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0408.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0408.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0409.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0409.lang", $FC_OVERWRITE)
			FileInstall(".\langs\040A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\040B.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040B.lang", $FC_OVERWRITE)
			FileInstall(".\langs\040C.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040C.lang", $FC_OVERWRITE)
			FileInstall(".\langs\040D.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040D.lang", $FC_OVERWRITE)
			FileInstall(".\langs\040E.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040E.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0410.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0410.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0411.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0411.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0412.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0412.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0413.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0413.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0414.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0414.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0415.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0415.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0416.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0416.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0418.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0418.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0419.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0419.lang", $FC_OVERWRITE)
			FileInstall(".\langs\041B.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\041B.lang", $FC_OVERWRITE)
			FileInstall(".\langs\041D.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\041D.lang", $FC_OVERWRITE)
			FileInstall(".\langs\041F.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\041F.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0422.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0422.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0425.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0425.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0429.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0429.lang", $FC_OVERWRITE)
			FileInstall(".\langs\042A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\042A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0804.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0804.lang", $FC_OVERWRITE)
			FileInstall(".\langs\080A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\080A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\0816.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0816.lang", $FC_OVERWRITE)
			FileInstall(".\langs\100A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\100A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\1038.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1038.lang", $FC_OVERWRITE)
			FileInstall(".\langs\140A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\140A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\1801.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1801.lang", $FC_OVERWRITE)
			FileInstall(".\langs\180A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\180A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\1C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1C0A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\200A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\200A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\240A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\240A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\280A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\280A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\2C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\2C0A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\300A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\300A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\340A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\340A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\380A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\380A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\3C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\3C0A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\440A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\440A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\480A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\480A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\4C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\4C0A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\500A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\500A.lang", $FC_OVERWRITE)
			FileInstall(".\langs\540A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\540A.lang", $FC_OVERWRITE)
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
			FileInstall(".\langs\0004.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0004.lang")
			FileInstall(".\langs\0C01.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0C01.lang")
			FileInstall(".\langs\0C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0C0A.lang")
			FileInstall(".\langs\0401.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0401.lang")
			FileInstall(".\langs\0404.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0404.lang")
			FileInstall(".\langs\0405.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0405.lang")
			FileInstall(".\langs\0407.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0407.lang")
			FileInstall(".\langs\0408.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0408.lang")
			FileInstall(".\langs\0409.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0409.lang")
			FileInstall(".\langs\040A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040A.lang")
			FileInstall(".\langs\040B.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040B.lang")
			FileInstall(".\langs\040C.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040C.lang")
			FileInstall(".\langs\040D.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040D.lang")
			FileInstall(".\langs\040E.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\040E.lang")
			FileInstall(".\langs\0410.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0410.lang")
			FileInstall(".\langs\0411.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0411.lang")
			FileInstall(".\langs\0412.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0412.lang")
			FileInstall(".\langs\0413.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0413.lang")
			FileInstall(".\langs\0414.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0414.lang")
			FileInstall(".\langs\0415.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0415.lang")
			FileInstall(".\langs\0416.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0416.lang")
			FileInstall(".\langs\0418.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0418.lang")
			FileInstall(".\langs\0419.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0419.lang")
			FileInstall(".\langs\041B.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\041B.lang")
			FileInstall(".\langs\041D.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\041D.lang")
			FileInstall(".\langs\041F.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\041F.lang")
			FileInstall(".\langs\0422.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0422.lang")
			FileInstall(".\langs\0425.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0425.lang")
			FileInstall(".\langs\0429.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0429.lang")
			FileInstall(".\langs\042A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\042A.lang")
			FileInstall(".\langs\0804.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0804.lang")
			FileInstall(".\langs\080A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\080A.lang")
			FileInstall(".\langs\0816.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0816.lang")
			FileInstall(".\langs\100A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\100A.lang")
			FileInstall(".\langs\1038.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1038.lang")
			FileInstall(".\langs\140A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\140A.lang")
			FileInstall(".\langs\1801.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1801.lang")
			FileInstall(".\langs\180A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\180A.lang")
			FileInstall(".\langs\1C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\1C0A.lang")
			FileInstall(".\langs\200A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\200A.lang")
			FileInstall(".\langs\240A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\240A.lang")
			FileInstall(".\langs\280A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\280A.lang")
			FileInstall(".\langs\2C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\2C0A.lang")
			FileInstall(".\langs\300A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\300A.lang")
			FileInstall(".\langs\340A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\340A.lang")
			FileInstall(".\langs\380A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\380A.lang")
			FileInstall(".\langs\3C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\3C0A.lang")
			FileInstall(".\langs\440A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\440A.lang")
			FileInstall(".\langs\480A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\480A.lang")
			FileInstall(".\langs\4C0A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\4C0A.lang")
			FileInstall(".\langs\500A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\500A.lang")
			FileInstall(".\langs\540A.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\540A.lang")
			FileWrite(@LocalAppDataDir & "\WhyNotWin11\langs\version", $sVersion)
			ContinueCase
		Case Not FileExists(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			FileInstall(".\includes\SupportedProcessorsAMD.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			FileInstall(".\includes\SupportedProcessorsIntel.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
			FileInstall(".\includes\SupportedProcessorsQualcomm.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
		Case Else
			;;;
	EndSelect
	FileChangeDir(@SystemDir)
EndFunc   ;==>ExtractFiles

Func Main()

	Local Static $iMUI = @MUILang
	Local Static $aFonts[4]
	$aFonts = _GetTranslationFonts($iMUI)

	Local Enum $FontSmall, $FontMedium, $FontLarge, $FontExtraLarge

	Local $hGUI = GUICreate("WhyNotWin11", 800, 600, -1, -1, BitOR($WS_POPUP, $WS_BORDER))
	GUISetBkColor(_HighContrast(0xF8F8F8))
	GUISetFont($aFonts[$FontSmall] * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_BOLD, "", "Arial")
	_Security()

	GUICtrlSetDefColor(_WinAPI_GetSysColor($COLOR_WINDOWTEXT))
	GUICtrlSetDefBkColor(_HighContrast(0xF8F8F8))

	Local $sCheck = RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
	If @error Then
		;;;
	ElseIf Not $sCheck Then
		GUICtrlSetDefColor(0xFFFFFF)
	EndIf

	Local $hDumpLang = GUICtrlCreateDummy()

	; Debug Key
	Local $aAccel[1][2] = [["{DEL}", $hDumpLang]]
	GUISetAccelerators($aAccel)

	; Top Most Interaction for Update Text
	Local $hUpdate = GUICtrlCreateLabel("", 130, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlSetCursor(-1, 0)

	#cs Maybe Readd Later
	; Top Most Interaction for Banner
	Local $hBanner = GUICtrlCreateLabel("", 5, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	#ce

	; Top Most Interaction for Closing Window
	Local $hExit = GUICtrlCreateLabel("", 760, 10, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontExtraLarge] * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_MEDIUM)
	GUICtrlSetCursor(-1, 0)

	; Top Most Interaction for Socials
	Local $hGithub = GUICtrlCreateLabel("", 34, 110, 32, 32)
	GUICtrlSetTip(-1, "GitHub")
	GUICtrlSetCursor(-1, 0)

	Local $hDonate = GUICtrlCreateLabel("", 34, 160, 32, 32)
	GUICtrlSetTip(-1, _Translate($iMUI, "Donate"))
	GUICtrlSetCursor(-1, 0)

	Local $hDiscord = GUICtrlCreateLabel("", 34, 210, 32, 32)
	GUICtrlSetTip(-1, "Discord")
	GUICtrlSetCursor(-1, 0)

	Local $hLTT = GUICtrlCreateLabel("", 34, 260, 32, 32)
	GUICtrlSetTip(-1, "LTT")
	GUICtrlSetCursor(-1, 0)

	Local $hJob
	If @LogonDomain <> @ComputerName Then
		$hJob = GUICtrlCreateLabel("", 34, 310, 32, 32)
		GUICtrlSetTip(-1, "I'm For Hire")
		GUICtrlSetCursor(-1, 0)
	Else
		$hJob = GUICtrlCreateDummy()
	EndIf

	Local $hToggle = GUICtrlCreateLabel("", 34, 518, 32, 32)
	GUICtrlSetTip(-1, "Settings")
	GUICtrlSetCursor(-1, 0)

	; Allow Dragging of Window
	GUICtrlCreateLabel("", 0, 0, 800, 30, -1, $GUI_WS_EX_PARENTDRAG)

	GUICtrlCreateLabel("", 0, 0, 100, 600)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	_GDIPlus_Startup()
	If @Compiled Then
		GUICtrlCreateIcon("", -1, 34, 110, 32, 32)
		_SetBkSelfIcon(-1, 0xE6E6E6, @ScriptFullPath, 201, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 160, 32, 32)
		_SetBkSelfIcon(-1, 0xE6E6E6, @ScriptFullPath, 202, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 210, 32, 32)
		_SetBkSelfIcon(-1, 0xE6E6E6, @ScriptFullPath, 203, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 260, 32, 32)
		_SetBkSelfIcon(-1, 0xE6E6E6, @ScriptFullPath, 204, 32, 32)
		If @LogonDomain <> @ComputerName Then
			GUICtrlCreateIcon("", -1, 34, 310, 32, 32)
			_SetBkSelfIcon(-1, 0xE6E6E6, @ScriptFullPath, 205, 32, 32)
		EndIf
		GUICtrlCreateIcon("", -1, 34, 518, 32, 32)
		_SetBkSelfIcon(-1, 0xE6E6E6, @ScriptFullPath, 206, 32, 32)
	Else
		GUICtrlCreateIcon("", -1, 34, 110, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, @ScriptDir & "\assets\git.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 160, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, @ScriptDir & ".\assets\pp.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 210, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, @ScriptDir & ".\assets\dis.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 260, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, @ScriptDir & ".\assets\web.ico", -1, 32, 32)
		If @LogonDomain <> @ComputerName Then
			GUICtrlCreateIcon("", -1, 34, 310, 32, 32)
			_SetBkIcon(-1, 0xE6E6E6, @ScriptDir & ".\assets\job.ico", -1, 32, 32)
		EndIf
		GUICtrlCreateIcon("", -1, 34, 518, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, @ScriptDir & ".\assets\set.ico", -1, 32, 32)
	EndIf
	_GDIPlus_Shutdown()

	GUICtrlCreateLabel(_Translate($iMUI, "Check for Updates"), 5, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontSmall] * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	GUICtrlCreateLabel("WhyNotWin11", 10, 10, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlCreateLabel("v " & $sVersion, 10, 30, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	GUICtrlCreateLabel("", 100, 560, 700, 40)
	GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))

	#cs Maybe Readd Later
	Local $hBannerText = GUICtrlCreateLabel("", 130, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontSmall] * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	Local $sBannerURL = _SetBannerText($hBannerText, $hBanner)
	#ce

	#cs
		If Not (@MUILang = "0409") Then
			GUICtrlCreateLabel(_Translate($iMUI, "Translation by") & " " & _GetTranslationCredit(), 130, 560, 310, 40)
			GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))
		EndIf
	#ce


	GUICtrlCreateLabel(_GetCPUInfo(2), 470, 560, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))
	GUICtrlCreateLabel(_GetGPUInfo(0), 470, 580, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))

	GUICtrlCreateLabel(_Translate($iMUI, "Your Windows 11 Compatibility Results are Below"), 130, 15, 640, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontLarge] * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_SEMIBOLD, "", "", $CLEARTYPE_QUALITY)

	GUICtrlCreateLabel(_Translate($iMUI, "Now Reach WhyNotWin11 via https://www.whynotwin11.org/"), 130, 45, 640, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontMedium] * _GDIPlus_GraphicsGetDPIRatio()[0])

	GUICtrlCreateLabel(_Translate($iMUI, "Results Based on Currently Known Requirements!"), 130, 65, 640, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetColor(-1, 0xE20012)
	GUICtrlSetFont(-1, $aFonts[$FontMedium] * _GDIPlus_GraphicsGetDPIRatio()[0])

	GUICtrlCreateLabel(ChrW(0x274C), 765, 5, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontLarge] * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_NORMAL)

	Local $hCheck[11][3]
	Local $hLabel[11] = ["Architecture (CPU + OS)", "Boot Method", "CPU Compatibility", "CPU Core Count", "CPU Frequency", "DirectX + WDDM2", "Disk Partition Type", "RAM Installed", "Secure Boot", "Storage Available", "TPM Version"]

	For $iRow = 0 To 10 Step 1
		$hCheck[$iRow][0] = GUICtrlCreateLabel("?", 130, 110 + $iRow * 40, 40, 40, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, 0xE6E6E6)
		$hCheck[$iRow][1] = GUICtrlCreateLabel(" " & _Translate($iMUI, $hLabel[$iRow]), 170, 110 + $iRow * 40, 300, 40, $SS_CENTERIMAGE)
		GUICtrlSetFont(-1, $aFonts[$FontLarge] * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_NORMAL)
		$hCheck[$iRow][2] = GUICtrlCreateLabel(_Translate($iMUI, "Checking..."), 470, 110 + $iRow * 40, 300, 40, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE)
		If $iRow = 0 Or $iRow = 3 Or $iRow = 6 Or $iRow = 9 Then GUICtrlSetStyle(-1, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetFont(-1, $aFonts[$FontMedium] * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_SEMIBOLD)
	Next

	Local $hDXFile = _TempFile(@TempDir, "dxdiag")
	Run(@SystemDir & "\dxdiag.exe /whql:off /t " & $hDXFile)

	Select
		Case @CPUArch = "X64" And @OSArch = "IA64"
			ContinueCase
		Case @CPUArch = "X64" And @OSArch = "X64"
			 _GUICtrlSetPass($hCheck[0][0])
			GUICtrlSetData($hCheck[0][2], _Translate($iMUI, "64 Bit CPU") & @CRLF & _Translate($iMUI, "64 Bit OS"))
		Case @CPUArch = "X64" And @OSArch = "X86"
			_GUICtrlSetWarn($hCheck[0][0], "!")
			GUICtrlSetData($hCheck[0][2], _Translate($iMUI, "64 Bit CPU") & @CRLF & _Translate($iMUI, "32 bit OS"))
		Case Else
			_GUICtrlSetFail($hCheck[0][0])
			GUICtrlSetData($hCheck[0][2], _Translate($iMUI, "32 Bit CPU") & @CRLF & _Translate($iMUI, "32 Bit OS"))
	EndSelect

	Local $sFirmware = EnvGet("firmware_type")
	Switch $sFirmware
		Case "UEFI"
			 _GUICtrlSetPass($hCheck[1][0])
			GUICtrlSetData($hCheck[1][2], $sFirmware)
		Case "Legacy"
			_GUICtrlSetFail($hCheck[1][0])
			GUICtrlSetData($hCheck[1][2], $sFirmware)
		Case Else
			_GUICtrlSetWarn($hCheck[1][0])
			GUICtrlSetData($hCheck[1][2], $sFirmware)
	EndSwitch

	Local $iLines, $sLine
	Select
		Case StringInStr(_GetCPUInfo(2), "AMD")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			If @error Then
				_GUICtrlSetWarn($hCheck[2][0])
				GUICtrlSetTip($hCheck[2][0], _Translate($iMUI, "Unable to Check List"))
			EndIf
			For $iLine = 1 To $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", $iLine)
				Select
					Case @error = -1
						_GUICtrlSetWarn($hCheck[2][0])
						GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Error Accessing List"))
						ExitLoop
					Case $iLine = $iLines
						_GUICtrlSetWarn($hCheck[2][0])
						GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Not Currently Listed as Compatible"))
						ExitLoop
					Case StringInStr(_GetCPUInfo(2), $sLine)
						 _GUICtrlSetPass($hCheck[2][0])
						GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Listed as Compatible"))
						ExitLoop
				EndSelect
			Next
		Case StringInStr(_GetCPUInfo(2), "Intel")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
			If @error Then
				_GUICtrlSetWarn($hCheck[2][0])
				GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Unable to Check List"))
			EndIf
			For $iLine = 1 To $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt", $iLine)
				Select
					Case @error = -1
						_GUICtrlSetWarn($hCheck[2][0])
						GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Error Accessing List"))
						ExitLoop
					Case $iLine = $iLines
						_GUICtrlSetWarn($hCheck[2][0])
						GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Not Currently Listed as Compatible"))
						ExitLoop
					Case StringInStr(_GetCPUInfo(2), $sLine)
						 _GUICtrlSetPass($hCheck[2][0])
						GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Listed as Compatible"))
						ExitLoop
				EndSelect
			Next
		Case StringInStr(_GetCPUInfo(2), "SnapDragon") Or StringInStr(_GetCPUInfo(2), "Microsoft")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
			If @error Then
				_GUICtrlSetWarn($hCheck[2][0])
				GUICtrlSetTip($hCheck[2][0], _Translate($iMUI, "Unable to Check List"))
			EndIf
			For $iLine = 1 To $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt", $iLine)
				Select
					Case @error = -1
						_GUICtrlSetWarn($hCheck[2][0])
						GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Error Accessing List"))
						ExitLoop
					Case $iLine = $iLines
						_GUICtrlSetWarn($hCheck[2][0])
						GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Not Currently Listed as Compatible"))
						ExitLoop
					Case StringInStr(_GetCPUInfo(2), $sLine)
						 _GUICtrlSetPass($hCheck[2][0])
						GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Listed as Compatible"))
						ExitLoop
				EndSelect
			Next
		Case Else
			_GUICtrlSetWarn($hCheck[2][0])
	EndSelect

	If _GetCPUInfo(0) >= 2 Or _GetCPUInfo(1) >= 2 Then
		 _GUICtrlSetPass($hCheck[3][0])
	Else
		_GUICtrlSetFail($hCheck[3][0])
	EndIf
	GUICtrlSetData($hCheck[3][2], _GetCPUInfo(0) & " " & _Translate($iMUI, "Cores") & @CRLF & _GetCPUInfo(1) & " " & _Translate($iMUI, "Threads"))

	If _GetCPUInfo(3) >= 1000 Then
		 _GUICtrlSetPass($hCheck[4][0])
		GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	Else
		_GUICtrlSetFail($hCheck[4][0])
		GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	EndIf

	Local $aDisks = _GetDiskInfo(1)
	Switch _GetDiskInfo(0)
		Case "GPT"
			If $aDisks[0] = $aDisks[1] Then
				 _GUICtrlSetPass($hCheck[6][0])
			ElseIf $aDisks[0] = 0 Then
				_GUICtrlSetFail($hCheck[6][0])
				GUICtrlSetData($hCheck[6][2], _Translate($iMUI, "GPT Not Detected") & @CRLF & "0 " & _Translate($iMUI, "Drive(s) Meet Requirements"))
			Else
				_GUICtrlSetWarn($hCheck[6][0], "!")
			EndIf
			GUICtrlSetData($hCheck[6][2], _Translate($iMUI, "GPT Detected") & @CRLF & $aDisks[1] & "/" & $aDisks[0] & " " & _Translate($iMUI, "Drive(s) Meet Requirements"))
		Case Else
			_GUICtrlSetFail($hCheck[6][0])
			GUICtrlSetData($hCheck[6][2], _Translate($iMUI, "GPT Not Detected"))
	EndSwitch

	Local $aMem = DllCall(@SystemDir & "\Kernel32.dll", "int", "GetPhysicallyInstalledSystemMemory", "int*", "")
	If @error Then
		$aMem = MemGetStats()
		$aMem = Round($aMem[1] / 1048576, 1)
		$aMem = Ceiling($aMem)
	Else
		$aMem = Round($aMem[1] / 1048576, 1)
	EndIf
	If $aMem = 0 Then
		$aMem = MemGetStats()
		$aMem = Round($aMem[1] / 1048576, 1)
		$aMem = Ceiling($aMem)
	EndIf

	If $aMem >= 4 Then
		 _GUICtrlSetPass($hCheck[7][0])
		GUICtrlSetData($hCheck[7][2], $aMem & " GB")
	Else
		_GUICtrlSetFail($hCheck[7][0])
		GUICtrlSetData($hCheck[7][2], $aMem & " GB")
	EndIf

	Local $sSecureBoot = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State", "UEFISecureBootEnabled")
	If @error Then $sSecureBoot = 999
	Switch $sSecureBoot
		Case 0
			 _GUICtrlSetPass($hCheck[8][0])
			GUICtrlSetData($hCheck[8][2], _Translate($iMUI, "Supported"))
		Case 1
			 _GUICtrlSetPass($hCheck[8][0])
			GUICtrlSetData($hCheck[8][2], _Translate($iMUI, "Enabled"))
		Case Else
			_GUICtrlSetFail($hCheck[8][0])
			GUICtrlSetData($hCheck[8][2], _Translate($iMUI, "Disabled / Not Detected"))
	EndSwitch


	Local $aDrives = DriveGetDrive($DT_FIXED)
	Local $iDrives = 0

	For $iLoop = 1 To $aDrives[0] Step 1
		If Round(DriveSpaceTotal($aDrives[$iLoop]) / 1024, 0) >= 64 Then $iDrives += 1
	Next


	If Round(DriveSpaceTotal("C:\") / 1024, 0) >= 64 Then
		 _GUICtrlSetPass($hCheck[9][0])
	Else
		_GUICtrlSetFail($hCheck[9][0])
	EndIf
	GUICtrlSetData($hCheck[9][2], Round(DriveSpaceTotal("C:\") / 1024, 0) & " GB C:\" & @CRLF & $iDrives & " " & _Translate($iMUI, "Drive(s) Meet Requirements"))

	Select
		Case _GetTPMInfo(0) = False
			ContinueCase
		Case _GetTPMInfo(1) = False
			_GUICtrlSetFail($hCheck[10][0])
			GUICtrlSetData($hCheck[10][2], _Translate($iMUI, "TPM Missing / Disabled"))
		Case Not Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
			_GUICtrlSetFail($hCheck[10][0])
			GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate($iMUI, "Not Supported"))
		Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 2.0
			 _GUICtrlSetPass($hCheck[10][0])
			GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate($iMUI, "Detected"))
		Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
			;_GUICtrlSetWarn($hCheck[10][0], "OK")
			_GUICtrlSetFail($hCheck[10][0])
			GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate($iMUI, "Detected"))
		Case Else
			_GUICtrlSetFail($hCheck[10][0])
			GUICtrlSetData($hCheck[10][2], _GetTPMInfo(0) & " " & _GetTPMInfo(1) & " " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]))
	EndSelect

	#Region Settings GUI
	Local $hSettings = GUICreate(_Translate($iMUI, "Settings"), 670, 558, 102, 2, $WS_POPUP, $WS_EX_MDICHILD, $hGUI)
	Local $bSettings = False
	GUISetBkColor(_HighContrast(0xF8F8F8))
	GUISetFont($aFonts[$FontSmall] * _GDIPlus_GraphicsGetDPIRatio()[0], $FW_BOLD, "", "Arial")

	GUICtrlSetDefColor(_WinAPI_GetSysColor($COLOR_WINDOWTEXT))
	GUICtrlSetDefBkColor(_HighContrast(0xF8F8F8))

	GUICtrlCreateGroup("", 30, 30, 640, 100)

	#EndRegion

	GUISwitch($hGUI)

	GUISetState(@SW_SHOW, $hGUI)

	Local $hMsg, $sDXFile
	While 1
		$hMsg = GUIGetMsg()

		Select

			Case $hMsg = $GUI_EVENT_CLOSE Or $hMsg = $hExit
				GUIDelete($hGUI)
				Exit

				; DirectX 12 takes a while. Grab the result once done
			Case Not ProcessExists("dxdiag.exe") And FileExists($hDXFile)
				$sDXFile = StringStripWS(StringStripCR(FileRead($hDXFile)), $STR_STRIPALL)
				Select
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "3") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:3") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM3")
						 _GUICtrlSetPass($hCheck[5][0])
						GUICtrlSetData($hCheck[5][2], "DirectX 12 && WDDM 3")   ; <== No translatin, "DirectX 12 and WDDM 3" in LANG-file
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "2") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:2") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
						 _GUICtrlSetPass($hCheck[5][0])
						GUICtrlSetData($hCheck[5][2], "DirectX 12 && WDDM 2")   ; <== No translatin, "DirectX 12 and WDDM 2" in LANG-file
					Case Not StringInStr($sDXFile, "FeatureLevels:12") Or Not StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
						_GUICtrlSetFail($hCheck[5][0])
						GUICtrlSetData($hCheck[5][2], _Translate($iMUI, "No DirectX 12, but WDDM2"))
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And Not StringInStr($sDXFile, "DriverModel:WDDM2")
						_GUICtrlSetFail($hCheck[5][0])
						GUICtrlSetData($hCheck[5][2], _Translate($iMUI, "DirectX 12, but no WDDM2"))
					Case Else
						_GUICtrlSetFail($hCheck[5][0])
						GUICtrlSetData($hCheck[5][2], _Translate($iMUI, "No DirectX 12 or WDDM2"))
				EndSelect
				FileDelete($hDXFile)

			Case $hMsg = $hDumpLang
				FileDelete(@LocalAppDataDir & "\WhyNotWin11\langs\")

			Case $hMsg = $hJob
				ShellExecute("https://fcofix.org/rcmaehl/wiki/I'M-FOR-HIRE")

			Case $hMsg = $hGithub
				ShellExecute("https://fcofix.org/WhyNotWin11")

			Case $hMsg = $hDonate
				ShellExecute("https://paypal.me/rhsky")

			Case $hMsg = $hDiscord
				ShellExecute("https://discord.gg/uBnBcBx")

			Case $hMsg = $hLTT
				ShellExecute("https://linustechtips.com/topic/1350354-windows-11-readiness-check-whynotwin11/")

			Case $hMsg = $hToggle
				If $bSettings Then
					GUISetState(@SW_HIDE, $hSettings)
				Else
					GUISetState(@SW_SHOW, $hSettings)
				EndIf
				$bSettings = Not $bSettings

			Case $hMsg = $hUpdate
				Switch _GetLatestRelease($sVersion)
					Case -1
						MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Test Build?"), _Translate($iMUI, "You're running a newer build than publicly Available!"), 10)
					Case 0
						Switch @error
							Case 0
								MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_TOPMOST, _Translate($iMUI, "Up to Date"), _Translate($iMUI, "You're running the latest build!"), 10)
							Case 1
								MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Unable to Check for Updates"), _Translate($iMUI, "Unable to load release data."), 10)
							Case 2
								MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Unable to Check for Updates"), _Translate($iMUI, "Invalid Data Received!"), 10)
							Case 3
								Switch @extended
									Case 0
										MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Unable to Check for Updates"), _Translate($iMUI, "Invalid Release Tags Received!"), 10)
									Case 1
										MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Unable to Check for Updates"), _Translate($iMUI, "Invalid Release Types Received!"), 10)
								EndSwitch
						EndSwitch
					Case 1
						If MsgBox($MB_YESNO + $MB_ICONINFORMATION + $MB_TOPMOST, _Translate($iMUI, "Update Available"), _Translate($iMUI, "An Update is Available, would you like to download it?"), 10) = $IDYES Then ShellExecute("https://fcofix.org/WhyNotWin11/releases")
				EndSwitch

			Case Else
				;;;

		EndSelect
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

Func ParseResults($aResults)

	Local $aLabel[11] = ["Architecture (CPU + OS)", "Boot Method", "CPU Compatibility", "CPU Core Count", "CPU Frequency", "DirectX + WDDM2", "Disk Partition Type", "RAM Installed", "Secure Boot", "Storage Available", "TPM Version"]

	Switch $aOutput[0]
		Case "txt"
			Local $sFile
			If StringInStr($aOutput[1], ":") Then
				$sFile = $aOutput[1]
			Else
				$sFile = @ScriptDir & "\" & $aOutput[1]
			EndIf
			Local $hFile = FileOpen($sFile, $FO_CREATEPATH + $FO_OVERWRITE)
			FileWrite($hFile, "Results for " & @ComputerName & @CRLF)
			For $iLoop = 0 To 10 Step 1
				FileWrite($hFile, $aLabel[$iLoop] & @TAB & $aResults[$iLoop][0] & @TAB & $aResults[$iLoop][1] & @TAB & $aResults[$iLoop][2] & @CRLF)
			Next
			FileClose($hFile)
		Case Else
			;;;
	EndSwitch

EndFunc   ;==>ParseResults

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

Func _HighContrast($sColor)
	Local Static $sSysWin

	If Not $sSysWin <> "" Then $sSysWin = _WinAPI_GetSysColor($COLOR_WINDOW)

	Select
		Case $sSysWin = 0
			ContinueCase
		Case $sSysWin = 16777215 And Not RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
			Return 16777215 - $sColor
		Case Else
			Return $sSysWin + $sColor + 1
	EndSelect

EndFunc   ;==>_HighContrast

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

Func _Security()
	If WinExists("WhyNotWin11 - Check Why Your PC Can't Run Windows 11") Then
		MsgBox($MB_TOPMOST+$MB_ICONWARNING, "Alert", _
			"WhyNotWin11 has detected that it may have been downloaded from a suspicious site. " & _
			"The owner of this site has refused to contact us and has hosted suspect files trying" & _
			" to hide they fact they are not affiliated before. Please see GitHub issue #66.")
	EndIf
EndFunc

Func _SetBannerText($hBannerText, $hBanner)

	Local $bLinux = False
	Local $hModule = _WinAPI_GetModuleHandle(@SystemDir & "\ntdll.dll")

	If _WinAPI_GetProcAddress($hModule, "wine_get_host_version") Then $bLinux = True

	Select
		Case $bLinux
			GUICtrlSetData($hBannerText, "i3 BEST WM")
			Return "https://archlinux.org/"
			GUICtrlSetCursor($hBannerText, 0)
			GUICtrlSetCursor($hBanner, 0)
		Case @LogonDomain <> @ComputerName
			GUICtrlSetData($hBannerText, "I'M FOR HIRE")
			Return "https://fcofix.org/rcmaehl/wiki/I'M-FOR-HIRE"
			GUICtrlSetCursor($hBannerText, 0)
			GUICtrlSetCursor($hBanner, 0)
		Case Else
			GUICtrlSetState($hBanner, $GUI_HIDE)
			GUICtrlSetState($hBannerText, $GUI_HIDE)
			GUICtrlSetCursor($hBanner, 2)
	EndSelect

EndFunc   ;==>_SetBannerText

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

	$hIcon =  _Resource_GetAsIcon($iIndex, "RC_DATA", $sIcon)

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

Func  _GUICtrlSetPass($hCtrl)
	GUICtrlSetData($hCtrl, "OK")
	GUICtrlSetBkColor($hCtrl, 0x4CC355)
EndFunc   ;==> _GUICtrlSetPass

Func _GUICtrlSetFail($hCtrl)
	GUICtrlSetData($hCtrl, "X")
	GUICtrlSetBkColor($hCtrl, 0xFA113D)
EndFunc   ;==>_GUICtrlSetFail

Func _GUICtrlSetWarn($hCtrl, $symbol = "?")
	GUICtrlSetData($hCtrl, $symbol)
	GUICtrlSetBkColor($hCtrl, 0xF4C141)
EndFunc   ;==>_GUICtrlSetWarn
