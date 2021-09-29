#include <Memory.au3>

Func Get_BitGroup_Dword($iDword, $iLsb, $iMsb)
    Local $iVal1 = BitShift($iDword, $iLsb) ;>>
    Local Const $iMask = 0xFFFFFFFF
    Local $iVal2 = BitNOT(BitShift($iMask, ($iLsb-$iMsb-1))) ;~<<
    Return BitAND($iVal1, $iVal2)
EndFunc

Func RevBinStr($val)
    Local $rev
    For $n = BinaryLen($val) To 1 Step -1
        $rev &= Hex(BinaryMid($val, $n, 1))
    Next
    Return BinaryToString("0x" & $rev)
EndFunc

Func CpuId($iLeaf, $iSubLeaf = 0)
    Local $aE[4] = [0, 0, 0, 0]
    Local $aCPUID = __Cpuid_Get_Leaf(BitAND($iLeaf, 0xFFFF0000)) ;need to get max first
    If @error or $aCPUID[0] < $iLeaf Then Return SetError(1, @error, $aE)
    Return __Cpuid_Get_Leaf($iLeaf, $iSubLeaf)
EndFunc

Func CpuId_Vendor()
    Local $aCPUID = __Cpuid_Get_Leaf(0x0)
    Return RevBinStr($aCPUID[1]) & RevBinStr($aCPUID[3]) & RevBinStr($aCPUID[2])
EndFunc

Func CpuId_Processor_Brand()
    Local $sPBS = "???"
    Local $aCPUID = __Cpuid_Get_Leaf(0x80000000) ;need to get max extended value first
    If $aCPUID[0] < 0x80000004 Then Return SetError(1, 0, $sPBS)
    $aCPUID = __Cpuid_Get_Leaf(0x80000002)
    $sPBS = RevBinStr($aCPUID[0]) & RevBinStr($aCPUID[1]) & RevBinStr($aCPUID[2]) & RevBinStr($aCPUID[3])
    $aCPUID = __Cpuid_Get_Leaf(0x80000003)
    $sPBS &= RevBinStr($aCPUID[0]) & RevBinStr($aCPUID[1]) & RevBinStr($aCPUID[2]) & RevBinStr($aCPUID[3])
    $aCPUID = __Cpuid_Get_Leaf(0x80000004)
    $sPBS &= RevBinStr($aCPUID[0]) & RevBinStr($aCPUID[1]) & RevBinStr($aCPUID[2]) & RevBinStr($aCPUID[3])
    Return StringStripWS($sPBS, 7)
EndFunc

Func CpuId_Signature_Info()
    Local $aRet[6] = [0, 0, 0, 0, 0 ,0]
    Local Enum $eStep = 0, $eModel, $eFamily, $eType, $eExtModel, $eExtFamily
    Local $aCPUID = __Cpuid_Get_Leaf(0x00000000) ;need to get max id value first
    If $aCPUID[0] < 0x00000001 Then Return SetError(1, 0, $aRet)
    $aCPUID = __Cpuid_Get_Leaf(0x00000001)
    Local $iEax = $aCPUID[0]
    $aRet[$eStep]      = Get_BitGroup_Dword($iEax, 0, 3)
    $aRet[$eModel]     = Get_BitGroup_Dword($iEax, 4, 7)
    $aRet[$eFamily]    = Get_BitGroup_Dword($iEax, 8, 11)
    $aRet[$eType]      = Get_BitGroup_Dword($iEax, 12, 13)
    $aRet[$eExtModel]  = Get_BitGroup_Dword($iEax, 16, 19)
    $aRet[$eExtFamily] = Get_BitGroup_Dword($iEax, 20, 27)
    Return $aRet
EndFunc

Func __Cpuid_Get_Leaf($iLeaf, $iSubLeaf = 0)

    Local Const $sCode32 =  "0x"     & _ ; use32
                            "55"     & _ ; push ebp
                            "89E5"   & _ ; mov ebp, esp
                            "53"     & _ ; push ebx
                            "8B4508" & _ ; mov eax, [ebp + 08] ;$iLeaf
                            "8B4D0C" & _ ; mov ecx, [epb + 12] ;$iSubLeaf
                            "31DB"   & _ ; xor ebx, ebx ; set ebx = 0
                            "31D2"   & _ ; xor edx, edx ; set edx = 0
                            "0FA2"   & _ ; cpuid
                            "8B6D10" & _ ; mov ebp, [ebp + 16] ;ptr int[4]
                            "894500" & _ ; mov [ebp + 00], eax
                            "895D04" & _ ; mov [edi + 04], ebx
                            "894D08" & _ ; mov [edi + 08], ecx
                            "89550C" & _ ; mov [edi + 12], edx
                            "5B"     & _ ; pop ebx
                            "5D"     & _ ; pop ebp
                            "C3"         ; ret

    Local Const $sCode64 =  "0x"         & _ ; use 64
                            "53"         & _ ; push rbx
                            "89C8"       & _ ; mov  eax, ecx ;$ileaf
                            "89D1"       & _ ; mov  ecx, edx ;$iSubleaf
                            "31DB"       & _ ; xor  ebx, ebx
                            "31D2"       & _ ; xor  edx, edx
                            "0FA2"       & _ ; cpuid
                            "67418900"   & _ ; mov  [r8d], eax ;ptr int[4]
                            "6741895804" & _ ; mov  [r8d + 04], ebx
                            "6741894808" & _ ; mov  [r8d + 08], ecx
                            "674189500C" & _ ; mov  [r8d + 12], edx
                            "5B"         & _ ; pop rbx
                            "C3"             ; ret


    Local Const $sCode = @AutoItX64 ? $sCode64 : $sCode32
    Local Const $iSize = BinaryLen($sCode)
    Local $aE_X[4] = [0, 0, 0, 0]
    Local $iErr

    Do
        $iErr = 1
        Local $pBuffer = _MemVirtualAlloc(0, $iSize, BitOR($MEM_COMMIT, $MEM_RESERVE), $PAGE_EXECUTE_READWRITE)
        If $pBuffer = 0 Then ExitLoop
        $iErr = 2
        DllStructSetData(DllStructCreate("BYTE[" & $iSize & "]", $pBuffer), 1, $sCode)
        If @error Then ExitLoop
        $iErr = 3
        Local $tRet = DllStructCreate("int EAX;int EBX;int ECX;int EDX;")
        If @error Then ExitLoop
        $iErr = 4
        ;Local $aRet = DllCallAddress("uint:cdecl", $pBuffer, "int", Int($iLeaf), "int", Int($iSubLeaf), "ptr", DllStructGetPtr($tRet))
        If @error Then ExitLoop
        $iErr = 0;Success?
    Until(True)

    _MemVirtualFree($pBuffer, $iSize, $MEM_DECOMMIT)

    For $i = 0 To $iErr <> 0 ? -1 : UBound($aE_X) - 1
        $aE_X[$i] = "0x" & Hex(DllStructGetData($tRet, $i + 1))
    Next

    Return SetError($iErr, @error, $aE_X)
EndFunc