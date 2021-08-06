#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
; #Tidy_Parameters=/sort_funcs /reel
#include-once

#include <APIResConstants.au3>
#include <ButtonConstants.au3>
#include <GDIPlus.au3>
#include <GUIMenu.au3>
#include <Memory.au3>
#include <StaticConstants.au3>
#include <WinAPIMisc.au3>
#include <WinAPIRes.au3>
#include <WindowsConstants.au3>

; Call once the script has ended to tidy up the used resources
OnAutoItExitRegister(_GDIPlus_Shutdown)
OnAutoItExitRegister(_Resource_DestroyAll)
_GDIPlus_Startup()

#Region ResourcesEx.au3 - Header
; #INDEX# =======================================================================================================================
; Title .........: ResourcesEx
; AutoIt Version : 3.3.12.0+
; Language ......: English
; Description ...:
; Author ........: Zedna (original)
; Modified ......: guinness (current). Thanks to Jos, Larry, Melba23, mLipok, ProgAndy, UEZ, ward and Yashied
; Dll ...........:
; ===============================================================================================================================

#cs
	TODO:
	Bug testing by the AutoIt community: http://www.autoitscript.com/forum/topic/162499-resourcesex-udf/
	http://pastebin.com/5ru8H0cN

	Code examples:
	http://www.autoitscript.com/forum/topic/74565-extracticontofile-with-simple-gui-example/page-2#entry670142
	Ref by AZJIO: http://www.autoitscript.com/forum/topic/51103-resources-udf/?p=1013300
	Ref by Funkey: http://www.autoitscript.com/forum/topic/140449-createresourcedll/
	Ref by ward: http://www.autoitscript.com/forum/topic/156041-resource-project-third-version/
	Ref by Yashied: http://www.autoitscript.com/forum/topic/51103-resources-udf/?p=1147585

	Resources:
	Resources Ref: http://www.skynet.ie/~caolan/publink/winresdump/winresdump/doc/resfmt.txt
	Resources Ref: http://msdn.microsoft.com/en-us/library/windows/desktop/aa381043(v=vs.85).aspx
	Icons Ref: http://msdn.microsoft.com/en-gb/library/windows/desktop/ms648050(v=vs.85).aspx#_win32_Icon_Sizes

	Changelog:
	2015/09/26
	Changed: Comments throughout the UDF, removing trailing dot
	Fixed: Various cosmetic changes

	2015/01/12
	Fixed: Example directive using double equals sign
	Fixed: Delete functions not being cast as a bool value. (Thanks Synix)
	Fixed: @error and @extended not be passed back in nested functions e.g. _Resource_GetAsRaw()

	2014/07/19
	Added: _Resource_SetBitmapToCtrlID() formerly known as _Resource_SetImageToCtrlID()
	Added: Note about using #AutoIt3Wrapper_Res_Icon_Add to the example. (Thanks Zedna)
	Added: Passing a blank string to _Resource_SetToCtrlID() through the $sResNameOrID parameter, will delete the image and previous handle
	Changed: _Resource_SetImageToCtrlID() now accepts a hBitmap not a HBITMAP object
	Fixed: _Resource_GetAsBitmap() now works the same way as _ResourceGetAsBitmap() did, by converting a jpg, png etc... to HBITMAP
	Fixed: Memory management of some functions

	2014/07/18
	Fixed: Destroying a cursor
	Fixed: Regression from loading the current of external module. (Thanks UEZ)

	2014/07/17
	Added: Additional checks to destroy cursors and icons
	Added: Checking if the dll or exe filepath has a valid extension
	Added: Example of using an icon and image on a button control
	Fixed: Icons and cursors (finally) being re-sized to a control
	Fixed: Using GUIGetStyle() on a non-AutoIt handle would cause issue with controls
	Fixed: Variable naming of $sDLL to $sDllOrExePath for improved clarity
	Removed: Workaround for setting icons to AutoIt controls

	2014/07/17
	Added: Commented workaround in the example for re-sizing an icon control
	Added: ResourcesEx_PE.au3 created by PreExpand for all you constant variable haters out there!!!
	Fixed: Changelog comments and source code comments
	Fixed: Re-sizing icons when the control was different to the icon's size. (Thanks czardas for the MSDN link and Jon.)
	Fixed: Re-sizing cursors and icons in general

	2014/07/15
	Added: Comments about using SOUND for wav files and RT_RCDATA for mp3 files. (Thanks Melba23)
	Added: Option to relevant functions to re-size the image based on the control's dimensions. (Requested by kinch: http://www.autoitscript.com/forum/topic/51103-resources-udf/?p=1147525)
	Added: Using _Resource_LoadFont() example. (Thanks UEZ)
	Changed: Certain example resources to now use those found in %AUTOITDIR%\Examples\Helpfile\Extras
	Changed: Constants and enums readability. (Thank mLipok)
	Changed: Internal functions for destroying resources
	Changed: Removed changes made from the previous version for loading resources multiple times. The design needs to be re-thought
	Changed: Setting styles of controls using native AutoIt functions
	Fixed: Destroying control resource images would fail to show if reinstated again
	Fixed: Documentation comments
	Fixed: Missing certain users who helped with creating this UDF
	Fixed: Outdated SciTE files

	2014/07/14:
	Added: _Resource_GetAsCursor(), for the loading of animated cursors and standard cursors which can then be used with _WinAPI_SetCursor()
	Added: _Resource_GetAsIcon(), for loading icon resource types
	Added: _Resource_LoadFont(), which retrieves a font resource and adds to the current memory of the associated module
	Added: _Resource_SetCursorToCtrlID() and _Resource_SetIconToCtrlID()
	Added: Additional resource types to destroy on exit, including $RT_FONT, $RT_ICON and $RT_MENU
	Added: Playing Mp3s to _Resource_LoadSound(). (Thanks to UEZ and Melba23 with changes made by me.)
	Changed: _Resource_GetAsBitmap() returns a HTBITMAP handle without converting from hBitmap to HBITMAP
	Changed: _Resource_PlaySound() to _Resource_LoadSound()
	Changed: _Resource_SetBitmapToCtrlID() to _Resource_SetImageToCtrlID()
	Changed: _SendMessage() to GUICtrlSendMsg()
	Changed: Example files
	Changed: Setting $iError in the internal get function
	Changed: Signature of _Resource_Destroy()
	Changed: Updated example to reflect major changes to the ResourcesEx UDF
	Changed: Various UDF tweaks that I didn't document because I simply couldn't keep track of all the playing around I did in the last week
	Fixed: _Resource_GetAsImage() not returning an error when a bitmap couldn't be found in the resource table
	Fixed: Retrieving length of a string
	Fixed: Using the current module instead of zero in _Resource_LoadSound()
	Fixed: Various comment changes. (Thanks mLipok)
	Fixed: Loading resources multiple times. This is fixed thanks to using the internal storage array

	2014/07/07:
	Added: _Resource_Destroy() and _Resource_DestroyAll() to destroy a particular resource name or all resources
	Added: Checking if the resource name of id value is empty
	Added: Descriptions, though could do with a little tweaking
	Changed: _Resource_Get() to _Resource_GetAsRaw()
	Changed: Internal workings of __Resource_Storage()
	Changed: Re-size the storage array when destroyed or on shutdown
	Fixed: _Resource_GetAsString() with default encoding of ANSI
	Fixed: Calltips API referencing Resources.au3 and not ResourcesEx.au3
	Removed: _Resource_Shutdown() due to the addition of _Resource_Destroy() and _Resource_DestroyAll()

	2014/07/06:
	Added: _Resource_Shutdown() to free up those resources which aren't loaded using _WinAPI_LockResource(). UnlockResource is obsolete
	Added: Support for using $RT_STRING
	Changed: _Resource_GetAsString() now works correctly for most encodings. (Thanks Jos)
	Changed: _Resource_GetAsString() will now load as a string if the resource type requested is $RT_STRING

	2014/07/04:
	Added: #Regions. (Thanks mLipok)
	Added: #Tidy_Parameters=/sort_funcs /reel (Thanks mLipok)
	Added: All optional params now accept the default keyword
	Added: Link to this thread. (Thanks mLipok)
	Added: Main header. (Thanks mLipok)
	Changed:  $f.... >> $b..... (Thanks mLipok)

	2014/07/03:
	Initial release
