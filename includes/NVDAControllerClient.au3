#include-once
#cs
Hello.
this include file is  contains some functions to control the NVDA screen reader
by using the nvdaControllerClient Library
These include file  was designed by nacer baaziz
You can contact me in the following accounts.
For any question or inquiry
my Facebook account
https://www.facebook.com/baaziznacer1
my skype name is :
simple-blind
my gmail is :
baaziznacer.140@gmail.com
#ce
#### global variables ###
global $_h_NVDAHandle = -1
### end ###


#cs
Available functions
_nvdaControllerClient_Load()
_nvdaControllerClient_free()
_nvdaControllerClient_SpeakText()
_nvdaControllerClient_brailleMessage()
_nvdaControllerClient_cancelSpeech()
_nvdaControllerClient_testIfRunning()
#ce



#### functions ####
; #FUNCTION# ====================================================================================================================
; Name...........: _nvdaControllerClient_Load
; Description ...: Starts up nvdaControllerClient functions
; Syntax.........: _nvdaControllerClient_Load($s_FileName = @scriptDir & "\nvdaControllerClient32.dll")
; Parameters ....:  -	$s_FileName	-	The relative path to nvdaControllerClient32.dll.
; Return values .: Success      - Returns the dllOpen handle or 1 if the dll is opened before
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										- -1 	-	File could not be found.
;										- 1 	-	dll File could not be load.
; Author ........: nacer baaziz
; Modified.......
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
func _nvdaControllerClient_Load($s_FileName = @scriptDir & "\nvdaControllerClient32.dll")
if $_h_NVDAHandle <> -1 then return 1
if fileExists($s_FileName) then
$_h_NVDAHandle = DllOpen($s_FileName)
if $_h_NVDAHandle = -1 then return SetError(1)
return $_h_NVDAHandle
else
setError(-1)
return false
endIf
endFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _nvdaControllerClient_Free
; Description ...: UnLoad the nvdaControllerClient dll
; Syntax.........: _nvdaControllerClient_free($DllHandle = $_h_NVDAHandle)
; Parameters ....:  -	$DllHandle	-	 the dllOpen handel returned by _nvdaControllerClient_Load.
; Return values .: Success      - Returns -1 if the dll is Closed.
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										- 0 	-	0 if the _nvdaControllerClient_Load is not used.
; Author ........: nacer baaziz
; Modified.......
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
func _nvdaControllerClient_free($DllHandle = $_h_NVDAHandle)
if $DllHandle <> -1 then
setError(0)
return false
endIf
DllClose($DllHandle)
$_h_NVDAHandle = -1
return $_h_NVDAHandle
endFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _nvdaControllerClient_SpeakText
; Description ...: speak a custom text using the NVDA screen Reader
; Syntax.........: _nvdaControllerClient_SpeakText($s_text, $DllHandle = $_h_NVDAHandle)
; Parameters ....:  -		$s_text the text-	
; -	$DllHandle	-	 the dllOpen handel returned by _nvdaControllerClient_Load.
; Return values .: Success      - Returns 1 .
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										-  	-	0 if the _nvdaControllerClient_Load is not used.
;										-  	-	dllCall result if there is any problem when try to call the dll file.
; Author ........: nacer baaziz
; Modified.......
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================

func _nvdaControllerClient_SpeakText($s_text, $DllHandle = $_h_NVDAHandle)
if $DllHandle = -1 then
setError(0)
return false
endIf
local $aDLLSpeak = DllCall($DllHandle, "long", "nvdaController_speakText", "wstr", String($s_text))
if @error then return $aDLLSpeak
return 1
endFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _nvdaControllerClient_brailleMessage
; Description ...: View any custom text in the Braille line
; Syntax.........: _nvdaControllerClient_brailleMessage($s_text, $DllHandle = $_h_NVDAHandle)
; Parameters ....:  -		$s_text the text-	
; -	$DllHandle	-	 the dllOpen handel returned by _nvdaControllerClient_Load.
; Return values .: Success      - Returns 1 .
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										-  	-	0 if the _nvdaControllerClient_Load is not used.
;										-  	-	dllCall result if there is any problem when try to call the dll file.
; Author ........: nacer baaziz
; Modified.......
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================

func _nvdaControllerClient_brailleMessage($s_text, $DllHandle = $_h_NVDAHandle)
if $DllHandle = -1 then
setError(0)
return false
endIf
local $aDLLMSg = DllCall($DllHandle, "long", "nvdaController_brailleMessage", "wstr", String($s_text))
if @error then return $aDLlMSG
return 1
endFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _nvdaControllerClient_cancelSpeech
; Description ...: Stop NVDA from talking
; Syntax.........: _nvdaControllerClient_cancelSpeech($DllHandle = $_h_NVDAHandle)
; Parameters ....:  -	$DllHandle	-	 the dllOpen handel returned by _nvdaControllerClient_Load.
; Return values .: Success      - Returns 1 .
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										-  	-	0 if the _nvdaControllerClient_Load is not used.
;										-  	-	dllCall result if there is any problem when try to call the dll file.
; Author ........: nacer baaziz
; Modified.......
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================

func _nvdaControllerClient_cancelSpeech($DllHandle = $_h_NVDAHandle)
if $DllHandle = -1 then 
setError(0)
return false
endIf
local $aDLLCancel = DllCall($DllHandle, "long", "nvdaController_cancelSpeech");, "wstr", "")
if @error then return $aDLLCancel
return 1
endFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _nvdaControllerClient_testIfRunning
; Description ...: test if the NVDA is running
; Syntax.........: _nvdaControllerClient_testIfRunning($DllHandle = $_h_NVDAHandle)
; Parameters ....:  -	$DllHandle	-	 the dllOpen handel returned by _nvdaControllerClient_Load.
; Return values .: Success      - Returns true if the NVDA is Running, else return false.
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										-  	-	0 if the _nvdaControllerClient_Load is not used.
;										-  	-	-1 if there is any problem when try to call the dll file.
; Author ........: nacer baaziz
; Modified.......
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================


func _nvdaControllerClient_testIfRunning($DllHandle = $_h_NVDAHandle)
if $DllHandle = -1 then
setError(0)
return false
endIf
local $aDLLIsRun = DllCall($DllHandle, "long", "nvdaController_testIfRunning")
if not (isArray($aDLLIsRun)) then return setError(-1)
if $aDLLIsRun[0] <> 0 then return false
return true
endFunc
### end ####