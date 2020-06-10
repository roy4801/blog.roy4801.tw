---
title: dear imgui 使用 - 單選、複選按鈕
date: 2020-03-29 13:30:28
categories:
- [學習紀錄, C/C++]
tags:
- C++
- 程式
- 教學
- C++ Library
- imgui

---

## 複選框 Checkbox

![](https://i.imgur.com/f9JWE2i.gif)

* Prototype
```cpp
bool Checkbox(const char* label, bool* v);
// label: 名稱
// v    : 是否已經勾選
```

* 回傳 bool
    * 當 checkbox 正被選取/取消勾選時為 `true`
    * 其餘回傳 `false`

* e.g.

```cpp=
static bool chk = false;
if(ImGui::Checkbox("test", &chk))
    std::cout << "changed" << '\n';
if(chk)
    ImGui::Text("the box has been checked");
```

![](https://i.imgur.com/yNpRn0Y.png)
![](https://i.imgur.com/4scz0nA.gif)

## 單選按鈕 Radio Button

![](https://i.imgur.com/fGH7AkZ.png)

* Prototype
    ```cpp
    bool RadioButton(const char* label, int* v, int v_button);
    // label    : 名稱
    // *v       : 指向儲存選項的 int pointer
    // v_button : 該 radio button 所代表的數字
    ```

* example
```cpp
static int select = -1;
ImGui::RadioButton("Zero", &select, 0); ImGui::SameLine();
ImGui::RadioButton("One", &select, 1); ImGui::SameLine();
ImGui::RadioButton("Two", &select, 2);

if(select >= 0)
{
    ImGui::Text("You Select %d\n", select);
}
```

![](https://i.imgur.com/nkXczwK.gif)