#ce
#EndRegion ResourcesEx.au3 - Header

#Region ResourcesEx.au3 - #VARIABLES#
; #VARIABLES# ===================================================================================================================
; Error enumeration flags
Global Enum _
		$RESOURCE_ERROR_NONE, _
		$RESOURCE_ERROR_FINDRESOURCE, _
		$RESOURCE_ERROR_INVALIDCONTROLID, _
		$RESOURCE_ERROR_INVALIDCLASS, _
		$RESOURCE_ERROR_INVALIDRESOURCENAME, _
		$RESOURCE_ERROR_INVALIDRESOURCETYPE, _
		$RESOURCE_ERROR_LOCKRESOURCE, _
		$RESOURCE_ERROR_LOADBITMAP, _
		$RESOURCE_ERROR_LOADCURSOR, _
		$RESOURCE_ERROR_LOADICON, _
		$RESOURCE_ERROR_LOADIMAGE, _
		$RESOURCE_ERROR_LOADLIBRARY, _
		$RESOURCE_ERROR_LOADSTRING, _
		$RESOURCE_ERROR_SETIMAGE
Global Const _
		$RESOURCE_SS_ENHMETAFILE = 0xF
Global Const _
		$RESOURCE_SS_REALSIZECONTROL = 0x40
Global Const _
		$RESOURCE_STM_SETICON = 0x0170
Global Const _
		$RESOURCE_STM_GETIMAGE = 0x0173
Global Const _
		$RESOURCE_STM_SETIMAGE = 0x0172
Global Const _
		$RESOURCE_LANG_DEFAULT = 0
Global Enum _
		$RESOURCE_RT_BITMAP = 1000, _
		$RESOURCE_RT_ENHMETAFILE, _
		$RESOURCE_RT_FONT
Global Enum _
		$RESOURCE_POS_H, _
		$RESOURCE_POS_W, _
		$RESOURCE_POS_MAX
Global Const _
		$RESOURCE_STORAGE_GUID = 'CA37F1E6-04D1-11E4-B340-4B0AE3E253B6'
Global Enum _
		$RESOURCE_STORAGE, _
		$RESOURCE_STORAGE_FIRSTINDEX
Global Enum _
		$RESOURCE_STORAGE_ID, _
		$RESOURCE_STORAGE_INDEX, _
		$RESOURCE_STORAGE_RESETCOUNT, _
		$RESOURCE_STORAGE_UBOUND
Global Enum _
		$RESOURCE_STORAGE_DLL, _
		$RESOURCE_STORAGE_CASTRESTYPE, _
		$RESOURCE_STORAGE_LENGTH, _
		$RESOURCE_STORAGE_PTR, _
		$RESOURCE_STORAGE_RESLANG, _
		$RESOURCE_STORAGE_RESNAMEORID, _
		$RESOURCE_STORAGE_RESTYPE, _
		$RESOURCE_STORAGE_MAX, _
		$RESOURCE_STORAGE_ADD, _
		$RESOURCE_STORAGE_DESTROY, _
		$RESOURCE_STORAGE_DESTROYALL, _
		$RESOURCE_STORAGE_GET
Global Enum _
		$RESOURCE_WINGETPOS_XPOS, _
		$RESOURCE_WINGETPOS_YPOS, _
		$RESOURCE_WINGETPOS_WIDTH, _
		$RESOURCE_WINGETPOS_HEIGHT

; ===============================================================================================================================
#EndRegion ResourcesEx.au3 - #VARIABLES#

#Region ResourcesEx.au3 - #FUNCTION#
; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_Destroy
; Description ...: Destroy a resource name or id value
; Syntax ........: _Resource_Destroy($sResNameOrID[, $iResType = $RT_RCDATA])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $iResLang            - [optional] A language identifier. Default value is 0
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - True
;                  Failure - False
; Author ........: guinness
; Modified ......:
; Remarks .......: Destroys the open $RT_BITMAP handles etc...of a resource name or id value
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_Destroy($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default)
	If $iResLang = Default Then $iResLang = $RESOURCE_LANG_DEFAULT
	If $iResType = Default Then $iResType = $RT_RCDATA
	Return __Resource_Storage($RESOURCE_STORAGE_DESTROY, $sDllOrExePath, Null, $sResNameOrID, $iResType, $iResLang, $iResType, Null)
EndFunc   ;==>_Resource_Destroy

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_DestroyAll
; Description ...: Destroy all resources
; Syntax ........: _Resource_DestroyAll()
; Parameters ....: None
; Return values .: Success - True
;                  Failure - False
; Author ........: guinness
; Modified ......:
; Remarks .......: Destroys all open $RT_BITMAP handles etc...of a resource name or id value
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_DestroyAll()
	Return __Resource_Storage($RESOURCE_STORAGE_DESTROYALL, Null, Null, Null, Null, Null, Null, Null)
EndFunc   ;==>_Resource_DestroyAll

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_GetAsBitmap
; Description ...: Get an image resource as a HBITMAP handle
; Syntax ........: _Resource_GetAsBitmap($sResNameOrID[, $iResType = $RT_RCDATA[, $sDllOrExePath = Default]])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - HBITMAP handle
;                  Failure - Zero and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness
; Remarks .......: The size of the resource is stored in @extended
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_GetAsBitmap($sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default)
	Local $hHBITMAP = 0, $hBitmap = _Resource_GetAsImage($sResNameOrID, $iResType, $sDllOrExePath)
	Local $iError = @error
	Local $iLength = @extended
	If $iError = $RESOURCE_ERROR_NONE And $iLength > 0 Then
		$hHBITMAP = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap) ; Convert to HBITMAP
		If @error Then
			$iError = $RESOURCE_ERROR_LOADBITMAP
		Else
			_GDIPlus_BitmapDispose($hBitmap)
			$hBitmap = 0
		EndIf
	EndIf
	If $iError <> $RESOURCE_ERROR_NONE Then $hHBITMAP = 0

	Return SetError($iError, $iLength, $hHBITMAP)
EndFunc   ;==>_Resource_GetAsBitmap

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_GetAsCursor
; Description ...: Get a resource as a cursor handle
; Syntax ........: _Resource_GetAsCursor($sResNameOrID[, $iResType = $RT_RCDATA[, $sDllOrExePath = Default]])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - Cursor handle
;                  Failure - Zero and sets @error to non-zero
; Author ........: guinness
; Modified ......:
; Remarks .......: The size of the resource is stored in @extended
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_GetAsCursor($sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default)
	Local $hCursor = __Resource_Get($sResNameOrID, $iResType, $RESOURCE_LANG_DEFAULT, $sDllOrExePath, $RT_CURSOR)
	Local $iError = @error
	Local $iLength = @extended
	If $iError <> $RESOURCE_ERROR_NONE Then $hCursor = 0

	Return SetError($iError, $iLength, $hCursor)
EndFunc   ;==>_Resource_GetAsCursor

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_GetAsBytes
; Description ...: Get a resources as bytes
; Syntax ........: _Resource_GetAsBytes($sResNameOrID[, $iResType = $RT_RCDATA[, $iResLang = Default[, $sDllOrExePath = Default]]])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $iResLang            - [optional] A language identifier. Default value is 0
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - String of bytes
;                  Failure - Empty byte string and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness
; Remarks .......: The size of the resource is stored in @extended. Doesn't work for RT_BITMAP type because _Resource_GetAsRaw() returns HBITMAP instead of memory pointer
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_GetAsBytes($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default)
	Local $pResource = __Resource_Get($sResNameOrID, $iResType, $iResLang, $sDllOrExePath, $RT_RCDATA)
	Local $iError = @error
	Local $iLength = @extended
	Local $dBytes = Binary(Null)
	If $iError = $RESOURCE_ERROR_NONE And $iLength > 0 Then
		Local $tBuffer = DllStructCreate('byte array[' & $iLength & ']', $pResource)
		$dBytes = DllStructGetData($tBuffer, 'array')
	EndIf

	Return SetError($iError, $iLength, $dBytes)
