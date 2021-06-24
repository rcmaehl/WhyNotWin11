#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\Downloads\windows11-logo.ico
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <String.au3>

RunWait("powershell -Command Get-Tpm | Out-File -FilePath .\WhyNot.txt", "", @SW_HIDE)

$sTPM = _StringBetween(FileRead(".\WhyNot.txt"), "TpmPresent", "TpmReady")[0]
$sTPM = StringStripWS($sTPM, $STR_STRIPALL)
$sTPM = StringTrimLeft($sTPM, 1)

RunWait("powershell -Command $env:firmware_type | Out-File -FilePath .\WhyNot.txt", "", @SW_HIDE)

$sBOOT = FileRead(".\WhyNot.txt")
$sBOOT = StringStripWS($sBOOT, $STR_STRIPALL)

RunWait("powershell -Command Get-Partition -DriveLetter C | Get-Disk | Out-File -FilePath .\WhyNot.txt", "", @SW_HIDE)

$sGPT = FileRead(".\WhyNot.txt")
If StringInStr($sGPT, "GPT") Then
	$sGPT = "GPT"
Else
	$sGPT = "Not GPT"
EndIf

FileDelete(".\WhyNot.txt")

MsgBox(0, "WhyNotWin11", "TPM:" & @TAB & $sTPM & @CRLF & _
						"BOOT:" & @TAB & $sBOOT & @CRLF & _
						"DISK:" & @TAB & $sGPT)