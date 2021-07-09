#include-once
;more sapi functions, such as change voice, etc
Global $sapi = ObjCreate("sapi.spvoice")
If @error Then
	MsgBox(4096, "Error", "Could not initialize sapi 5 engine.")
EndIf
Func speak($sText, $Ivalue = 0)
	$sapi.Speak($sText, $Ivalue)
EndFunc   ;==>speak
#cs
these are the values to use with the second speech parameter.

Value

Description

0

Default – Synchronous. Control waits until the speaking is done.

1

Asynchronous. Control returns immediately after the command has been accepted which may be BEFORE the text is actively spoken.

2

Purge Before Speak.

All other text statements are purged before it speaks.

4

Is File Name.

Instead of reading the text passed, opens the file and reads the file specified.

8

IsXML. You can send grammatical and pronunciation rules to the Speech engine (see below).

16

IsNotXML. By default, the variables are not read as XML.

32

PersistXML. Changes made in one speak command will persist to other calls to Speak.

64

SpeakPunctuation

With this flag, punctuation is actually spoken so the "." becomes the word "period"

#ce
Func changeVoice($id = 0)
	Local $voices = $sapi.GetVoices()
	Local $number_of_voices = $voices.Count
	If IsInt($id) Then
	Else
		SetError(-1)
		Return 0
	EndIf
	If $id < 0 Then
		SetError(-1)
		Return 0
	EndIf
	$number_of_voices = $number_of_voices - 1
	If $id > $number_of_voices Then
		SetError(-1)
		Return 0
	EndIf
	$sapi.Voice = $voices.Item($id)
	Return 1
EndFunc   ;==>changeVoice
; get_number_of_voices
; This function is quite useful when you want to display a list of all the available voices. ; This will return the number of voices that are installed on your system. Note that if you ; want to change the voice, you need to subtract the number with 1, since it is 0 based when ; you change stuff.
; Return values
; The number of voices installed, 1 based.

Func getNumberOfVoices()
	Local $voices = $sapi.GetVoices()
	Local $number_of_voices = $voices.Count
	Return $number_of_voices
EndFunc   ;==>getNumberOfVoices

; get_voice_name
; Returns the name of the voice that you specify. Once again, it is 0 based. For example, if ; I pass 0 to this function, it will return "Microsoft Mary" on my system. However, it is ;different for every user.
; Return values
; Success returns the name of the voice.
; Failure returns 0 and sets @Error to -1, this will for example be the case if you try to ; get the name of a voice that does not exist. Sometimes, there are corrupt or invalid
; voices on the system, it will return 0 and set @Error to -1 then as well.
; Obviously, those voices cannot be used even though they're in the list, if you try AutoIt ; will generate an error.

Func getVoiceName($i = 0)
	If IsInt($i) Then
	Else
		SetError(-1)
		Return 0
	EndIf
	If $i < 0 Then
		SetError(-1)
		Return 0
	EndIf
	Local $voices = $sapi.GetVoices()
	Local $number_of_voices = $voices.Count
	$number_of_voices = $number_of_voices - 1
	If $number_of_voices < $i Then
		SetError(-1)
		Return 0
	EndIf
	Local $name = "" & $voices.Item($i).GetDescription() & ""
	If $name = "" Then
		SetError(-1)
		Return 0
	EndIf
	Return $name
EndFunc   ;==>getVoiceName
