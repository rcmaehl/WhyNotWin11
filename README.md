[![Build Status](https://img.shields.io/github/workflow/status/rcmaehl/WhyNotWin11/wnw11)](https://github.com/rcmaehl/WhyNotWin11/actions?query=workflow%3AWNW11)
[![Download](https://img.shields.io/github/v/release/rcmaehl/WhyNotWin11)](https://github.com/rcmaehl/WhyNotWin11/releases/latest/)
[![Download count)](https://img.shields.io/github/downloads/rcmaehl/whynotwin11/total?label=Downloads)](https://github.com/rcmaehl/WhyNotWin11/releases/latest/)
[![Ko-fi](https://img.shields.io/badge/Support%20me%20on-Ko--fi-FF5E5B.svg?logo=ko-fi)](https://ko-fi.com/rcmaehl)
[![PayPal](https://img.shields.io/badge/Donate%20on-PayPal-00457C.svg?logo=paypal)](https://paypal.me/rhsky)
[![Join the Discord chat](https://img.shields.io/badge/Discord-chat-7289da.svg?&logo=discord)](https://discord.gg/uBnBcBx)
[![My Twitter](https://img.shields.io/badge/twitter-545454.svg?logo=twitter)](https://twitter.com/WhyNotWin11)

# WhyNotWin11
Detection Script to help identify why your PC isn't Windows 11 Release Ready

![image](https://user-images.githubusercontent.com/716581/123796852-91b16600-d8b3-11eb-869f-b5f6c67a6de8.png)

----

## Download

[Download latest stable release](https://github.com/rcmaehl/WhyNotWin11/releases/latest/download/WhyNotWin11.exe)

[Download latest testing release](https://nightly.link/rcmaehl/WhyNotWin11/workflows/wnw11/main/WNW11.zip)\
**Keep in mind that you will have to update testing releases manually**

## To-Do

- [x] Hard Floor Checks:
    - [x] Cores >= 2
    - [x] CPU Freq >= 1 GHZ
    - [X] CPU Arch = 64
    - [x] RAM >= 4 GB
    - [x] Storage >= 64 GB
    - [x] ~~TPM >= 1.2~~ (Removed with recent changes from Microsoft)
    - [x] SecureBoot
    - [x] ~~SMode~~ (WhyNotWin11 is not compatible with S Mode Devices)
- [x] Soft Floor Checks:
    - [x] TPM >= 2.0
    - [x] CPU Compatibility list
- [ ] Other Checks:
    - [x] DirectX 12
    - [x] WDDM 2
    - [ ] Screen Resolution
- [x] A fancier GUI

## Compiling

1. Download and run "AutoIt Full Installation" from [official website](https://www.autoitscript.com/site/autoit/downloads). 
1. Get the source code either by [downloading zip](https://github.com/rcmaehl/WhyNotWin11/archive/main.zip) or do `git clone https://github.com/rcmaehl/WhyNotWin11`.
1. Right click on `WhyNotWin11.au3` in the WhyNotWin11 directory and select "Compile Script (x64) (or x86 if you have 32 bit Windows install).
1. This will create WhyNotWin11.exe in the same directory.

## License

WhyNotWin11 is free and open source software, it is using the LGPL-3.0 license.

See LICENSE for the full license text.
