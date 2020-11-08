---
title: SFML 使用 - Event 視窗事件
date: 2020-07-30 12:53:00
categories:
- [學習紀錄, SFML]
tags:
- SFML
- 程式
- 筆記
- C++

---

要怎麼跟視窗互動呢？使用者在視窗上互動時，SFML 會產生事件(Event)，進而接收窗口的事件，並針對發生的事件（例如：滑鼠移動、點擊，鍵盤點擊等）做相對應的處理。

```cpp
sf::Event event;
while (window.pollEvent(event))
{
    switch (event.type)
    {
        case sf::Event::Closed:
            window.close();
            break;

        case sf::Event::KeyPressed:
            // ...
            break;

        default:
            break;
    }
}
```

SFML 總共有以下這幾種事件：

* `sf::Event::Closed`
    * 視窗關閉

* `sf::Event::LostFocus`, `sf::Event::GainedFocus`
    * 選擇/隱藏 視窗

* `sf::Event::Resized`
    * 視窗大小調整
    * 資料 `event.size`
        * `event.size.width` 寬
        * `event.size.height` 高

* `sf::Event::TextEntered`
    * 文字輸入

```cpp
if (event.type == sf::Event::TextEntered)
{
    if (event.text.unicode < 128)
        std::cout << "ASCII character typed: " << static_cast<char>(event.text.unicode) << std::endl;
}
```

* `sf::Event::KeyPressed`, `sf::Event::KeyReleased`
    * 鍵盤按下/放開按鍵
    * 會有延遲（跟在文字編輯器上打字一樣），如果不希望有延遲請用 Real-time Input
    * 可以把關閉重複的事件（當按鍵持續按下）
        * `window.setKeyRepeatEnabled(false)` 

```cpp
if (event.type == sf::Event::KeyPressed)
{
    if (event.key.code == sf::Keyboard::Escape)
    {
        std::cout << "the escape key was pressed" << std::endl;
        std::cout << "control:" << event.key.control << std::endl;
        std::cout << "alt:" << event.key.alt << std::endl;
        std::cout << "shift:" << event.key.shift << std::endl;
        std::cout << "system:" << event.key.system << std::endl;
    }
}
```

* `sf::Event::MouseWheelScrolled`
    * 滾動滑鼠滾輪
    * 資料： `event.mouseWheelScroll`
        * `wheel` 哪種滾輪
            * `sf::Mouse::Wheel::VerticalWheel`
            * `sf::Mouse::Wheel::HorizontalWheel`
        * `delta` 位移量 （正代表上、左，負相反）
        * `x`, `y` 座標

```cpp
if (event.type == sf::Event::MouseWheelScrolled)
{
    if (event.mouseWheelScroll.wheel == sf::Mouse::VerticalWheel)
        std::cout << "wheel type: vertical" << std::endl;
    else if (event.mouseWheelScroll.wheel == sf::Mouse::HorizontalWheel)
        std::cout << "wheel type: horizontal" << std::endl;
    else
        std::cout << "wheel type: unknown" << std::endl;
    std::cout << "wheel movement: " << event.mouseWheelScroll.delta << std::endl;
    std::cout << "mouse x: " << event.mouseWheelScroll.x << std::endl;
    std::cout << "mouse y: " << event.mouseWheelScroll.y << std::endl;
}
```

* `sf::Event::MouseButtonPressed`, `sf::Event::MouseButtonReleased`
    * 滑鼠按鍵
    * 資料：`event.mouseButton`
        * `button` 按鍵
        * `x`, `y` 座標

```cpp
if (event.type == sf::Event::MouseButtonPressed)
{
    if (event.mouseButton.button == sf::Mouse::Right)
    {
        std::cout << "the right button was pressed" << std::endl;
        std::cout << "mouse x: " << event.mouseButton.x << std::endl;
        std::cout << "mouse y: " << event.mouseButton.y << std::endl;
    }
}
```

* `sf::Event::MouseMoved`
    * 滑鼠移動
    * 只有在視窗內才會產生此事件

```cpp
if (event.type == sf::Event::MouseMoved)
{
    std::cout << "new mouse x: " << event.mouseMove.x << std::endl;
    std::cout << "new mouse y: " << event.mouseMove.y << std::endl;
}
```

* `sf::Event::MouseEntered`, `sf::Event::MouseMouseLeft`
    * 滑鼠進入視窗、離開視窗

* 此外還有跟搖桿有關的事件，但這裡省略

## 參考

SFML2.5 Tutorial Events explained
https://www.sfml-dev.org/tutorials/2.5/window-events.php

