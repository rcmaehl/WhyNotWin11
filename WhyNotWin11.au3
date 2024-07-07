#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Assets\WhyNotWin11.ico
#AutoIt3Wrapper_Outfile=WhyNotWin11_x86.exe
#AutoIt3Wrapper_Outfile_x64=WhyNotWin11.exe
#AutoIt3Wrapper_Compile_Both=Y
#AutoIt3Wrapper_UseX64=Y
#AutoIt3Wrapper_Res_Comment=https://www.whynotwin11.org
#AutoIt3Wrapper_Res_CompanyName=Robert Maehl Software
#AutoIt3Wrapper_Res_Description=Detection Script to help identify why your PC isn't Windows 11 Release Ready. Now Supporting Update Checks!
#AutoIt3Wrapper_Res_Fileversion=2.6.1.0
#AutoIt3Wrapper_Res_ProductName=WhyNotWin11
#AutoIt3Wrapper_Res_ProductVersion=2.6.1.0
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
#AutoIt3Wrapper_Res_Icon_Add=Assets\WhyNotWin11.ico
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7 -v1 -v2 -v3
#AutoIt3Wrapper_Run_Tidy=n
#Tidy_Parameters=/tc 0 /serc /scec
#AutoIt3Wrapper_Run_Au3Stripper=Y
#Au3Stripper_Parameters=/so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $aFonts[5]
Global $bWinPE = False
Global $aColors[4] ; Convert to [4][8] for 2.0 themes
Global $sEdition = "Standard"
Global $sVersion
FileChangeDir(@SystemDir)
Global Static $aPass[2] = [Null, ""] ; Forced, Pass Symbol

If @Compiled Then
	$sVersion = FileGetVersion(@ScriptFullPath)
Else
	$sVersion = "x.x.x.x"
EndIf

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
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <AutoItConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>

Global $WINDOWS_DRIVE = EnvGet("SystemDrive")

Global Static $aMUI[2] = [Null, @MUILang] ; Forced, MUI Lang
Global Static $aName[2] = [Null, "WhyNotWin11"] ; Forced, AppName

#include "Includes\GetDiskInfo.au3"
#include "Includes\ResourcesEx.au3"

#include "Includes\_WMIC.au3"
#include "Includes\_Checks.au3"
#include "Includes\_Theming.au3"
#include "Includes\_Resources.au3"
#include "Includes\_Translations.au3"
; #include "includes\WhyNotWin11_accessibility.au3"

Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)

Opt("GUIResizeMode", $GUI_DOCKSIZE)

ExtractFiles()

ProcessCMDLine()

