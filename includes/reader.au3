#include-once
#include "jfw.au3"
#include "sapi.au3"
;este es un script para los lectores de pantalla. this is a script for screen readers.
;Autor: Mateo Cedillo.
Func speaking($text)
	Local $speak = IniRead(@ScriptDir & "\config\config.st", "accessibility", "Speak Whit", "")
	Select
		Case $speak = "Sapi"
			speak($text, 3)
		Case $speak = "JAWS"
			JFWSpeak($text)
		Case Else
			autodetect()
	EndSelect
EndFunc   ;==>speaking

Func autodetect()
	If ProcessExists("JFW.exe") Then
		IniWrite(@ScriptDir & "\config\config.st", "accessibility", "Speak Whit", "JAWS")
	EndIf
	If Not ProcessExists("JFW.exe") Then
		IniWrite(@ScriptDir & "\config\config.st", "accessibility", "Speak Whit", "Sapi")
	EndIf
EndFunc   ;==>autodetect

Func TTsDialog($text, $ttsString = " press enter to continue, space to repeat information.")
	Local $pressed = 0
	Local $repeatinfo = 0
	speaking($text & @LF & $ttsString)
	While 1
		Local $active_window = WinGetProcess("")
		If $active_window = @AutoItPID Then
			Sleep(10)
			;ContinueLoop
		EndIf
		If Not _IsPressed($spacebar) Or Not _IsPressed($up) Or Not _IsPressed($down) Or Not _IsPressed($left) Or Not _IsPressed($right) Then $repeatinfo = 0
		If _IsPressed($spacebar) Or _IsPressed($up) Or _IsPressed($down) Or _IsPressed($left) Or _IsPressed($right) And $repeatinfo = 0 Then
			$repeatinfo = 1
			speaking($text & @LF & $ttsString)
		EndIf
		If Not _IsPressed($control) And _IsPressed($c) Then $pressed = 0
		If _IsPressed($control) And _IsPressed($c) And $pressed = 0 Then
			ClipPut($text)
			speaking($text & "Copied to clipboard.")
		EndIf
		If Not _IsPressed($enter) Then $pressed = 0
		If _IsPressed($enter) And $pressed = 0 Then
			$pressed = 1
			speaking("ok")
			ExitLoop
		EndIf
		Sleep(50)
	WEnd
EndFunc   ;==>TTsDialog

Func createTtsOutput($filetoread, $title)
	Local $move_doc = 0
	Local $r_file = FileReadToArray($filetoread)
	Local $iCountLines = @extended
	Local $not = 0
	If @error Then
		speaking("Error reading file...")
	Else
		speaking($title)
	EndIf
	While 1
		Local $active_window = WinGetProcess("")
		If $active_window = @AutoItPID Then
		Else
			Sleep(10)
			ContinueLoop
		EndIf
		If Not _IsPressed($up) Then $not = 1
		If _IsPressed($up) And $move_doc = 0 Then
			Return $move_doc
			speaking("home.")
		EndIf
		Sleep(15)
		If Not _IsPressed($up) Then $not = 1
		If _IsPressed($up) And $move_doc > 0 Then
			$move_doc = $move_doc - 1
			speaking($r_file[$move_doc])
		EndIf
		Sleep(15)
		If Not _IsPressed($down) Then $not = 1
		If _IsPressed($down) And $move_doc = $iCountLines Then
			Return $move_doc
			speaking("document end. Press enter to back.")
			If Not _IsPressed($enter) Then $not = 0
			If _IsPressed($enter) And $not = 0 Then
				$not = 0
				ExitLoop
			EndIf
		EndIf
		Sleep(15)
		If Not _IsPressed($down) Then $not = 1
		If _IsPressed($down) Then ; AND $move_doc > 0 Then
			$move_doc = $move_doc + 1
			speaking($r_file[$move_doc])
		EndIf
		Sleep(15)
	WEnd
EndFunc   ;==>createTtsOutput