EndFunc   ;==>_Resource_GetAsBytes

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_GetAsIcon
; Description ...: Get a resource as an icon handle
; Syntax ........: _Resource_GetAsIcon($sResNameOrID[, $iResType = $RT_RCDATA[, $sDllOrExePath = Default]])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - Icon handle
;                  Failure - Zero and sets @error to non-zero
; Author ........: guinness
; Modified ......:
; Remarks .......: The size of the resource is stored in @extended
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_GetAsIcon($sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default)
	Local $hIcon = __Resource_Get($sResNameOrID, $iResType, $RESOURCE_LANG_DEFAULT, $sDllOrExePath, $RT_ICON)
	Local $iError = @error
	Local $iLength = @extended
	If $iError <> $RESOURCE_ERROR_NONE Then $hIcon = 0

	Return SetError($iError, $iLength, $hIcon)
EndFunc   ;==>_Resource_GetAsIcon

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_GetAsImage
; Description ...: Get a resource as a hBitmap handle
; Syntax ........: _Resource_GetAsImage($sResNameOrID[, $iResType = $RT_RCDATA[, $sDllOrExePath = Default]])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - hBitmap handle
;                  Failure - Zero and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness. Thanks to ProgAndy and UEZ
; Remarks .......: The size of the resource is stored in @extended
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_GetAsImage($sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default)
	If $iResType = Default Then $iResType = $RT_RCDATA

	Local $iError = $RESOURCE_ERROR_LOADIMAGE, $iLength = 0, _
			$hBitmap = 0
	Switch $iResType
		Case $RT_BITMAP
			Local $hHBITMAP = __Resource_Get($sResNameOrID, $RT_BITMAP, 0, $sDllOrExePath, $RT_BITMAP)
			$iError = @error
			$iLength = @extended
			If $iError = $RESOURCE_ERROR_NONE And $iLength > 0 Then
				$hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBITMAP)
				If @error Then
					$iError = $RESOURCE_ERROR_LOADIMAGE
				Else
					; _GDIPlus_BitmapDispose($hHBITMAP) ; Creates hard crash
					; $hHBITMAP = 0
				EndIf
			EndIf

		Case Else
			Local $pResource = __Resource_Get($sResNameOrID, $iResType, 0, $sDllOrExePath, $RT_RCDATA)
			$iError = @error
			$iLength = @extended
			If $iError = $RESOURCE_ERROR_NONE And $iLength > 0 Then
				$hBitmap = __Resource_ConvertToBitmap($pResource, $iLength)
			EndIf
	EndSwitch

	Return SetError($iError, $iLength, $hBitmap)
EndFunc   ;==>_Resource_GetAsImage

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_GetAsRaw
; Description ...: Get a resource in a raw format
; Syntax ........: _Resource_GetAsRaw($sResNameOrID[, $iResType = $RT_RCDATA[, $iResLang = Default[, $sDllOrExePath = Default]]])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $iResLang            - [optional] A language identifier. Default value is 0
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - Resource pointer
;                  Failure - Null and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness
; Remarks .......: The size of the resource is stored in @extended
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_GetAsRaw($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default)
	Local $hResource = __Resource_Get($sResNameOrID, $iResType, $iResLang, $sDllOrExePath, $RT_RCDATA)
	Return SetError(@error, @extended, $hResource)
EndFunc   ;==>_Resource_GetAsRaw

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_GetAsString
; Description ...: Get a resource as a string
; Syntax ........: _Resource_GetAsString($sResNameOrID[, $iResType = $RT_RCDATA[, $iResLang = Default[, $sDllOrExePath = Default]]])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $iResLang            - [optional] A language identifier. Default value is 0
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - String
;                  Failure - Empty string and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness. Thanks to Jos
; Remarks .......: The size of the resource is stored in @extended
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_GetAsString($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default)
	Local $iError = $RESOURCE_ERROR_LOADSTRING, _
			$iLength = 0, _
			$sString = ''

	Switch $iResType
		Case $RT_RCDATA
			Local $dBytes = _Resource_GetAsBytes($sResNameOrID, $iResType, $iResLang, $sDllOrExePath)
			$iError = @error
			$iLength = @extended

			If $iError = $RESOURCE_ERROR_NONE And $iLength > 0 Then ; Parse the data by retrieving the correct encoding
				Local Enum _
						$BINARYTOSTRING_NONE, _
						$BINARYTOSTRING_ANSI, _
						$BINARYTOSTRING_UTF16LE, _
						$BINARYTOSTRING_UTF16BE, _
						$BINARYTOSTRING_UTF8
				Local $iStart = $BINARYTOSTRING_NONE, $iUTFEncoding = $BINARYTOSTRING_ANSI
				Local Const $sUTF8 = '0xEFBBBF', _
						$sUTF16BE = '0xFEFF', _
						$sUTF16LE = '0xFFFE', _
						$sUTF32BE = '0x0000FEFF', _
						$sUTF32LE = '0xFFFE0000'
				Local $iUTF8 = BinaryLen($sUTF8), _
						$iUTF16BE = BinaryLen($sUTF16BE), _
						$iUTF16LE = BinaryLen($sUTF16LE), _
						$iUTF32BE = BinaryLen($sUTF32BE), _
						$iUTF32LE = BinaryLen($sUTF32LE)
				Select
					Case BinaryMid($dBytes, 1, $iUTF32BE) = $sUTF32BE
						$iStart = $iUTF32BE
						$iUTFEncoding = $BINARYTOSTRING_ANSI
					Case BinaryMid($dBytes, 1, $iUTF32LE) = $sUTF32LE
						$iStart = $iUTF32LE
						$iUTFEncoding = $BINARYTOSTRING_ANSI
					Case BinaryMid($dBytes, 1, $iUTF16BE) = $sUTF16BE
						$iStart = $iUTF16BE
						$iUTFEncoding = $BINARYTOSTRING_UTF16BE
					Case BinaryMid($dBytes, 1, $iUTF16LE) = $sUTF16LE
						$iStart = $iUTF16LE
						$iUTFEncoding = $BINARYTOSTRING_UTF16LE
					Case BinaryMid($dBytes, 1, $iUTF8) = $sUTF8
						$iStart = $iUTF8
						$iUTFEncoding = $BINARYTOSTRING_UTF8
				EndSelect
				$iStart += 1 ; Increase by 1 to strip the byte order mark
				$iLength = $iLength + 1 - $iStart
				$sString = BinaryToString(BinaryMid($dBytes, $iStart), $iUTFEncoding)
			EndIf
			$dBytes = 0

		Case $RT_STRING
			$sString = __Resource_Get($sResNameOrID, $iResType, $iResLang, $sDllOrExePath, $iResType)
			$iError = @error
			$iLength = @extended

	EndSwitch

	Return SetError($iError, $iLength, $sString)
EndFunc   ;==>_Resource_GetAsString

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_LoadFont
; Description ...: Load a font resource into the memory of the specified module
; Syntax ........: _Resource_LoadFont($sResNameOrID[, $iResLang = Default[, $sDllOrExePath = Default]])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iResLang            - [optional] A language identifier. Default value is 0
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - Resource pointer
;                  Failure - Null and sets @error to non-zero
; Author ........: guinness
; Modified ......:
; Remarks .......: The size of the resource is stored in @extended
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_LoadFont($sResNameOrID, $iResLang = Default, $sDllOrExePath = Default)
	Local $pResource = __Resource_Get($sResNameOrID, $RT_FONT, $iResLang, $sDllOrExePath, $RT_FONT)
	Local $iError = @error
	Local $iLength = @extended

	If $iError = $RESOURCE_ERROR_NONE Then
		Local $hFont = _WinAPI_AddFontMemResourceEx($pResource, $iLength) ; Load the font to memory and add to the internal storage array
		__Resource_Storage($RESOURCE_STORAGE_ADD, $sDllOrExePath, $hFont, $sResNameOrID, $RESOURCE_RT_FONT, $iResLang, $RESOURCE_RT_FONT, $iLength)
		$hFont = 0
	EndIf

	Return SetError($iError, $iLength, $pResource)
