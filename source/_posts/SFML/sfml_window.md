---
title: SFML 使用 - 視窗(Window)建立與 OpenGL
date: 2020-07-29 02:19:00
categories:
- [學習紀錄, SFML]
tags:
- SFML
- OpenGL
- 程式
- 筆記
- C++

---

<img src="https://i.imgur.com/lHiqhyi.png" width=500>

在 SFML 要建立一個視窗，要使用 `sf::RenderWindow` 並指定解析度(Resolution)、標題(Title)便可以建立視窗，開始處理事件(Event)循環，以及畫東西在螢幕上。

```cpp
sf::RenderWindow window(sf::VideoMode(1280, 720), "SFML Window");
```

`sf::RenderWindow` 的第三個參數可以指定視窗的 Style：

* `sf::Style::None`
    * 沒有標題欄，不能跟其他 style 混合
    * 適合拿來當啟動畫面(Splash screen)
* `sf::Style::Titlebar`
    * 有標題欄
* `sf::Style::Resize`
    * 可以拉伸視窗
* `sf::Style::Close`
    * 有關閉視窗按鈕
* `sf::Style::Fullscreen`
    * 全螢幕，有限制 `sf::VideoMode`
        * 用 [`sf::VideoMode::getFullscreenModes()`](https://www.sfml-dev.org/documentation/2.5.1/classsf_1_1VideoMode.php#a6815b9b3b35767d5b4563fbed4bfc67b) 查詢
* `sf::Style::Default`
    * 等於 `Titlebar | Resize | Close`

## 事件循環

使用者跟視窗互動會引發(Trigger)視窗事件(Event)，如果程式沒有處理事件的話，整個窗口就不會有反應，所以每個視窗都一定要有事件處理的邏輯。

```cpp=
#include <SFML/RenderWindow.hpp>

int main()
{
    sf::RenderWindow window(sf::VideoMode(800, 600), "My window");

    // run the program as long as the window is open
    while (window.isOpen())
    {
        // check all the window's events that were triggered since the last iteration of the loop
        sf::Event event;
        while (window.pollEvent(event))
        {
            // "close requested" event: we close the window
            if (event.type == sf::Event::Closed)
                window.close();
        }
    }
}
```

## 窗口操作

SFML 只提供一些基本的窗口操作

```cpp
// 設定視窗位置
window.setPosition(sf::Vector2i(10, 50));

// 顯示或隱藏視窗
window.setVisible(false);

// 更改大小
window.setSize(sf::Vector2u(640, 480));

// 設定標題
window.setTitle("SFML window");

// 查詢大小
sf::Vector2u size = window.getSize();
unsigned int width = size.x;
unsigned int height = size.y;

// 是否正使用
window.hasFocus() == true;
// 提示系統要求關注視窗
window.requestFocus(); 
```

* 滑鼠相關

```cpp
// 顯示或隱藏滑鼠游標
window.setMouseCursorVisible(true);

// 限制滑鼠移動範圍
window.setMouseCursorGrabbed(true);
```

* 查詢螢幕解析度

```cpp
sf::VideoMode v = sf::VideoMode::getDesktopMode();
// v.width, v.height
```

* fps 相關

```cpp
// 開啟垂直同步
window.setVerticalSyncEnabled(true);
// 設定最高 fps
window.setFramerateLimit(60);  // 使用不太準的 sf::Clock (+-10-15ms)
```

* 更改視窗成全螢幕模式

```cpp
window.create(sf::VideoMode(800, 600), "test", sf::Style::Fullscreen);
```

這裡只列出常用的，其他比如：設定 Icon、設定滑鼠游標圖片等，請參考 [Docs](https://www.sfml-dev.org/documentation/2.5.1/classsf_1_1RenderWindow.php)

SFML 支援多個建立窗口，但有一些限制：可以在不同的 thread，但獲取事件時一定要在窗口自己的 thread 上，建議的做法是用 main thread 管理窗口跟事件，然後其他例如：渲染、物理等，拿到其他 thread。

SFML 不像其他 GUI Library 提供許多窗口的功能，可以用 `window.getSystemHandle()` 來拿到底層的窗口 Handle，之後可以用 OS-Specific 的 function 做事

```cpp
sf::WindowHandle handle = window.getSystemHandle();
// Use handle
```

## OpenGL

SFML 建立的視窗支援使用 OpenGL 混用，假如說你的程式會用到 OpenGL 的話，那要在 `.cpp` 中加入：

```cpp
#include <SFML/OpenGL.hpp>
```

之後記得要 Link OpenGL 函式庫，否則可能會產生 Link error。

在建立視窗時可以指定 `sf::ContextSettings` 來設定 OpenGL 的參數。

```cpp
sf::ContextSettings settings;
settings.depthBits   = 24; // 深度
settings.stencilBits = 8;  // 模板
settings.antialiasingLevel = 4; // 反鋸齒
settings.majorVersion = 3; // 版本號 （第一個數字） 
settings.minorVersion = 0; // 版本號 （第二個數字）
sf::RenderWindow window(sf::VideoMode(1280, 720), "SFML window", settings);
```

一個簡單的視窗建立可能會長這樣：

```cpp=
#include <SFML/Graphics.hpp>

int main()
{
    sf::RenderWindow window(sf::VideoMode(1280, 720), "SFML window");
    window.setFramerateLimit(60);

    sf::Clock clk, imgui;
    bool running = true;
    while (running)
    {
        float dt = clk.restart().asSeconds();
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                running = false;
            else if(event.type == sf::Event::Resized)
                glViewport(0, 0, event.size.width, event.size.height);
        }

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Do OpenGL Things

        window.display();
    }
}
```

如果要混用 OpenGL 繪圖與 SFML 的繪圖 funciton 的話，則要多花心力在維護 OpenGL state 上： 在用 SFML 的繪圖 function 之前，必須先清掉 OpenGL 狀態，否則會炸裂。

```cpp
glDraw...

window.pushGLStates(); // Push OpenGL States

window.draw(...);

window.popGLStates();  // Pop OpenGL States

glDraw..
```

又因為 SFML 並沒有維護 OpenGL 3.x 以上的 state ，所以當你如果有使用如 VAO, VBO, EBO 時，記得要重設狀態

```cpp=
// 清掉 OpenGL 3.x 以上的狀態
glBindBuffer(GL_ARRAY_BUFFER, 0);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
glBindVertexArray(0);

window.pushGLStates();
window.resetGLStates();
    window.draw(sprite);
window.popGLStates();

// ...
```

## 參考

Using OpenGL in a SFML window
https://www.sfml-dev.org/tutorials/2.5/window-opengl.php

SFML GRAPHICS MODULE WITH OPENGL 3.3+
https://en.sfml-dev.org/forums/index.php?topic=20968.msg150056#msg150056

OPENGL WITH SFML (ASSUMED CONTEXT ISSUE)
https://en.sfml-dev.org/forums/index.php?topic=20979.0
