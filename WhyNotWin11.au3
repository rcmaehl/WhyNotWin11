#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Assets\windows11-logo.ico
#AutoIt3Wrapper_Outfile=WhyNotWin11_x86.exe
#AutoIt3Wrapper_Outfile_x64=WhyNotWin11.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Detection Script to help identify why your PC isn't Windows 11 Release Ready
#AutoIt3Wrapper_Res_Fileversion=2.3.1
#AutoIt3Wrapper_Res_ProductName=WhyNotWin11
#AutoIt3Wrapper_Res_ProductVersion=2.3.1
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Icon_Add=Assets\git.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\pp.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\dis.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\web.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\job.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\set.ico
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7 -v1 -v2 -v3
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $aResults[11][4]
Global $sVersion = "2.3.1.0"
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

Global $WINDOWS_DRIVE = EnvGet("SystemDrive")

#include "Includes\ResourcesEx.au3"

#include "Includes\_WMIC.au3"
#include "Includes\_Checks.au3"
#include "Includes\_Theming.au3"
#include "Includes\_Resources.au3"
#include "Includes\_GetDiskInfo.au3"
#include "Includes\_Translations.au3"
; #include "includes\WhyNotWin11_accessibility.au3"

Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)
Switch @OSVersion
	Case "WIN_7", "WIN_VISTA", "WIN_XP", "WIN_XPe"
		MsgBox($MB_ICONWARNING, _Translate(@MUILang, "Not Supported"), @OSVersion & " " & _Translate(@MUILang, "Not Supported"))
		Exit 1
	Case "WIN_8", "WIN_8.1"
		MsgBox($MB_ICONWARNING, _Translate(@MUILang, "Warning"), StringReplace(_Translate(@MUILang, "May Report DirectX 12 Incorrectly"), '#', @OSVersion))
	Case Else
		;;;
EndSwitch

Global $__g_hModule = _WinAPI_GetModuleHandle(@SystemDir & "\ntdll.dll")
If @OSBuild >= 22000 Or _WinAPI_GetProcAddress($__g_hModule, "wine_get_host_version") Then
	MsgBox($MB_ICONWARNING, _Translate(@MUILang, "Your Windows 11 Compatibility Results are Below"), _Translate(@MUILang, "You're running the latest build!"))
	Exit 1
EndIf

If $CmdLine[0] > 0 Then ProcessCMDLine()
ExtractFiles()
Main()

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

	$aResults[3][0] = _CPUCoresCheck(_GetCPUInfo(0), _GetCPUInfo(1))
	$aResults[3][1] = @error
	$aResults[3][2] = @extended

	$aResults[4][0] = _CPUSpeedCheck()
	$aResults[4][1] = @error
	$aResults[4][2] = @extended

	$aDirectX = _DirectXStartCheck()

	Local $aDisks, $aPartitions
	_GetDiskInfoFromWmi($aDisks, $aPartitions, 1)
	$aResults[6][0] = _GPTCheck($aDisks)
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

