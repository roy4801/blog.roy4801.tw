---
title: 使用 CLion + gdb Debug 程式
date: 2020-05-18 21:41:58
categories:
 - [學習紀錄, C/C++]
tags:
- C++
- IDE
- 程式
- 教學

---


![](https://i.imgur.com/r1NLY9U.png)

CLion是一款專為開發C及C++所設計的跨平台IDE。它是以IntelliJ為基礎設計的，包含了許多智慧功能來提高開發人員的生產力。支援代碼分析、快速修復和重構，集合的除錯器可以用 GDB 或 LLDB 作為後端，輕鬆調查和解決問題，能夠為程序員提供一個整合式的C/C ++開發環境

https://www.jetbrains.com/clion/

* 本人目前的開發環境
    * Compiler
        * msys2 mingw-w64-i686
    * 開發
        * vscode + C/C++ plugin
    * 除錯
        * CLion + gdb

目前我是使用 vscode 進行開發，但是遇到需要用上 gdb 的場合時，vscode 就顯得吃力了，在 Windows 上時不時會壞掉。

故使用 CLion 的 debug 功能來除錯。 CLion 的一大特點是支援 `CMake`，所以只要你的 Project 有 `CMakeLists.txt` 就可以直接匯入。並且有很強大的 Rafactor 、Quick Fix 、Code Generation 功能，可以讓開發人員省下一些時間。

CLion 個人使用一年大約[兩千多新台幣](https://www.jetbrains.com/clion/buy/#personal?billing=yearly)，而如果你是學生的話則是[免費的](https://www.jetbrains.com/community/education/#students)

## 使用 CLion

![](https://i.imgur.com/S2aoCKa.png)

安裝完成後，打開 CLion 便是這個畫面，可以選擇 `New Project` 建立新的專案；或是 Import 其他專案 (可以用 File Expolrer 拖移到上頭開啟)

![](https://i.imgur.com/yN0DjLa.png)

開啟專案後，首先要設定 Toolchain (`Settings`>`Build.. `>`Toolchain`)，點選加號新增一個 toolchain

![](https://i.imgur.com/UrtqHgr.png)

`Environment` 選擇 mingw-w64 的目錄，如果是 32-bit 就選擇 `mingw32`，如果是 64-bit 就選擇 `mingw64`
如果發現 gdb 版本不符合時，CLion 會提示說 `Incompatible`，則需要降級版本


![](https://i.imgur.com/MBjoebN.png)

## 降級 gdb 版本

* 目標:降級到 `8.3.x` 版本的 gdb

![](https://i.imgur.com/SPxYRAf.png)

* 去 [repo.msys2.org](http://repo.msys2.org/mingw/i686/) 找到你要的版本的 package
    * 下載該 package

* 降級

```bash
pacman -U mingw-w64-i686-gdb-8.3.1-3-any.pkg.tar.xz
```
 
## Debugging

Debugging 時就如同其他 IDE 一樣，選擇 break point 後，點右上角的蟲子(Debug)
右下角可以輸入 gdb 指令，中下方可以觀察變數，左下方則是 Stack Frame 並且可以切換 Thread

<iframe width="560" height="315" src="https://www.youtube.com/embed/xDB7dxXvcQ8" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## 參考

CLion Debigging
https://www.jetbrains.com/help/clion/debugging-code.html

How to obtain older versions of packages using MSYS2?
https://stackoverflow.com/questions/33969803/how-to-obtain-older-versions-of-packages-using-msys2
