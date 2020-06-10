---
title: 在64-bit Ubuntu執行32-bit程式
date: 2019-01-26 19:50:16
categories:
- [學習紀錄, Linux]
tags:
- Linux
- 心得

---

# 前言

安裝64-bit的ubuntu時，預設是不裝32-bit的lib的，如果你在一個64-bit的環境，執行32-bit的程式。
會看到以下畫面

```
$ ./file1
bash: ./file1: No such file or directory
```

用`file`觀察發現：

```
$ file ./file1
./file1: ELF 32-bit LSB  executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.8, not stripped.
```

# 解法

只要安裝32-bit的lib就可解決。

```
$ sudo dpkg --add-architecture i386
$ sudo apt-get update
$ sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386
```

# 參考

How to run 32-bit app in Ubuntu 64-bit?
https://askubuntu.com/questions/454253/how-to-run-32-bit-app-in-ubuntu-64-bit/454254#454254

How to install ia32-libs in Ubuntu 14.04 LTS (Trusty Tahr)
https://stackoverflow.com/questions/23182765/how-to-install-ia32-libs-in-ubuntu-14-04-lts-trusty-tahr