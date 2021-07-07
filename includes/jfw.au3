Global $o_speech = ObjCreate("jfwapi")
If @error Then
	Sleep(10)
	;msgbox(16, "Error", "Failed to initialice object")
	;exit
EndIf

Func JFWSpeak($text)
	$o_speech.saystring($text, -1)
	;$o_speech = ""
	Return 1 ;
EndFunc   ;==>JFWSpeak