Func ProcessCMDLine()
	Local $aResults
	Local $aExtended

	Local $aTemp
	Local $aSkips[11] = [False, False, False, False, False, False, False, False, False, False, False]
	Local $bFUC = False
	Local $sDrive = Null
	Local $bForce = False
	Local $bSilent = False
	Local $aOutput[3] = [False, "", ""]
	Local $iParams = $CmdLine[0]

	If $aMUI[0] = Null Then
		$aMUI[1] = RegRead("HKEY_LOCAL_MACHINE\Software\Policies\Robert Maehl Software\WhyNotWin11", "ForcedMUI")
		$aMUI[0] = $aMUI[1] ? True : False
		If Not $aMUI[0] Then $aMUI[1] = @MUILang
	EndIf

	If $aName[0] = Null Then
		$aName[1] = RegRead("HKEY_LOCAL_MACHINE\Software\Policies\Robert Maehl Software\WhyNotWin11", "SetAppName")
		$aName[0] = $aName[1] ? True : False
		If Not $aName[0] Then $aName[1] = "WhyNotWin11"
	EndIf

	If $aPass[0] = Null Then
		$aPass[1] = RegRead("HKEY_LOCAL_MACHINE\Software\Policies\Robert Maehl Software\WhyNotWin11", "SetPassedSymbol")
		$aPass[0] = $aPass[1] ? True : False
		If Not $aPass[0] Then $aPass[1] = ""
	EndIf

	If RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoAppName") Then $aName[1] = ""

	If $iParams > 0 Then
		Do
			Switch $CmdLine[1]
				Case "/?", "/h", "/help"
					MsgBox(0, "Help and Flags", _
							"Checks PC for Windows 11 Release Compatibility" & @CRLF & _
							@CRLF & _
							"WhyNotWin11 [/export FORMAT FILENAME] [/drive DRIVE:] [/force] [/fuonly] [/silent] [/skip [check]] [/update [branch]]" & @CRLF & _
							@CRLF & _
							@TAB & "/export" & @TAB & "Export Results in an Available format, can be used" & @CRLF & _
							@TAB & "       " & @TAB & "without the /silent flag for both GUI and file" & @CRLF & _
							@TAB & "       " & @TAB & "output. Requires a filename if used." & @CRLF & _
							@TAB & "formats" & @TAB & "TXT, CSV" & @CRLF & _
							@TAB & "/force " & @TAB & "Ignores program system requirements (e.g. WinPE)" & @CRLF & _
							@TAB & "/fuonly" & @TAB & "Checks Win11 Feature Update compatibility" & @CRLF & _
							@TAB & "/silent" & @TAB & "Don't Display the GUI. Compatible Systems will Exit" & @CRLF & _
							@TAB & "       " & @TAB & "with ERROR_SUCCESS." & @CRLF & _
							@TAB & "/skip  " & @TAB & "Skips a Comma Separated List of Checks (see Wiki)" & @CRLF & _
							@TAB & "/update" & @TAB & "Downloads the latest RELEASE (default) or DEV build" & @CRLF & _
							@CRLF & _
							"Refer to https://WhyNotWin11.org/wiki/Command-Line-Switches for more details" & @CRLF)
					Exit 0
				Case "/d", "/drive"
					Select
						Case UBound($CmdLine) <= 2
							MsgBox(0, "Invalid", "Missing DRIVE: parameter for /drive." & @CRLF)
							Exit 87 ; ERROR_INVALID_PARAMETER
						Case StringLen($CmdLine[2]) <> 2
							MsgBox(0, "Invalid", "Invalid DRIVE: parameter for /drive." & @CRLF)
							Exit 87 ; ERROR_INVALID_PARAMETER
						Case Else
							$sDrive = $CmdLine[2]
							$WINDOWS_DRIVE = $sDrive
							_ArrayDelete($CmdLine, "1-2")
					EndSelect
				Case "/e", "/export", "/format"
					Select
						Case UBound($CmdLine) <= 3
							MsgBox(0, "Invalid", "Missing FILENAME parameter for /format." & @CRLF)
							Exit 87 ; ERROR_INVALID_PARAMETER
						Case UBound($CmdLine) <= 2
							MsgBox(0, "Invalid", "Missing FORMAT parameter for /format." & @CRLF)
							Exit 87 ; ERROR_INVALID_PARAMETER
						Case Else
							Switch $CmdLine[2]
								Case "CSV", "TXT"
									$aOutput[0] = True
									$aOutput[1] = $CmdLine[2]
									$aOutput[2] = $CmdLine[3]
									_ArrayDelete($CmdLine, "1-3")
								Case Else
									MsgBox(0, "Invalid", "Invalid FORMAT parameter for /format." & @CRLF)
									Exit 87 ; ERROR_INVALID_PARAMETER
							EndSwitch
					EndSelect
				Case "/f", "/force"
					$bForce = True
					_ArrayDelete($CmdLine, 1)
				Case "/fu", "/fuonly"
					$bFUC = True
					_ArrayDelete($CmdLine, 1)
				Case "/s", "/silent"
					$bSilent = True
					_ArrayDelete($CmdLine, 1)
				Case "/sc", "/skip"
					Select
						Case UBound($CmdLine) <= 2
							MsgBox(0, "Invalid", "Missing FORMAT parameter for /format." & @CRLF)
							Exit 87 ; ERROR_INVALID_PARAMETER
						Case Else
							$aTemp = StringSplit($CmdLine[2], ",", $STR_NOCOUNT)
							For $iLoop = 0 To UBound($aTemp) - 1
								Switch $aTemp[$iLoop]
									Case "Arch"
										$aSkips[0] = True
									Case "Boot"
										$aSkips[1] = True
									Case "Config"
										$aSkips[1] = True
										$aSkips[6] = True
										$aSkips[8] = True
									Case "CPU"
										$aSkips[2] = True
										$aSkips[3] = True
										$aSkips[4] = True
									Case "CPUCompat"
										$aSkips[2] = True
									Case "CPUCores"
										$aSkips[3] = True
									Case "CPUFreq"
										$aSkips[4] = True
									Case "DirectX"
										$aSkips[5] = True
									Case "Disk"
										$aSkips[6] = True
									Case "Hardware"
										$aSkips[0] = True
										$aSkips[2] = True
										$aSkips[3] = True
										$aSkips[4] = True
										$aSkips[5] = True
										$aSkips[7] = True
									Case "RAM"
										$aSkips[7] = True
									Case "SecureBoot"
										$aSkips[8] = True
									Case "Storage"
										$aSkips[9] = True
									Case "TPM"
										$aSkips[10] = True
									Case Else
										MsgBox(0, "Invalid", "Invalid CHECK parameter for /skip." & @CRLF)
										Exit 87 ; ERROR_INVALID_PARAMETER	
								EndSwitch
							Next
							_ArrayDelete($CmdLine, "1-2")
					EndSelect
				Case "/u", "/update"
					Select
						Case UBound($CmdLine) = 2
							InetGet("https://WhyNotWin11.org/releases/latest/download/WhyNotWin11.exe", @ScriptDir & "\WhyNotWin11_Latest.exe")
							_ArrayDelete($CmdLine, 1)
						Case UBound($CmdLine) > 2 And $CmdLine[2] = "dev"
							InetGet("https://nightly.link/rcmaehl/WhyNotWin11/workflows/wnw11/main/WNW11.zip", @ScriptDir & "\WhyNotWin11_dev.zip")
							_ArrayDelete($CmdLine, "1-2")
						Case UBound($CmdLine) > 2 And $CmdLine[2] = "release"
							InetGet("https://WhyNotWin11.org/releases/latest/download/WhyNotWin11.exe", @ScriptDir & "\WhyNotWin11_Latest.exe")
							_ArrayDelete($CmdLine, "1-2")
						Case StringLeft($CmdLine[2], 1) = "/"
							InetGet("https://WhyNotWin11.org/releases/latest/download/WhyNotWin11.exe", @ScriptDir & "\WhyNotWin11_Latest.exe")
							_ArrayDelete($CmdLine, 1)
						Case Else
							MsgBox(0, "Invalid", 'Invalid release type - "' & $CmdLine[2] & "." & @CRLF)
							Exit 87 ; ERROR_INVALID_PARAMETER
					EndSelect
				Case Else
					If @Compiled Then ; support for running non-compiled script - mLipok
						MsgBox(0, "Invalid", 'Invalid parameter - "' & $CmdLine[1] & "." & @CRLF)
						Exit 87 ; ERROR_INVALID_PARAMETER
					EndIf
			EndSwitch
		Until UBound($CmdLine) <= 1
	EndIf

	#Region ; OS Checks
	If Not $bForce Then
		Switch @OSVersion
			Case "WIN_7", "WIN_VISTA", "WIN_XP", "WIN_XPe"
				If $bSilent Then
					Exit 10 ; ERROR_BAD_ENVIRONMENT
				Else
					MsgBox($MB_ICONWARNING, StringReplace(_Translate($aMUI[1], "Not Supported"), "#", ""), StringReplace(_Translate($aMUI[1], "Not Supported"), "#", @OSVersion))
				EndIf
			Case "WIN_8", "WIN_8.1"
				If $bSilent Then
					Exit 10 ; ERROR_BAD_ENVIRONMENT
				Else
					MsgBox($MB_ICONWARNING, _Translate($aMUI[1], "Warning"), StringReplace(_Translate($aMUI[1], "May Report DirectX 12 Incorrectly"), "#", @OSVersion))
				EndIf
			Case "WIN_11"
				If $bSilent Then
					;;; ; Anyone using silent for WNW11 on Win11 can use /fuonly
				Else
					If MsgBox($MB_ICONQUESTION+$MB_YESNO, _Translate($aMUI[1], "Up to Date"), _Translate($aMUI[1], "Your computer is already on Windows 11. Would you like to check Feature Update Compatiblity instead?")) = $IDYES Then
						$bFUC = True
					Else
						$bFUC = False
					EndIf
				EndIf
			Case Else
				;;;
		EndSwitch

		If _WinAPI_GetProcAddress(_WinAPI_GetModuleHandle(@SystemDir & "\ntdll.dll"), "wine_get_host_version") Then
			If $bSilent Then
				Exit 10 ; ERROR_BAD_ENVIRONMENT
			Else
				MsgBox($MB_ICONWARNING, StringReplace(_Translate($aMUI[1], "Not Supported"), "#", ""), StringReplace(_Translate($aMUI[1], "Not Supported"), "#", "WINE"))
			EndIf
		EndIf

	EndIf

	$bWinPE = RegRead("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\WinPE", "Version")
	If @error Then
		$bWinPE = False
	Else
		If $sDrive = Null Then $WINDOWS_DRIVE = "C:"
	EndIf
	#EndRegion

	If Not $bSilent And Not RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoProgress") Then ProgressOn($aName[1], _Translate(@MUILang, "Loading WMIC"))

	$aResults = RunChecks($sDrive)
	$aExtended = RunExtendedChecks($sDrive, $bFUC)

	ProgressSet(80, "Done")

	If Not $bSilent Then

		#cs ; 2.0 Theming Enums
		Local Enum $iGeneral = 0, $iText, $iIcons, $iStatus

		Local Enum $iBackground = 0, $iSidebar, $iFooter, $iResults
		Local Enum $iDefault = 0, $iName, $iVersion, $iHeader, $iSubHead, $iLinks, $iChecks, $iResults
		Local Enum $iGithub = 0, $iDonate, $iDiscord, $iLTT, $iWork, $iSettings
		Local Enum $iFail = 0, $iPass, $iUnsure, $iWarn, $iRunning
		#ce

		$aColors = _SetTheme()
		$aFonts = _GetTranslationFonts($aMUI[1])

		Main($aResults, $aExtended, $aSkips, $aOutput, $bFUC)
	Else
		Do
			FinalizeResults($aResults)
		Until Not IsArray($aResults[5][0])
	EndIf
	If $aOutput[0] = True Then OutputResults($aResults, $aSkips, $aOutput)
	For $iLoop = 0 To 10 Step 1
		If $aResults[$iLoop][0] = False Or $aResults[$iLoop][0] < 1 Then Exit 1
	Next
	Exit 0
