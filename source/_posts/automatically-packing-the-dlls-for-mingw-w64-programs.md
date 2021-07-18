---
title: Automatically packing the dlls for mingw-w64 programs
date: 2021-07-12 13:55:36
categories:
- [學習紀錄, C/C++]
tags:
- C++
- 程式
- 教學
- mingw-w64

---

# Problem

When using mingw-64 to compile programs, it usually comes with lots of dlls in dependencies. Moreover, these dlls are placed inside the installation path, inside `mingw32/bin` for 32-bit dlls and `mingw64/bin` for 64-bit dlls. When I want to share my program with my friends, I need to collect the dlls by hand.
Open the program and see the error message and then copy the dlls to folder. Sometimes the error message even doesn't tell the dll name, only with some vague error message that I need to google myself. 

# Solution

Use [ListDLLs](https://docs.microsoft.com/en-us/sysinternals/downloads/listdlls) to list all the dlls which our program depends on.

```

```
