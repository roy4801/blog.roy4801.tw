---
title: dear imgui 使用 - 拉桿 Slider
date: 2020-04-16 01:01:48
categories:
- [學習紀錄, C/C++]
tags:
- C++
- 程式
- 教學
- C++ Library
- imgui

---

![](https://i.imgur.com/0VGhoZw.png)

https://github.com/ocornut/imgui/blob/master/imgui.h#L479

### SliderFloat / SliderInt

```cpp=
static float X = 0.f;
static float Y = 0.f;
static int Radius = 0;
ImGui::SliderFloat("X",&X,0.f,1080.f);
ImGui::SliderFloat("Y",&Y,0.f,720.f);
ImGui::SliderInt("Size",&Radius,0,100);
```

![](https://i.imgur.com/hLOXOVw.png)

* e.g.
    * 將拉桿拉出的值用在 SFML 上

```cpp=
sf::CircleShape circle;
circle.setFillColor(sf::Color(255, 255, 255));
circle.setPosition(X-Radius,Y-Radius);
circle.setRadius(Radius);
```

![](https://i.imgur.com/zHbykRo.gif)

### SliderXXX1/2/3/4

![](https://i.imgur.com/JxhQmWI.png)

```cpp
// Float
bool SliderFloat(const char* label, float* v, float v_min, float v_max, const char* format = "%.3f", float power = 1.0f);
bool SliderFloat2(const char* label, float v[2], float v_min, float v_max, const char* format = "%.3f", float power = 1.0f);
bool SliderFloat3(const char* label, float v[3], float v_min, float v_max, const char* format = "%.3f", float power = 1.0f);
bool SliderFloat4(const char* label, float v[4], float v_min, float v_max, const char* format = "%.3f", float power = 1.0f);
// Int
bool SliderInt(const char* label, int* v, int v_min, int v_max, const char* format = "%d");
bool SliderInt2(const char* label, int v[2], int v_min, int v_max, const char* format = "%d");
bool SliderInt3(const char* label, int v[3], int v_min, int v_max, const char* format = "%d");
bool SliderInt4(const char* label, int v[4], int v_min, int v_max, const char* format = "%d");
```

Slider 系列的 widget 有複數個 slider 的版本，命名規則都是 `SliderXXX` 加上數字
例如: `SliderFloat2()` 代表兩個，要注意傳入的參數與 `SliderFloat()` 不同

e.g.

```cpp
ImGui::SliderInt("SliderInt 1", &a, 0.f, 10.f);   // [0, 10]
ImGui::SliderInt2("SliderInt 2", b, -10.f, 10.f); // [-10, 10]
ImGui::SliderInt3("SliderInt 3", c, -10.f, 10.f);
ImGui::SliderInt4("SliderInt 4", d, -10.f, 10.f);
```
