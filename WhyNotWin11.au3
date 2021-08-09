#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Assets\WhyNotWin11.ico
#AutoIt3Wrapper_Outfile=WhyNotWin11_x86.exe
#AutoIt3Wrapper_Outfile_x64=WhyNotWin11.exe
#AutoIt3Wrapper_Compile_Both=Y
#AutoIt3Wrapper_UseX64=Y
#AutoIt3Wrapper_Res_Comment=https://www.whynotwin11.org
#AutoIt3Wrapper_Res_Description=Detection Script to help identify why your PC isn't Windows 11 Release Ready
#AutoIt3Wrapper_Res_Fileversion=2.3.2.0
#AutoIt3Wrapper_Res_ProductName=WhyNotWin11
#AutoIt3Wrapper_Res_ProductVersion=2.3.2
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Res_Compatibility=Win8,Win81,Win10
#AutoIt3Wrapper_Res_Icon_Add=Assets\GitHub.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\PayPal.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\Discord.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\Web.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\HireMe.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\Settings.ico
#AutoIt3Wrapper_Res_Icon_Add=Assets\Info.ico
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7 -v1 -v2 -v3
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/tc 0 /serc /scec
#AutoIt3Wrapper_Run_Au3Stripper=Y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $sVersion = "2.3.2.0"
FileChangeDir(@SystemDir)

#include <File.au3>
#include <Misc.au3>
#include <Array.au3>
#include <String.au3>
#include <GDIPlus.au3>
#include <WinAPIGDI.au3>
#include <WinAPISys.au3>
#include <TabConstants.au3>
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

ExtractFiles()

#Region ; OS Checks
Switch @OSVersion
	Case "WIN_7", "WIN_VISTA", "WIN_XP", "WIN_XPe"
		MsgBox($MB_ICONWARNING, _Translate(@MUILang, "Not Supported"), @OSVersion & " " & _Translate(@MUILang, "Not Supported"))
		Exit 1
	Case "WIN_8", "WIN_8.1"
		MsgBox($MB_ICONWARNING, _Translate(@MUILang, "Warning"), StringReplace(_Translate(@MUILang, "May Report DirectX 12 Incorrectly"), '#', @OSVersion))
	Case Else
		;;;
EndSwitch

If @OSBuild >= 22000 Or _WinAPI_GetProcAddress(_WinAPI_GetModuleHandle(@SystemDir & "\ntdll.dll"), "wine_get_host_version") Then
	MsgBox($MB_ICONWARNING, _Translate(@MUILang, "Not Supported"), _Translate(@MUILang, "You're running the latest build!"))
EndIf
#EndRegion

ProcessCMDLine()

Func ProcessCMDLine()
	Local $aResults
	Local $bSilent = False
	Local $aOutput[3] = [False, "", ""]
	#forceref $aOutput
	Local $iParams = $CmdLine[0]

	If $iParams > 0 Then
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
							@TAB & "formats" & @TAB & "TXT, CSV" & @CRLF & _
							@TAB & "/silent" & @TAB & "Don't Display the GUI. Compatible Systems will Exit" & @CRLF & _
							@TAB & "       " & @TAB & "with ERROR_SUCCESS." & @CRLF & _
							@CRLF & _
							"All flags can be shortened to just the first character (e.g. /s)" & @CRLF)
					Exit 0
				Case "/s", "/silent"
					$bSilent = True
					_ArrayDelete($CmdLine, 1)
					If UBound($CmdLine) = 1 Then ExitLoop
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
								Case "CSV", "TXT"
									$aOutput[0] = True
									$aOutput[1] = $CmdLine[2]
									$aOutput[2] = $CmdLine[3]
									_ArrayDelete($CmdLine, "1-3")
									If UBound($CmdLine) = 1 Then ExitLoop
								Case Else
									MsgBox(0, "Invalid", "Invalid FORMAT parameter for /format." & @CRLF)
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
	EndIf

	If Not $bSilent Then ProgressOn("WhyNotWin11", _Translate(@MUILang, "Loading WMIC"))

	$aResults = RunChecks($bSilent)

	ProgressSet(80, "Done")

	If Not $bSilent Then
		Main($aResults, $aOutput)
	Else
		FinalizeResults($aResults)
	EndIf
	If $aOutput[0] = True Then OutputResults($aResults, $aOutput)
	For $iLoop = 0 To 10 Step 1
		If $aResults[$iLoop][0] = False Or $aResults[$iLoop][0] < 1 Then Exit 1
	Next
	Exit 0

