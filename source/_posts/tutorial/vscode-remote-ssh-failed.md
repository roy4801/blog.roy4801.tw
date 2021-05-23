---
title: Visual Studio Code Remote SSH 無法連線問題
date: 2021-05-24 03:48:01
categories:
  - [學習紀錄, 其他]
tags:
  - 教學
  - vscode

---

## 問題

最近在使用 vscode 並使用 [Remote SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) 透過 SSH 連線至伺服器做事時，遇到了無法連線的問題。

如圖所示，在嘗試連線時會卡在歡迎訊息然後出現 `Resolver error: Connecting with SSH timed out`

![](https://i.imgur.com/SMrBpRC.png)

## 解法

在設定加入

```json
"remote.SSH.useLocalServer": false
```

應可解決

## 參考

ssh -T timeouts with Remote - SSH.
https://github.com/microsoft/vscode-remote-release/issues/1721

why ssh connection timed out in vscode?
https://stackoverflow.com/questions/59978826/why-ssh-connection-timed-out-in-vscode

Can't connect with ssh: Terminating local server. Resolver error: Error: Connecting with SSH timed out
https://github.com/microsoft/vscode-remote-release/issues/3723