Func Main()

	Local Static $iMUI = @MUILang
	Local Static $aFonts[4]
	$aFonts = _GetTranslationFonts($iMUI)

	Local Enum $iFail = 0, $iPass, $iUnsure, $iWarn

	Local Enum $FontSmall, $FontMedium, $FontLarge, $FontExtraLarge
	Local Const $DPI_RATIO = _GDIPlus_GraphicsGetDPIRatio()[0]
	Local $aDisks, $aPartitions

	ProgressOn("WhyNotWin11", "Loading WMIC")
	ProgressSet(0, "_GetCPUInfo()")
	_GetCPUInfo()
	ProgressSet(20, "_GetDiskInfo()")
	_GetDiskInfo()
	ProgressSet(40, "_GetGPUInfo()")
	_GetGPUInfo()
	ProgressSet(60, "_GetTPMInfo()")
	_GetTPMInfo()
	ProgressSet(80, "_GetDiskInfoFromWmi")
	_GetDiskInfoFromWmi($aDisks, $aPartitions, 1)
	ProgressSet(100, "Done")

	Local $hGUI = GUICreate("WhyNotWin11", 800, 600, -1, -1, BitOR($WS_POPUP, $WS_BORDER))
	GUISetBkColor(_HighContrast(0xF8F8F8))
	GUISetFont($aFonts[$FontSmall] * $DPI_RATIO, $FW_BOLD, "", "Arial")

	GUICtrlSetDefColor(_WinAPI_GetSysColor($COLOR_WINDOWTEXT))
	GUICtrlSetDefBkColor(_HighContrast(0xF8F8F8))

	Local $sCheck = _CheckAppsUseLightTheme()
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
	Local $hUpdate = GUICtrlCreateLabel("", 0, 570, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlSetCursor(-1, 0)

	#cs Maybe Readd Later
	; Top Most Interaction for Banner
	Local $hBanner = GUICtrlCreateLabel("", 5, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	#ce Maybe Readd Later

	; Top Most Interaction for Closing Window
	Local $hExit = GUICtrlCreateLabel("", 760, 10, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontExtraLarge] * $DPI_RATIO, $FW_MEDIUM)
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

	GUICtrlCreateLabel("", 0, 0, 100, 570)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	GUICtrlCreateLabel(_Translate($iMUI, "Check for Updates"), 0, 570, 100, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontSmall] * $DPI_RATIO, $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlSetTip(-1, "Update")
	GUICtrlSetCursor(-1, 0)

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

	GUICtrlCreateLabel("WhyNotWin11", 10, 10, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlCreateLabel("v " & $sVersion, 10, 30, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	GUICtrlCreateLabel(_Translate($iMUI, "Check for Updates"), 5, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontSmall] * $DPI_RATIO, $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	GUICtrlCreateLabel("", 100, 560, 700, 40)
	GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))

	#cs Maybe Readd Later
	Local $hBannerText = GUICtrlCreateLabel("", 130, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontSmall] * $DPI_RATIO, $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	Local $sBannerURL = _SetBannerText($hBannerText, $hBanner)
	#ce Maybe Readd Later

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

	GUICtrlCreateLabel(_Translate($iMUI, "Your Windows 11 Compatibility Results are Below"), 130, 10, 640, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_SEMIBOLD, "", "", $CLEARTYPE_QUALITY)

	#cs
	Local $h_WWW = GUICtrlCreateLabel(_Translate($iMUI, "Now Reach WhyNotWin11 via https://www.whynotwin11.org/"), 130, 45, 640, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO)
	GUICtrlSetCursor(-1, 0)
	#ce

	GUICtrlCreateLabel(_Translate($iMUI, "Results Based on Currently Known Requirements!"), 130, 45, 640, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetColor(-1, 0xE20012)
	GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO)

	GUICtrlCreateLabel(ChrW(0x274C), 765, 5, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_NORMAL)

	Local $hCheck[11][3]
	Local $hLabel[11] = ["Architecture", "Boot Method", "CPU Compatibility", "CPU Core Count", "CPU Frequency", "DirectX + WDDM2", "Disk Partition Type", "RAM Installed", "Secure Boot", "Storage Available", "TPM Version"]
	Local $hInfo[11]

	_GDIPlus_Startup()
	For $iRow = 0 To 10 Step 1
		$hCheck[$iRow][0] = GUICtrlCreateLabel("?", 113, 110 + $iRow * 40, 40, 40, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, 0xE6E6E6)
		$hCheck[$iRow][1] = GUICtrlCreateLabel(" " & _Translate($iMUI, $hLabel[$iRow]), 153, 110 + $iRow * 40, 297, 40, $SS_CENTERIMAGE)
		GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_NORMAL)
		$hCheck[$iRow][2] = GUICtrlCreateLabel(_Translate($iMUI, "Checking..."), 450, 110 + $iRow * 40, 300, 40, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE)
		If $iRow = 0 Or $iRow = 3 Or $iRow = 6 Or $iRow = 9 Then GUICtrlSetStyle(-1, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO, $FW_SEMIBOLD)
		If @Compiled Then
			$hInfo[$iRow] = GUICtrlCreateIcon("", -1, 763, 118 + $iRow * 40, 24, 40, $SS_CENTERIMAGE + $SS_CENTER)
			_SetBkSelfIcon(-1, 0xF8F8F8, @ScriptFullPath, 201, 24, 24)
		Else
			$hInfo[$iRow] = GUICtrlCreateIcon("", -1, 763, 118 + $iRow * 40, 24, 40)
			_SetBkIcon(-1, 0xF8F8F8, @ScriptDir & "\assets\inf.ico", -1, 24, 24)
		EndIf
	Next
	_GDIPlus_Shutdown()

	Local $hDXFile = _TempFile(@TempDir, "dxdiag")
	Local $hDXPID = Run(@SystemDir & "\dxdiag.exe /whql:off /t " & $hDXFile)

	Switch _ArchCheck()
		Case True
			_GUICtrlSetState($hCheck[0][0], $iPass)
			GUICtrlSetData($hCheck[0][2], _Translate($iMUI, "64 Bit CPU") & @CRLF & _Translate($iMUI, "64 Bit OS"))
		Case Else
			Switch @error
				Case 1
					_GUICtrlSetState($hCheck[0][0], $iWarn)
					GUICtrlSetData($hCheck[0][2], _Translate($iMUI, "64 Bit CPU") & @CRLF & _Translate($iMUI, "32 bit OS"))
				Case 2
					_GUICtrlSetState($hCheck[0][0], $iFail)
					GUICtrlSetData($hCheck[0][2], _Translate($iMUI, "32 Bit CPU") & @CRLF & _Translate($iMUI, "32 Bit OS"))
				Case Else
					_GUICtrlSetState($hCheck[0][0], $iFail)
					GUICtrlSetData($hCheck[0][2], "?")
			EndSwitch
	EndSwitch

	Switch _BootCheck()
		Case True
			_GUICtrlSetState($hCheck[1][0], $iPass)
			GUICtrlSetData($hCheck[1][2], "UEFI")
		Case False
			Switch @error
				Case 0
					_GUICtrlSetState($hCheck[1][0], $iFail)
					GUICtrlSetData($hCheck[1][2], "Legacy")
				Case Else
					GUICtrlSetData($hCheck[1][2], @extended)
					_GUICtrlSetState($hCheck[1][0], $iWarn)
			EndSwitch
	EndSwitch


	Switch _CPUNameCheck(_GetCPUInfo(2))
		Case False
			Switch @error
				Case 1
					_GUICtrlSetState($hCheck[2][0], $iWarn)
					GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Unable to Check List"))
				Case 2
					_GUICtrlSetState($hCheck[2][0], $iWarn)
					GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Error Accessing List"))
				Case 3
					_GUICtrlSetState($hCheck[2][0], $iUnsure)
					GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Not Currently Listed as Compatible"))
			EndSwitch
		Case Else
			_GUICtrlSetState($hCheck[2][0], $iPass)
			GUICtrlSetData($hCheck[2][2], _Translate($iMUI, "Listed as Compatible"))
	EndSwitch

	#Region - Determining CPU properties
	If _CPUCoresCheck(_GetCPUInfo(0), _GetCPUInfo(1)) Then
		_GUICtrlSetState($hCheck[3][0], $iPass)
	Else
		_GUICtrlSetState($hCheck[3][0], $iFail)
	EndIf

	Local $sCores = StringReplace(_Translate($iMUI, "Cores"), '#', _GetCPUInfo(0))
	If @extended = 0 Then $sCores = _GetCPUInfo(0) & " " & $sCores
	Local $sThreads = StringReplace(_Translate($iMUI, "Threads"), '#', _GetCPUInfo(1))
	If @extended = 0 Then $sThreads = _GetCPUInfo(1) & " " & $sThreads
	GUICtrlSetData($hCheck[3][2], $sCores & @CRLF & $sThreads)

	If _GetCPUInfo(3) >= 1000 Then
		_GUICtrlSetState($hCheck[4][0], $iPass)
		GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	Else
		_GUICtrlSetState($hCheck[4][0], $iFail)
		GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	EndIf
	#EndRegion - Determining CPU properties

	Local $aDirectX
	$aDirectX = _DirectXStartCheck()

	If _GPTCheck($aDisks) Then
		If @error Then
			_GUICtrlSetState($hCheck[6][0], $iPass)
			GUICtrlSetData($hCheck[6][2], _Translate($iMUI, "GPT Detected"))
		Else
			_GUICtrlSetState($hCheck[6][0], $iPass)
			GUICtrlSetData($hCheck[6][2], _Translate($iMUI, "GPT Detected"))
		EndIf
	Else
		GUICtrlSetData($hCheck[6][2], _Translate($iMUI, "GPT Not Detected") & @CRLF & @error)
		_GUICtrlSetState($hCheck[6][0], $iFail)
	EndIf

	If _MemCheck() Then
		_GUICtrlSetState($hCheck[7][0], $iPass)
		GUICtrlSetData($hCheck[7][2], _MemCheck() & " GB")
	Else
		_GUICtrlSetState($hCheck[7][0], $iFail)
		GUICtrlSetData($hCheck[7][2], _MemCheck() & " GB")
	EndIf

	Switch _SecureBootCheck()
		Case 2
			_GUICtrlSetPass($hCheck[8][0])
			GUICtrlSetData($hCheck[8][2], _Translate($iMUI, "Enabled"))
		Case True
			_GUICtrlSetPass($hCheck[8][0])
			GUICtrlSetData($hCheck[8][2], _Translate($iMUI, "Supported"))
		Case False
			_GUICtrlSetFail($hCheck[8][0])
			GUICtrlSetData($hCheck[8][2], _Translate($iMUI, "Disabled / Not Detected"))
	EndSwitch

	_SpaceCheck()
	GUICtrlSetData($hCheck[9][2], @error & " GB " & $WINDOWS_DRIVE & @CRLF & @extended & " " & _Translate($iMUI, "Drive(s) Meet Requirements"))
	If _SpaceCheck() Then
		_GUICtrlSetPass($hCheck[9][0])
	Else
		_GUICtrlSetFail($hCheck[9][0])
	EndIf

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
	Local $hSettings = GUICreate(_Translate($iMUI, "Settings"), 698, 528, 102, 32, $WS_POPUP, $WS_EX_MDICHILD, $hGUI)
	Local $bSettings = False
	GUISetBkColor(_HighContrast(0xF8F8F8))
	GUISetFont($aFonts[$FontSmall] * $DPI_RATIO, $FW_BOLD, "", "Arial")

	GUICtrlSetDefColor(_WinAPI_GetSysColor($COLOR_WINDOWTEXT))
	GUICtrlSetDefBkColor(_HighContrast(0xF8F8F8))

	GUICtrlCreateGroup("Info", 30, 20, 638, 100)
	If @Compiled Then
		GUICtrlCreateIcon(@ScriptFullPath, 99, 50, 30, 40, 40)
	Else
		GUICtrlCreateIcon(@ScriptDir & "\assets\windows11-logo.ico", -1, 50, 50, 40, 40)
	EndIf

	#EndRegion Settings GUI

	GUISwitch($hGUI)

	ProgressOff()
	GUISetState(@SW_SHOW, $hGUI)

	Local $hMsg, $sDXFile
	While 1
		$hMsg = GUIGetMsg()

		Select

			Case $hMsg = $GUI_EVENT_CLOSE Or $hMsg = $hExit
				GUIDelete($hGUI)
				Exit

				#cs
				Case $hMsg = $h_WWW
					ShellExecute("https://www.whynotwin11.org/")
				#ce

				; DirectX 12 takes a while. Grab the result once done
			Case _GetDirectXCheck($aDirectX)
			Case (Not ProcessExists($hDXPID)) And FileExists($hDXFile)
				$sDXFile = StringStripWS(StringStripCR(FileRead($hDXFile)), $STR_STRIPALL)
				Select
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "3") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:3") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM3")
						_GUICtrlSetPass($hCheck[5][0])
						GUICtrlSetData($hCheck[5][2], "DirectX 12 && WDDM 3")   ; <== No translation, "DirectX 12 and WDDM 3" in LANG-file
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "2") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:2") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "FeatureLevels:12") Or StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
						_GUICtrlSetPass($hCheck[5][0])
						GUICtrlSetData($hCheck[5][2], "DirectX 12 && WDDM 2")   ; <== No translation, "DirectX 12 and WDDM 2" in LANG-file
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