EndFunc   ;==>ProcessCMDLine

Func RunChecks($sDrive = Null)

	Local $aResults[11][3]

	$aResults[0][0] = _ArchCheck()
	$aResults[0][1] = @error
	$aResults[0][2] = @extended

	$aResults[1][0] = _BootCheck()
	$aResults[1][1] = @error
	$aResults[1][2] = @extended

	$aResults[2][0] = _CPUNameCheck(_GetCPUInfo(2), _GetCPUInfo(6), _GetCPUInfo(5))
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

	$aResults[9][0] = _SpaceCheck($sDrive)
	$aResults[9][1] = @error
	$aResults[9][2] = @extended

	$aResults[10][0] = _TPMCheck()
	$aResults[10][1] = @error
	$aResults[10][2] = @extended

	Return $aResults

EndFunc   ;==>RunChecks

Func RunExtendedChecks($sDrive = Null, $bFUC = False)

	Local $sTemp
	Local $aResults[11][3]
	Local $sFeatureUpdate = False

	If @OSVersion = "WIN_11" and $bFUC Then
		For $iLoop = 1 To 10 Step 1
			$sTemp = RegEnumKey("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators", $iLoop)
			If @error Then ExitLoop
			If StringRegExp($sTemp, ".*\d\d[Hh]\d") Then
				If StringRegExpReplace($sTemp, "\D", "") > StringRegExpReplace($sFeatureUpdate, "\D", "") Then $sFeatureUpdate = $sTemp
			EndIf
		Next
	EndIf

	$aResults[2][0] = _CPUNameCheck(_GetCPUInfo(2), _GetCPUInfo(6), _GetCPUInfo(5), $sFeatureUpdate)
	$aResults[2][1] = @error
	$aResults[2][2] = @extended

	$aResults[3][0] = _CPUCoresCheck(_GetCPUInfo(0), _GetCPUInfo(1), $sFeatureUpdate)
	$aResults[3][1] = @error
	$aResults[3][2] = @extended

	$aResults[4][0] = _CPUSpeedCheck($sFeatureUpdate)
	$aResults[4][1] = @error
	$aResults[4][2] = @extended

	$aResults[7][0] = _MemCheck($sFeatureUpdate)
	$aResults[7][1] = @error
	$aResults[7][2] = @extended

	$aResults[8][0] = _SecureBootCheck($sFeatureUpdate)
	$aResults[8][1] = @error
	$aResults[8][2] = @extended

	$aResults[9][0] = _SpaceCheck($sDrive, $sFeatureUpdate)
	$aResults[9][1] = @error
	$aResults[9][2] = @extended

	$aResults[10][0] = _TPMCheck($sFeatureUpdate)
	$aResults[10][1] = @error
	$aResults[10][2] = @extended

	Return $aResults

EndFunc

Func RunCheckValidation($aInitial, $aExtended)

	Local $bMismatch = False

	For $iLoop = 0 To 10 Step 1
		Switch $iLoop
			Case 2, 7 to 10
				If Not $aExtended[$iLoop][1] Then
					If $aExtended[$iLoop][0] <> $aInitial[$iLoop][0] Then $bMismatch = True
				EndIf
			Case Else
				;;;
		EndSwitch
	Next

	Return Not $bMismatch

EndFunc

