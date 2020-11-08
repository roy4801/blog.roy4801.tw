---
title: SFML 簡介及環境設置
date: 2020-07-14 02:57:00
categories:
- [學習紀錄, SFML]
tags:
- SFML
- 程式
- 筆記
- C++

---

**S**imple and **F**ase **M**edia **L**ibrary (SFML) 是一個由 C++ 寫成的跨平台(cross-platfrom)的用於遊戲、多媒體應用開發的 Library，有多個語言的綁定 (Binding) ，分成幾大模塊：系統、視窗、圖形、音訊跟網路。

![](https://upload.wikimedia.org/wikipedia/commons/b/bf/SFML2.svg)
https://github.com/SFML/SFML

* SFML 分成幾大模塊
    * `System` 一些基礎建設，例如：向量(vector)、字串、thread、timer
    * `Window` 管理視窗以及輸入（鍵盤、滑鼠、搖桿等）及 OpenGL
    * `Graphics` 硬體加速的 2D 圖形：sprite, text, shapes
    * `Audio` 音訊、錄音、[3D音效](https://zh.wikipedia.org/wiki/3D%E9%9F%B3%E6%95%88)
    * `Network` TDP 與 UDP socket 與 HTTP 跟 FTP

## Installation 環境設置

* 本人使用 msys2
    * 其他環境請參考：<https://www.sfml-dev.org/tutorials/2.5/#getting-started>

* 先安裝 msys2
    * https://hackmd.io/N8ILFLYTRKqMP9x5PxXiRw?view

![](https://i.imgur.com/XUjbJ5O.png)

* 更新完 msys2 之後
    * 開啟 `MSYS2 MinGW 32-bit`  (如上圖)
    * 安裝 sfml
        * `pacman -S mingw32/mingw-w64-i686-sfml`

* 使用範例編譯
    * [example.zip](https://drive.google.com/file/d/1C20ODFLfFbJh7J5SUAQKbyxb9CNTkNec/view?usp=sharing)

## Example 範例

```cpp=
#include <SFML/Audio.hpp>
#include <SFML/Graphics.hpp>
int main()
{
    // Create the main window
    sf::RenderWindow window(sf::VideoMode(800, 600), "SFML window");
    // Load a sprite to display
    sf::Texture texture;
    if (!texture.loadFromFile("cute_image.jpg"))
        return EXIT_FAILURE;
    sf::Sprite sprite(texture);
    // Create a graphical text to display
    sf::Font font;
    if (!font.loadFromFile("arial.ttf"))
        return EXIT_FAILURE;
    sf::Text text("Hello SFML", font, 50);
    // Load a music to play
    sf::Music music;
    if (!music.openFromFile("nice_music.ogg"))
        return EXIT_FAILURE;
    // Play the music
    music.play();
    // Start the game loop
    while (window.isOpen())
    {
        // Process events
        sf::Event event;
        while (window.pollEvent(event))
        {
            // Close window: exit
            if (event.type == sf::Event::Closed)
                window.close();
        }
        // Clear screen
        window.clear();
        // Draw the sprite
        window.draw(sprite);
        // Draw the string
        window.draw(text);
        // Update the window
        window.display();
    }
    return EXIT_SUCCESS;
}
```

## Useful Links 實用連結

* SFML Tutorials 教學文
https://www.sfml-dev.org/tutorials/2.5/

* SFML 官方論壇
https://en.sfml-dev.org/forums/index.php

* 善用 google hacking: `xxx site:https://en.sfml-dev.org/forums/index.php`

* SFML Docs 文檔
https://www.sfml-dev.org/documentation/2.5.1/

* Q: 不能搜尋？
    * A: 善用 google hacking: `xxx site:https://www.sfml-dev.org/documentation/2.5.1`