Func _GUICtrlSetState($hCtrl, $iState)
	Switch $iState
		Case 0
			GUICtrlSetData($hCtrl, "X")
			GUICtrlSetBkColor($hCtrl, 0xFA113D)
		Case 1
			GUICtrlSetData($hCtrl, "OK")
			GUICtrlSetBkColor($hCtrl, 0x4CC355)
		Case 2
			GUICtrlSetData($hCtrl, "?")
			GUICtrlSetBkColor($hCtrl, 0xF4C141)
		Case 3
			GUICtrlSetData($hCtrl, "!")
			GUICtrlSetBkColor($hCtrl, 0xF4C141)
	EndSwitch
EndFunc   ;==>_GUICtrlSetState


Func _GUICtrlSetPass($hCtrl)
	GUICtrlSetData($hCtrl, "OK")
	GUICtrlSetBkColor($hCtrl, 0x4CC355)
EndFunc   ;==>_GUICtrlSetPass

Func _GUICtrlSetFail($hCtrl)
	GUICtrlSetData($hCtrl, "X")
	GUICtrlSetBkColor($hCtrl, 0xFA113D)
EndFunc   ;==>_GUICtrlSetFail

Func _GUICtrlSetWarn($hCtrl, $symbol = "?")
	GUICtrlSetData($hCtrl, $symbol)
	GUICtrlSetBkColor($hCtrl, 0xF4C141)
EndFunc   ;==>_GUICtrlSetWarn