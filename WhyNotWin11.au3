#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=.\assets\windows11-logo.ico
#AutoIt3Wrapper_Outfile=WhyNotWin11_x86.exe
#AutoIt3Wrapper_Outfile_x64=WhyNotWin11.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_HiDpi=N
#AutoIt3Wrapper_Res_Description=Detection Script to help identify the more niche settings for why your PC isn't Windows 11 ready
#AutoIt3Wrapper_Res_Fileversion=2.2.5.0
#AutoIt3Wrapper_Res_ProductVersion=2.2.5
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#AutoIt3Wrapper_Res_Icon_Add=assets\git.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\pp.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\dis.ico
#AutoIt3Wrapper_Res_Icon_Add=assets\web.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Global $sVersion = "2.2.5.0"

#include <File.au3>
#include <Misc.au3>
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

Opt("TrayIconHide",1)
Opt("TrayAutoPause",0)

ExtractFiles()

If $CmdLine[0] > 0 Then
	For $iLoop = 1 To $CmdLine[0] Step 1
		Switch $CmdLine[$iLoop]
			Case "/?", "/h", "/help"
				MsgBox(0, "Help and Flags", _
					"Checks PC for Windows 11 Release Compatibility" & @CRLF & _
					@CRLF & _
					"WhyNotWin11 [/format:FORMAT filename] [/silent]" & @CRLF & _
					@CRLF & _
					@TAB & "/format" & @TAB & "Export Results in an available format, can be used" & @CRLF & _
					@TAB & "       " & @TAB & "without the /silent flag for both GUI and file" & @CRLF & _
					@TAB & "       " & @TAB & "output. Requires a filename if used." & @CRLF & _
					@TAB & "formats" & @TAB & "TXT, XML" & @CRLF & _
					@TAB & "/silent" & @TAB & "Don't Display the GUI. Compatible Systems will Exit" & @CRLF & _
					@TAB & "       " & @TAB & "with ERROR_SUCCESS." & @CRLF & _
					@CRLF & _
					"All flags can be shortened to just the first character (e.g. /s)" & @CRLF)
			Case "/s", "/silent"
				ChecksOnly()
			Case Else
				MsgBox(0, "Invalid", 'Invalid switch - "' & $CmdLine[$iLoop] & "." & @CRLF)
				Exit 1
		EndSwitch
	Next
Else
	Main()
EndIf

Func ChecksOnly()
EndFunc

