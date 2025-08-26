#include-once

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Func _GetMonInfo($minWidth, $minHeight, $minBPC, $minInches)
; Input : $minWidth  = minimal horizontal monitor resolution in pixels
;         $minHeight = minimal vertical monitor resolution in pixels
;         $minBPC    = minimal Bits Per Color channel
;         $minInches = minimal diagonal monitor physical size in inches

; Output: $aRes[0]   = total number of monitors
;         $aRes[1]   = number of compliant monitors
;         $aRes[2]   = number of lower resolution monitors
;         $aRes[3]   = number of physically smaller monitors
;         $aRes[4]   = number of monitors with less than 8 bits per color
;         $aRes[5]   = number of monitors with at least 1 undetected parameter

Local Enum $iPixWidth = 0, $iPixHeight, $iBits, $iHz, $iDimWcm, $iDimHcm, $iDimWmm, $iDimHmm, $iDiagonal, $iMonID, $iMonNatW, $iMonNatH, $iMonNatB, $iMonNatF, $i2Dim
Local $minBPP = 3 * $minBPC, $aMons[1][$i2Dim] = [[0]], $aRes[6] = [0, 0, 0, 0, 0, 0]

$aMons[0][$iPixWidth]  = "max. res. width"
$aMons[0][$iPixHeight] = "max. res. height"
$aMons[0][$iBits]      = "bits"
$aMons[0][$iHz]        = "Hz"
$aMons[0][$iDimWcm]    = "width [cm]"
$aMons[0][$iDimHcm]    = "height [cm]"
$aMons[0][$iDimWmm]    = "width [mm]"
$aMons[0][$iDimHmm]    = "height [mm]"
$aMons[0][$iDiagonal]  = "diagonal [in]"
$aMons[0][$iMonID]     = "monitor ID"
$aMons[0][$iMonNatW]   = "monitor native width"
$aMons[0][$iMonNatH]   = "monitor native height"
$aMons[0][$iMonNatF]   = "monitor native Hz"
$aMons[0][$iMonNatB]   = "monitor native bits per color"

Local $data1 = DllStructCreate("int; char[32]; char[128]; int; char[128]; char[128]")

