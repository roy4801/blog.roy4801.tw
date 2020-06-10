---
title: dear imgui 介紹 - 輕量級的 GUI Library
date: 2020-03-24 04:18:45
categories:
- [學習紀錄, C/C++]
tags:
- C++
- 程式
- 教學
- C++ Library
- imgui

---

![](https://i.imgur.com/irlVLsy.png)

[Dear Imgui](https://github.com/ocornut/imgui) 是個輕量、快速的 imtermediate GUI 讓開發者可以非常快速的建立 GUI，被遊戲開發(gamedev)、編輯器(editor)、除錯器(debugger)開發者等使用。

使用 imgui 的 code 非常簡單且易於修改，imgui 本身是無狀態的，與一般的 retained mode GUI 相反，imgui 不用儲存 GUI 物件或是註冊回調(Callback)

![](https://i.imgur.com/YFSmVdi.gif)
![](https://i.imgur.com/cz0E7Wt.gif)
![](https://i.imgur.com/6zdOsUX.png)
![](https://i.imgur.com/KeFnXt1.gif)


## Immediate mode GUI 概念

Immediate mode GUI 跟一般 Retained mode 不同的是，其將資料獨立於 GUI 元件外，在每幀都會根據資料重畫窗口部件，不用考慮 GUI 目前的狀態，大大減少元件增加時，個個元件間相互影響的複雜度上升(retained mode)，但也是由於每次畫面所有元件都要重畫，所以效能會比 Retain mode 差。

如何畫出一個按鈕：
```cpp=
if (ImGui::Button("Some Button")) {
    ... // code which will be called on button pressed
}
```

* dear imgui 的優點
    * 快速及輕量
    * 沒有動態分配(dynamic allocation)
    * 容易移植(portable)
    * 容易擴展(expandable)

## 系列文

* [安裝/使用 imgui-SFML](/2020/03/25/imgui-intro-pt2/)
* [視窗、文字及按鈕](/2020/03/28/imgui-intro-pt3/)
* [單選、複選按鈕](/2020/03/28/imgui-intro-pt4/)
* [拉桿 Slider](/2020/04/16/imgui-intro-pt5/)

## Reference

IMMEDIATE-MODE GRAPHICAL USER INTERFACES (2005)
https://caseymuratori.com/blog_0001

Immediate Mode Graphical User Interfaces
http://www.cse.chalmers.se/edu/year/2011/course/TDA361/Advanced%20Computer%20Graphics/IMGUI.pdf

https://tw.twincl.com/javascript/reactjs/*631q