EndFunc   ;==>_Resource_LoadFont

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_LoadSound
; Description ...: Load (play) a sound resource. This is limited to mp3 and wav only
; Syntax ........: _Resource_LoadSound($sResNameOrID[, $iFlags = $SND_SYNC[, $sDllOrExePath = Default]])
; Parameters ....: $sResNameOrID        - A resource name or id value
;                  $iFlags              - [optional] See $iFlags for the $SND_* constants in _WinAPI_PlaySound(). Default value is $SND_SYNC
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - True
;                  Failure - False and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness. Thanks to Larry, ProgAndy, UEZ, Melba23
; Remarks .......: Use the resource type RT_RCDATA for mp3 files and SOUND for wav files
; Related .......:
; Link ..........: http://msdn2.microsoft.com/en-us/library/ms712879.aspx
; ===============================================================================================================================
Func _Resource_LoadSound($sResNameOrID, $iFlags = $SND_SYNC, $sDllOrExePath = Default) ; Returns no @error, just True or False
	Local $bIsInternal = False, $bReturn = False
	Local $hInstance = __Resource_LoadModule($sDllOrExePath, $bIsInternal)
	If Not $hInstance Then Return SetError($RESOURCE_ERROR_LOADLIBRARY, 0, $bReturn) ; Return an error as an issue occurred and there is no point in continuing

	Local $dSound = _Resource_GetAsBytes($sResNameOrID) ; Assume mp3 so look in RT_RCDATA
	Local $iLength = @extended
	If Not $iLength Then
		; Assume a wav file
		$bReturn = _WinAPI_PlaySound($sResNameOrID, BitOR($SND_RESOURCE, $iFlags), $hInstance)
	Else
		; Convert mp3 to a hybrid wav
		Local $sAlign_Buffer = '00', _
				$sHeader_1 = '0x52494646', _
				$sHeader_2 = '57415645666D74201E0000005500020044AC0000581B0000010000000C00010002000000B600010071056661637404000000640E060064617461'
		Local $sMp3 = StringTrimLeft(Binary($dSound), StringLen('00'))

		Local Const $iByte = 8

		; Convert to required format
		Local $iMp3Size = StringRegExpReplace(Hex($iLength, $iByte), '(..)(..)(..)(..)', '$4$3$2$1')
		Local $iWavSize = StringRegExpReplace(Hex($iLength + 63, $iByte), '(..)(..)(..)(..)', '$4$3$2$1')

		; Construct hybrid wav file
		Local $sHybridWav = $sHeader_1 & $iWavSize & $sHeader_2 & $iMp3Size & $sMp3
		If Mod($iMp3Size, 2) Then
			$sHybridWav &= $sAlign_Buffer
		EndIf

		; Create struct
		Local $tWAV = DllStructCreate('byte array[' & BinaryLen($sHybridWav) & ']')
		DllStructSetData($tWAV, 'array', $sHybridWav)

		$iFlags = BitOR($SND_MEMORY, $SND_NODEFAULT, $iFlags) ; Set the appropriate flags
		$bReturn = _WinAPI_PlaySound(DllStructGetPtr($tWAV), $iFlags, $hInstance)
	EndIf

	__Resource_UnloadModule($hInstance, $bIsInternal)

	Return $bReturn
EndFunc   ;==>_Resource_LoadSound

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_SaveToFile
; Description ...: Save a resource to a file
; Syntax ........: _Resource_SaveToFile($sFilePath, $sResNameOrID[, $iResType = $RT_RCDATA[, $iResLang = Default[, $bCreatePath = Default[,
;                  $sDllOrExePath = Default]]]])
; Parameters ....: $sFilePath           - The filepath to save the resource to
;                  $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $iResLang            - [optional] A language identifier. Default value is 0
;                  $bCreatePath         - [optional] Create the path if it doesn't exist. Default value is False
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
; Return values .: Success - True
;                  Failure - False and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness
; Remarks .......: The size of the resource is stored in @extended
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_SaveToFile($sFilePath, $sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $bCreatePath = Default, $sDllOrExePath = Default)
	Local $bReturn = False, _
			$iCreatePath = (IsBool($bCreatePath) And $bCreatePath ? $FO_CREATEPATH : 0), $iError = $RESOURCE_ERROR_NONE, $iLength = 0
	If $iResType = Default Then $iResType = $RT_RCDATA
	If $iResType = $RT_BITMAP Then
		; Workaround: for RT_BITMAP _Resource_GetAsBytes() doesn't work so use _Resource_GetAsImage() instead
		Local $hImage = _Resource_GetAsImage($sResNameOrID, $iResType)
		$iError = @error
		$iLength = @extended

		If $iError = $RESOURCE_ERROR_NONE And $iLength > 0 Then
			FileClose(FileOpen($sFilePath, BitOR($FO_OVERWRITE, $FO_BINARY, $iCreatePath))) ; Create the filepath
			$bReturn = _GDIPlus_ImageSaveToFile($hImage, $sFilePath)
			_GDIPlus_ImageDispose($hImage)
		EndIf
	Else
		Local $dBytes = _Resource_GetAsBytes($sResNameOrID, $iResType, $iResLang, $sDllOrExePath)
		$iError = @error
		$iLength = @extended

		If $iError = $RESOURCE_ERROR_NONE And $iLength > 0 Then
			Local $hFileOpen = FileOpen($sFilePath, BitOR($FO_OVERWRITE, $FO_BINARY, $iCreatePath))
			If $hFileOpen > -1 Then
				$bReturn = True
				FileWrite($hFileOpen, $dBytes)
				FileClose($hFileOpen)
			EndIf
		EndIf
	EndIf

	Return SetError($iError, $iLength, $bReturn)
EndFunc   ;==>_Resource_SaveToFile

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_SetBitmapToCtrlID
; Description ...: Set a HBITMAP handle to controlid
; Syntax ........: _Resource_SetBitmapToCtrlID($iCtrlID, $hHBITMAP)
; Parameters ....: $iCtrlID             - A valid controlid
;                  $hHBITMAP            - A HBITMAP handle
;                  $bResize             - [optional] Resize the image based on the controlid's dimensions. Default is False
; Return values .: Success - True
;                  Failure - False and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness
; Remarks .......:
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_SetBitmapToCtrlID($iCtrlID, $hHBITMAP, $bResize = Default)
	Local $bReturn = __Resource_SetToCtrlID($iCtrlID, $hHBITMAP, $RT_BITMAP, False, $bResize)
	Return SetError(@error, @extended, $bReturn)
EndFunc   ;==>_Resource_SetBitmapToCtrlID

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_SetCursorToCtrlID
; Description ...: Set a cursor handle to controlid
; Syntax ........: _Resource_SetCursorToCtrlID($iCtrlID, $hCursor)
; Parameters ....: $iCtrlID             - A valid controlid
;                  $hCursor             - A cursor handle
;                  $bResize             - [optional] Resize the image based on the controlid's dimensions. Default is False
; Return values .: Success - True
;                  Failure - False and sets @error to non-zero
; Author ........: guinness
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_SetCursorToCtrlID($iCtrlID, $hCursor, $bResize = Default)
	Local $bReturn = __Resource_SetToCtrlID($iCtrlID, $hCursor, $RT_CURSOR, False, $bResize)
	Return SetError(@error, @extended, $bReturn)
EndFunc   ;==>_Resource_SetCursorToCtrlID

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_SetIconToCtrlID
; Description ...: Set a icon handle to controlid
; Syntax ........: _Resource_SetIconToCtrlID($iCtrlID, $hIcon)
; Parameters ....: $iCtrlID           - A valid controlid
;                  $hIcon             - An icon handle
;                  $bResize           - [optional] Resize the image based on the controlid's dimensions. Default is False
; Return values .: Success - True
;                  Failure - False and sets @error to non-zero
; Author ........: guinness
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_SetIconToCtrlID($iCtrlID, $hIcon, $bResize = Default)
	Local $bReturn = __Resource_SetToCtrlID($iCtrlID, $hIcon, $RT_ICON, False, $bResize)
	Return SetError(@error, @extended, $bReturn)
