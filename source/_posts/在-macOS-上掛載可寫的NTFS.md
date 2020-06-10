---
title: 在 macOS 上掛載可寫的NTFS
date: 2019-03-31 22:43:36
categories:
- [學習紀錄, macOS]
tags:
- 教學
- 檔案系統
---

macOS 預設是無法寫入NTFS檔案系統的硬碟的（只可讀），如果想要寫入NTFS檔案系統的硬碟就必須使用其他工具。

# osxfuse

`osxfuse` 使得macOS可以使用第三方的檔案系統

* [官網](https://osxfuse.github.io/)
* [Github](https://github.com/osxfuse/osxfuse)

## 到官網下載`osxfuse-3.8.3.dmg`

<img src="https://i.imgur.com/4yKutPy.png" width="500" />
<img src="https://i.imgur.com/x3QQKxt.png" width="500" />
    
# ntfs-3g

`ntfs-3g`是個開源、跨平台的`NTFS`實作，在macOS上必須先安裝`osxfuxe`才可使用`ntfs-3g`掛載。

## 安裝

使用 homebrew 安裝 ntfs-3g

```
$ brew install ntfs-3g
```

安裝完成後便可以掛載可寫的NTFS檔案系統

## 掛載

### 手動

* 在終端輸入`diskutil list`，查詢想掛載的硬碟名稱

<img src="https://i.imgur.com/oryxROf.png" width="500" />

* 使用`ntfs-3g`掛載
```
$ sudo mkdir /Volumes/<硬碟名稱>
$ sudo /usr/local/bin/ntfs-3g /dev/disk2s1 /Volumes/<硬碟名稱> -olocal -oallow_other
```

### 自動

即使安裝完`ntfs-3g`，macOS預設的掛載方式還是只可讀，每一次都要打指令也很麻煩，解決方法是：把macOS預設掛載NTFS的工具替換掉即可。

```
$ sudo mv "/Volumes/Macintosh HD/sbin/mount_ntfs" "/Volumes/Macintosh HD/sbin/mount_ntfs.orig"
$ sudo ln -s /usr/local/sbin/mount_ntfs "/Volumes/Macintosh HD/sbin/mount_ntfs"
```

> 在`OS X El Capitan`之後的版本，由於[`System Integrity Protection (SIP)`](https://support.apple.com/zh-tw/HT204899)的保護機制，導致無法更動`/sbin/`目錄底下的東西，必須關閉SIP才可替換
> 

# 參考

ntfs-3g
https://github.com/osxfuse/osxfuse/wiki/NTFS-3G

MAC OS X 讀／寫 NTFS 格式硬碟
http://max-everyday.com/2017/08/mac-os-x-ntfs/