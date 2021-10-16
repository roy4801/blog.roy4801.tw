---
title: Collecting the dlls for mingw-w64 compiled programs
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

When using mingw-64 to compile programs, it usually comes with lots of dlls in dependencies. Moreover, these dlls are placed inside the installation path, inside `mingw32/bin` for 32-bit dlls and `mingw64/bin` for 64-bit dlls. When I want to share my program with my friends, I usually need to packing the dlls with the exe. So I need to collect the dlls by hand which bothers me a lot.

Open the program and see the error message and then copy the dlls to folder. Sometimes the error message doesn't even tell the dll name, only with some vague error message that I need to google myself. 

# Solution

Use [ListDLLs](https://docs.microsoft.com/en-us/sysinternals/downloads/listdlls) to list all the dlls which our program depends on.

```
Listdlls v3.2 - Listdlls
Copyright (C) 1997-2016 Mark Russinovich
Sysinternals

usage: listdlls [-r] [-v | -u] [processname|pid]
usage: listdlls [-r] [-v] [-d dllname]
  processname   Dump DLLs loaded by process (partial name accepted)
  pid           Dump DLLs associated with the specified process id
  dllname       Show only processes that have loaded the specified DLL.
  -r            Flag DLLs that relocated because they are not loaded at
                their base address.
  -u            Only list unsigned DLLs.
  -v            Show DLL version information.
```

To list the dlls of a program, run the following command:

```
listdlls example.exe
```

The dlls which path starts with mingw are the dlls we want.

![](https://i.imgur.com/b8DJx40.png)

The result has some dlls that we don't care, we can use some cli tools to sort the output for better format.

```bash
listdlls example.exe | tail -n +11 | tr -s ' ' | sort -u -k 3
```

![](https://i.imgur.com/DkFGb12.png)

Then just copy the dlls and place them aside the exe file.
