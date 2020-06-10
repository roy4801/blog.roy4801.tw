---
title: ssh到linux(ubuntu)上無法輸入中文問題
date: 2018-08-25 00:38:03
categories:
- [學習紀錄, Linux]
tags:
- Linux
- 教學

---
# 前言

在前幾個星期，筆者被windows折磨（各種工具無法在windows上使用），所以索性將PC灌成Ubuntu，但在ssh進入ubuntu上卻遇到了無法輸入中文的問題。

連入ssh時可能會注意到一行
```
-bash: warning: setlocale: LC_ALL: cannot change locale (zh_TW.UTF-8)
```

原因是ssh在連上主機時會將本地的LC_*環境變數自動設定到遠端主機上，而如果遠端主機不支援該語系時就會出現「`-bash: warning: setlocale: LC_ALL: cannot change locale`」的錯誤。

ssh的設定檔可以在`/etc/ssh/`中找到。

# 解決

更改語系成`zh_TW.UTF-8`


先用`locale -a`查看有沒有`zh_TW.utf8`的選項，如果沒有則使用`locale-gen`產生新的語系+編碼。

```bash
$ sudo locale-gen zh_TW.UTF-8
```

之後在更改環境變數

```bash
$ export LC_ALL="zh_TW.UTF-8"
$ export LANG="zh_TW.UTF-8"
```

# 參考

warning: setlocale: LC_ALL: cannot change locale
https://askubuntu.com/questions/114759/warning-setlocale-lc-all-cannot-change-locale

bash: warning: setlocale: LC_ALL: cannot change locale
https://coder.tw/?p=7490

[Mac] SSH 到 Linux 機器時，出現 cannot change locale (UTF-8) 訊息
https://ephrain.net/mac-ssh-%E5%88%B0-linux-%E6%A9%9F%E5%99%A8%E6%99%82%EF%BC%8C%E5%87%BA%E7%8F%BE-cannot-change-locale-utf-8-%E8%A8%8A%E6%81%AF/

[Ubuntu] 如何設定語系locale
http://www.davidpai.tw/ubuntu/2011/ubuntu-set-locale/