;                               1         2      3      4      5      6    7       8    9    10     11     12     13     14     15        16     17      18   19   20   21        
Local $data2 = DllStructCreate("char[32]; short; short; short; short; int; int[2]; int; int; short; short; short; short; short; char[32]; short; ushort; int; int; int; int")
Local $ptrData1 = DllStructGetPtr($data1), $ptrData2 = DllStructGetPtr($data2)
Local $ResNum, $DispNum = 0, $MonNum, $sMonID, $aDisp, $tmp, $hDLL = DllOpen("user32.dll")
Local $width, $height, $bits, $hz, $sDispName, $Obj_WMIService, $Col_Items

    DllStructSetData($data1, 1, DllStructGetSize($data1))
    DllStructSetData($data2, 4, DllStructGetSize($data2))
    Do
        $aDisp = DllCall($hDLL, "int", "EnumDisplayDevices", "ptr", 0, "int", $DispNum, "ptr", $ptrData1, "int", 0)
        If @error Or ($aDisp[0] = 0) Then ExitLoop
        $DispNum += 1
        If Not BitAND(DllStructGetData($data1, 4), 1) Then ContinueLoop ;Not DISPLAY_DEVICE_ACTIVE
        $aMons[0][0] += 1                                               ;monitors count
        $aMons[0][1] += 1                                               ;displays count
        ReDim $aMons[$aMons[0][0] + 1][$i2Dim]
        $sDispName = DllStructGetData($data1, 2)                        ;display ID
        $aMons[$aMons[0][0]][$iPixWidth]  = -1
        $aMons[$aMons[0][0]][$iPixHeight] = -1
        $aMons[$aMons[0][0]][$iBits]      = -1
        $aMons[$aMons[0][0]][$iHz]        = -1
        $ResNum = -1
        Do
            $ResNum += 1
            $tmp = DllCall($hDLL, "int", "EnumDisplaySettingsEx", "str", $sDispName, "int", $ResNum, "ptr", $ptrData2, "int", 0) ;EDS_RAWMODE = 2 , EDS_ROTATEDMODE = 4
            If @error Or ($tmp[0] = 0) Then ExitLoop
            $bits   = DllStructGetData($data2, 17)  ;dmBitsPerPel
            $width  = DllStructGetData($data2, 18)  ;dmPelsWidth
            $height = DllStructGetData($data2, 19)  ;dmPelsHeight
            $hz = DllStructGetData($data2, 21)      ;dmDisplayFrequency
            If $height > $width Then                ;if monitor is in portrait, swap dimensions
                $width  = $height
                $height = DllStructGetData($data2, 18)
            EndIf
            
            If ( ($aMons[$aMons[0][0]][$iPixWidth] < 1) And ($aMons[$aMons[0][0]][$iPixHeight] < 1) ) Or _
               ( ($width > $aMons[$aMons[0][0]][$iPixWidth]) And ( ($aMons[$aMons[0][0]][$iPixHeight] < $minHeight) Or ($height >= $minHeight) ) And ( ($aMons[$aMons[0][0]][$iBits] < $minBPP) Or ($bits >= $minBPP) ) ) Or _
               ( ($width = $aMons[$aMons[0][0]][$iPixWidth]) And ($height > $aMons[$aMons[0][0]][$iPixHeight]) And ( ($aMons[$aMons[0][0]][$iBits] < $minBPP) Or ($bits >= $minBPP) ) ) Or _
               ( ($width = $aMons[$aMons[0][0]][$iPixWidth]) And ($height = $aMons[$aMons[0][0]][$iPixHeight]) And ($bits > $aMons[$aMons[0][0]][$iBits]) ) Or _
               ( ($width = $aMons[$aMons[0][0]][$iPixWidth]) And ($height = $aMons[$aMons[0][0]][$iPixHeight]) And ($bits = $aMons[$aMons[0][0]][$iBits]) And ($hz > $aMons[$aMons[0][0]][$iHz]) ) _
            Then
                $aMons[$aMons[0][0]][$iPixWidth]  = $width
                $aMons[$aMons[0][0]][$iPixHeight] = $height
                $aMons[$aMons[0][0]][$iBits]      = $bits
                $aMons[$aMons[0][0]][$iHz]        = $hz
            EndIf

        Until 0 
        $MonNum = -1
        Do
            $MonNum += 1
            $aDisp = DllCall($hDLL, "int", "EnumDisplayDevices", "str", $sDispName, "int", $MonNum, "ptr", $ptrData1, "int", 1)
            If @error Or ($aDisp[0] = 0) Then ExitLoop
            If Not BitAND(DllStructGetData($data1, 4), 1) Then ContinueLoop ;If monitor is not connnected to desktop
            $sMonID = StringRegExpReplace(StringReplace(DllStructGetData($data1, 5), "#", "\"), "^.*(DISP.*)\\\{.*$", "$1")
            $tmp = StringSplit($sMonID, "\")
            If $MonNum Then
                If ($tmp[0] < 2) Or ($tmp[2] = "Default_Monitor") Or (StringLeft($tmp[2], 3) = "MS_") Then ContinueLoop
                $aMons[0][0] += 1                      ;next monitor but not display
                ReDim $aMons[$aMons[0][0] + 1][$i2Dim]
                For $i = 0 To $i2Dim - 1
                    $aMons[$aMons[0][0]][$i] = $aMons[$aMons[0][0] - 1][$i]
                Next
            EndIf
            If $tmp[0] > 1 Then
                $aMons[$aMons[0][0]][$iMonID] = $sMonID
            Else
                $aMons[$aMons[0][0]][$iMonID] = "virtual"
            EndIf
            
            $tmp = __EDIDGet($aMons[$aMons[0][0]][$iMonID])
            $aMons[$aMons[0][0]][$iDimWcm]  = $tmp[0]
            $aMons[$aMons[0][0]][$iDimHcm]  = $tmp[1]
            $aMons[$aMons[0][0]][$iDimWmm]  = $tmp[2]
            $aMons[$aMons[0][0]][$iDimHmm]  = $tmp[3]
            $aMons[$aMons[0][0]][$iMonNatW] = $tmp[4]
            $aMons[$aMons[0][0]][$iMonNatH] = $tmp[5]
            $aMons[$aMons[0][0]][$iMonNatF] = $tmp[6]
            $aMons[$aMons[0][0]][$iMonNatB] = $tmp[7]
        Until 0
    Until 0
    DllClose($hDLL)
    
    $Obj_WMIService = ObjGet("winmgmts:{impersonationLevel=Impersonate}!\\.\root\wmi")
    If (Not @error) And IsObj($Obj_WMIService) Then
        $Col_Items = $Obj_WMIService.ExecQuery("Select * From WmiMonitorBasicDisplayParams")
        If (Not @error) And IsObj($Obj_WMIService) Then
            For $Obj_Item in $Col_Items
                
                For $i = 1 To $aMons[0][0]
                    If StringInStr($Obj_Item.InstanceName, $aMons[$i][$iMonID]) = 1 Then
                        $aMons[$i][$iDimWcm] = $Obj_Item.MaxHorizontalImageSize                ;assume that WMI is more reliable than EDID  => overwrite
                        $aMons[$i][$iDimHcm] = $Obj_Item.MaxVerticalImageSize
                        If $aMons[$i][$iDimWcm] < $aMons[$i][$iDimHcm] Then                    ;if monitor is in portrait, swap dimensions
                            $aMons[$i][$iDimWcm] = $aMons[$i][$iDimHcm]
                            $aMons[$i][$iDimHcm] = $Obj_Item.MaxHorizontalImageSize
                        EndIf
                        ExitLoop
                    EndIf    
                Next
            Next
        EndIf
    EndIf
    
    $aRes[0] = $aMons[0][0]
    For $i = 1 To $aMons[0][0]
        If Not $aMons[$i][$iDimWcm] Then $aMons[$i][$iDimWcm] = -1
        If Not $aMons[$i][$iDimHcm] Then $aMons[$i][$iDimHcm] = -1
        If $aMons[$i][$iMonNatB] < 1 Then $aMons[$i][$iMonNatB] = Int($aMons[$i][$iBits] / 3)


        If $aMons[$i][$iDimWmm] And $aMons[$i][$iDimHmm] Then
            If ($aMons[$i][$iDimWcm] < 1) Or ($aMons[$i][$iDimHcm] < 1) Then                  ;mm are known but cm aren't => use mm
                $aMons[$i][$iDiagonal] = __Diagonal($aMons[$i][$iDimWmm] / 10, $aMons[$i][$iDimHmm] / 10, 1)
            ElseIf ( Abs($aMons[$i][$iDimWmm] - 10 * $aMons[$i][$iDimWcm]) < 6 ) And _
                   ( Abs($aMons[$i][$iDimHmm] - 10 * $aMons[$i][$iDimHcm]) < 6 ) Then         ;mm and cm are known and deviation is less than 6 mm => use mm
                $aMons[$i][$iDiagonal] = __Diagonal($aMons[$i][$iDimWmm] / 10, $aMons[$i][$iDimHmm] / 10, 1)
            Else                                                                              ;mm and cm are known but deviation is greater than 6 mm => use cm
                $aMons[$i][$iDiagonal] = __Diagonal($aMons[$i][$iDimWcm], $aMons[$i][$iDimHcm], 0)
            EndIf 
        Else
            If ($aMons[$i][$iDimWcm] > 0) And ($aMons[$i][$iDimHcm] > 0) Then                 ;cm are known but mm aren't => use cm
                $aMons[$i][$iDiagonal] = __Diagonal($aMons[$i][$iDimWcm], $aMons[$i][$iDimHcm], 0)
            Else                                                                              ;neither cm nor mm are known => diagonal size is unknown 
                $aMons[$i][$iDiagonal] = -1
            EndIf
        EndIf

        If ($aMons[$i][$iPixWidth] >= $minWidth) And ($aMons[$i][$iPixHeight] >= $minHeight) And _
           ($aMons[$i][$iDiagonal] >= $minInches) And ($aMons[$i][$iMonNatB] >= $minBPC)      Then $aRes[1] += 1 ;compliant monitors
        
        If ($aMons[$i][$iPixWidth] > 0) And ($aMons[$i][$iPixHeight] > 0) And _
           ( ($aMons[$i][$iPixWidth] < $minWidth) Or ($aMons[$i][$iPixHeight] < $minHeight) ) Then $aRes[2] += 1 ;lower resolution monitors
           
        If ($aMons[$i][$iDiagonal] > -1) And ($aMons[$i][$iDiagonal] < $minInches)            Then $aRes[3] += 1 ;physically smaller monitors

        If ($aMons[$i][$iMonNatB] > -1) And ($aMons[$i][$iMonNatB] < $minBPC)                 Then $aRes[4] += 1 ;monitors with less than 8 bits per color

        If ($aMons[$i][$iPixWidth] = -1) Or ($aMons[$i][$iPixHeight] = -1) Or _
           ($aMons[$i][$iDiagonal] = -1) Or ($aMons[$i][$iMonNatB] = -1)                      Then $aRes[5] += 1 ;monitor with at least 1 undetected parameter
    Next
    
    Return $aRes
EndFunc

Func __Diagonal($x, $y, $dec)
;cm x cm to inches
    If ($x <= 0) Or ($y <= 0) Then Return -1
    Return Round(Sqrt($x^2 + $y^2) / 2.54, $dec)
EndFunc

Func __EDIDGet($id)
; $aResult[0] = Horizontal Screen Size in cm
; $aResult[1] = Vertical Screen Size in cm
; $aResult[2] = max. Horizontal Addressable Video Image Size in mm
; $aResult[3] = max. Vertical Addressable Video Image Size in mm
; $aResult[4] = Horizontal Addressable Video in pixels
; $aResult[5] = Vertical Addressable Video in lines
; $aResult[6] = calculated frequency
; $aResult[7] = Color Bit Depth per color
Local $sReg, $aEDID, $block, $i, $width, $height, $EDIDver, $aResult[8] = [-1, -1, -1, -1, -1, -1, -1, -1]
Local $HorAddrPix, $HorBlnkPix, $VerAddrLin, $VerBlnkLin, $PixelClock

    $sReg = RegRead("HKLM\SYSTEM\CurrentControlSet\Enum\" & $id & "\Device Parameters", "EDID")
    If @error Then Return $aResult

    $aEDID = StringToASCIIArray(BinaryToString($sReg), 0, -1, 1)
    If Not IsArray($aEDID) Then Return $aResult
    ReDim $aEDID[128]

    $EDIDver = Number($aEDID[0x12] & "." & $aEDID[0x13])
    
    If BitAND($aEDID[0x14], 128) Then                       ;Input is a Digital Video Signal Interface
        $i = BitAND(BitShift($aEDID[0x14], 4), 7)           ;Color Bit Depth (bits 4 to 6)
        Switch $i
            Case 1 To 6                                     ;6, 8, 10, 12, 14 or 16 bits per color
                $aResult[7] = 2 * $i + 4
            Case Else                                       ;0 = undefined, 7 = Reserved (Do Not Use)
                $aResult[7] = -1
        EndSwitch
    EndIf

    If $aEDID[0x15] And $aEDID[0x16] Then                  ;nonzero values => size in cm
        $aResult[0] = $aEDID[0x15]
        $aResult[1] = $aEDID[0x16]
    EndIf

    For $block = 1 To 4
        $i = 18 * $block + 36                                                   ;index into EDID array  (54, 72, 90, 108 = 0x36, 0x48, 0x5A, 0x6C)
        If $aEDID[$i] Or $aEDID[$i + 1] Then                                    ;DTD (Detailed Timing Descriptor)
            $width = $aEDID[$i + 12] + BitAND($aEDID[$i + 14], 240)*16          ;Horizontal Addressable Video Image Size in mm
            $height = $aEDID[$i + 13] + BitAND($aEDID[$i + 14], 15)*256         ;Vertical Addressable Video Image Size in mm
            If $width And $height And ( ($width > $aResult[2]) Or ($height > $aResult[3]) ) Then
                $aResult[2] = $width
                $aResult[3] = $height
            EndIf
            $width = ($EDIDver >= 1.4)
            If ($block = 1) And (BitAND($aEDID[0x18], 2) Or $width) Then
                $PixelClock = (256 * $aEDID[$i + 1] + $aEDID[$i]) * 1e4
                $HorAddrPix = BitAND($aEDID[$i + 4], 240) * 16 + $aEDID[$i + 2]
                $HorBlnkPix = BitAND($aEDID[$i + 4], 15) * 256 + $aEDID[$i + 3]
                $VerAddrLin = BitAND($aEDID[$i + 7], 240) * 16 + $aEDID[$i + 5]
                $VerBlnkLin = BitAND($aEDID[$i + 7], 15) * 256 + $aEDID[$i + 6]
                $aResult[4] = $HorAddrPix
                $aResult[5] = $VerAddrLin
                $aResult[6] = Round($PixelClock / ($HorAddrPix + $HorBlnkPix) / ($VerAddrLin + $VerBlnkLin))
            EndIf
        EndIf
    Next
    
    Return $aResult
EndFunc
