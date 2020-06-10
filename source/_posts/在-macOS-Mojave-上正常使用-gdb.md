---
title: 在 macOS Mojave 上正常使用 gdb
date: 2020-01-27 05:42:06
categories:
- [學習紀錄, macOS]
tags:
- 教學
- gdb
---

在 macOS 上使用 gdb 時，如果沒有做以下修改，通常會是這樣：

```
gdb$ r
Starting program: /private/tmp/a.out
Unable to find Mach task port for process-id 20201: (os/kern) failure (0x5).
 (please check gdb is codesigned - see taskgated(8))
```

這是因為 Darwin 內核預設禁止沒有特殊權限的程序偵錯(Debugging)其他程序，在預設這個選項是關閉的，如果要開啟則要用系統信任的憑證進行簽章(codesign)。

> 身為開發者，如果沒有了 debugger 就只剩下 printf 流了
> 當然如果使用 root 執行可以 debug，但用 root 權限來執行是一件很糟糕的事

## 新增憑證

![](https://i.imgur.com/JWFmBlK.png)

1. 打開 `Keychain Access.app`，在選項選擇：Certificate Assistant > Create a Certificate

![](https://i.imgur.com/stBoJsk.png)

* 名字隨意（但之後會用到），`Certificate Type` 選擇 `Code Signing`
    * 會遇到警告，但 `Continue` 即可

![](https://i.imgur.com/R5PWXr3.png)

* 時間可以挑整，預設是一年

![](https://i.imgur.com/pvMh6gY.png)

* 後面的都不用動，下一步連打直到 Specify a Location 這個畫面
  * Keychain location 選擇 `System`

![](https://i.imgur.com/Ad7jvo3.png)

* 新增完成後，重新開機

* 回到 `Key Access.app`，找在剛剛設定的憑證（certificate)，右鍵點選 Get Info

![](https://i.imgur.com/JDDZtbR.png)

* 展開 Trust 選單，點選 `Code Signing` 將其改成 `Always Trust`

![](https://i.imgur.com/5TfSJcX.png)

  * 在 terminal 中輸入 `security dump-trust-settings -d`，應能看見之前新增之憑證

    ```
    Number of trusted certs = 1
    Cert 0: gdb-cert
    Number of trust settings : 1
    Trust Setting 0:
        Policy OID            : Code Signing
        Allowed Error         : CSSMERR_TP_CERT_EXPIRED
        Result Type           : kSecTrustSettingsResultTrustRoot
    ```

## 簽章

* 找到 gdb 所在路徑 e.g. `/usr/local/Cellar/gdb/8.3.1/bin`，並 cd 過去
  * `$ where gdb`

* 建立 `gdb.xml`，並貼上以下內容（給予 gdb debugger 的權限）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.debugger</key>
    <true/>
</dict>
</plist>
</pre>
```

* 執行指令 `codesign --entitlements gdb.xml -fs gdb-cert ./gdb`

* 之後執行 `codesign -d --entitlements - $(which gdb)`，應看見先前之 `gdb.xml` 一樣內容

```
Executable=/usr/local/Cellar/gdb/8.3.1/bin/gdb
��qq<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.debugger</key>
    <true/>
</dict>
</plist>
</pre>
```

## gdb

* 在 `~/.gdbinit` 中新增 `set startup-with-shell off`

* 如果出現 gdb 凍結在 `run` 時，可以試試將 DevToolsSecurity 關閉
  * `sudo DevToolsSecurity -disable`

* 成功使用 gdb
![](https://i.imgur.com/wKHmmhr.gif)

## 參考

PermissionsDarwin@gdb wiki
https://sourceware.org/gdb/wiki/PermissionsDarwin

macOS Mojave: How to achieve codesign to enable debugging (gdb)?
https://stackoverflow.com/questions/52699661/macos-mojave-how-to-achieve-codesign-to-enable-debugging-gdb

解决GDB在Mac下不能调试的问题
https://segmentfault.com/q/1010000004136334

Getting gdb to (semi) reliably work on Mojave MacOS
https://timnash.co.uk/getting-gdb-to-semi-reliably-work-on-mojave-macos/