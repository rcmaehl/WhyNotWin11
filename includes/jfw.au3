$o_speech = ObjCreate("jfwapi")
if @error then
sleep(10)
;msgbox(16, "Error", "Failed to initialice object")
;exit
EndIf
func JFWSpeak($text)
$o_speech.saystring ($text,-1)
;$o_speech = ""
return 1;
EndFunc