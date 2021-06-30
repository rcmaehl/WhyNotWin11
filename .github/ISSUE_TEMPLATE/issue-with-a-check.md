---
name: Issue with a Check
about: One of the checks incorrectly passed/failed
title: ''
labels: ''
assignees: ''

---

**All Checks**
- Download and run the latest build https://nightly.link/rcmaehl/WhyNotWin11/workflows/wnw11/main/WNW11.zip
- Attach a picture of your WhyNotWin11 Results
- Attach required information based on the category:

**Architecture, CPU Compatibility, CPU Core Count, and CPU Frequency**
- Please run `taskmgr`, select Performance, then CPU, and attach a screenshot of the output
- Please run `gwmi win32_processor | Format-List -Property MaxClockSpeed,Name,NumberOfCores,NumberOfLogicalProcessors,AddressWidth` in Powershell and attach a screenshot of the output

**Boot Method**
- Please run `bcdedit` in an *Admin* Powershell and attach a screenshot of the output
- Please run ` $env:firmware_type` in Powershell and attach a screenshot of the output

**DirectX**
- Please [download and run GPU-Z](https://www.techpowerup.com/download/techpowerup-gpu-z/) and attach a screenshot of the "Graphics Card" tab
- Please run `dxdiag`, select `Save All Information` and upload the file it generates

**Disk Partition Type, Storage Available**
- Please run `diskmgmt.msc`, maximize the window, and attach a screenshot of the output

**RAM Installed**
- Please run `gwmi Win32_PhysicalMemory | Format-List -Property BankLabel,Capacity,PartNumber` in Powershell and attach a screenshot of the output

**Secure Boot**
- Please run `reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\State` in Powershell and attach a screenshot of the output

**TPM**
- Please run `windowsdefender://devicesecurity`, Select `Security Processor Details` and attach a screenshot of the output
