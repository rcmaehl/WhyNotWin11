#
# MIT License
#
# Copyright (c) 2025 Free Geek
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

$processorBrands = @('Intel', 'AMD', 'Qualcomm')
$windowsVersions = @('11')

$subtractYears = 0
do {
	$featureVersion = "$((Get-Date).AddYears($subtractYears).ToString('yy'))H2"
	$windowsVersions += "11 $featureVersion"
	$subtractYears --
}
until ($featureVersion -eq '22H2')

$dateString = $(Get-Date -Format 'yyyy.M.d')

$outputFolderPath = "$PSScriptRoot\Windows 11 Supported Processors Lists $dateString"
if (-not (Test-Path $outputFolderPath)) {
	New-Item -ItemType 'Directory' -Path $outputFolderPath -ErrorAction Stop | Out-Null
}

foreach ($thisProcessorBrand in $processorBrands) {
	$allSupportedProcessorNames = @()

	foreach ($thisWindowsVersion in $windowsVersions) {
		$thisSupportedProcessorsURL = "https://learn.microsoft.com/en-us/windows-hardware/design/minimum/supported/windows-$($thisWindowsVersion.ToLower().Replace(' ', '-'))-supported-$($thisProcessorBrand.ToLower())-processors"

		Write-Output "`n$thisProcessorBrand $thisWindowsVersion`n$thisSupportedProcessorsURL"

		$tableContents = ''
		try {
			$tableContents = [System.IO.StreamReader]::new((Invoke-WebRequest -TimeoutSec 5 -Uri $thisSupportedProcessorsURL -ErrorAction Stop).RawContentStream).ReadToEnd()
			# Parse the "RawContentStream" instead of "Content" so that multi-byte characters (® and ™) don't get mangled: https://www.reddit.com/r/PowerShell/comments/17h8koy/comment/k6otsr1
		} catch {
			Write-Host "HTTP ERROR: $($_.Exception.Response.StatusCode)"
		}

		$tableTagIndex = $tableContents.indexOf('<table>') # Extract only the table to avoid HTML parsing issues with Select-Xml
		if ($tableTagIndex -gt -1) {
			$tableContents = $tableContents.Substring($tableTagIndex, ($tableContents.indexOf('</table>') + 8 - $tableTagIndex)).Replace('&nbsp;', ' ')

			$thisSupportedProcessorNames = @()
			Select-Xml -Content $tableContents -XPath '//tr' -ErrorAction Stop | Select-Object -Skip 1 | ForEach-Object {
				$tdNodes = $_.Node.ChildNodes
				if ($tdNodes.Count -ge 3) {
					if (($tdNodes.Count -lt 4) -or ($tdNodes[3].InnerText -ne 'IoT Enterprise Only')) {
						# Processor names are modified to match format of the following WhyNotWin11 files (which match the brand strings of the processors):
						# https://github.com/rcmaehl/WhyNotWin11/blob/main/includes/SupportedProcessorsIntel.txt
						# https://github.com/rcmaehl/WhyNotWin11/blob/main/includes/SupportedProcessorsAMD.txt
						# https://github.com/rcmaehl/WhyNotWin11/blob/main/includes/SupportedProcessorsQualcomm.txt

						$registeredSymbolReplacement = '(R)'
						$trademarkSymbolReplacement = '(TM)'
						if ($thisProcessorBrand -eq 'AMD') {
							$registeredSymbolReplacement = ''
							$trademarkSymbolReplacement = ''
						}

						$processorFamily = $tdNodes[1].InnerText.Replace("$([char]0x00AE)", $registeredSymbolReplacement).Replace("$([char]0x2122)", $trademarkSymbolReplacement).Replace("$([char]0x200B)", '').Trim()
						$processorModel = ($tdNodes[2].InnerText.Replace("$([char]0x00AE)", $registeredSymbolReplacement).Replace("$([char]0x2122)", $trademarkSymbolReplacement).Replace("$([char]0x200B)", '') -Replace '\[\d+\]', '').Trim()
						# On https://learn.microsoft.com/en-us/windows-hardware/design/minimum/supported/windows-11-24h2-supported-amd-processors some model names such as "4345P" has a zero-width space (ZWSP) character (0x200B) after them that needs to be removed.

						if ($thisProcessorBrand -eq 'Intel') {
							$processorModel = $processorModel -Replace ' [Pp]rocessor ', '-'
						} elseif ($thisProcessorBrand -eq 'AMD') {
							$processorModel = $processorModel.Replace(' (OEM Only)', '').Replace(' Microsoft Surface Edition', '').Replace(' Processor', '') -Replace ' with Radeon .* Graphics', ''
						} elseif ($thisProcessorBrand -eq 'Qualcomm') {
							$processorModel = $processorModel.Replace('Snapdragon', 'Snapdragon (TM)')
						}

						if (($processorFamily -ne '') -and ($processorFamily -ne $thisProcessorBrand) -and ($thisProcessorBrand -ne 'Qualcomm')) {
							$thisSupportedProcessorNames += "$processorFamily $processorModel"
						} else {
							$thisSupportedProcessorNames += $processorModel
						}
					}
				}
			}

			$thisSupportedProcessorNames = $thisSupportedProcessorNames | Sort-Object -Unique
			$allSupportedProcessorNames += $thisSupportedProcessorNames

			$thisSupportedProcessorNames = ,$dateString + $thisSupportedProcessorNames + 'EOF'
			$thisSupportedProcessorNames | Set-Content "$outputFolderPath\SupportedProcessors$thisProcessorBrand $thisWindowsVersion.txt"
		} else {
			Write-Output "FAILED TO DETECT SUPPORTED PROCESSORS TABLE FOR $thisProcessorBrand - $thisWindowsVersion"
		}
	}

	$allSupportedProcessorNames = $allSupportedProcessorNames | Sort-Object -Unique
	$allSupportedProcessorNames = ,$dateString + $allSupportedProcessorNames + 'EOF'
	$allSupportedProcessorNames | Set-Content "$outputFolderPath\SupportedProcessors$thisProcessorBrand.txt"
}