Func ExtractFiles()
	Select
		Case Not FileExists(@LocalAppDataDir & "\WhyNotWin11\")
			DirCreate(@LocalAppDataDir & "\WhyNotWin11\")
		Case Not FileExists(@LocalAppDataDir & "\WhyNotWin11\Langs\")
			DirCreate(@LocalAppDataDir & "\WhyNotWin11\Langs\")
			FileInstall(".\langs\0407.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0407.lang") ; German
			FileInstall(".\langs\0409.lang", @LocalAppDataDir & "\WhyNotWin11\Langs\0409.lang") ; English
			ContinueCase
		Case Not FileExists(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			FileInstall(".\includes\SupportedProcessorsAMD.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			FileInstall(".\includes\SupportedProcessorsIntel.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
			FileInstall(".\includes\SupportedProcessorsQualcomm.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
		Case FileExists(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			If _VersionCompare($sVersion, FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt",1)) = 1 Then
				FileInstall(".\includes\SupportedProcessorsAMD.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", $FC_OVERWRITE)
				FileInstall(".\includes\SupportedProcessorsIntel.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt", $FC_OVERWRITE)
				FileInstall(".\includes\SupportedProcessorsQualcomm.txt", @LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt", $FC_OVERWRITE)
			EndIf
		Case Else
			;;;
	EndSelect
EndFunc

Func Main()

	$BKC = _WinAPI_GetSysColor($COLOR_WINDOW)

	$hGUI = GUICreate("WhyNotWin11", 800, 600, -1, -1, BitOr($WS_POPUP,$WS_BORDER))
	GUISetBkColor(_HighContrast(0xF8F8F8))
	GUISetFont(8.5,$FW_BOLD,"","Arial")

	GUICtrlSetDefColor(_WinAPI_GetSysColor($COLOR_WINDOWTEXT))
	GUICtrlSetDefBKColor(_HighContrast(0xF8F8F8))

	; Top Most Interaction for Update Text
	$hUpdate = GUICtrlCreateLabel("", 5, 560, 90, 40, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlSetCursor(-1, 0)

	; Top Most Interaction for Banner
	$hBanner = GUICtrlCreateLabel("", 5, 540, 90, 40, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	; Top Most Interaction for Closing Window
	$hExit = GUICtrlCreateLabel("", 760, 10, 30, 30, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 24, $FW_MEDIUM)

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

	; Allow Dragging of Window
	GUICtrlCreateLabel("", 0, 0, 800, 30, -1, $GUI_WS_EX_PARENTDRAG)

	GUICtrlCreateLabel("", 0, 0, 100, 600)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	_GDIPlus_Startup()
	Local $aIcons[4]
	If @Compiled Then
		$aIcons[0] = GUICtrlCreateIcon(@ScriptFullPath, 201, 12, 100, 32, 32)
		_SetBkIcon($aIcons[0], 0xE6E6E6, @ScriptFullPath, 201, 32, 32)
		$aIcons[1] = GUICtrlCreateIcon(@ScriptFullPath, 202, 56, 100, 32, 32)
		_SetBkIcon($aIcons[1], 0xE6E6E6, @ScriptFullPath, 202, 32, 32)
		$aIcons[2] = GUICtrlCreateIcon(@ScriptFullPath, 203, 12, 144, 32, 32)
		_SetBkIcon($aIcons[2], 0xE6E6E6, @ScriptFullPath, 203, 32, 32)
		$aIcons[3] = GUICtrlCreateIcon(@ScriptFullPath, 204, 56, 144, 32, 32)
		_SetBkIcon($aIcons[3], 0xE6E6E6, @ScriptFullPath, 204, 32, 32)
	Else
		GUICtrlCreateIcon("", -1, 12, 100, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, ".\assets\Git.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 56, 100, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, ".\assets\PP.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 12, 144, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, ".\assets\dis.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 56, 144, 32, 32)
		_SetBkIcon(-1, 0xE6E6E6, ".\assets\Web.ico", -1, 32, 32)
	EndIf
	_GDIPlus_Shutdown()

	$hBannerText = GUICtrlCreateLabel("", 5, 540, 90, 20, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 8.5, $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	$sBannerURL = _SetBannerText($hBannerText, $hBanner)

	GUICtrlCreateLabel(_Translate("Check for Updates"), 5, 560, 90, 40, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 8.5, $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	GUICtrlCreateLabel("WhyNotWin11", 10, 10, 80, 20, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))
	GUICtrlCreateLabel("v " & $sVersion, 10, 30, 80, 20, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, _HighContrast(0xE6E6E6))

	GUICtrlCreateLabel("", 100, 560, 700, 40)
	GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))

	If Not @MUILang = 0409 Then
		GUICtrlCreateLabel(("Translation by") & " " & _GetTranslationCredit(), 130, 570, 250, 20, $SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, _HighContrast(0xF2F2F2))
	EndIf

	GUICtrlCreateLabel(_Translate("Your Windows 11 Compatibility Results are Below"), 130, 30, 640, 40, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 18, $FW_SEMIBOLD, "", "", $CLEARTYPE_QUALITY)

	GUICtrlCreateLabel(_Translate("Now Reach WhyNotWin11 via https://www.whynotwin11.org/"), 130, 60, 640, 20, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 10)

	GUICtrlCreateLabel(_Translate("Results Based on Currently Known Requirements!"), 130, 80, 640, 20, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetColor(-1, 0xE20012)
	GUICtrlSetFont(-1, 10)

	GUICtrlCreateLabel("X", 760, 10, 30, 30, $SS_CENTER+$SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 24, $FW_NORMAL)
	GUICtrlSetCursor(-1, 0)

	Local $hCheck[11][3]
	Local $hLabel[11] = ["Architecture (CPU + OS)", "Boot Method", "CPU Compatibility", "CPU Core Count", "CPU Frequency", "DirectX + WDDM2", "Disk Partition Type", "RAM Installed", "Secure Boot", "Storage Available", "TPM Version"]

	For $iRow = 0 To 10 Step 1
		$hCheck[$iRow][0] = GUICtrlCreateLabel("?", 130, 110 + $iRow * 40, 40, 40, $SS_CENTER+$SS_SUNKEN+$SS_CENTERIMAGE)
		GUICtrlSetBkColor(-1, 0xE6E6E6)
		$hCheck[$iRow][1] = GUICtrlCreateLabel(" " & _Translate($hLabel[$iRow]), 170, 110 + $iRow * 40, 300, 40, $SS_CENTERIMAGE)
		GUICtrlSetFont(-1, 18, $FW_NORMAL)
		$hCheck[$iRow][2] = GUICtrlCreateLabel(_Translate("Checking..."), 470, 110 + $iRow * 40, 300, 40, $SS_CENTER+$SS_SUNKEN)
		GUICtrlSetFont(-1, 12, $FW_SEMIBOLD)
	Next

	GUISetState(@SW_SHOW, $hGUI)

	$hFile = _TempFile()
	$hDXFile = _TempFile(@TempDir, "dxdiag")
	Run("dxdiag /whql:off /t " & $hDXFile)

	Select
		Case @CPUArch = "X64" And @OSArch = "IA64"
			ContinueCase
		Case @CPUArch = "X64" And @OSArch = "X64"
			GUICtrlSetData($hCheck[0][0], "OK")
			GUICtrlSetBkColor($hCheck[0][0], 0x4CC355)
			GUICtrlSetData($hCheck[0][2], _Translate("64 Bit CPU") & @CRLF & _Translate("64 Bit OS"))
		Case @CPUArch = "X64" And @OSArch = "X86"
			GUICtrlSetData($hCheck[0][0], "!")
			GUICtrlSetBkColor($hCheck[0][0], 0xF4C141)
			GUICtrlSetData($hCheck[0][2], _Translate("64 Bit CPU") & @CRLF & _Translate("32 bit OS"))
		Case Else
			GUICtrlSetData($hCheck[0][0], "X")
			GUICtrlSetBkColor($hCheck[0][0], 0xFA113D)
			GUICtrlSetData($hCheck[0][2], _Translate("32 Bit CPU") & @CRLF & _Translate("32 Bit OS"))
	EndSelect

	RunWait("powershell -Command $env:firmware_type | Out-File -FilePath " & $hFile, "", @SW_HIDE)
	Switch StringStripWS(StringStripCR(FileRead($hFile)), $STR_STRIPALL)
		Case "UEFI"
			GUICtrlSetData($hCheck[1][0], "OK")
			GUICtrlSetBkColor($hCheck[1][0], 0x4CC355)
			GUICtrlSetData($hCheck[1][2], FileReadLine($hFile, 1))
		Case "Legacy"
			GUICtrlSetData($hCheck[1][0], "X")
			GUICtrlSetBkColor($hCheck[1][0], 0xFA113D)
			GUICtrlSetData($hCheck[1][2], FileReadLine($hFile, 1))
		Case Else
			GUICtrlSetData($hCheck[1][0], "?")
			GUICtrlSetBkColor($hCheck[1][0], 0xF4C141)
			GUICtrlSetData($hCheck[1][2], _Translate("Unable to Determine"))
	EndSwitch

	Select
		Case StringInStr(_GetCPUInfo(2), "AMD")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt")
			If @error Then
				GUICtrlSetData($hCheck[2][0], "?")
				GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
				GUICtrlSetTip($hCheck[2][0], _Translate("Unable to Check List") & @CRLF & _GetCPUInfo(2))
			EndIf
			For $iLine = 1 to $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsAMD.txt", $iLine)
				Select
					Case @error = -1
						GUICtrlSetData($hCheck[2][0], "?")
						GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
						GUICtrlSetData($hCheck[2][2], _Translate("Error Accessing List") & @CRLF & _GetCPUInfo(2))
						ExitLoop
					Case $iLine = $iLines
						GUICtrlSetData($hCheck[2][0], "?")
						GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
						GUICtrlSetData($hCheck[2][2], _Translate("Not Currently Listed as Compatible") & @CRLF & _GetCPUInfo(2))
						ExitLoop
					Case StringInStr(_GetCPUInfo(2), $sLine)
						GUICtrlSetData($hCheck[2][0], "OK")
						GUICtrlSetBkColor($hCheck[2][0], 0x4CC355)
						GUICtrlSetData($hCheck[2][2], _Translate("Listed as Compatible") & @CRLF & _GetCPUInfo(2))
						ExitLoop
				EndSelect
			Next
		Case StringInStr(_GetCPUInfo(2), "Intel")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt")
			If @error Then
				GUICtrlSetData($hCheck[2][0], "?")
				GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
				GUICtrlSetData($hCheck[2][2], _Translate("Unable to Check List") & @CRLF & _GetCPUInfo(2))
			EndIf
			For $iLine = 1 to $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsIntel.txt", $iLine)
				Select
					Case @error = -1
						GUICtrlSetData($hCheck[2][0], "?")
						GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
						GUICtrlSetData($hCheck[2][2], _Translate("Error Accessing List") & @CRLF & _GetCPUInfo(2))
						ExitLoop
					Case $iLine = $iLines
						GUICtrlSetData($hCheck[2][0], "?")
						GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
						GUICtrlSetData($hCheck[2][2], _Translate("Not Currently Listed as Compatible") & @CRLF & _GetCPUInfo(2))
						ExitLoop
					Case StringInStr(_GetCPUInfo(2), $sLine)
						GUICtrlSetData($hCheck[2][0], "OK")
						GUICtrlSetBkColor($hCheck[2][0], 0x4CC355)
						GUICtrlSetData($hCheck[2][2], _Translate("Listed as Compatible") & @CRLF & _GetCPUInfo(2))
						ExitLoop
				EndSelect
			Next
		Case StringInStr(_GetCPUInfo(2), "SnapDragon") Or StringInStr(_GetCPUInfo(2), "Microsoft")
			$iLines = _FileCountLines(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt")
			If @error Then
				GUICtrlSetData($hCheck[2][0], "?")
				GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
				GUICtrlSetTip($hCheck[2][0], _Translate("Unable to Check List") & @CRLF & _GetCPUInfo(2))
			EndIf
			For $iLine = 1 to $iLines Step 1
				$sLine = FileReadLine(@LocalAppDataDir & "\WhyNotWin11\SupportedProcessorsQualcomm.txt", $iLine)
				Select
					Case @error = -1
						GUICtrlSetData($hCheck[2][0], "?")
						GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
						GUICtrlSetData($hCheck[2][2], _Translate("Error Accessing List") & @CRLF & _GetCPUInfo(2))
						ExitLoop
					Case $iLine = $iLines
						GUICtrlSetData($hCheck[2][0], "?")
						GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
						GUICtrlSetData($hCheck[2][2], _Translate("Not Currently Listed as Compatible") & @CRLF & _GetCPUInfo(2))
						ExitLoop
					Case StringInStr(_GetCPUInfo(2), $sLine)
						GUICtrlSetData($hCheck[2][0], "OK")
						GUICtrlSetBkColor($hCheck[2][0], 0x4CC355)
						GUICtrlSetData($hCheck[2][2], _Translate("Listed as Compatible") & @CRLF & _GetCPUInfo(2))
						ExitLoop
				EndSelect
			Next
		Case Else
			GUICtrlSetData($hCheck[2][0], "?")
			GUICtrlSetBkColor($hCheck[2][0], 0xF4C141)
	EndSelect

	If _GetCPUInfo(0) >= 2 Or _GetCPUInfo(1) >= 2 Then
		GUICtrlSetData($hCheck[3][0], "OK")
		GUICtrlSetBkColor($hCheck[3][0], 0x4CC355)
	Else
		GUICtrlSetData($hCheck[3][0], "X")
		GUICtrlSetBkColor($hCheck[3][0], 0xFA113D)
	EndIf
	GUICtrlSetData($hCheck[3][2], _GetCPUInfo(0) & " " & _Translate("Cores") & @CRLF & _GetCPUInfo(1) & " " & _Translate("Threads"))

	If _GetCPUInfo(3) >= 1000 Then
		GUICtrlSetData($hCheck[4][0], "OK")
		GUICtrlSetBkColor($hCheck[4][0], 0x4CC355)
		GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	Else
		GUICtrlSetData($hCheck[4][0], "X")
		GUICtrlSetBkColor($hCheck[4][0], 0xFA113D)
		GUICtrlSetData($hCheck[4][2], _GetCPUInfo(3) & " MHz")
	EndIf

	RunWait("powershell -Command Get-Partition -DriveLetter $env:SystemDrive | Get-Disk | Select-Object -Property PartitionStyle | Out-File -FilePath " & $hFile, "", @SW_HIDE)
	Select
		Case StringInStr(FileRead($hFile), "Error")
			GUICtrlSetData($hCheck[6][0], "?")
			GUICtrlSetBkColor($hCheck[6][0], 0xF4C141)
			GUICtrlSetData($hCheck[6][2], _Translate("Unable to Determine"))
		Case StringInStr(FileRead($hFile), "GPT")
			GUICtrlSetData($hCheck[6][0], "OK")
			GUICtrlSetBkColor($hCheck[6][0], 0x4CC355)
			GUICtrlSetData($hCheck[6][2], _Translate("GPT Detected"))
		Case Else
			GUICtrlSetData($hCheck[6][0], "X")
			GUICtrlSetBkColor($hCheck[6][0], 0xFA113D)
			GUICtrlSetData($hCheck[6][2], _Translate("GPT Not Detected"))
	EndSelect

	$aMem = DllCall("Kernel32.dll", "int", "GetPhysicallyInstalledSystemMemory", "int*", "")
	If @error Then
		$aMem = MemGetStats()
		$aMem = $aMem[1]
		$aMem = Ceiling($aMem)
	Else
		$aMem = Round($aMem[1]/1048576, 1)
	EndIf
	If $aMem = 0 Then
		$aMem = MemGetStats()
		$aMem = $aMem[1]
		$aMem = Ceiling($aMem)
	EndIf

	If $aMem >= 4 Then
		GUICtrlSetData($hCheck[7][0], "OK")
		GUICtrlSetBkColor($hCheck[7][0], 0x4CC355)
		GUICtrlSetData($hCheck[7][2], $aMem & " GB")
	Else
		GUICtrlSetData($hCheck[7][0], "X")
		GUICtrlSetBkColor($hCheck[7][0], 0xFA113D)
		GUICtrlSetData($hCheck[7][2], $aMem & " GB")
	EndIf

	RunWait("powershell -Command Confirm-SecureBootUEFI | Out-File -FilePath " & $hFile, "", @SW_HIDE)
	Select
		Case StringInStr(FileRead($hFile), "True")
			GUICtrlSetData($hCheck[8][0], "OK")
			GUICtrlSetBkColor($hCheck[8][0], 0x4CC355)
			GUICtrlSetData($hCheck[8][2], _Translate("Enabled"))
		Case StringInStr(FileRead($hFile), "False")
			GUICtrlSetData($hCheck[8][0], "OK")
			GUICtrlSetBkColor($hCheck[8][0], 0x4CC355)
			GUICtrlSetData($hCheck[8][2], _Translate("Supported"))
		Case Else
			GUICtrlSetData($hCheck[8][0], "X")
			GUICtrlSetBkColor($hCheck[8][0], 0xFA113D)
			GUICtrlSetData($hCheck[8][2], _Translate("Disabled / Not Detected"))
	EndSelect

	$aDrives = DriveGetDrive($DT_FIXED)
	$iDrives = 0

	For $iLoop = 1 to $aDrives[0] Step 1
		If Round(DriveSpaceTotal($aDrives[$iLoop])/1024, 0) >= 64 Then $iDrives += 1
	Next


	If Round(DriveSpaceTotal("C:\")/1024, 0) >= 64 Then
		GUICtrlSetData($hCheck[9][0], "OK")
		GUICtrlSetBkColor($hCheck[9][0], 0x4CC355)
		GUICtrlSetData($hCheck[9][2], Round(DriveSpaceTotal("C:\")/1024, 0) & " GB C:\" & @CRLF & $iDrives & " " & _Translate("Drive(s) Meet Requirements"))
	Else
		GUICtrlSetData($hCheck[9][0], "X")
		GUICtrlSetBkColor($hCheck[9][0], 0xFA113D)
		GUICtrlSetData($hCheck[9][2], Round(DriveSpaceTotal("C:\")/1024, 0) & " GB C:\" & @CRLF & $iDrives & " " * _Translate("Drive(s) Meet Requirements"))
	EndIf

	Select
		Case _GetTPMInfo(0) = False
			ContinueCase
		Case _GetTPMInfo(1) = False
			GUICtrlSetData($hCheck[10][0], "X")
			GUICtrlSetBkColor($hCheck[10][0], 0xFA113D)
			GUICtrlSetData($hCheck[10][2], _Translate("TPM Missing / Disabled"))
		Case Not Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
			GUICtrlSetData($hCheck[10][0], "X")
			GUICtrlSetBkColor($hCheck[10][0], 0xFA113D)
			GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Not Supported"))
		Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 2.0
			GUICtrlSetData($hCheck[10][0], "OK")
			GUICtrlSetBkColor($hCheck[10][0], 0x4CC355)
			GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Detected"))
		Case _GetTPMInfo(0) = True And _GetTPMInfo(0) = True And Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) >= 1.2
			;GUICtrlSetData($hCheck[10][0], "OK")
			;GUICtrlSetBkColor($hCheck[10][0], 0xF4C141)
			GUICtrlSetData($hCheck[10][0], "X")
			GUICtrlSetBkColor($hCheck[10][0], 0xFA113D)
			GUICtrlSetData($hCheck[10][2], "TPM " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]) & " " & _Translate("Detected"))
		Case Else
			GUICtrlSetData($hCheck[10][0], "X")
			GUICtrlSetBkColor($hCheck[10][0], 0xFA113D)
			GUICtrlSetData($hCheck[10][2], _GetTPMInfo(0) & " " & _GetTPMInfo(1) & " " & Number(StringSplit(_GetTPMInfo(2), ", ", $STR_NOCOUNT)[0]))
	EndSelect

	FileDelete($hFile)

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
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "3") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:3") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM3")
						GUICtrlSetData($hCheck[5][0], "OK")
						GUICtrlSetBkColor($hCheck[5][0], 0x4CC355)
						GUICtrlSetData($hCheck[5][2], _GetGPUInfo(0) & @CRLF & _Translate("DirectX 12 and WDDM 3"))
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM" & Chr(160) & "2") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:2") ; Non-English Languages
						ContinueCase
					Case StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
						GUICtrlSetData($hCheck[5][0], "OK")
						GUICtrlSetBkColor($hCheck[5][0], 0x4CC355)
						GUICtrlSetData($hCheck[5][2], _GetGPUInfo(0) & @CRLF & _Translate("DirectX 12 and WDDM 2"))
					Case Not StringInStr($sDXFile, "DDIVersion:12") And StringInStr($sDXFile, "DriverModel:WDDM2")
						GUICtrlSetData($hCheck[5][0], "X")
						GUICtrlSetBkColor($hCheck[5][0], 0xFA113D)
						GUICtrlSetData($hCheck[5][2], _GetGPUInfo(0) & @CRLF & _Translate("No DirectX 12, but WDDM2"))
					Case StringInStr($sDXFile, "DDIVersion:12") And Not StringInStr($sDXFile, "DriverModel:WDDM2")
						GUICtrlSetData($hCheck[5][0], "X")
						GUICtrlSetBkColor($hCheck[5][0], 0xFA113D)
						GUICtrlSetData($hCheck[5][2], _GetGPUInfo(0) & @CRLF & _Translate("DirectX 12, but no WDDM2"))
					Case Else
						GUICtrlSetData($hCheck[5][0], "X")
						GUICtrlSetBkColor($hCheck[5][0], 0xFA113D)
						GUICtrlSetData($hCheck[5][2], _GetGPUInfo(0) & @CRLF & _Translate("No DirectX 12 or WDDM2"))
				EndSelect
				FileDelete($hDXFile)

			Case $hMsg = $hBanner
				ShellExecute($sBannerURL)

			Case $hMsg = $hGithub
				ShellExecute("https://fcofix.org/WhyNotWin11")

			Case $hMsg = $hDonate
				ShellExecute("https://paypal.me/rhsky")

			Case $hMsg = $hDiscord
				ShellExecute("https://discord.gg/uBnBcBx")

			Case $hMsg = $hLTT
				ShellExecute("https://linustechtips.com/topic/1350354-windows-11-readiness-check-whynotwin11/")

			Case $hMsg = $hUpdate
				Switch _GetLatestRelease($sVersion)
					Case -1
						MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, _Translate("Test Build?"), _Translate("You're running a newer build than publically available!"), 10)
					Case 0
						Switch @error
							Case 0
								MsgBox($MB_OK+$MB_ICONINFORMATION+$MB_TOPMOST, _Translate("Up to Date"), _Translate("You're running the latest build!"), 10)
							Case 1
								MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, _Translate("Unable to Check for Updates"), _Translate("Unable to load release data."), 10)
							Case 2
								MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, _Translate("Unable to Check for Updates"), _Translate("Invalid Data Received!"), 10)
							Case 3
								Switch @extended
									Case 0
										MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, _Translate("Unable to Check for Updates"), _Translate("Invalid Release Tags Received!"), 10)
									Case 1
										MsgBox($MB_OK+$MB_ICONWARNING+$MB_TOPMOST, _Translate("Unable to Check for Updates"), _Translate("Invalid Release Types Received!"), 10)
								EndSwitch
						EndSwitch
					Case 1
						If MsgBox($MB_YESNO+$MB_ICONINFORMATION+$MB_TOPMOST, _Translate("Update Available"), _Translate("An Update is Availabe, would you like to download it?"), 10) = $IDYES Then ShellExecute("https://fcofix.org/WhyNotWin11/releases")
				EndSwitch

			Case Else
				;;;

		EndSelect
	WEnd
EndFunc

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

EndFunc

Func _GetTranslationCredit()
	Return INIRead(@LocalAppDataDir & "\WhyNotWin11\" & @MUILang & ".lang", "MetaData", "Translator", "???")
EndFunc

Func _HighContrast($sColor)
	Local Static $sSysWin

	If Not $sSysWin <> "" Then $sSysWin = _WinAPI_GetSysColor($COLOR_WINDOW)

	If $sSysWin = 0 Then
		Return 16777215 - $sColor
	Else
		Return $sColor
	EndIf

EndFunc

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
		Case @LogonDomain <> @ComputerName
			GUICtrlSetData($hBannerText, "I'M FOR HIRE")
			Return "https://fcofix.org/rcmaehl/wiki/I'M-FOR-HIRE"
			GUICtrlSetCursor($hBannerText, 0)
			GUICtrlSetCursor($hBanner, 0)
		Case Else
			GUICtrlSetCursor($hBanner, 2)
	EndSelect

EndFunc

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
	Return _WinAPI_OemToChar(INIRead(@LocalAppDataDir & "\WhyNotWin11\Langs\" & @MUILang & ".lang", "Strings", $sString, $sString))
EndFunc