Func Main(ByRef $aResults, ByRef $aExtended, ByRef $aSkips, ByRef $aOutput, $bFUC = False)

	; Disable Scaling
	If @OSVersion = 'WIN_10' Or 'WIN_11' Then DllCall(@SystemDir & "\User32.dll", "bool", "SetProcessDpiAwarenessContext", "HWND", "DPI_AWARENESS_CONTEXT" - 1)

	Local $bComplete = False

	Local Enum $iFail = 0, $iPass, $iUnsure, $iWarn
	Local Enum $iBackground = 0, $iText, $iSidebar, $iFooter

	Local Const $DPI_RATIO = _GDIPlus_GraphicsGetDPIRatio()[0]
	Local Enum $FontSmall, $FontMedium, $FontLarge, $FontExtraLarge

	ProgressSet(100, _Translate($aMUI[1], "Done"))

	Local $hGUI = GUICreate($aName[1], 800, 600, -1, -1, BitOR($WS_POPUP, $WS_BORDER), _GetTranslationRTL($aMUI[1]))
	_WinAPI_DwmSetWindowAttributeExt($hGUI, 33, 2)
	GUISetBkColor($aColors[$iBackground])
	GUISetFont($aFonts[$FontSmall] * $DPI_RATIO, $FW_BOLD, "", $aFonts[4])

	GUICtrlSetDefColor($aColors[$iText])
	GUICtrlSetDefBkColor($aColors[$iBackground])

	Local $aLangs = _FileListToArray(@LocalAppDataDir & "\WhyNotWin11\langs\", "*.lang", $FLTA_FILES)
	If Not @error Then
		For $iLoop = 1 To $aLangs[0] Step 1
			$aLangs[$iLoop] &= " - " & IniRead(@LocalAppDataDir & "\WhyNotWin11\langs\" & $aLangs[$iLoop], "MetaData", "Language", "Unknown")
		Next
			_ArrayDelete($aLangs, 0)
			_ArrayDelete($aLangs, 55) ;==> Remove the "Unknown" entry
	EndIf

	Local $aThemes = _FileListToArray(@ScriptDir & "\", "*.def", $FLTA_FILES)
	If Not @error Then
		For $iLoop = 1 To $aThemes[0] Step 1
			$aThemes[$iLoop] &= " - " & IniRead(@ScriptDir & "\" & $aThemes[$iLoop], "MetaData", "Name", "Unknown")
		Next
		_ArrayDelete($aThemes, 0)
	EndIf

	Local $hDumpLang = GUICtrlCreateDummy()

	; Debug Key
	Local $aAccel[1][2] = [["{DEL}", $hDumpLang]]
	GUISetAccelerators($aAccel)

	#Region Sidebar
	; Top Most Interaction for Update Text
	Local $hUpdate = Default
	If $bWinPE Or Not RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoUpdate") Then
		$hUpdate = GUICtrlCreateLabel("", 0, 560, 90, 60, $SS_CENTER + $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, $aColors[$iSidebar])
		GUICtrlSetCursor(-1, 0)
	EndIf

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
	Local $hGithub = Default, $hDonate = Default, $hDiscord = Default, $hWeb = Default, $hJob = Default
	If $bWinPE Or Not RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoSocials") Then
		$hGithub = GUICtrlCreateLabel("", 34, 110, 32, 32)
		GUICtrlSetTip(-1, "GitHub")
		GUICtrlSetCursor(-1, 0)

		$hDonate = GUICtrlCreateLabel("", 34, 160, 32, 32)
		GUICtrlSetTip(-1, _Translate($aMUI[1], "Donate"))
		GUICtrlSetCursor(-1, 0)

		$hDiscord = GUICtrlCreateLabel("", 34, 210, 32, 32)
		GUICtrlSetTip(-1, "Discord")
		GUICtrlSetCursor(-1, 0)

		$hWeb = GUICtrlCreateLabel("", 34, 260, 32, 32)
		GUICtrlSetTip(-1, _Translate($aMUI[1], "My Projects"))
		GUICtrlSetCursor(-1, 0)

		If @LogonDomain <> @ComputerName Then
			$hJob = GUICtrlCreateLabel("", 34, 310, 32, 32)
			GUICtrlSetTip(-1, _Translate($aMUI[1], "I'm For Hire"))
			GUICtrlSetCursor(-1, 0)
		EndIf
	EndIf

	Local $dSettings = Number(RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoSettings"))

	Local $hToggle = Default
	If BitAND($dSettings, 65535) = 65535 Then
		;;;
	Else
		$hToggle = GUICtrlCreateLabel("", 34, 518, 32, 32)
		GUICtrlSetTip(-1, _Translate($aMUI[1], "Settings"))
		GUICtrlSetCursor(-1, 0)
	EndIf

	; Allow Dragging of Window
	GUICtrlCreateLabel("", 0, 0, 800, 30, -1, $GUI_WS_EX_PARENTDRAG)

	GUICtrlCreateLabel("", 0, 0, 100, 600)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])

	If $bWinPE Or Not RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoUpdate") Then
		GUICtrlCreateLabel(_Translate($aMUI[1], "Check for Updates"), 0, 563, 100, 60, $SS_CENTER)
		GUICtrlSetFont(-1, $aFonts[$FontSmall] * $DPI_RATIO, $FW_NORMAL, $GUI_FONTUNDER)
		GUICtrlSetBkColor(-1, $aColors[$iSidebar])
		GUICtrlSetTip(-1, "Update")
		GUICtrlSetCursor(-1, 0)
	EndIf

	_GDIPlus_Startup()
	If @Compiled Then
		If $bWinPE Or Not RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoSocials") Then
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
		EndIf
		If BitAND($dSettings, 65535) = 65535 Then
			;;;
		Else
			GUICtrlCreateIcon("", -1, 34, 518, 32, 32)
			_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 206, 32, 32)
		EndIf
		GUICtrlCreateIcon("", -1, 42, 20, 20, 20)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 208, 20, 20)
	Else
		If Not RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoSocials") Then
			GUICtrlCreateIcon("", -1, 34, 110, 32, 32)
			_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & "\assets\GitHub.ico", -1, 32, 32)
			GUICtrlCreateIcon("", -1, 34, 160, 32, 32)
			_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & "\assets\PayPal.ico", -1, 32, 32)
			GUICtrlCreateIcon("", -1, 34, 210, 32, 32)
			_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & "\assets\Discord.ico", -1, 32, 32)
			GUICtrlCreateIcon("", -1, 34, 260, 32, 32)
			_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & "\assets\Web.ico", -1, 32, 32)
			If @LogonDomain <> @ComputerName Then
				GUICtrlCreateIcon("", -1, 34, 310, 32, 32)
				_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & "\assets\HireMe.ico", -1, 32, 32)
			EndIf
		EndIf
		If BitAND($dSettings, 65535) = 65535 Then
			;;;
		Else
			GUICtrlCreateIcon("", -1, 34, 518, 32, 32)
			_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & "\assets\Settings.ico", -1, 32, 32)
		EndIf
		GUICtrlCreateIcon("", -1, 42, 20, 20, 20)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & "\assets\WhyNotWin11.ico", -1, 20, 20)
	EndIf

	If Not RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoAppName") Then
		GUICtrlCreateIcon(@ScriptDir & "\assets\WhyNotWin11.ico", -1, 42, 20, 20, 20)
		GUICtrlSetBkColor(-1, $aColors[$iSidebar])
		GUICtrlCreateLabel($aName[1], 10, 40, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, $aColors[$iSidebar])
		GUICtrlCreateLabel("v " & $sVersion, 10, 60, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, $aColors[$iSidebar])
	EndIf
	_GDIPlus_Shutdown()

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
			GUICtrlCreateLabel(_Translate($aMUI[1], "Translation by") & " " & _GetTranslationCredit(), 130, 560, 310, 40)
			GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))
		EndIf
	#ce

	GUICtrlCreateLabel(@ComputerName, 113, 560, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])
	GUICtrlCreateLabel(_GetMotherboardInfo(0) & " " & _GetMotherboardInfo(1) & " @ " & _GetBIOSInfo(0), 113, 580, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])
	GUICtrlCreateLabel(StringReplace(_GetCPUInfo(2), " CPU", ""), 450, 560, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])
	GUICtrlCreateLabel(_GetGPUInfo(0), 450, 580, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])
	#EndRegion

	#Region Header
	Local $hHeader
	If $bFUC Then
		$hHeader = GUICtrlCreateLabel(_Translate($aMUI[1], "Your Feature Update Compatibility Results Are Below"), 130, 10, 640, 40, $SS_CENTER + $SS_CENTERIMAGE)
	Else
		$hHeader = GUICtrlCreateLabel(_Translate($aMUI[1], "Your Windows 11 Compatibility Results Are Below"), 130, 10, 640, 40, $SS_CENTER + $SS_CENTERIMAGE)
	EndIf
	GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_SEMIBOLD, "", "", $CLEARTYPE_QUALITY)

	#cs
	Local $h_WWW = GUICtrlCreateLabel(_Translate($aMUI[1], "Now Reach WhyNotWin11 via https://www.whynotwin11.org/"), 130, 45, 640, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO)
	GUICtrlSetCursor(-1, 0)
	#ce

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

	Local $bInfoBox = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoInfoBox")
	Local $hCheck[11][3]
	Local $hLabel[11] = ["Architecture", "Boot Method", "CPU Compatibility", "CPU Core Count", "CPU Frequency", "DirectX 12 and WDDM 2", "Disk Partition Type", "RAM Installed", "Secure Boot", "Storage Available", "TPM Version"]
	Local $aInfo = _GetDescriptions($aMUI[1])

	_GDIPlus_Startup()

	For $iRow = 0 To 10 Step 1
		$hCheck[$iRow][0] = GUICtrlCreateLabel("…", 113, 70 + $iRow * 44, 40, 40, $SS_CENTER + $SS_SUNKEN + $SS_CENTERIMAGE) 
		GUICtrlSetBkColor(-1, $aColors[$iBackground])
		GUICtrlCreateIcon("", -1, 763, 78 + $iRow * 44, 24, 40)
		$hCheck[$iRow][1] = GUICtrlCreateLabel(" " & _Translate($aMUI[1], $hLabel[$iRow]), 153, 70 + $iRow * 44, 297, 40, $SS_CENTERIMAGE)
		GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_NORMAL)
		$hCheck[$iRow][2] = GUICtrlCreateLabel(_Translate($aMUI[1], "Checking..."), 450, 70 + $iRow * 44, 300, 40, $SS_SUNKEN)
		Switch $iRow
			Case 0, 3, 9
				GUICtrlSetStyle(-1, $SS_CENTER + $SS_SUNKEN)
			Case Else
				GUICtrlSetStyle(-1, $SS_CENTER + $SS_CENTERIMAGE + $SS_SUNKEN)
		EndSwitch
		GUICtrlSetFont(-1, $aFonts[$FontMedium] * $DPI_RATIO, $FW_SEMIBOLD)
		If Not $bInfoBox Then
			GUICtrlCreateIcon("", -1, 763, 78 + $iRow * 44, 24, 40)
			If @Compiled Then
				_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iBackground], @ScriptFullPath, 207, 24, 24)
			Else
				_SetBkIcon(-1, $aColors[$iText], $aColors[$iBackground], @ScriptDir & "\assets\Info.ico", -1, 24, 24)
			EndIf
			GUICtrlSetTip(-1, $aInfo[$iRow], "", $TIP_NOICON, $TIP_CENTER)
		EndIf
	Next
	_GDIPlus_Shutdown()

	#Region ; ArchCheck()
	If $aSkips[0] Then
		_GUICtrlSetState($hCheck[0][0], $iUnsure)
		GUICtrlSetData($hCheck[0][2], _Translate($aMUI[1], "Check Skipped"))
	Else
		Switch $aResults[0][0]
			Case True
				_GUICtrlSetState($hCheck[0][0], $iPass)
				GUICtrlSetData($hCheck[0][2], _Translate($aMUI[1], "64 Bit CPU") & @CRLF & _Translate($aMUI[1], "64 Bit OS"))
			Case Else
				Switch $aResults[0][1]
					Case 0
						_GUICtrlSetState($hCheck[0][0], $iUnsure)
						GUICtrlSetData($hCheck[0][2], _Translate($aMUI[1], "Check Skipped"))
					Case 1
						_GUICtrlSetState($hCheck[0][0], $iWarn)
						GUICtrlSetData($hCheck[0][2], _Translate($aMUI[1], "64 Bit CPU") & @CRLF & _Translate($aMUI[1], "32 Bit OS"))
					Case 2
						_GUICtrlSetState($hCheck[0][0], $iFail)
						GUICtrlSetData($hCheck[0][2], _Translate($aMUI[1], "32 Bit CPU") & @CRLF & _Translate($aMUI[1], "32 Bit OS"))
					Case Else
						_GUICtrlSetState($hCheck[0][0], $iFail)
						GUICtrlSetData($hCheck[0][2], "?")
				EndSwitch
		EndSwitch
	EndIf
	#EndRegion

	#Region ; _BootCheck()
	If $aSkips[1] Then
		_GUICtrlSetState($hCheck[1][0], $iUnsure)
		GUICtrlSetData($hCheck[1][2], _Translate($aMUI[1], "Check Skipped"))
	Else
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
						GUICtrlSetData($hCheck[1][2], StringReplace(_Translate($aMUI[1], "Not Supported"), "#", ""))
						_GUICtrlSetState($hCheck[1][0], $iWarn)
				EndSwitch
		EndSwitch
	EndIf
	#EndRegion

	#Region ; _CPUNameCheck()
	If $aSkips[2] Then
		_GUICtrlSetState($hCheck[2][0], $iUnsure)
		GUICtrlSetData($hCheck[2][2], _Translate($aMUI[1], "Check Skipped"))
	Else
		If ($bFUC = True ? $aExtended[2][0] : $aResults[2][0]) Then
			_GUICtrlSetState($hCheck[2][0], $iPass)
			GUICtrlSetData($hCheck[2][2], _Translate($aMUI[1], "Listed as Compatible"))
		Else
			Switch ($bFUC = True ? $aExtended[2][0] : $aResults[2][0])
				Case False
					Switch $aResults[2][1]
						Case 1
							_GUICtrlSetState($hCheck[2][0], $iWarn)
							GUICtrlSetData($hCheck[2][2], _Translate($aMUI[1], "Unable to Check List"))
						Case 2
							_GUICtrlSetState($hCheck[2][0], $iWarn)
							GUICtrlSetData($hCheck[2][2], _Translate($aMUI[1], "Error Accessing List"))
						Case 3
							_GUICtrlSetState($hCheck[2][0], $iFail)
							GUICtrlSetData($hCheck[2][2], StringReplace(_Translate($aMUI[1], "Not Supported"), "#", ""))
						Case Else
							_GUICtrlSetState($hCheck[2][0], $iFail)
							GUICtrlSetData($hCheck[2][2], StringReplace(_Translate($aMUI[1], "Not Supported"), "#", ""))
					EndSwitch
				Case Else
					_GUICtrlSetState($hCheck[2][0], $iPass)
					GUICtrlSetData($hCheck[2][2], _Translate($aMUI[1], "Listed as Compatible"))
			EndSwitch
		EndIf
	EndIf
	#EndRegion

	#Region ; _CPUCoresCheck()
	If $aSkips[3] Then
		_GUICtrlSetState($hCheck[3][0], $iUnsure)
		GUICtrlSetData($hCheck[3][2], _Translate($aMUI[1], "Check Skipped"))
	Else
		If ($bFUC = True ? $aExtended[3][0] : $aResults[3][0]) Then
			_GUICtrlSetState($hCheck[3][0], $iPass)
		Else
			_GUICtrlSetState($hCheck[3][0], $iFail)
		EndIf

		Local $sCores = StringReplace(_Translate($aMUI[1], "Cores"), "#", _GetCPUInfo(0))
		If @extended = 0 Then $sCores = _GetCPUInfo(0) & " " & $sCores
		Local $sThreads = StringReplace(_Translate($aMUI[1], "Threads"), "#", _GetCPUInfo(1))
		If @extended = 0 Then $sThreads = _GetCPUInfo(1) & " " & $sThreads
		GUICtrlSetData($hCheck[3][2], $sCores & @CRLF & $sThreads)
	EndIf
	#EndRegion

	#Region ; _CPUSpeedCheck()
	If $aSkips[4] Then
		_GUICtrlSetState($hCheck[4][0], $iUnsure)
		GUICtrlSetData($hCheck[4][2], _Translate($aMUI[1], "Check Skipped"))
	Else
		If ($bFUC = True ? $aExtended[4][0] : $aResults[4][0]) Then
			_GUICtrlSetState($hCheck[4][0], $iPass)
			Switch $aResults[4][2]
				Case 0
					GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
				Case 1
					GUICtrlSetData($hCheck[4][2], RegRead("HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0", "~MHz") & " MHz")
			EndSwitch
		Else
			_GUICtrlSetState($hCheck[4][0], $iFail)
			GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
		EndIf
	EndIf
	#EndRegion

	#Region ; _DirectXStartCheck() Skip
	If $aSkips[5] Then
		_GUICtrlSetState($hCheck[5][0], $iUnsure)
		GUICtrlSetData($hCheck[5][2], _Translate($aMUI[1], "Check Skipped"))
		$bComplete = True
	EndIf

	#Region ; _GPTCheck()
	If $aSkips[6] Then
		_GUICtrlSetState($hCheck[6][0], $iUnsure)
		GUICtrlSetData($hCheck[6][2], _Translate($aMUI[1], "Check Skipped"))
	Else
		If $aResults[6][0] Then
			If $aResults[6][1] Then
				_GUICtrlSetState($hCheck[6][0], $iPass)
				GUICtrlSetData($hCheck[6][2], _Translate($aMUI[1], "GPT Detected"))
			Else
				_GUICtrlSetState($hCheck[6][0], $iPass)
				GUICtrlSetData($hCheck[6][2], _Translate($aMUI[1], "GPT Detected"))
			EndIf
		Else
			GUICtrlSetData($hCheck[6][2], _Translate($aMUI[1], "GPT Not Detected"))
			_GUICtrlSetState($hCheck[6][0], $iFail)
		EndIf
	EndIf
	#EndRegion

	#Region ; _MemCheck()
	If $aSkips[7] Then
		_GUICtrlSetState($hCheck[7][0], $iUnsure)
		GUICtrlSetData($hCheck[7][2], _Translate($aMUI[1], "Check Skipped"))
	Else
		If ($bFUC = True ? $aExtended[7][0] : $aResults[7][0]) Then
			_GUICtrlSetState($hCheck[7][0], $iPass)
			GUICtrlSetData($hCheck[7][2], $aResults[7][1] & " GB")
		Else
			GUICtrlSetData($hCheck[7][2], $aResults[7][1] & " GB")
			_GUICtrlSetState($hCheck[7][0], $iFail)
		EndIf
	EndIf
	#EndRegion

	#Region ; _SecureBootCheck()
	If $aSkips[8] Then
		_GUICtrlSetState($hCheck[8][0], $iUnsure)
		GUICtrlSetData($hCheck[8][2], _Translate($aMUI[1], "Check Skipped"))
	Else
		Switch ($bFUC = True ? $aExtended[8][0] : $aResults[8][0])
			Case True
				Switch $aResults[8][2]
					Case 1
						_GUICtrlSetState($hCheck[8][0], $iPass)
						GUICtrlSetData($hCheck[8][2], _Translate($aMUI[1], "Enabled"))
					Case 0
						_GUICtrlSetState($hCheck[8][0], $iPass)
						GUICtrlSetData($hCheck[8][2], _Translate($aMUI[1], "Supported"))
				EndSwitch
			Case False
				_GUICtrlSetState($hCheck[8][0], $iFail)
				GUICtrlSetData($hCheck[8][2], _Translate($aMUI[1], "Disabled / Not Detected"))
		EndSwitch
	EndIf
	#EndRegion

	#Region ; _SpaceCheck()
	If $aSkips[9] Then
		_GUICtrlSetState($hCheck[9][0], $iUnsure)
		GUICtrlSetData($hCheck[9][2], _Translate($aMUI[1], "Check Skipped"))
	Else
		If ($bFUC = True ? $aExtended[9][0] : $aResults[9][0]) Then
			_GUICtrlSetState($hCheck[9][0], $iPass)
		Else
			_GUICtrlSetState($hCheck[9][0], $iFail)
		EndIf
		GUICtrlSetData($hCheck[9][2], $WINDOWS_DRIVE & " " & $aResults[9][1] & " GB" & @CRLF & StringReplace(_Translate($aMUI[1], "Drive(s) Meet Requirements"), "#", $aResults[9][2]))
	EndIf
	#EndRegion

	#Region : TPM Check
	If $aSkips[10] Then
		_GUICtrlSetState($hCheck[10][0], $iUnsure)
		GUICtrlSetData($hCheck[10][2], _Translate($aMUI[1], "Check Skipped"))
	Else
		If ($bFUC = True ? $aExtended[10][0] : $aResults[10][0]) Then
			_GUICtrlSetState($hCheck[10][0], $iPass)
			GUICtrlSetData($hCheck[10][2], "TPM " & $aResults[10][1] & " " & _Translate($aMUI[1], "Detected"))
		Else
			_GUICtrlSetState($hCheck[10][0], $iFail)
			Switch $aResults[10][1]
				Case 0
					GUICtrlSetData($hCheck[10][2], _Translate($aMUI[1], "Disabled / Not Detected"))
				Case 1
					GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & StringReplace(_Translate($aMUI[1], "Not Supported"), "#", ""))
				Case 2
					GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & StringReplace(_Translate($aMUI[1], "Not Supported"), "#", ""))
				Case 3
					_GUICtrlSetState($hCheck[10][0], $iUnsure)
					GUICtrlSetData($hCheck[10][2], _Translate($aMUI[1], "TPM Status Error"))
			EndSwitch
		EndIf
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
		$hAdvCheck[$iRow][1] = GUICtrlCreateLabel(" " & _Translate($aMUI[1], $hAdvLabel[$iRow]), 153, 110 + $iRow * 40, 297, 40, $SS_CENTERIMAGE)
		GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_NORMAL)
		$hAdvCheck[$iRow][2] = GUICtrlCreateLabel(_Translate($aMUI[1], "Checking..."), 450, 110 + $iRow * 40, 300, 40, $SS_SUNKEN)
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
		GUICtrlSetData($hAdvCheck[4][2], _Translate($aMUI[1], "Detected"))
	Else
		_GUICtrlSetState($hAdvCheck[4][0], $iFail)
		GUICtrlSetData($hAdvCheck[4][2], _Translate($aMUI[1], "Disabled / Not Detected"))
	EndIf
	#ce
	#EndRegion

	;GUICtrlCreateTabItem("")

	#Region Settings GUI
	Local $hSettings = GUICreate(_Translate($aMUI[1], "Settings"), 698, 528, 102, 32, $WS_POPUP, $WS_EX_MDICHILD, $hGUI)
	Local $bSettings = False
	GUISetBkColor($aColors[$iBackground])
	GUISetFont($aFonts[$FontSmall] * $DPI_RATIO, $FW_BOLD, "", "Arial")

	GUICtrlSetDefColor($aColors[$iText])
	GUICtrlSetDefBkColor($aColors[$iBackground])

	If BitAND($dSettings, 1) = 1 Then
		;;;
	Else
		GUICtrlCreateGroup("", 30, 20, 638, 100)
		GUICtrlCreateLabel(" " & _Translate($aMUI[1], "Info") & " ", 40, 20, 618, 20)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		If @Compiled Then
			GUICtrlCreateIcon(@ScriptFullPath, 99, 50, 30, 40, 40)
		Else
			GUICtrlCreateIcon(@ScriptDir & "\assets\WhyNotWin11.ico", -1, 50, 50, 40, 40)
		EndIf
	EndIf

	GUICtrlCreateGroup("", 30, 180, 400, 328)
	GUICtrlCreateLabel(" " & _Translate($aMUI[1], "Settings") & " ", 40, 180, 380, 20)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlCreateLabel(_Translate($aMUI[1], "Language") & ":", 40, 200, 380, 20)
	Local $hLanguage = GUICtrlCreateCombo($alangs, 40, 220, 380, 20, $CBS_DROPDOWNLIST+$WS_VSCROLL)
	If BitAND($dSettings, 4) = 4 Then
		GUICtrlCreateLabel(_Translate($aMUI[1], "Language Switcher currently disabled with Group Policy."), 40, 240, 380, 20)
	Else
		If IsArray($aLangs) Then
			GUICtrlSetData(-1, _ArrayToString($aLangs), $aMUI[1])
		Else
			GUICtrlSetData(-1, "English - No Alternative Language Files Found", "English - No Alternative Language Files Found")
			GUICtrlSetState(-1, $GUI_DISABLE)
		EndIf
	EndIf
	If BitAND($dSettings, 8) = 8 Then
		;;;
	Else
	GUICtrlCreateLabel(_Translate($aMUI[1], "Translation by") & ":", 40, 260, 100, 20)
	GUICtrlCreateLabel(_GetTranslationCredit($aMUI[1]), 140, 260, 280, 40, $SS_RIGHT)
	EndIf

	GUICtrlCreateLabel(_Translate($aMUI[1], "Theme") & ":", 40, 290, 380, 20)
	Local $hTheme = GUICtrlCreateCombo("", 40, 310, 380, 20, $CBS_DROPDOWNLIST+$WS_VSCROLL)
	#forceref $hTheme
	If BitAND($dSettings, 16) = 16 Then
		GUICtrlCreateLabel(_Translate($aMUI[1], "Theme Switcher currently disabled with Group Policy."), 40, 340, 380, 20)
	Else
		If IsArray($aThemes) Then
			GUICtrlSetData(-1, _ArrayToString($aThemes))
		Else
			GUICtrlSetData(-1, _Translate($aMUI[1], "Default - No Theme Files Found"), _Translate($aMUI[1], "Default - No Theme Files Found"))
			GUICtrlSetState(-1, $GUI_DISABLE)
		EndIf
	EndIf
	If BitAND($dSettings, 32) = 32 Then
		;;;
	Else
		GUICtrlCreateLabel(_Translate($aMUI[1], "Theme by") & ":", 40, 360, 100, 20)
