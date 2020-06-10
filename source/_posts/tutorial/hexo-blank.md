---
title: hexo 產生空白的 HTML
date: 2020-05-17 20:21:45
categories:
  - [學習紀錄,其他]
tags:
  - 教學
  - hexo
  - node.js

---

## 問題

在最近更新 blog 時，寫好一篇文後發現，hexo 產生的 HTML 竟然是空白的。（push 上 Github Page 才發現）
順手做個紀錄

## 原因

node.js 版本(v14.0.0) 太高，降級至 13 或 12 即可解決

## brew 降級

以降級 `node` 為例

* 查詢 package 安裝腳本 URL
	* 之後步驟會用到

```bash
brew info node

...
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
...

```

![](https://i.imgur.com/Y8suv5o.png)

* 查詢歷史版本的安裝腳本
	* 複製該 commit hash

```bash
brew log node
```

![](https://i.imgur.com/H9SMy0r.png)


* 得到 該 commit 版本的檔案
	* 用 commit hash 取代剛剛 URL 的 master
	* 得到 `https://github.com/Homebrew/homebrew-core/blob/44c81305cf707d181a87086386ad2e63846cbe75/Formula/node.rb`
	* 點選 `Raw` 獲得 raw 版本的 URL

![](https://i.imgur.com/2fb0WYy.png)

* 解除安裝新版的 package ，並安裝舊版

```bash
brew uninstall --ignore-dependencies node
brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/44c81305cf707d181a87086386ad2e63846cbe75/Formula/node.rb
```

* 鎖定該 package 的版本，直到可以更新上去再解除

```bash
brew pin node
```

## 參考

hexo generates empty files #4267
https://github.com/hexojs/hexo/issues/4267#issuecomment-619394907

hexo generates empty files #4268
https://github.com/hexojs/hexo/issues/4268

Warning: Accessing non-existent property 'lineno' of module exports inside circular dependency #4257
https://github.com/hexojs/hexo/issues/4257

Downgrade any Homebrew package easily
https://dae.me/blog/2516/downgrade-any-homebrew-package-easily/
