;#include "kbc.au3"
#include-once
#include "jfw.au3"
#include "NVDAControllerClient.au3"
#include "sapi.au3"
;este es un script para los lectores de pantalla. this is a script for screen readers.
;Autor: Mateo Cedillo.
func speaking($text)
$speak = iniRead ("config\config.st", "accessibility", "Speak Whit", "")
select
case $speak ="NVDA"
_nvdaControllerClient_Load()
if @error then
msgBox(16, "error", "cant load the NVDA DLL file")
exit
else
_NVDAControllerClient_SpeakText($text)
_NVDAControllerClient_BrailleMessage($text)
EndIf
case $speak ="Sapi"
speak($text, 3)
case $speak ="JAWS"
JFWSpeak($text)
Case Else
autoDetect()
endselect
endfunc
func autodetect()
If ProcessExists("NVDA.exe") Then
IniWrite("config\config.st", "accessibility", "Speak Whit", "NVDA")
endif
If ProcessExists("JFW.exe") Then
IniWrite("config\config.st", "accessibility", "Speak Whit", "JAWS")
endif
If not ProcessExists("NVDA.exe") or ProcessExists("JFW.exe") Then
IniWrite("config\config.st", "accessibility", "Speak Whit", "Sapi")
EndIf
endfunc
func TTsDialog($text, $ttsString = " press enter to continue, space to repeat information.")
$pressed = 0
$repeatinfo = 0
If ProcessExists("NVDA.exe") Then
_NVDAControllerClient_CancelSpeech()
endif
speaking($text &@lf &$ttsString)
While 1
$active_window = WinGetProcess("")
If $active_window = @AutoItPid Then
Sleep(10)
;ContinueLoop
EndIf
If NOT _ispressed($spacebar) or NOT _ispressed($up) or NOT _ispressed($down) or NOT _ispressed($left) or NOT _ispressed($right) Then $repeatinfo = 0
If _ispressed($spacebar) or _ispressed($up) or _ispressed($down) or _ispressed($left) or _ispressed($right) AND $repeatinfo = 0 Then
$repeatinfo = 1
If ProcessExists("NVDA.exe") Then
_NVDAControllerClient_CancelSpeech()
endif
speaking($text &@lf &$ttsString)
EndIf
If not _ispressed($control) AND _ispressed($c) Then $pressed = 0
If _ispressed($control) AND _ispressed($c) AND $pressed = 0 Then
ClipPut($text)
speaking($text &"Copied to clipboard.")
EndIf
If NOT _ispressed($enter) Then $pressed = 0
If _ispressed($enter) AND $pressed = 0 Then
$pressed = 1
speaking("ok")
ExitLoop
endIf
Sleep(50)
wend
endFunc
func createTtsOutput($filetoread,$title)
$move_doc = 0
	Local $r_file = FileReadToArray($filetoread)
Local $iCountLines = @extended
$not = 0
If @error Then
speaking("Error reading file...")
writeinlog("error reading file...")
	Else
speaking($title)
writeinlog("Dialog: " &$title)
writeinlog("file: " &$filetoread)
writeinlog("File information: Lines: " &$iCountLines)
endIf
While 1
$active_window = WinGetProcess("")
If $active_window = @AutoItPid Then
Else
Sleep(10)
ContinueLoop
EndIf
If NOT _ispressed($up) Then $not = 1
If _ispressed($up) AND $move_doc = 0 Then
return $move_doc
speaking("home.")
writeinlog($move_doc)
endIf
Sleep(15)
If NOT _ispressed($up) Then $not = 1
If _ispressed($up) AND $move_doc > 0 Then
$move_doc = $move_doc -1
speaking($R_File[$MOVE_DOC])
writeinlog($move_doc)
endIf
Sleep(15)
If NOT _ispressed($down) Then $not = 1
If _ispressed($down) AND $move_doc = $iCountLines then
return $move_doc
speaking("document end. Press enter to back.")
If NOT _ispressed($enter) Then $not = 0
If _ispressed($enter) AND $not = 0 Then
$not = 0
ExitLoop
endIf
endIf
sleep(15)
If NOT _ispressed($down) Then $not = 1
If _ispressed($down) then; AND $move_doc > 0 Then
$move_doc = $move_doc +1
writeinlog($move_doc)
speaking($R_File[$MOVE_DOC])
endIf
Sleep(15)
Wend
EndFunc