EndFunc   ;==>_Resource_SetIconToCtrlID

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_SetImageToCtrlID
; Description ...: Set a hBitmap handle to controlid
; Syntax ........: _Resource_SetImageToCtrlID($iCtrlID, $hBitmap)
; Parameters ....: $iCtrlID             - A valid controlid
;                  $hBitmap             - A hBitmap handle
;                  $bResize             - [optional] Resize the image based on the controlid's dimensions. Default is False
; Return values .: Success - True
;                  Failure - False and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness
; Remarks .......:
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_SetImageToCtrlID($iCtrlID, $hBitmap, $bResize = Default)
	Local $hHBITMAP = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap) ; Convert to HBITMAP
	If @error Then
		$hHBITMAP = 0
	Else
		_GDIPlus_BitmapDispose($hBitmap)
	EndIf
	$hBitmap = 0
	Local $bReturn = __Resource_SetToCtrlID($iCtrlID, $hHBITMAP, $RT_BITMAP, False, $bResize)

	Return SetError(@error, @extended, $bReturn)
EndFunc   ;==>_Resource_SetImageToCtrlID

; #FUNCTION# ====================================================================================================================
; Name ..........: _Resource_SetToCtrlID
; Description ...: Set am image from resources to controlid
; Syntax ........: _Resource_SetToCtrlID($iCtrlID, $sResNameOrID[, $iResType = $RT_RCDATA[, $sDllOrExePath = Default]])
; Parameters ....: $iCtrlID             - A valid controlid
;                  $sResNameOrID        - A resource name or id value
;                  $iResType            - [optional] Resource type. $RT_* constants located in APIResConstants.au3 Default value is $RT_RCDATA
;                  $sDllOrExePath       - [optional] A filepath to an external Dll or executable. Default value is the current module
;                  $bResize             - [optional] Resize the image based on the controlid's dimensions. Default is False
; Return values .: Success - True (if an image and on XP then it returns a HBITMAP handle which can then be destroyed by _WinAPI_DeleteObject() when no longer required.)
;                  Failure - False and sets @error to non-zero
; Author ........: Zedna
; Modified ......: guinness. Thanks to ProgAndy and UEZ
; Remarks .......: The size of the resource is stored in @extended
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Resource_SetToCtrlID($iCtrlID, $sResNameOrID, $iResType = $RT_RCDATA, $sDllOrExePath = Default, $bResize = Default)
	If $iResType = Default Then $iResType = $RT_RCDATA

	Local $aWinGetPos = 0, _
			$bDestroy = True, $bReturn = False, _
			$iError = $RESOURCE_ERROR_INVALIDRESOURCETYPE, $iLength = 0, _
			$vReturn = False

	Local $hWnd = 0
	__Resource_GetCtrlId($hWnd, $iCtrlID)
	Switch $iResType
		Case $RT_BITMAP, $RT_RCDATA
			If StringStripWS($sResNameOrID, $STR_STRIPALL) = '' Or String($sResNameOrID) = '0' Then
				$bReturn = __Resource_SetToCtrlID($iCtrlID, 0, $RT_BITMAP, True, False)
				$iError = @error
			Else
				Local $hHBITMAP = _Resource_GetAsBitmap($sResNameOrID, $iResType, $sDllOrExePath) ; hBitmap
				$iError = @error
				$iLength = @extended

				If $iError = $RESOURCE_ERROR_NONE And $iLength > 0 Then
					; $bDestroy = False
					$bReturn = __Resource_SetToCtrlID($iCtrlID, $hHBITMAP, $RT_BITMAP, $bDestroy, $bResize)
					$iError = @error

					If $bReturn Then
						If _WinAPI_GetVersion() >= 0x0600 Then
							$bReturn = _WinAPI_DeleteObject($hHBITMAP) > 0 ; Delete if Vista or above
							$vReturn = $bReturn
						Else
							__Resource_Storage($RESOURCE_STORAGE_ADD, $sDllOrExePath, $hHBITMAP, $sResNameOrID, $iResType, Null, $iResType, $iLength)
							$vReturn = $hHBITMAP
						EndIf
					EndIf
				EndIf
			EndIf

		Case $RT_CURSOR
			If StringStripWS($sResNameOrID, $STR_STRIPALL) = '' Or String($sResNameOrID) = '0' Then
				$bReturn = __Resource_SetToCtrlID($iCtrlID, 0, $RT_CURSOR, True, False)
				$iError = @error
			Else
				$bDestroy = False
				Local $hCursor = 0
				If $bResize Then
					$aWinGetPos = WinGetPos($hWnd)
					If Not @error Then
						Local $aPos[$RESOURCE_POS_MAX]
						$aPos[$RESOURCE_POS_H] = $aWinGetPos[$RESOURCE_WINGETPOS_HEIGHT]
						$aPos[$RESOURCE_POS_W] = $aWinGetPos[$RESOURCE_WINGETPOS_WIDTH]

						If $aPos[$RESOURCE_POS_H] = 0 And $aPos[$RESOURCE_POS_W] = 0 Then
							GUICtrlSetImage($iCtrlID, @AutoItExe, 0)
							$aWinGetPos = WinGetPos($hWnd)
							If Not @error Then
								$aPos[$RESOURCE_POS_H] = $aWinGetPos[$RESOURCE_WINGETPOS_HEIGHT]
								$aPos[$RESOURCE_POS_W] = $aWinGetPos[$RESOURCE_WINGETPOS_WIDTH]
							EndIf
						EndIf

						$hCursor = __Resource_Get($sResNameOrID, $RT_CURSOR, $RESOURCE_LANG_DEFAULT, $sDllOrExePath, $RT_CURSOR, $aPos)
						$iError = @error
						$iLength = @extended
					EndIf
				Else
					$hCursor = _Resource_GetAsCursor($sResNameOrID, $iResType, $sDllOrExePath)
					$iError = @error
					$iLength = @extended
				EndIf

				If $iError = $RESOURCE_ERROR_NONE Then
					$bReturn = __Resource_SetToCtrlID($iCtrlID, $hCursor, $RT_CURSOR, $bDestroy, $bResize)
				EndIf
				$hCursor = 0
				$vReturn = $bReturn
			EndIf

		Case $RT_ICON
			If StringStripWS($sResNameOrID, $STR_STRIPALL) = '' Or String($sResNameOrID) = '0' Then
				$bReturn = __Resource_SetToCtrlID($iCtrlID, 0, $RT_ICON, True, False)
				$iError = @error
			Else
				$bDestroy = False
				Local $hIcon = 0
				If $bResize Then
					__Resource_GetCtrlId($hWnd, $iCtrlID)
					$aWinGetPos = WinGetPos($hWnd)
					If Not @error Then
						Local $aPos[$RESOURCE_POS_MAX]
						$aPos[$RESOURCE_POS_H] = $aWinGetPos[$RESOURCE_WINGETPOS_HEIGHT]
						$aPos[$RESOURCE_POS_W] = $aWinGetPos[$RESOURCE_WINGETPOS_WIDTH]

						If $aPos[$RESOURCE_POS_H] = 0 And $aPos[$RESOURCE_POS_W] = 0 Then
							GUICtrlSetImage($iCtrlID, @AutoItExe, 0)
							$aWinGetPos = WinGetPos($hWnd)
							If Not @error Then
								$aPos[$RESOURCE_POS_H] = $aWinGetPos[$RESOURCE_WINGETPOS_HEIGHT]
								$aPos[$RESOURCE_POS_W] = $aWinGetPos[$RESOURCE_WINGETPOS_WIDTH]
							EndIf
						EndIf

						$hIcon = __Resource_Get($sResNameOrID, $RT_ICON, $RESOURCE_LANG_DEFAULT, $sDllOrExePath, $RT_ICON, $aPos)
						$iError = @error
						$iLength = @extended
						#cs
							If $iError = $RESOURCE_ERROR_NONE Then
							Local $pData = __Resource_Get($sResNameOrID, $RT_ICON, $RESOURCE_LANG_DEFAULT, $sDllOrExePath, $RT_ICON)
							Local $iIconName = _WinAPI_LookupIconIdFromDirectoryEx($pData, True, $aWinGetPos[2], $aWinGetPos[3])
							$pData = __Resource_Get($iIconName, $RT_ICON, $RESOURCE_LANG_DEFAULT, $sDllOrExePath, $RT_RCDATA)
							$iError = @error
							$iLength = @extended
							If $iError = $RESOURCE_ERROR_NONE Then
							$hIcon = _WinAPI_CreateIconFromResourceEx($pData, $iLength)
							EndIf
							EndIf
						#ce
					EndIf
				Else
					$hIcon = _Resource_GetAsIcon($sResNameOrID, $iResType, $sDllOrExePath)
					$iError = @error
					$iLength = @extended
				EndIf

				If $iError = $RESOURCE_ERROR_NONE Then
					$bReturn = __Resource_SetToCtrlID($iCtrlID, $hIcon, $RT_ICON, $bDestroy, $bResize)
				EndIf
				$hIcon = 0
				$vReturn = $bReturn
			EndIf

	EndSwitch

	Return SetError($iError, $iLength, $vReturn)
