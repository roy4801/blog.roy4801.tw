---
title: OpenGL 筆記 - 環境設定和簡介
date: 2020-06-29 02:10:45
categories:
- [學習紀錄, C/C++]
tags:
- OpenGL
- 程式
- 筆記
- 圖學

---

![](https://i.imgur.com/w8lbcXL.png)

這系列文是我在閱讀 [LearnOpenGL](https://learnopengl.com/) 之後的筆記

## 環境設定

> 建議參考原文的環境設定

* 我使用 msys2 + CMake
* 使用 SFML 建立 Window
    * 在 SFML 使用 OpenGL 要注意混用時要先 reset OpenGL state
    * SFML 並不會維護 OpenGL 3.x 以上的 state ，必須自己手動維護 e.g. VAO
    * [參考](https://www.sfml-dev.org/tutorials/2.5/window-opengl.php)

* [SFML + OpenGL helloworld](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/1.1.hello_window)

### glad

* 因為 OpenGL 的實作都是由顯卡生產商撰寫，所以大多都是在 Run-Time 才載入進程式中，所以在沒有 library 的輔助時，你的 code 會長這樣，非常的麻煩

```cpp
// Prototype
typedef void (*GL_GENBUFFERS) (GLsizei, GLuint*);
// Find the address
GL_GENBUFFERS glGenBuffers = (GL_GENBUFFERS)wglGetProcAddress("glGenBuffers");

GLuint buffer;
glGenBuffers(1, &buffer);
```

複雜的事情就會有人寫好 Library 來輔助，過去有 glew 而我們使用最新、最流行的 [glad](https://github.com/Dav1dde/glad)
它還有[網頁工具版](https://glad.dav1d.de/)

![glad](https://i.imgur.com/Buhnf01.png)

GLAD 可以指定 OpenGL 的版本、Extension，它可以生成一個加載器，可以加到你的專案裏頭即可。

如果不知道你的電腦可以支援的 OpenGL ，可以使用 [OpenGL Viewer](http://www.realtech-vr.com/home/glview) 查看
![opengl_viewer](https://i.imgur.com/IowvTRx.png)

## 前言

* OpenGL 規定了每個 function 如何執行、輸出值，但每個 function 的實作，並沒有規定: OpenGL 是個規範
    * 真正開發者用的 OpenGL 庫都是由顯卡生產商(Nvidia, AMD) 所實作的
    * 也因為如此，如果有 Bug 的話，通常更新顯卡驅動都能解決問題

* 核心模式(Core-profile)與立即渲染模式(Immediate mode)
    * 立即渲染模式(Immediate mode)
        * 早期 OpenGL
        * 容易理解、使用
        * 效率低、靈活性低
        * 已被廢棄 ＝ 不用學習了
    * 核心模式(Core-profile)
        * 主流
        * 靈活性高、效率高
        * 上手比較難

* 上面提到 OpenGL 實作都是由顯卡生產商進行實作的，而 OpenGL 支援擴展(Extension)，不同的生產商可能提供不同的擴展功能，當一個擴展很流行或非常有用時，他會成為 OpenGL 規範的一部分

* OpenGL 本質上是個狀態機(State Machine)，OpenGL 的狀態叫做 上下文(Context)
    * 改變狀態：設定參數、操作 buffer
    * 使用當前 Context 來渲染畫面

* 一個常見的 OpenGL 程式碼可能長這樣
    * 建立 object (拿到id)
    * 綁定到 Context 上
    * 設定選項
    * 綁定 0 代表改回默認

```cpp
// 建立 Object
unsigned int objectId = 0;
glGenObject(1, &objectId);
// 講 Object 綁定到 Context 上
glBindObject(GL_WINDOW_TARGET, objectId);
// 設定選項
glSetObjectOption(GL_WINDOW_TARGET, GL_OPTION_WINDOW_WIDTH, 800);
glSetObjectOption(GL_WINDOW_TARGET, GL_OPTION_WINDOW_HEIGHT, 600);
// 把 Context 設回預設
glBindObject(GL_WINDOW_TARGET, 0);
```

## Reference

LearnOpenGL
<https://learnopengl.com/>

LearnOpenGL CN
<https://learnopengl-cn.github.io/>

LearnOpenGL github repo
<https://github.com/JoeyDeVries/LearnOpenGL>
