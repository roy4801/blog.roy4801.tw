---
title: tmux 基本使用
date: 2018/08/25 20:45:19
categories:
- [學習紀錄, Linux]
tags:
- Linux
- 教學
---
## tmux 基本使用

### Terminal MUltipleXer

* 名稱:`terminal`的多工器

* 在一個terminal視窗下開啟多個視窗或是區塊(pane)，並且可以快速地切換不同的tmux視窗，且**與unix工具契合**，是個**提高生產力**的工具。

> 就像sublime的group
> 或是iTerm的tab跟split
> [name=roy4801]

![](https://www.hamvocke.com/assets/img/uploads/tmux.png)
> 使用中的tmux

### 安裝

* macos
```
$ brew install tmux
```

* msys2
```
$ pacman -S tmux
```

* apt
```
$ sudo apt install tmux
```

安裝完成後到家目錄下建立`.tmux.conf`設定檔
```
$ touch ~/.tmux.conf
```

[設定檔範例](https://pastebin.com/bM01dyJa)
> 設定檔範例[取自Mr.opengate](http://mropengate.blogspot.com/2017/12/tmux.html)

### 基本使用


#### 在開始使用之前，要知道一些tmux的概念:
* 會話(`Session`) : 視窗的集合。
* 視窗(`Window`)  : 覆蓋整個terminal的視窗。
* 區塊(`Pane`)    : 執行程式的地方。

![](https://3.bp.blogspot.com/-VWISLRT_Ppw/WjuPq-03itI/AAAAAAABW5g/YOnQ9zNxCnkhMaALcWucsVhAd-srLsoRgCLcBGAs/s1600/tmux-concept.png)

#### 開始使用

```
$ tmux
```

#### 按鍵說明
* 在`tmux`中，快捷鍵都是要先按`<prefix key> + 其他按鍵`
`tmux`預設是`ctrl + b`，但剛剛的`.tmux.conf`把`<prefix key>`改成了`Ctrl + a`
    ![](https://imgur.com/BTvPZpp.png)

---
##### 視窗(Window)

| 快捷鍵 | 說明 |
| -------- | -------- |
| `<prefix> c`   | 開新視窗   |
| `<prefix> &`     | 關閉視窗 |
| `<prefix> 0~9`   | 切換至指定視窗 |
| `<prefix> n`     | 切換到下一個視窗 (next) |
| `<prefix> p`     | 切換到上一個視窗 (previous) |
| `<prefix> f`     | 找尋指定 pattern 並跳到該視窗 |
| `<prefix> ,`     | 命名視窗 |
    
---
##### 區塊(Pane)

| 快捷鍵 | 說明|
| -------- | -------- |
| <code><prefix\> &#124;</code>   | 水平分割視窗 |
| `<prefix> -`     |垂直分割視窗 |
| `<prefix> 方向鍵`   |  分割視窗大小調整 |
| `<prefix> h,j,k,l (vim 方向鍵)` |    切換游標所在區塊 |
| `<prefix> space`   |  重新佈局分割視窗，內建多種佈局。 |
| `<prefix> x`    | 關閉當前面板 |
| `<prefix> q`    | 顯示面板編號 |
| `<prefix> {`    | 交換面板位置（向前） |
| `<prefix> }`    | 交換面板位置（向後） |

---
##### 操作tmux
	
| 快捷鍵 | 說明|
| -------- | -------- |
|`<prefix> d` |  將目前的 session 放到背景執行 (detach) |
|`<prefix> s` |  切換 session |
|`<prefix> [` |  進入複製模式 |
|`<prefix> :` |  進入命令模式 |
|`<prefix> ?` |  查詢快捷鍵 |
    
---
##### 指令
在`<prefix> :`中輸入或是在shell中輸入都可

| 快捷鍵 | 說明|
| -------- | -------- |
| `tmux`    |  啟動 |
| `tmux ls`|      列出所有 session |
| `tmux detach`|      背景執行 |
| `tmux attach -t [num]`|     回到第 [num] 號 session |
| `tmux kill-session -t [num]` |    關閉第 [num] 號 session |
| `tmux kill-session -a`  |   關閉除了自己的所有 session |


## 參考

作弊紙
http://tmuxcheatsheet.com/

終端機管理工具：tmux
http://mropengate.blogspot.com/2017/12/tmux.html

A Quick and Easy Guide to tmux
https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/