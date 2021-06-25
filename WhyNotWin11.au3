#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=.\windows11-logo.ico
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Detection Script to help identify the more niche settings for why your PC isn't Windows 11 ready
#AutoIt3Wrapper_Res_Fileversion=1.1.2
#AutoIt3Wrapper_Res_ProductVersion=1.1.2
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <String.au3>
#include <AutoItConstants.au3>

RunWait("powershell -Command Get-Tpm | Out-File -FilePath .\WhyNot.txt", "", @SW_HIDE)
$sTPM = _StringBetween(FileRead(".\WhyNot.txt"), "TpmPresent", "TpmReady")
If Not IsArray($sTPM) Then
	MsgBox(16, "Get-TPM call failed", "TPM check 1 failed; The application may be running in a sandbox, attempting alternative check.", 10)
	$sFile = @WorkingDir & "\WhyNot.txt"
	$iPID = Run(@ComSpec & ' /k C:\Windows\System32\tpmtool.exe getdeviceinformation > ' & $sFile, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $sOut = ""
	While 1
		$sOut = $sOut & @CRLF & StdoutRead($iPID)
		If @error Then ExitLoop ; Exit the loop if the process closes or StdoutRead returns an error.
	WEnd
	MsgBox(0, "Out", $sOut)
	Exit
	$sTPM = _StringBetween(FileRead(".\WhyNot.txt"), "-TPM Present:", "-TPM Version")
	If Not IsArray($sTPM) Then
		MsgBox(16, "TPMTool call failed", "TPM check 2 failed; This will be reported as 'Not Present'.", 10)
		$sTPM = "???"
	Else
		$sTPM = $sTPM[0]
		$sTPM = StringStripWS($sTPM, $STR_STRIPALL)
		$sTPM = StringTrimLeft($sTPM, 1)
		$sTPMV = "Unknown"
	EndIf
Else
	$sTPM = $sTPM[0]
	$sTPM = StringStripWS($sTPM, $STR_STRIPALL)
	$sTPM = StringTrimLeft($sTPM, 1)
	$sTPMV = _StringBetween(FileRead(".\WhyNot.txt"), "-TPM Version: ", "-TPM Manufacturer ID:")
	If Not IsArray($sTPM) Then
		$sTPMV = "Unknown"
	Else
		$sTPMV = $sTPMV[0]
	EndIf
EndIf

If $sTPM = "True" Then
	Switch $sTPMV
		Case "2.0"
			$sTPM = "Present";, Up To Date"
			$sTPMText = "Congrats, this value checks out."
		Case "Unknown"
			$sTPM = "Present";, Version Unknown"
			$sTPMText = "Congrats, this value checks out.";"A TPM was detected but it's version couldn't be determined. Search 'Security Processor' in the Windows 10 start menu to check that it's version 2.0 manually."
		Case Else
			$sTPM = "Present, Out of Date"
			$sTPMText = "A TPM was detected but it does not meet TPM 2.0 specifications. You may be able to work around this by buying a TPM 2.0 chip, or upgrading your Processor."
	EndSwitch
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