EndFunc   ;==>_Resource_SetToCtrlID

; INTERNAL FUNCTIONS
Func __Resource_ConvertToBitmap($pResource, $iLength) ; hBitmap
	; Local $tByte = DllStructCreate('byte[' & $iLength & ']')
	; _MemMoveMemory($pResource, DllStructGetPtr($tByte), $iLength)

	Local $hData = _MemGlobalAlloc($iLength, $GMEM_MOVEABLE)
	Local $pData = _MemGlobalLock($hData)

	_MemMoveMemory($pResource, $pData, $iLength)
	; _MemMoveMemory(DllStructGetPtr($tByte), $pData, $iLength)

	_MemGlobalUnlock($hData)
	Local $pStream = _WinAPI_CreateStreamOnHGlobal($hData)
	Local $hBitmap = _GDIPlus_BitmapCreateFromStream($pStream) ; hBitmap

	; _MemGlobalFree($hData) ; Uncomment and gifs don't work

	_WinAPI_ReleaseStream($pStream)
	Return $hBitmap ; To destroy use _GDIPlus_BitmapDispose()
EndFunc   ;==>__Resource_ConvertToBitmap

Func __Resource_Destroy($pResource, $iResType)
	Local $bReturn = False
	Switch $iResType
		Case $RT_ANICURSOR, $RT_CURSOR
			$bReturn = _WinAPI_DeleteObject($pResource) > 0
			If Not $bReturn Then
				$bReturn = _WinAPI_DestroyCursor($pResource) > 0
			EndIf
		Case $RT_BITMAP
			$bReturn = _WinAPI_DeleteObject($pResource) > 0
		Case $RT_FONT
			$bReturn = True ; No action required
		Case $RT_ICON
			$bReturn = _WinAPI_DeleteObject($pResource) > 0
			If Not $bReturn Then
				$bReturn = _WinAPI_DestroyIcon($pResource) > 0
			EndIf
		Case $RT_MENU
			$bReturn = _GUICtrlMenu_DestroyMenu($pResource) > 0
		Case $RT_STRING
			$bReturn = True ; No action required
		Case $RESOURCE_RT_BITMAP
			$bReturn = _GDIPlus_BitmapDispose($pResource) > 0
		Case $RESOURCE_RT_ENHMETAFILE
			$bReturn = _WinAPI_DeleteEnhMetaFile($pResource) > 0
		Case $RESOURCE_RT_FONT
			$bReturn = _WinAPI_RemoveFontMemResourceEx($pResource) > 0
		Case Else
			$bReturn = True ; No action required
	EndSwitch
	If Not IsBool($bReturn) Then $bReturn = $bReturn > 0

	Return $bReturn
EndFunc   ;==>__Resource_Destroy

Func __Resource_Get($sResNameOrID, $iResType = $RT_RCDATA, $iResLang = Default, $sDllOrExePath = Default, $iCastResType = Default, $aPos = Null)
	If $iResType = $RT_RCDATA And StringStripWS($sResNameOrID, $STR_STRIPALL) = '' Then Return SetError($RESOURCE_ERROR_INVALIDRESOURCENAME, 0, Null) ; If the resource name or id value is empty

	If $iCastResType = Default Then $iCastResType = $iResType
	If $iResLang = Default Then $iResLang = $RESOURCE_LANG_DEFAULT
	If $iResType = Default Then $iResType = $RT_RCDATA

	Local $iError = $RESOURCE_ERROR_NONE, $iLength = 0, _
			$vResource = __Resource_Storage($RESOURCE_STORAGE_GET, $sDllOrExePath, Null, $sResNameOrID, $iResType, $iResLang, $iCastResType, Null)
	$iLength = @extended
	If $vResource Then
		Return SetError($iError, $iLength, $vResource)
	EndIf

	Local $bIsInternal = False
	Local $hInstance = __Resource_LoadModule($sDllOrExePath, $bIsInternal)
	If Not $hInstance Then Return SetError($RESOURCE_ERROR_LOADLIBRARY, 0, 0) ; Return an error as an issue occurred and there is no point in continuing

	Local $hResource = (($iResLang <> $RESOURCE_LANG_DEFAULT) ? _WinAPI_FindResourceEx($hInstance, $iResType, $sResNameOrID, $iResLang) : _WinAPI_FindResource($hInstance, $iResType, $sResNameOrID))
	If @error <> $RESOURCE_ERROR_NONE Then $iError = $RESOURCE_ERROR_FINDRESOURCE

	If $iError = $RESOURCE_ERROR_NONE Then
		If $aPos = Null Then
			Local $aTemp[$RESOURCE_POS_MAX] = [0, 0]
			$aPos = $aTemp
			$aTemp = 0
			$aPos[$RESOURCE_POS_H] = 0
			$aPos[$RESOURCE_POS_W] = 0
		EndIf
		$iLength = _WinAPI_SizeOfResource($hInstance, $hResource)
		Switch $iCastResType
			Case $RT_ANICURSOR, $RT_CURSOR
				$vResource = _WinAPI_LoadImage($hInstance, $sResNameOrID, $IMAGE_CURSOR, $aPos[$RESOURCE_POS_W], $aPos[$RESOURCE_POS_H], $LR_DEFAULTCOLOR)
				If @error <> $RESOURCE_ERROR_NONE Or Not $vResource Then $iError = $RESOURCE_ERROR_LOADCURSOR
			Case $RT_BITMAP
				$vResource = _WinAPI_LoadImage($hInstance, $sResNameOrID, $IMAGE_BITMAP, $aPos[$RESOURCE_POS_W], $aPos[$RESOURCE_POS_H], $LR_DEFAULTCOLOR)
				If @error <> $RESOURCE_ERROR_NONE Or Not $vResource Then $iError = $RESOURCE_ERROR_LOADBITMAP
			Case $RT_ICON
				$vResource = _WinAPI_LoadImage($hInstance, $sResNameOrID, $IMAGE_ICON, $aPos[$RESOURCE_POS_W], $aPos[$RESOURCE_POS_H], $LR_DEFAULTCOLOR)
				If @error <> $RESOURCE_ERROR_NONE Or Not $vResource Then $iError = $RESOURCE_ERROR_LOADICON
			Case $RT_STRING
				$vResource = _WinAPI_LoadString($hInstance, $sResNameOrID)
				$iLength = @extended
				If @error <> $RESOURCE_ERROR_NONE Then $iError = $RESOURCE_ERROR_LOADSTRING
			Case Else ; $RT_RCDATA
				Local $hData = _WinAPI_LoadResource($hInstance, $hResource)
				$vResource = _WinAPI_LockResource($hData)
				$hData = 0
				If Not $vResource Then $iError = $RESOURCE_ERROR_LOCKRESOURCE
		EndSwitch
		If $iError = $RESOURCE_ERROR_NONE Then
			__Resource_Storage($RESOURCE_STORAGE_ADD, $sDllOrExePath, $vResource, $sResNameOrID, $iResType, $iResLang, $iCastResType, $iLength)
		Else
			$vResource = Null
		EndIf
	EndIf
	__Resource_UnloadModule($hInstance, $bIsInternal)

	Return SetError($iError, $iLength, $vResource)
EndFunc   ;==>__Resource_Get

Func __Resource_GetCtrlId(ByRef $hWnd, ByRef $iCtrlID)
	If $iCtrlID = Default Or $iCtrlID <= 0 Or Not IsInt($iCtrlID) Then $iCtrlID = -1 ; Set to -1 if $iCtrlID is Default, less than zero or not an integer
	$hWnd = GUICtrlGetHandle($iCtrlID) ; Get the handle of the controlid
	If $hWnd And $iCtrlID = -1 Then ; Get the controlid if $iCtrlID is -1
		$iCtrlID = _WinAPI_GetDlgCtrlID($hWnd) ; Support for $iCtrlID = Default or $iCtrlID = -1
	EndIf

	Return True
