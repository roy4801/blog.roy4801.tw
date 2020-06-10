---
title: 在macos 如何build zbarimg
date: 2018-08-04 16:57:45
categories:
- [學習紀錄, 其他]
tags:
- ctf tools
- 程式
- 教學

---

## 前言
在打CTF時，在`Misc`遇到有用[QRcode](https://en.wikipedia.org/wiki/QR_code) encode的flag，雖然有線上的工具，但身為~~programmer~~就要用command-line，所以就找到了一個cli的qrcode-decoder，但是官方並沒有提供macos的binary而brew也沒有，以至於就得自己build了。

macos版本：`OS X 10.11.6 El Capitan`
## Build

1. 下載`zbarimg` source code，並解壓
http://zbar.sourceforge.net/download.html

2. 在資料夾下開起terminal
```
$ ./configure --disable-video --without-python --without-gtk --without-qt
```

3. 接著開始build並安裝
```
$ make
$ make install
```

### 問題：`Can't find MagickWand.h. `

zbarimg需要依賴imgagemagick
而在`brew`不加後綴的的是7.*版，而zbarimg使用6.*版，所以導致錯誤。
```
$ brew unlink imagemagick
$ brew install imagemagick@6 && brew link imagemagick@6 --force
```
> Imagemagick-7
> `/usr/local/Cellar/imagemagick/7.0.8-8/include/ImageMagick-7/MagickWand/MagickWand.h`
> Imagemagick-6
> `/usr/local/Cellar/imagemagick@6/6.9.10-8/include/ImageMagick-6/wand/MagickWand.h`

## 參考

QR decoder that works on mac?
https://stackoverflow.com/questions/210470/qr-decoder-that-works-on-mac

zbar src
http://zbar.sourceforge.net/download.html

RMagick installation: Can't find MagickWand.h
https://stackoverflow.com/questions/39494672/rmagick-installation-cant-find-magickwand-h