;		GUICtrlCreateLabel(_GetThemeCredit($sTheme), 140, 340, 280, 40, $SS_RIGHT)
	EndIf

	;Local $hMUI = GUICtrlCreateCheckbox(_Translate($aMUI[1], "Remember Last Language Used"), 40, 380, 380, 20, $BS_RIGHTBUTTON)
	;Local $hUOL = GUICtrlCreateCheckbox(_Translate($aMUI[1], "Check for Updates on App Launch"), 40, 400, 380, 20, $BS_RIGHTBUTTON)

	;GUICtrlCreateCheckbox(_Translate($aMUI[1], "Save Settings in Registry, Not Disk"), 40, 480, 380, 20, $BS_RIGHTBUTTON)

	Local $hChecks = Default, $hConvert = Default, $hSecure = Default, $hTPM = Default, $hSkips = Default, $hInstall = Default
	If BitAND($dSettings, 2) = 2 Then
		;;;
	Else
		GUICtrlCreateGroup("", 470, 180, 200, 328)
		GUICtrlCreateLabel(" " & _Translate($aMUI[1], "Guides") & " ", 480, 180, 180, 20)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		$hChecks = GUICtrlCreateButton(_Translate($aMUI[1],"Windows 11 Requirements"), 480, 200, 180, 40)
		GUICtrlSetCursor(-1, 0)
		$hConvert = GUICtrlCreateButton(_Translate($aMUI[1],"Convert Disk to GPT"), 480, 250, 180, 40)
		GUICtrlSetCursor(-1, 0)
		$hSecure = GUICtrlCreateButton(_Translate($aMUI[1],"Enable Secure Boot"), 480, 300, 180, 40)
		GUICtrlSetCursor(-1, 0)
		$hTPM = GUICtrlCreateButton(_Translate($aMUI[1],"Enable TPM"), 480, 350, 180, 40)
		GUICtrlSetCursor(-1, 0)
		$hSkips = GUICtrlCreateButton(_Translate($aMUI[1],"Skip CPU && TPM"), 480, 400, 180, 40)
		GUICtrlSetCursor(-1, 0)
		$hInstall = GUICtrlCreateButton(_Translate($aMUI[1],"Get Windows 11 Now"), 480, 450, 180, 40)
		GUICtrlSetCursor(-1, 0)
	EndIf

	#EndRegion Settings GUI

	GUISwitch($hGUI)

	ProgressOff()
	GUISetState(@SW_SHOW, $hGUI)

	Local $hMsg
	While 1
		$hMsg = GUIGetMsg()

		If IsArray($aResults[5][0]) Then
			FinalizeResults($aResults)
		EndIf

		Select

			Case $hMsg = $GUI_EVENT_CLOSE Or $hMsg = $hExit
				GUIDelete($hGUI)
				If $aOutput[0] = True Then Return
				Exit

			Case Not IsArray($aResults[5][0]) And $bComplete = False And Not $bSettings
				$bComplete = True
				Switch $aResults[5][0]
					Case True
						Switch $aResults[5][2]
							Case 1
								_GUICtrlSetState($hCheck[5][0], $iPass)
								GUICtrlSetData($hCheck[5][2], _Translate($aMUI[1], "DirectX 12 and WDDM 2"))
							Case 2
								_GUICtrlSetState($hCheck[5][0], $iPass)
								GUICtrlSetData($hCheck[5][2], _Translate($aMUI[1], "DirectX 12 and WDDM 3"))
						EndSwitch
					Case Else
						Switch $aResults[5][1]
							Case 0
								Switch $aResults[5][2]
									Case 1
										_GUICtrlSetState($hCheck[5][0], $iUnsure)
										GUICtrlSetData($hCheck[5][2], _Translate($aMUI[1], "DxDiag Errored"))
									Case 2
										_GUICtrlSetState($hCheck[5][0], $iUnsure)
										GUICtrlSetData($hCheck[5][2], _Translate($aMUI[1], "Check Timed Out"))
								EndSwitch
							Case 1
								_GUICtrlSetState($hCheck[5][0], $iPass)
								GUICtrlSetData($hCheck[5][2], _Translate($aMUI[1], "No DirectX 12, but WDDM2"))
							Case 2
								_GUICtrlSetState($hCheck[5][0], $iFail)
								GUICtrlSetData($hCheck[5][2], _Translate($aMUI[1], "DirectX 12, but no WDDM2"))
							Case Else
								_GUICtrlSetState($hCheck[5][0], $iFail)
								GUICtrlSetData($hCheck[5][2], _Translate($aMUI[1], "No DirectX 12 or WDDM2"))
						EndSwitch
				EndSwitch
				If Not RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Robert Maehl Software\WhyNotWin11", "NoPopUp") Then
					For $iLoop = 0 To 10 Step 1
						If $iLoop = 2 And $aExtended[$iLoop][0] = True Then ContinueLoop ; Pass if Windows Update Reports CPU Okay
						If $aResults[$iLoop][0] = False Or $aResults[$iLoop][0] < 1 Then
							MsgBox($MB_OK+$MB_ICONERROR+$MB_TOPMOST+$MB_SETFOREGROUND, _
								StringReplace(_Translate($aMUI[1], "Not Supported"), "#", ""), _
								_Translate($aMUI[1], "Your Computer is NOT ready for Windows 11, you can join the Discord using the Discord Icon if you need assistance."))
							ContinueLoop 2
						EndIf
					Next
					If Not RunCheckValidation($aResults, $aExtended) Then
						MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST+$MB_SETFOREGROUND, _
							_Translate($aMUI[1], "Supported"), _
							_Translate($aMUI[1], "Your Computer is ready for Windows 11 and its updates, but Windows Update may think you are not for 30 days. You can fix this using the Windows Installation Assistant."))
					Else
						MsgBox($MB_OK+$MB_ICONINFORMATION+$MB_TOPMOST+$MB_SETFOREGROUND, _
							_Translate($aMUI[1], "Supported"), _
							_Translate($aMUI[1], "Your Computer is ready for Windows 11 and its updates."))
					EndIf
				EndIf

			Case $hMsg = $hLanguage
				If StringLeft(GUICtrlRead($hLanguage), 4) <> $aMUI[1] Then
					$aMUI[1] = StringLeft(GUICtrlRead($hLanguage), 4)
					GUIDelete($hGUI)
					Main($aResults, $aExtended, $aSkips, $aOutput, $bFUC)
				EndIf

			Case $hMsg = $hTheme
				$aColors = _SetTheme(StringSplit(GUICtrlRead($hTheme), " - ")[1])
				GUIDelete($hGUI)
				Main($aResults, $aExtended, $aSkips, $aOutput, $bFUC)

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

			Case $hMsg = $hWeb
				ShellExecute("https://fcofix.org")

			; Case $hMsg = $hMUI

			; Case $hMsg = $hUOL

			Case $hMsg = $hChecks
				ShellExecute("https://www.microsoft.com/en-us/windows/windows-11-specifications")

			Case $hMsg = $hConvert
				ShellExecute("https://youtu.be/NivpAiuh-s0?t=311")

			Case $hMsg = $hSecure
				ShellExecute("https://youtu.be/NivpAiuh-s0?t=272s")

			Case $hMsg = $hTPM
				ShellExecute("https://www.youtube.com/watch?v=GOqVVP52qsk&t=137s")

			Case $hMsg = $hSkips
				ShellExecute("https://support.microsoft.com/en-us/windows/ways-to-install-windows-11-e0edbbfb-cfc5-4011-868b-2ce77ac7c70e")

			Case $hMsg = $hInstall
				ShellExecute("https://www.youtube.com/watch?v=GOqVVP52qsk&t=515s")

			Case $hMsg = $hToggle
				If $bSettings Then
					GUISetState(@SW_HIDE, $hSettings)
					GUICtrlSetState($hHeader, $GUI_SHOW)
				Else
					GUICtrlSetState($hHeader, $GUI_HIDE)
					GUISetState(@SW_SHOW, $hSettings)
				EndIf
				$bSettings = Not $bSettings

			Case $hMsg = $hUpdate
				Switch _GetLatestRelease($sVersion)
					Case -1
						MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($aMUI[1], "Test Build?"), _Translate($aMUI[1], "You're running a newer build than publicly Available!"), 10)
					Case 0
						Switch @error
							Case 0
								MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_TOPMOST, _Translate($aMUI[1], "Up to Date"), _Translate($aMUI[1], "You're running the latest build!"), 10)
							Case 1
								MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($aMUI[1], "Unable to Check for Updates"), _Translate($aMUI[1], "Unable to load release data."), 10)
							Case 2
								MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($aMUI[1], "Unable to Check for Updates"), _Translate($aMUI[1], "Invalid Data Received!"), 10)
							Case 3
								Switch @extended
									Case 0
										MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($aMUI[1], "Unable to Check for Updates"), _Translate($aMUI[1], "Invalid Release Tags Received!"), 10)
									Case 1
										MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($aMUI[1], "Unable to Check for Updates"), _Translate($aMUI[1], "Invalid Release Types Received!"), 10)
								EndSwitch
						EndSwitch
					Case 1
						If MsgBox($MB_YESNO + $MB_ICONINFORMATION + $MB_TOPMOST, _Translate($aMUI[1], "Update Available"), _Translate($aMUI[1], "An Update is Available, would you like to download it?"), 10) = $IDYES Then ShellExecute("https://fcofix.org/WhyNotWin11/releases")
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
; Modified ......: 10/18/2021
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func FinalizeResults(ByRef $aResults)

	Local $aDirectX = $aResults[5][0]

	$aDirectX = _GetDirectXCheck($aDirectX)
	$aResults[5][0] = $aDirectX
	$aResults[5][1] = @error
	$aResults[5][2] = @extended

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
Func OutputResults(ByRef $aResults, ByRef $aSkips, $aOutput)

	Local $sFile, $hFile, $sOut = ""

	Local $aLabel[11] = ["Architecture", "Boot Method", "CPU Compatibility", "CPU Core Count", "CPU Frequency", "DirectX + WDDM2", "Disk Partition Type", "RAM Installed", "Secure Boot", "Storage Available", "TPM Version"]

	Switch $aOutput[1]
		Case "txt"
			If StringInStr($aOutput[2], ":") Or StringInStr($aOutput[2], "\\") Then
				$sFile = $aOutput[2]
			Else
				$sFile = @ScriptDir & "\" & $aOutput[2]
			EndIf
			$hFile = FileOpen($sFile, $FO_CREATEPATH + $FO_OVERWRITE)
			$sOut = "Results for " & @ComputerName & @CRLF
			For $iLoop = 0 To 10 Step 1
				If $aSkips[$iLoop] Then
					$sOut &= $aLabel[$iLoop] & @TAB & True & @TAB & "Skipped" & @TAB & "Skipped" & @CRLF
				Else
					$sOut &= $aLabel[$iLoop] & @TAB & $aResults[$iLoop][0] & @TAB & $aResults[$iLoop][1] & @TAB & $aResults[$iLoop][2] & @CRLF
				EndIf
			Next

		Case "csv"
			If StringInStr($aOutput[2], ":") Or StringInStr($aOutput[2], "\\") Then
				$sFile = $aOutput[2]
			Else
				$sFile = @ScriptDir & "\" & $aOutput[2]
			EndIf
			If Not FileExists($sFile) Then
				$hFile = FileOpen($sFile, $FO_CREATEPATH + $FO_OVERWRITE)
				$sOut = FileWrite($hFile, "Hostname")
				For $iLoop = 0 To 10 Step 1
					$sOut &= FileWrite($hFile, "," & $aLabel[$iLoop])
				Next
				FileWrite($hFile, $sOut & @CRLF)
			Else
				$hFile = FileOpen($sFile, $FO_APPEND)
			EndIf
			$sOut = @ComputerName
			For $iLoop = 0 To 10 Step 1
				If $aSkips[$iLoop] Then
					$sOut &= FileWrite($hFile, "," & True)
				Else
					$sOut &= FileWrite($hFile, "," & $aResults[$iLoop][0])
				EndIf
			Next

		Case Else
			;;;

	EndSwitch
	FileWrite($hFile, $sOut & @CRLF)
	FileClose($hFile)

EndFunc   ;==>OutputResults

; #FUNCTION# ====================================================================================================================
; Name ..........: _SetBannerText
; Description ...: Set the Text and Cursor of a GUI Control
; Syntax ........: _SetBannerText($hBannerText, $hBanner)
; Parameters ....: $hBannerText         - Handle to a GUI Control
;                  $hBanner             - Handle to a GUI Control
; Return values .: URL String
; Author ........: rcmaehl
; Modified ......: 10/05/2021
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SetBannerText($hBannerText, $hBanner)

	Select
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
			GUICtrlSetData($hCtrl, "❌") ; Failed
			GUICtrlSetBkColor($hCtrl, 0xFA113D)
		Case 1
			GUICtrlSetData($hCtrl, $aPass[1]) ; Passed
			GUICtrlSetBkColor($hCtrl, 0x4CC355)
		Case 2
			GUICtrlSetData($hCtrl, "?") ; Unsure
			GUICtrlSetBkColor($hCtrl, 0xF4C141)
		Case 3
			GUICtrlSetData($hCtrl, "!") ; Warn
			GUICtrlSetBkColor($hCtrl, 0xF4C141)
	EndSwitch
EndFunc   ;==>_GUICtrlSetState