EndFunc   ;==>__Resource_GetCtrlId

Func __Resource_GetLastImage($iCtrlID, $hResource, $sClassName, ByRef $hPrevious, ByRef $iPreviousResType)
	; Set the out variables to null/zero
	$hPrevious = 0
	$iPreviousResType = 0

	Local $aGetImage = 0, _
			$bReturn = True, _
			$iMsg_Get = 0

	Switch $sClassName
		Case 'Button' ; button, checkbox, groupbox, radiobutton
			Local $aButton = _
					[[$IMAGE_BITMAP, $RT_BITMAP], _
					[$IMAGE_ICON, $RT_ICON]]
			$aGetImage = $aButton
			$aButton = 0
			$iMsg_Get = $BM_GETIMAGE

		Case 'Static' ; icon, label, picture
			Local $aStatic = _
					[[$IMAGE_BITMAP, $RT_BITMAP], _
					[$IMAGE_CURSOR, $RT_CURSOR], _
					[$IMAGE_ENHMETAFILE, $RESOURCE_RT_ENHMETAFILE], _
					[$IMAGE_ICON, $RT_ICON]]
			$aGetImage = $aStatic
			$aStatic = 0
			$iMsg_Get = $RESOURCE_STM_GETIMAGE

		Case Else
			$bReturn = False

	EndSwitch

	If $bReturn Then
		Local Enum $eWPARAM, $eRESTYPE
		For $i = 0 To UBound($aGetImage) - 1
			$hPrevious = GUICtrlSendMsg($iCtrlID, $iMsg_Get, $aGetImage[$i][$eWPARAM], 0)
			If $hPrevious <> 0 And $hPrevious <> $hResource Then
				$iPreviousResType = $aGetImage[$i][$eRESTYPE]
				ExitLoop
			EndIf
		Next
	EndIf

	Return $bReturn
EndFunc   ;==>__Resource_GetLastImage

Func __Resource_LoadModule(ByRef $sDllOrExePath, ByRef $bIsInternal)
	$bIsInternal = ($sDllOrExePath = Default Or $sDllOrExePath = -1)
	If Not $bIsInternal And Not StringRegExp($sDllOrExePath, '\.(?:cpl|dll|exe)$') Then
		$bIsInternal = True
	EndIf

	Return ($bIsInternal ? _WinAPI_GetModuleHandle(Null) : _WinAPI_LoadLibraryEx($sDllOrExePath, $LOAD_LIBRARY_AS_DATAFILE))
EndFunc   ;==>__Resource_LoadModule

Func __Resource_UnloadModule(ByRef $hInstance, ByRef $bIsInternal)
	Local $bReturn = True
	If $bIsInternal And $hInstance Then
		$bReturn = _WinAPI_FreeLibrary($hInstance)
	EndIf
	Return $bReturn
EndFunc   ;==>__Resource_UnloadModule

Func __Resource_SetToCtrlID($iCtrlID, $hResource, $iResType, $bDestroy, $bResize)
	Local $bReturn = False, _
			$iError = $RESOURCE_ERROR_SETIMAGE

	; If $hResource Then
	Local $hWnd = 0
	__Resource_GetCtrlId($hWnd, $iCtrlID)
	$iError = $RESOURCE_ERROR_INVALIDCONTROLID ; No controlid or handle
	If $hWnd And $iCtrlID > 0 Then
		Local $aStyles[0]
		$bReturn = True
		$iError = $RESOURCE_ERROR_NONE

		; Local $iMsg_Get = 0, $iMsg_Set = 0, $iStyle = 0, $wParam = 0
		Local $iMsg_Set = 0, $iStyle = 0, $wParam = 0
		; Determine the control class and adjust the values accordingly
		Local $sClassName = _WinAPI_GetClassName($iCtrlID)
		Switch $sClassName
			Case 'Button' ; button, checkbox, groupbox, radiobutton
				Local $aButtonStyles = [$BS_BITMAP, $BS_ICON]
				$aStyles = $aButtonStyles
				$aButtonStyles = 0

				; $iMsg_Get = $BM_GETIMAGE
				$iMsg_Set = $BM_SETIMAGE

				Switch $iResType
					Case $RT_BITMAP
						$iStyle = $BS_BITMAP
						$wParam = $IMAGE_BITMAP
						$bResize = False ; This can't be set

					Case $RT_ICON
						$iStyle = $BS_ICON
						$wParam = $IMAGE_ICON
						$bResize = False ; This can't be set

					Case Else
						$bReturn = False
						$iError = $RESOURCE_ERROR_INVALIDRESOURCETYPE

				EndSwitch

			Case 'Static' ; icon, label, picture
				Local $aStaticStyles = [$SS_BITMAP, $SS_ICON, $RESOURCE_SS_ENHMETAFILE]
				$aStyles = $aStaticStyles
				$aStaticStyles = 0

				; $iMsg_Get = $RESOURCE_STM_GETIMAGE
				$iMsg_Set = $RESOURCE_STM_SETIMAGE

				Switch $iResType
					Case $RT_BITMAP
						$iStyle = $SS_BITMAP
						$wParam = $IMAGE_BITMAP

					Case $RT_CURSOR
						$iStyle = $SS_ICON
						$wParam = $IMAGE_CURSOR

					Case $RESOURCE_RT_ENHMETAFILE
						$iStyle = $RESOURCE_SS_ENHMETAFILE
						$wParam = $IMAGE_ENHMETAFILE

					Case $RT_ICON
						$iStyle = $SS_ICON
						$wParam = $IMAGE_ICON

					Case Else
						$bReturn = False
						$iError = $RESOURCE_ERROR_INVALIDRESOURCETYPE

				EndSwitch

			Case Else
				$bReturn = False
				$iError = $RESOURCE_ERROR_INVALIDCLASS

		EndSwitch

		If $bReturn Then
			; Local Enum $eSTYLE, $eEXSTYLE
			; #forceref $eEXSTYLE
			; Local $aCurrentStyle =  GUIGetStyle($hWnd)
			Local $iCurrentStyle = _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
			If Not @error Then
				For $i = 0 To UBound($aStyles) - 1
					If BitAND($aStyles[$i], $iCurrentStyle) Then
						$iCurrentStyle = BitXOR($iCurrentStyle, $aStyles[$i])
					EndIf
					;If BitAND($aStyles[$i], $aCurrentStyle[$eSTYLE]) Then
					; $aCurrentStyle[$eSTYLE] = BitXOR($aCurrentStyle[$eSTYLE], $aStyles[$i])
					; EndIf
				Next

				; Set appropriate style to the controlid if not already set by the user
				If $bResize Then ; Set the the SS_REALSIZECONTROL style
					_WinAPI_SetWindowLong($hWnd, $GWL_STYLE, BitOR($iCurrentStyle, $RESOURCE_SS_REALSIZECONTROL, $iStyle))
					; GUICtrlSetStyle($iCtrlID, BitOR($aCurrentStyle[$eSTYLE], $RESOURCE_SS_REALSIZECONTROL, $iStyle), -1)
				Else
					_WinAPI_SetWindowLong($hWnd, $GWL_STYLE, BitOR($iCurrentStyle, $iStyle))
					; GUICtrlSetStyle($iCtrlID, BitOR($aCurrentStyle[$eSTYLE], $iStyle), -1)
				EndIf
			EndIf

			Local $hPrevious = 0, _
					$iPreviousResType = 0
			; Get the previous image handle type for destroying when set
			__Resource_GetLastImage($iCtrlID, $hResource, $sClassName, $hPrevious, $iPreviousResType)
			; If $iResType = $RT_ICON Then
			; GUICtrlSendMsg($iCtrlID, $RESOURCE_STM_SETICON, $hResource, 0)
			; GUICtrlSendMsg($iCtrlID, 100, $RESOURCE_STM_SETIMAGE, $IMAGE_ICON)
			; Else
			; Set the image to the control and delete the previous image handle
			GUICtrlSendMsg($iCtrlID, $iMsg_Set, $wParam, $hResource)
			; EndIf
			If $iPreviousResType Then
				__Resource_Destroy($hPrevious, $iPreviousResType)
				__Resource_Storage($RESOURCE_STORAGE_DESTROY, Null, $hPrevious, Null, Null, Null, Null, Null)
				If $bDestroy = Default Or $bDestroy Then
					__Resource_Destroy($hResource, $iResType)
					__Resource_Storage($RESOURCE_STORAGE_DESTROY, Null, $hResource, Null, Null, Null, Null, Null)
				EndIf
				_WinAPI_InvalidateRect($hWnd, 0, True)
				_WinAPI_UpdateWindow($hWnd) ; Force a WM_PAINT
			Else
				$bReturn = False
				$iError = $RESOURCE_ERROR_SETIMAGE
			EndIf
		EndIf
	EndIf
	; EndIf

	Return SetError($iError, 0, $bReturn)
