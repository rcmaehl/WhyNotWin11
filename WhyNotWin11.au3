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

If $sTPM = "True" Then
	$sTPM = "Present"
	$sTPMText = "Congrats, this value checks out."
Else
	$sTPM = "Not Present"
	$sTPMText = "TPM should have a 'Present' result. This means a TPM is installed and enabled. If you have an AMD Ryzen Processor, you may have a TPM that is not enabled. If you have a newer Intel Processor, you MAY have a TPM that is not enabled but it is not guaranteed, you can check at https://ark.intel.com/. If not enabled, you can adjust this in your motherboard settings."
EndIf

RunWait("powershell -Command $env:firmware_type | Out-File -FilePath .\WhyNot.txt", "", @SW_HIDE)

$sBOOT = FileRead(".\WhyNot.txt")
$sBOOT = StringStripWS($sBOOT, $STR_STRIPALL)
If Not StringInStr($sBOOT, "Legacy") Then
	$sBOOTText = "Congrats, this value checks out."
Else
	$sBOOTText = "BOOT should have a 'UEFI' or 'Secure' result. This means that your computer is using modern and secure code to prevent data tampering during boot. You can adjust this in your motherboard settings after ensuring that your disk below is GPT."
EndIf

RunWait("powershell -Command Get-Partition -DriveLetter C | Get-Disk | Out-File -FilePath .\WhyNot.txt", "", @SW_HIDE)

$sGPT = FileRead(".\WhyNot.txt")
If StringInStr($sGPT, "GPT") Then
	$sGPT = "GPT"
	$sGPTText = "Congrats, this value checks out."
Else
	$sGPT = "Not GPT"
	$sGPTText = "DISK should have a 'GPT' result. This means your disk can have it's data on the disk organized in more efficient and modern ways. You can adjust this in Disk Management. Additionally, Intel has a guide available, Google Search 'Intel Converting Legacy' (without quotes)."
EndIf

FileDelete(".\WhyNot.txt")

MsgBox(0, "WhyNotWin11", "TPM:" & @TAB & $sTPM & @CRLF & _
						@CRLF & _
						$sTPMText & @CRLF & _
						@CRLF & _
						"BOOT:" & @TAB & $sBOOT & @CRLF & _
						@CRLF & _
						$sBOOTText & @CRLF & _
						@CRLF & _
						"DISK:" & @TAB & $sGPT & @CRLF & _
						@CRLF & _
						$sGPTText)