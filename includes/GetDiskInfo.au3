; Includes
;----------
#include-once
#include <Array.au3>



#cs
===============================================================================================================================
 Title ...............: _GetDiskInfoFromWmi (GitHub: https://github.com/htcfreek/AutoIt-Scripts)
 Version .............: 1.4.1
 License .............: GNU LGPLv3
 AutoIt Version ......: 3.3.14.5+
 Language ............: English
 Description .........: Get disk and partition informations from WMI.
 Author ..............: htcfreek (Heiko) - https://github.com/htcfreek [original]
 Modified ............: 2021-07-12 (htcfreek): Temporary fix build warnings until new version is released.
 Required includes ...: Array.au3
 Dll .................:
===============================================================================================================================

CHANGELOG:
	2021-07-12 (v1.4.1 + temporary fix)
		Fix: Build warings for non declared vars $sDiskHeader, $sPartitionHeader

	2021-07-06 (v1.4.1)
		Fixed: Code styling

	2021-07-05 (v1.4)
		Fixed: Typos in script and example.

	2021-07-04 (v1.3)
		Fixed: Typos
		Added: DiskType filter
		Added: Constants
		Added: Required includes
		Added: Error handling
		Changed: Improved comments
		Changed: Disk property header renamed: WindowsRunningOnDisk (SystemRoot) -> WindowsRunningOnDisk (SystemDisk)
		Changed: Partition property header renamed: PartitionIsSystemRoot -> PartitionIsSystemDisk

	2021-07-02 (v1.2)
		Added: Disk properties Manufacturer, InterfaceType, MediaType, SerialNumber, Status
		Added: Partition property: Filesystem
		Changed: Disk property header renamed: SystemIsBootedFromDisk -> WindowsRunningOnDisk (SystemRoot)
		Changed: Partition property header renamed: SystemIsBootedFromPartition -> PartitionIsSystemRoot

	2021-07-02 (v1.0)
		New: Initial release

#ce



; Global constants
; -----------------
Global Const $DiskInfoWmi_TableHeader_Yes = 1
Global Const $DiskInfoWmi_TableHeader_No = 0
Global Const $DiskInfoWmi_DiskType_All = "%"
Global Const $DiskInfoWmi_DiskType_External = "External%"
Global Const $DiskInfoWmi_DiskType_Removable = "Removable%"
Global Const $DiskInfoWmi_DiskType_Fixed = "Fixed%"
Global Const $DiskInfoWmi_DiskType_Unknown = "Unknown%"



; Function
; ---------
Func _GetDiskInfoFromWmi(ByRef $aDiskList, ByRef $aPartitionList, $bAddTableHeader = $DiskInfoWmi_TableHeader_Yes, $sFilterDiskType = $DiskInfoWmi_DiskType_All)
	; Name ...............: _GetDiskInfoFromWmi
	; Author .............: htcfreek (Heiko) - https://github.com/htcfreek
	; Input parameter ....: ByRef $aDiskList = Array var for list of disks.
	;                       ByRef $aPartitionList = Array var for list of partitions.
	;                       [$bAddTableHeader = $DiskInfoWmi_TableHeader_Yes] = Should array tables have a header row. (Values: 0|1 or $DiskInfoWmi_TableHeader_Yes|$DiskInfoWmi_TableHeader_No)
	;                       [$sFilterDiskType = $DiskInfoWmi_DiskType_All] = Which type of disk should be included in result. (Values: $DiskInfoWmi_DiskType_All|$DiskInfoWmi_DiskType_External|$DiskInfoWmi_DiskType_Removable|$DiskInfoWmi_DiskType_Fixed|$DiskInfoWmi_DiskType_Unknown)
	; Output parameter ...: none
	; On WMI-Error .......: @error = 1


	; Initialize function wide vars
	Local $aDisks[0][12]
	Local $aPartitions[0][13]
	Local $iDiskArrayCount = 0 ; Initialize counter to write some disk data later in correct array row.
	Local $iPartArrayCount = 0 ; Initialize counter to write partition data later in correct array row.


	; Add Array header
	If ($bAddTableHeader = 1) Then
		Local $sDiskHeader = "DiskNum" & "||" & "DiskDeviceID" & "||" & "DiskManufacturer" & "||" & "DiskModel" & "||" & "DiskInterfaceType" & "||" & "DiskMediaType" & "||" & "DiskSerialNumber" & "||" & "DiskState" & "||" & "DiskSize" & "||" & "DiskInitType" & "||" & "DiskPartitionCount" & "||" & "WindowsRunningOnDisk (SystemDrive)"
		_ArrayAdd($aDisks, $sDiskHeader, 0, "||")
		Local $sPartitionHeader = "DiskNum" & "||" & "PartitionNum" & "||" & "PartitionID" & "||" & "PartitionType" & "||" & "PartitionIsPrimary" & "||" & "PartitionIsBootPartition" & "||" & "PartitionLetter" & "||" & "PartitionLabel" & "||" & "PartitionFileSystem" & "||" & "PartitionSizeTotal" & "||" & "PartitionSizeUsed" & "||" & "PartitionSizeFree" & "||" & "PartitionIsSystemDrive"
		_ArrayAdd($aPartitions, $sPartitionHeader, 0, "||")
		$iDiskArrayCount += 1
		$iPartArrayCount += 1
	EndIf

	; Get Information from WMI
	Local $oWmiInstance = ObjGet('winmgmts:\\' & @ComputerName & '\root\cimv2')
	If (IsObj($oWmiInstance)) And (Not @error) Then
		; Get Disks
		Local $oPhysicalDisks = $oWmiInstance.ExecQuery('Select * from Win32_DiskDrive WHERE MediaType like "' & $sFilterDiskType & '"')
		For $oDisk In $oPhysicalDisks
			; Add Disk data to Array
			Local $iDisk = $oDisk.Index
			Local $sNewDisk = $iDisk & "||" & $oDisk.DeviceID & "||" & $oDisk.Manufacturer & "||" & $oDisk.Model & "||" & $oDisk.InterfaceType & "||" & $oDisk.MediaType & "||" & $oDisk.SerialNumber & "||" & $oDisk.Status & "||" & $oDisk.Size & "||" & "<DiskInitStyle>" & "||" & $oDisk.Partitions & "||" & False
			_ArrayAdd($aDisks, $sNewDisk, 0, "||")

			; Get Partitions
			Local $oPartitions = $oWmiInstance.ExecQuery("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & $oDisk.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition")
			For $oPartition In $oPartitions
				; Add Partition data to Array
				Local $iPartition = $oPartition.Index
				Local $sNewPart = $iDisk & "||" & $iPartition & "||" & $oPartition.DeviceID & "||" & $oPartition.Type & "||" & $oPartition.PrimaryPartition & "||" & $oPartition.BootPartition & "||" & "" & "||" & "" & "||" & "" & "||" & $oPartition.Size & "||" & "" & "||" & "" & "||" & False
				_ArrayAdd($aPartitions, $sNewPart, 0, "||")

				; Set DiskInitStyle
				If StringRegExp($oPartition.Type, "^GPT.*") Then
					$aDisks[$iDiskArrayCount][9] = "GPT"
				Else
					$aDisks[$iDiskArrayCount][9] = "MBR"
				EndIf

				; Get logical disks
				Local $oLogicalDisks = $oWmiInstance.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & $oPartition.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition")
				For $oLogicalDisk In $oLogicalDisks
					; Add logical disk data to array
					$aPartitions[$iPartArrayCount][6] = $oLogicalDisk.DeviceID
					$aPartitions[$iPartArrayCount][7] = $oLogicalDisk.VolumeName
					$aPartitions[$iPartArrayCount][8] = $oLogicalDisk.FileSystem
					$aPartitions[$iPartArrayCount][9] = $oLogicalDisk.Size ; Value of LogicalDisk.Size is different to Size of DiskPartition.Size!!
					$aPartitions[$iPartArrayCount][10] = ($oLogicalDisk.Size - $oLogicalDisk.FreeSpace)
					$aPartitions[$iPartArrayCount][11] = $oLogicalDisk.FreeSpace

					; Detect SystemBootDisk
					If $oLogicalDisk.DeviceID = EnvGet("SystemDrive") Then
						$aDisks[$iDiskArrayCount][11] = True
						$aPartitions[$iPartArrayCount][12] = True
					EndIf
				Next

				; Array counter (Partitions) + 1
				$iPartArrayCount += 1
			Next

			; Array counter (Disks) + 1
			$iDiskArrayCount += 1
		Next
	Else
		; If WMI-Error then set @error
		SetError(1)
	EndIf

	; Return Data
	$aDiskList = $aDisks
	$aPartitionList = $aPartitions
EndFunc   ;==>_GetDiskInfoFromWmi