EndFunc   ;==>__Resource_SetToCtrlID

Func __Resource_Storage($iAction, $sDllOrExePath, $pResource, $sResNameOrID, $iResType, $iResLang, $iCastResType, $iLength)
	Local Static $aStorage[$RESOURCE_STORAGE_FIRSTINDEX][$RESOURCE_STORAGE_MAX] ; Internal storage

	Local $bReturn = False
	Switch $iAction
		Case $RESOURCE_STORAGE_ADD
			If Not ($aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_ID] = $RESOURCE_STORAGE_GUID) Then
				$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_ID] = $RESOURCE_STORAGE_GUID
				$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX] = 0
				$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_RESETCOUNT] = 0
				$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_UBOUND] = $RESOURCE_STORAGE_FIRSTINDEX
			EndIf

			If Not ($pResource = Null) And Not __Resource_Storage($RESOURCE_STORAGE_GET, $sDllOrExePath, Null, $sResNameOrID, $iResType, $iResLang, $iCastResType, Null) Then ; If the resource pointer is not Null
				$bReturn = True
				$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX] += 1
				If $aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX] >= $aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_UBOUND] Then ; Re-size the internal storage if required
					$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_UBOUND] = Ceiling($aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX] * 1.3)
					ReDim $aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_UBOUND]][$RESOURCE_STORAGE_MAX]
				EndIf
				$aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]][$RESOURCE_STORAGE_DLL] = $sDllOrExePath
				$aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]][$RESOURCE_STORAGE_PTR] = $pResource
				$aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]][$RESOURCE_STORAGE_RESLANG] = $iResLang
				$aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]][$RESOURCE_STORAGE_RESNAMEORID] = $sResNameOrID
				$aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]][$RESOURCE_STORAGE_RESTYPE] = $iResType
				$aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]][$RESOURCE_STORAGE_CASTRESTYPE] = $iCastResType
				$aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]][$RESOURCE_STORAGE_LENGTH] = $iLength
			EndIf

		Case $RESOURCE_STORAGE_DESTROY ; http://msdn.microsoft.com/en-us/library/windows/desktop/ms648044(v=vs.85).aspx
			Local $iDestoryCount = 0, $iDestoryed = 0
			; Delete a resource name or id value handle
			For $i = $RESOURCE_STORAGE_FIRSTINDEX To $aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]
				If Not ($aStorage[$i][$RESOURCE_STORAGE_PTR] = Null) Then
					If $aStorage[$i][$RESOURCE_STORAGE_PTR] = $pResource Or ($aStorage[$i][$RESOURCE_STORAGE_DLL] = $sDllOrExePath And _
							$aStorage[$i][$RESOURCE_STORAGE_RESNAMEORID] = $sResNameOrID And _
							$aStorage[$i][$RESOURCE_STORAGE_RESTYPE] = $iResType And _
							$aStorage[$i][$RESOURCE_STORAGE_CASTRESTYPE] = $iCastResType) Then
						$bReturn = __Resource_Storage_Destroy($aStorage, $i)
						If $bReturn Then
							$iDestoryed += 1
							$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_RESETCOUNT] += 1 ; Increase the reset count
						EndIf
						$iDestoryCount += 1
					EndIf
				EndIf
			Next
			$bReturn = $iDestoryCount = $iDestoryed ; If the destroyed count equals the actual destroyed values

			; Delete Null entries and tidy the internal storage if 20 or more items have been destroyed
			If $aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_RESETCOUNT] >= 20 Then
				Local $iIndex = 0
				For $i = $RESOURCE_STORAGE_FIRSTINDEX To $aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]
					If Not ($aStorage[$i][$RESOURCE_STORAGE_PTR] = Null) Then
						$iIndex += 1
						For $j = 0 To $RESOURCE_STORAGE_MAX - 1
							$aStorage[$iIndex][$j] = $aStorage[$i][$j]
						Next
					EndIf
				Next
				$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX] = $iIndex ; Last index added
				$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_RESETCOUNT] = 0 ; Reset the reset count
				$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_UBOUND] = $iIndex + $RESOURCE_STORAGE_FIRSTINDEX ; Last index plus the first index position
				ReDim $aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_UBOUND]][$RESOURCE_STORAGE_MAX]
			EndIf

		Case $RESOURCE_STORAGE_DESTROYALL
			$bReturn = True
			For $i = $RESOURCE_STORAGE_FIRSTINDEX To $aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]
				__Resource_Storage_Destroy($aStorage, $i)
			Next
			$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX] = 0 ; Reset the index count
			$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_RESETCOUNT] = 0 ; Reset the reset count
			$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_UBOUND] = $RESOURCE_STORAGE_FIRSTINDEX ; Reset the length count
			ReDim $aStorage[$aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_UBOUND]][$RESOURCE_STORAGE_MAX]

		Case $RESOURCE_STORAGE_GET ; Removed for now. Needs more work
			Local $iExtended = 0, _
					$pReturn = Null
			#cs
				For $i = $RESOURCE_STORAGE_FIRSTINDEX To $aStorage[$RESOURCE_STORAGE][$RESOURCE_STORAGE_INDEX]
				If $aStorage[$i][$RESOURCE_STORAGE_DLL] = $sDllOrExePath And _
				$aStorage[$i][$RESOURCE_STORAGE_RESNAMEORID] = $sResNameOrID And _
				$aStorage[$i][$RESOURCE_STORAGE_RESTYPE] = $iResType And _
				$aStorage[$i][$RESOURCE_STORAGE_CASTRESTYPE] = $iCastResType Then
				$iExtended = $aStorage[$i][$RESOURCE_STORAGE_LENGTH]
				$pReturn = $aStorage[$i][$RESOURCE_STORAGE_PTR]
				ExitLoop
				EndIf
				Next
			#ce
			Return SetExtended($iExtended, $pReturn)

	EndSwitch

	Return $bReturn
EndFunc   ;==>__Resource_Storage

Func __Resource_Storage_Destroy(ByRef $aStorage, $iIndex)
	Local $bReturn = False
	If Not ($aStorage[$iIndex][$RESOURCE_STORAGE_PTR] = Null) Then
		$bReturn = __Resource_Destroy($aStorage[$iIndex][$RESOURCE_STORAGE_PTR], $aStorage[$iIndex][$RESOURCE_STORAGE_RESTYPE])
		If $bReturn Then
			; Destroy the internal array contents
			$aStorage[$iIndex][$RESOURCE_STORAGE_PTR] = Null
			$aStorage[$iIndex][$RESOURCE_STORAGE_RESLANG] = Null
			$aStorage[$iIndex][$RESOURCE_STORAGE_RESNAMEORID] = Null
			$aStorage[$iIndex][$RESOURCE_STORAGE_RESTYPE] = Null
		EndIf
	EndIf

	Return $bReturn
EndFunc   ;==>__Resource_Storage_Destroy
#EndRegion ResourcesEx.au3 - #FUNCTION#

#cs
	Func IS_INTRESOURCE($pResource)
	Return ($pResource And Not BitAND($pResource, 0xFFFF0000))
	EndFunc   ;==>IS_INTRESOURCE

	Func MAKEINTRESOURCE($iInt) ; http://www.autoitscript.com/forum/topic/69968-need-also-help-with-translating-vb-code/
	; Return '#' & _WinAPI_MakeLong($iInt, 0)
	If Not StringIsDigit($iInt) Then Return SetError(1, 0, '') ; If $iInt has other chars than 0-9
	Return '#' & Int($iInt) ; Return # and delete leading zeros from $iInt
	EndFunc   ;==>MAKEINTRESOURCE#
#ce