EndFunc   ;==>ProcessCMDLine

Func RunChecks($bSilent)

	#forceref $bSilent

	Local $aResults[11][3]

	$aResults[0][0] = _ArchCheck()
	$aResults[0][1] = @error
	$aResults[0][2] = @extended

	$aResults[1][0] = _BootCheck()
	$aResults[1][1] = @error
	$aResults[1][2] = @extended

	$aResults[2][0] = _CPUNameCheck(_GetCPUInfo(2), _GetCPUInfo(5))
	$aResults[2][1] = @error
	$aResults[2][2] = @extended

	$aResults[3][0] = _CPUCoresCheck(_GetCPUInfo(0), _GetCPUInfo(1))
	$aResults[3][1] = @error
	$aResults[3][2] = @extended

	$aResults[4][0] = _CPUSpeedCheck()
	$aResults[4][1] = @error
	$aResults[4][2] = @extended

	$aResults[5][0] = _DirectXStartCheck()
	$aResults[5][1] = -1
	$aResults[5][2] = -1

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

	Return $aResults

EndFunc   ;==>RunChecks

Func Main(ByRef $aResults, ByRef $aOutput)

	; Disable Scaling
	If @OSVersion = 'WIN_10' Then DllCall(@SystemDir & "\User32.dll", "bool", "SetProcessDpiAwarenessContext", "HWND", "DPI_AWARENESS_CONTEXT" - 1)

	Local Static $aFonts[5]
	Local Static $aColors[4] ; Convert to [4][8] for 2.0 themes
	Local Static $iMUI = @MUILang

	#cs ; 2.0 Theming Enums
	Local Enum $iGeneral = 0, $iText, $iIcons, $iStatus

	Local Enum $iBackground = 0, $iSidebar, $iFooter, $iResults
	Local Enum $iDefault = 0, $iName, $iVersion, $iHeader, $iSubHead, $iLinks, $iChecks, $iResults
	Local Enum $iGithub = 0, $iDonate, $iDiscord, $iLTT, $iWork, $iSettings
	Local Enum $iFail = 0, $iPass, $iUnsure, $iWarn, $iRunning
	#ce

	$aColors = _SetTheme()
	$aFonts = _GetTranslationFonts($iMUI)

	Local $aDirectX = $aResults[5][0]

	Local Enum $iFail = 0, $iPass, $iUnsure, $iWarn
	Local Enum $iBackground = 0, $iText, $iSidebar, $iFooter

	Local Const $DPI_RATIO = _GDIPlus_GraphicsGetDPIRatio()[0]
	Local Enum $FontSmall, $FontMedium, $FontLarge, $FontExtraLarge

	ProgressSet(100, _Translate($iMUI, "Done"))

	Local $hGUI = GUICreate("WhyNotWin11", 800, 600, -1, -1, BitOR($WS_POPUP, $WS_BORDER), _GetTranslationRTL($iMUI))
	GUISetBkColor($aColors[$iBackground])
	GUISetFont($aFonts[$FontSmall] * $DPI_RATIO, $FW_BOLD, "", $aFonts[4])

	GUICtrlSetDefColor($aColors[$iText])
	GUICtrlSetDefBkColor($aColors[$iBackground])

	Local $hDumpLang = GUICtrlCreateDummy()

	; Debug Key
	Local $aAccel[1][2] = [["{DEL}", $hDumpLang]]
	GUISetAccelerators($aAccel)

	#Region Sidebar
	; Top Most Interaction for Update Text
	Local $hUpdate = GUICtrlCreateLabel("", 0, 560, 90, 60, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])
	GUICtrlSetCursor(-1, 0)

	#cs Maybe Readd Later
	; Top Most Interaction for Banner
	Local $hBanner = GUICtrlCreateLabel("", 5, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])
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
	GUICtrlSetState(-1, $GUI_HIDE)

	; Allow Dragging of Window
	GUICtrlCreateLabel("", 0, 0, 800, 30, -1, $GUI_WS_EX_PARENTDRAG)

	GUICtrlCreateLabel("", 0, 0, 100, 570)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])

	GUICtrlCreateLabel(_Translate($iMUI, "Check for Updates"), 0, 563, 100, 60, $SS_CENTER)
	GUICtrlSetFont(-1, $aFonts[$FontSmall] * $DPI_RATIO, $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])
	GUICtrlSetTip(-1, "Update")
	GUICtrlSetCursor(-1, 0)

	_GDIPlus_Startup()
	If @Compiled Then
		GUICtrlCreateIcon("", -1, 34, 110, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 201, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 160, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 202, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 210, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 203, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 260, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 204, 32, 32)
		If @LogonDomain <> @ComputerName Then
			GUICtrlCreateIcon("", -1, 34, 310, 32, 32)
			_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 205, 32, 32)
		EndIf
		GUICtrlCreateIcon("", -1, 34, 518, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 206, 32, 32)
		GUICtrlSetState(-1, $GUI_HIDE)
	Else
		GUICtrlCreateIcon("", -1, 34, 110, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & "\assets\GitHub.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 160, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\PayPal.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 210, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\Discord.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 260, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\Web.ico", -1, 32, 32)
		If @LogonDomain <> @ComputerName Then
			GUICtrlCreateIcon("", -1, 34, 310, 32, 32)
			_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\HireMe.ico", -1, 32, 32)
		EndIf
		GUICtrlCreateIcon("", -1, 34, 518, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\Settings.ico", -1, 32, 32)
		GUICtrlSetState(-1, $GUI_HIDE)
	EndIf
	_GDIPlus_Shutdown()

	GUICtrlCreateLabel("WhyNotWin11", 10, 10, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])
	GUICtrlCreateLabel("v " & $sVersion, 10, 30, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])
	#EndRegion

	#Region Footer
	GUICtrlCreateLabel("", 100, 560, 700, 40)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])

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

	GUICtrlCreateLabel(_GetCPUInfo(2), 450, 560, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])
	GUICtrlCreateLabel(_GetGPUInfo(0), 450, 580, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])
	#EndRegion

	#Region Header
	GUICtrlCreateLabel(_Translate($iMUI, "Your Windows 11 Compatibility Results Are Below"), 130, 10, 640, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_SEMIBOLD, "", "", $CLEARTYPE_QUALITY)

	#cs
	Local $h_WWW = GUICtrlCreateLabel(_Translate($iMUI, "Now Reach WhyNotWin11 via https://www.whynotwin11.org/"), 130, 45, 640, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO)
	GUICtrlSetCursor(-1, 0)
	#ce

	GUICtrlCreateLabel("* " & _Translate($iMUI, "Results based on currently known requirements!"), 130, 45, 640, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetColor(-1, 0xE20012)
	GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO)

	GUICtrlCreateLabel(ChrW(0x274C), 765, 5, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_NORMAL)
	#EndRegion

	#cs
	Local $hTab = GUICtrlCreateTab(100, 80, 700, 520, BitOR($TCS_BUTTONS,$TCS_FLATBUTTONS,$TCS_FOCUSNEVER))
	GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO)
	#ce

	#Region Summary Tab
	;Local $hSummary = GUICtrlCreateTabItem("Summary")

	#EndRegion

	#Region Basic Checks Tab
	;Local $hBasic = GUICtrlCreateTabItem("Basic Checks")
	;GUICtrlSetColor(-1, $aColors[$iBackground])

	Local $hCheck[11][3]
	Local $hLabel[11] = ["Architecture", "Boot Method", "CPU Compatibility", "CPU Core Count", "CPU Frequency", "DirectX + WDDM2", "Disk Partition Type", "RAM Installed", "Secure Boot", "Storage Available", "TPM Version"]
	Local $aInfo = _GetDescriptions($iMUI)

	_GDIPlus_Startup()
	For $iRow = 0 To 10 Step 1
		;		GUICtrlCreateLabel("", 113, 113 + $iRow * 40, 637, 32)
		;		GUICtrlSetBkColor(-1, $aColors[$iFooter])
		$hCheck[$iRow][0] = GUICtrlCreateLabel("…", 113, 110 + $iRow * 40, 40, 40, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, $aColors[$iBackground])
		GUICtrlCreateIcon("", -1, 763, 118 + $iRow * 40, 24, 40)
		$hCheck[$iRow][1] = GUICtrlCreateLabel(" " & _Translate($iMUI, $hLabel[$iRow]), 153, 110 + $iRow * 40, 297, 40, $SS_CENTERIMAGE)
		GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_NORMAL)
		$hCheck[$iRow][2] = GUICtrlCreateLabel(_Translate($iMUI, "Checking..."), 450, 110 + $iRow * 40, 300, 40, $SS_SUNKEN)
		Switch $iRow
			Case 0, 3, 9
				GUICtrlSetStyle(-1, $SS_CENTER + $SS_SUNKEN)
			Case Else
				GUICtrlSetStyle(-1, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
		EndSwitch
		GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO, $FW_SEMIBOLD)
		GUICtrlCreateIcon("", -1, 763, 118 + $iRow * 40, 24, 40)
		If @Compiled Then
			_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iBackground], @ScriptFullPath, 207, 24, 24)
		Else
			_SetBkIcon(-1, $aColors[$iText], $aColors[$iBackground], @ScriptDir & "\assets\Info.ico", -1, 24, 24)
		EndIf
		GUICtrlSetTip(-1, $aInfo[$iRow], "", $TIP_NOICON, $TIP_CENTER)
	Next
	_GDIPlus_Shutdown()

	#Region ; ArchCheck()
	Switch $aResults[0][0]
		Case True
			_GUICtrlSetState($hCheck[0][0], $iPass)
			GUICtrlSetData($hCheck[0][2], _Translate($iMUI, "64 Bit CPU") & @CRLF & _Translate($iMUI, "64 Bit OS"))
		Case Else
			Switch $aResults[0][1]
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
	#EndRegion

	#Region ; _BootCheck()
	Switch $aResults[1][0]
		Case True
			_GUICtrlSetState($hCheck[1][0], $iPass)
			GUICtrlSetData($hCheck[1][2], "UEFI")
		Case False
			Switch $aResults[1][1]
				Case 0
					_GUICtrlSetState($hCheck[1][0], $iFail)
					GUICtrlSetData($hCheck[1][2], "Legacy")
				Case Else
					GUICtrlSetData($hCheck[1][2], $aResults[1][1])
					_GUICtrlSetState($hCheck[1][0], $iWarn)
			EndSwitch
	EndSwitch
	#EndRegion

	#Region ; _CPUNameCheck()
	Switch $aResults[2][0]
		Case False
			Switch $aResults[2][1]
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
	#EndRegion

	#Region ; _CPUCoresCheck()
	If $aResults[3][0] Then
		_GUICtrlSetState($hCheck[3][0], $iPass)
	Else
		_GUICtrlSetState($hCheck[3][0], $iFail)
	EndIf

	Local $sCores = StringReplace(_Translate($iMUI, "Cores"), '#', _GetCPUInfo(0))
	If @extended = 0 Then $sCores = _GetCPUInfo(0) & " " & $sCores
	Local $sThreads = StringReplace(_Translate($iMUI, "Threads"), '#', _GetCPUInfo(1))
	If @extended = 0 Then $sThreads = _GetCPUInfo(1) & " " & $sThreads
	GUICtrlSetData($hCheck[3][2], $sCores & @CRLF & $sThreads)
	#EndRegion

	#Region ; _CPUSpeedCheck()
	If $aResults[4][0] Then
		_GUICtrlSetState($hCheck[4][0], $iPass)
		GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	Else
		_GUICtrlSetState($hCheck[4][0], $iFail)
		GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	EndIf
	#EndRegion

	#Region ; _GPTCheck()
	If $aResults[6][0] Then
		If $aResults[6][1] Then
			_GUICtrlSetState($hCheck[6][0], $iPass)
			GUICtrlSetData($hCheck[6][2], _Translate($iMUI, "GPT Detected"))
		Else
			_GUICtrlSetState($hCheck[6][0], $iPass)
			GUICtrlSetData($hCheck[6][2], _Translate($iMUI, "GPT Detected"))
		EndIf
	Else
		GUICtrlSetData($hCheck[6][2], _Translate($iMUI, "GPT Not Detected"))
		_GUICtrlSetState($hCheck[6][0], $iFail)
	EndIf
	#EndRegion

	#Region ; _MemCheck()
	If $aResults[7][0] Then
		_GUICtrlSetState($hCheck[7][0], $iPass)
		GUICtrlSetData($hCheck[7][2], $aResults[7][1] & " GB")
	Else
		GUICtrlSetData($hCheck[7][2], $aResults[7][1] & " GB")
		_GUICtrlSetState($hCheck[7][0], $iFail)
	EndIf
	#EndRegion

	#Region ; _SecureBootCheck()
	Switch $aResults[8][0]
		Case 2
			_GUICtrlSetState($hCheck[8][0], $iPass)
			GUICtrlSetData($hCheck[8][2], _Translate($iMUI, "Enabled"))
		Case 1
			_GUICtrlSetState($hCheck[8][0], $iPass)
			GUICtrlSetData($hCheck[8][2], _Translate($iMUI, "Supported"))
		Case False
			_GUICtrlSetState($hCheck[8][0], $iFail)
			GUICtrlSetData($hCheck[8][2], _Translate($iMUI, "Disabled / Not Detected"))
	EndSwitch
	#EndRegion

	#Region ; _SpaceCheck()
	If $aResults[9][0] Then
		_GUICtrlSetState($hCheck[9][0], $iPass)
	Else
		_GUICtrlSetState($hCheck[9][0], $iFail)
	EndIf
	GUICtrlSetData($hCheck[9][2], $aResults[9][1] & " GB " & $WINDOWS_DRIVE & @CRLF & $aResults[9][2] & " " & _Translate($iMUI, "Drive(s) Meet Requirements"))
	#EndRegion

	#Region : TPM Check
	If $aResults[10][0] Then
		_GUICtrlSetState($hCheck[10][0], $iPass)
		GUICtrlSetData($hCheck[10][2], "TPM " & $aResults[10][1] & " " & _Translate($iMUI, "Detected"))
	Else
		_GUICtrlSetState($hCheck[10][0], $iFail)
		Switch $aResults[10][1]
			Case 0
				GUICtrlSetData($hCheck[10][2], _Translate($iMUI, "TPM Missing / Disabled"))
			Case 1
				GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate($iMUI, "Not Supported"))
			Case 2
				GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate($iMUI, "Not Supported"))
		EndSwitch
	EndIf
	#EndRegion

	#EndRegion

	#Region Advanced Checks Tab
	#cs
	Local $hAdv = GUICtrlCreateTabItem("Advanced Checks")

	Local $hAdvCheck[11][3]
	Local $hAdvLabel[11] = ["Camera", "Display Depth", "Display Resolution", "Display Size", "Internet Access", "S Mode", "", "", "", "", ""]

	_GDIPlus_Startup()
	For $iRow = 0 To 10 Step 1
		$hAdvCheck[$iRow][0] = GUICtrlCreateLabel("?", 113, 110 + $iRow * 40, 40, 40, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, $aColors[$iBackground])
		$hAdvCheck[$iRow][1] = GUICtrlCreateLabel(" " & _Translate($iMUI, $hAdvLabel[$iRow]), 153, 110 + $iRow * 40, 297, 40, $SS_CENTERIMAGE)
		GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_NORMAL)
		$hAdvCheck[$iRow][2] = GUICtrlCreateLabel(_Translate($iMUI, "Checking..."), 450, 110 + $iRow * 40, 300, 40, $SS_SUNKEN)
		Switch $iRow
			Case -1
				GUICtrlSetStyle(-1, $SS_CENTER + $SS_SUNKEN)
			Case Else
				GUICtrlSetStyle(-1, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE)
		EndSwitch
		GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO, $FW_SEMIBOLD)
		GUICtrlCreateIcon("", -1, 763, 118 + $iRow * 40, 24, 40)
		If @Compiled Then
			_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iBackground], @ScriptFullPath, 207, 24, 24)
		Else
			_SetBkIcon(-1, $aColors[$iText], $aColors[$iBackground], @ScriptDir & "\assets\Info.ico", -1, 24, 24)
		EndIf
		;GUICtrlSetTip(-1, $aInfo[$iRow + 10], "", $TIP_NOICON,  $TIP_CENTER)
	Next
	_GDIPlus_Shutdown()

	If _InternetCheck() Then
		_GUICtrlSetState($hAdvCheck[4][0], $iPass)
		GUICtrlSetData($hAdvCheck[4][2], _Translate($iMUI, "Detected"))
	Else
		_GUICtrlSetState($hAdvCheck[4][0], $iFail)
		GUICtrlSetData($hAdvCheck[4][2], _Translate($iMUI, "Disabled / Not Detected"))
	EndIf
	#ce
	#EndRegion

	;GUICtrlCreateTabItem("")

	#Region Settings GUI
	Local $hSettings = GUICreate(_Translate($iMUI, "Settings"), 698, 528, 102, 32, $WS_POPUP, $WS_EX_MDICHILD, $hGUI)
	Local $bSettings = False
	GUISetBkColor($aColors[$iBackground])
	GUISetFont($aFonts[$FontSmall] * $DPI_RATIO, $FW_BOLD, "", "Arial")

	GUICtrlSetDefColor($aColors[$iText])
	GUICtrlSetDefBkColor($aColors[$iBackground])

	GUICtrlCreateGroup("Info", 30, 20, 638, 100)
	If @Compiled Then
		GUICtrlCreateIcon(@ScriptFullPath, 99, 50, 30, 40, 40)
	Else
		GUICtrlCreateIcon(@ScriptDir & "\assets\WhyNotWin11.ico", -1, 50, 50, 40, 40)
	EndIf

	#EndRegion Settings GUI

	GUISwitch($hGUI)

	ProgressOff()
	GUISetState(@SW_SHOW, $hGUI)

	Local $hMsg
	While 1
		$hMsg = GUIGetMsg()

		Select

			Case $hMsg = $GUI_EVENT_CLOSE Or $hMsg = $hExit
				GUIDelete($hGUI)
				If $aOutput[0] = True Then Return
				Exit

				#cs
				Case $hMsg = $h_WWW
					ShellExecute("https://www.whynotwin11.org/")
				#ce

				; DirectX 12 takes a while. Grab the result once done
			Case IsArray($aDirectX) And (Not ProcessExists($aDirectX[1])) And FileExists($aDirectX[0])
				Switch _GetDirectXCheck($aDirectX)
					Case 2
						_GUICtrlSetState($hCheck[5][0], $iPass)
						GUICtrlSetData($hCheck[5][2], "DirectX 12 && WDDM 3")   ; <== No translation, "DirectX 12 and WDDM 3" in LANG-file
					Case 1
						_GUICtrlSetState($hCheck[5][0], $iPass)
						GUICtrlSetData($hCheck[5][2], "DirectX 12 && WDDM 2")   ; <== No translation, "DirectX 12 and WDDM 2" in LANG-file
					Case Else
						Switch @error
							Case 1
								_GUICtrlSetState($hCheck[5][0], $iPass)
								GUICtrlSetData($hCheck[5][2], _Translate($iMUI, "No DirectX 12, but WDDM2"))
							Case 2
								_GUICtrlSetState($hCheck[5][0], $iFail)
								GUICtrlSetData($hCheck[5][2], _Translate($iMUI, "DirectX 12, but no WDDM2"))
							Case Else
								_GUICtrlSetState($hCheck[5][0], $iFail)
								GUICtrlSetData($hCheck[5][2], _Translate($iMUI, "No DirectX 12 or WDDM2"))
						EndSwitch
				EndSwitch
				$aDirectX = Null

			Case $hMsg = $hDumpLang
				FileDelete(@LocalAppDataDir & "\WhyNotWin11\langs\")

			Case $hMsg = $hJob
				ShellExecute("https://fcofix.org/rcmaehl/wiki/I'M-FOR-HIRE")

			Case $hMsg = $hGithub
				ShellExecute("https://whynotwin11.org")

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

; #FUNCTION# ====================================================================================================================
; Name ..........: _GetLatestRelease
; Description ...: Checks GitHub for the Latest Release
; Syntax ........: _GetLatestRelease($sCurrent)
; Parameters ....: $sCurrent            - a string containing the current program version
; Return values .: Returns True if Update Available
; Author ........: rcmaehl
; Modified ......: 07/09/2021
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
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

; #FUNCTION# ====================================================================================================================
; Name ..........: FinalizeResults
; Description ...: Finalizes Checks that take extended periods to execute
; Syntax ........: FinalizeResults(Byref $aResults)
; Parameters ....: $aResults            - an array of results
; Return values .: None
; Author ........: rcmaehl
; Modified ......: 08/08/2021
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func FinalizeResults(ByRef $aResults)

	Local $aDirectX = $aResults[5][0]

	While 1
		Select
			Case IsArray($aDirectX) And (Not ProcessExists($aDirectX[1])) And FileExists($aDirectX[0])
				_GetDirectXCheck($aDirectX)
				$aDirectX = Null
			Case $aDirectX = Null
				Return
		EndSelect
	WEnd

EndFunc   ;==>FinalizeResults

; #FUNCTION# ====================================================================================================================
; Name ..........: OutputResults
; Description ...: Parses an Array of Check Results and formats it to a file based on file setting
; Syntax ........: OutputResults($aResults)
; Parameters ....: $aResults            - an array of results
; Return values .: None
; Author ........: rcmaehl
; Modified ......: 08/08/2021
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func OutputResults(ByRef $aResults, $aOutput)

	Local $sFile, $hFile

	Local $aLabel[11] = ["Architecture", "Boot Method", "CPU Compatibility", "CPU Core Count", "CPU Frequency", "DirectX + WDDM2", "Disk Partition Type", "RAM Installed", "Secure Boot", "Storage Available", "TPM Version"]

	Switch $aOutput[1]
		Case "txt"
			If StringInStr($aOutput[2], ":") Then
				$sFile = $aOutput[2]
			Else
				$sFile = @ScriptDir & "\" & $aOutput[2]
			EndIf
			$hFile = FileOpen($sFile, $FO_CREATEPATH + $FO_OVERWRITE)
			FileWrite($hFile, "Results for " & @ComputerName & @CRLF)
			For $iLoop = 0 To 10 Step 1
				FileWrite($hFile, $aLabel[$iLoop] & @TAB & $aResults[$iLoop][0] & @TAB & $aResults[$iLoop][1] & @TAB & $aResults[$iLoop][2] & @CRLF)
			Next
			FileClose($hFile)
		Case "csv"
			If StringInStr($aOutput[2], ":") Then
				$sFile = $aOutput[2]
			Else
				$sFile = @ScriptDir & "\" & $aOutput[2]
			EndIf
			If Not FileExists($sFile) Then
				$hFile = FileOpen($sFile, $FO_CREATEPATH + $FO_OVERWRITE)
				FileWrite($hFile, "Hostname")
				For $iLoop = 0 To 10 Step 1
					FileWrite($hFile, "," & $aLabel[$iLoop])
				Next
				FileWrite($hFile, @CRLF)
			Else
				$hFile = FileOpen($sFile, $FO_APPEND)
			EndIf
			FileWrite($hFile, @ComputerName)
			For $iLoop = 0 To 10 Step 1
				FileWrite($hFile, "," & $aResults[$iLoop][0])
			Next
			FileWrite($hFile, @CRLF)
			FileClose($hFile)
		Case Else
			;;;
	EndSwitch

EndFunc   ;==>OutputResults

; #FUNCTION# ====================================================================================================================
; Name ..........: _SetBannerText
; Description ...: Set the Text and Cursor of a GUI Control
; Syntax ........: _SetBannerText($hBannerText, $hBanner)
; Parameters ....: $hBannerText         - Handle to a GUI Control
;                  $hBanner             - Handle to a GUI Control
; Return values .: URL String
; Author ........: rcmaehl
; Modified ......: 07/09/2021
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
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

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlSetState
; Description ...: Set the Text and Color of GUI Control to Indicate status
; Syntax ........: _GUICtrlSetState($hCtrl, $iState)
; Parameters ....: $hCtrl               - Handle to a GUI Control
;                  $iState              - State to set the GUI Control
; Return values .: None
; Author ........: rcmaehl
; Modified ......: 07/09/2021
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _GUICtrlSetState($hCtrl, $iState)
	Switch $iState
		Case 0
			GUICtrlSetData($hCtrl, "X") ; Failed
			GUICtrlSetBkColor($hCtrl, 0xFA113D)
		Case 1
			GUICtrlSetData($hCtrl, "") ; Passed
			GUICtrlSetBkColor($hCtrl, 0x4CC355)
		Case 2
			GUICtrlSetData($hCtrl, "?") ; Unsure
			GUICtrlSetBkColor($hCtrl, 0xF4C141)
		Case 3
			GUICtrlSetData($hCtrl, "!") ; Warn
			GUICtrlSetBkColor($hCtrl, 0xF4C141)
	EndSwitch
EndFunc   ;==>_GUICtrlSetState
