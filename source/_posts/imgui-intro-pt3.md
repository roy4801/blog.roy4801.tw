---
title: dear imgui 使用 - 視窗、文字及按鈕
date: 2020-03-28 17:32:36
categories:
- [學習紀錄, C/C++]
tags:
- C++
- 程式
- 教學
- C++ Library
- imgui

---

## 建立視窗 Window

```cpp=
ImGui::Begin("Window Title");
// .. window content code here
ImGui::End();
```
![](https://i.imgur.com/6zd5twX.gif)

## 顯示文字 Text

* Prototype
```cpp=
void Text(const char* fmt, ...)
```

* `fmt`

    * 格式字串

```cpp=
ImGui::Text("This is a text");
ImGui::Text("Hello, world %d", 123);
```

![](https://i.imgur.com/tfLFDJE.png)

所有的 `TextXXX()` 系列的 function 皆有 `va_list` 版本 `TextXXXV()`

### 有顏色的字 TextColored

```cpp=
ImGui::TextColored(ImVec4(255, 0, 0, 255), "red");
ImGui::TextColored(ImVec4(0, 255, 0, 255), "blue");
ImGui::TextColored(ImVec4(0, 0, 255, 255), "green");
ImGui::TextColored(ImVec4(128, 128, 128, 255), "grey");
ImGui::TextColored(ImVec4(255, 255, 255, 0), "trans");
```

![](https://i.imgur.com/f5ddAe1.png)

### TextDisabled

```cpp
ImGui::Text("Enabled text");
ImGui::TextDisabled("Disabled text");
```

![](https://i.imgur.com/WoL9lBA.png)

### 縮放文字 TextWrapped

`TextWrapped` 會跟隨著視窗的縮放

```cpp
ImGui::Text("Normal texts");
ImGui::NewLine();
ImGui::TextWrapped("wrapped texts");
```

![](https://i.imgur.com/biwfDC9.gif)

### 標籤文字 LabelText

```cpp
ImGui::LabelText("t1", "texts in label1");
ImGui::LabelText("t2", "texts in label2");
ImGui::LabelText("t2", "blah blah");
ImGui::LabelText("t1", "123123");
```

![](https://i.imgur.com/hJsbPAL.png)

<details>
<summary>Pic</summary>

![](https://i.imgur.com/Je13T7s.png)

</details>

### 項目符號文字 BulletText

```cpp
ImGui::BulletText("texts in label1");
ImGui::BulletText("texts in label2");
ImGui::BulletText("blah blah");
ImGui::BulletText("123123");
```

![](https://i.imgur.com/4fALPgn.png)

### 工具提示 Tooltip

將滑鼠擺在該元素上，顯示工具提示

```cpp
ImGui::Text("Hover over me");
if(ImGui::IsItemHovered())
    ImGui::SetTooltip("I am a tooltip");
```

![](https://i.imgur.com/MwVNreg.png)

> 截圖沒辦法擷取滑鼠，但此圖滑鼠確實擺在文字上方

* tooltip 裏頭想裝其他 widget?
    * 用 `BeginTooltip()`/`EndTooltip()`

```cpp
ImGui::Text("Hover over me");
if(ImGui::IsItemHovered())
{
    ImGui::BeginTooltip();
    ImGui::Text("I am a fancy tooltip");
    static float arr[] = {0.6f, 0.1f, 1.0f, 0.5f, 0.92f, 0.1f, 0.2f};
    ImGui::PlotLines("Curve", arr, IM_ARRAYSIZE(arr));
    ImGui::EndTooltip();
}
```

![](https://i.imgur.com/zrSdAwu.png)

### 例子：HelpMarker

將滑鼠放在 `(?)` 文字上方可以顯示提示(Tooltip)

```cpp
void HelpMarker(const char *desc)
{
    ImGui::TextDisabled("(?)");
    if(ImGui::IsItemHovered())
    {
        ImGui::BeginTooltip();
        ImGui::PushTextWrapPos(ImGui::GetFontSize() * 35.0f);
        ImGui::TextUnformatted(desc);
        ImGui::PopTextWrapPos();
        ImGUi::EndTooltip();
    }
}
ImGui::Text("Here is a sample text"); ImGui::SameLine();
HelpMarker("Need some help?");
```

![](https://i.imgur.com/QWhyX91.png)


## 按鈕 Buttons

* Prototype
```cpp
bool Button(const char* label, const ImVec2& size = ImVec2(0,0)); 
```

```cpp=
if(ImGui::Button("Button"))
{
    // when the button is pressed
}
```

![](https://i.imgur.com/JnQTAp9.gif)


* e.g. 1
    ```cpp=
    static int clicked = 0;
    if(ImGui::Button("Press me"))
        clicked++;
    if(clicked)
    {
        ImGui::SameLine();
        ImGui::Text("You pressed for %d times\n", clicked);
    }
    ```
    ![](https://i.imgur.com/lrUCywn.gif)

* 按鈕可以設定大小(第二個參數)

```cpp
ImGui::Button("tets", ImVec2(100, 100));
```
![](https://i.imgur.com/gDEQwLk.png)

### 換顏色

Button 可以用 `PushStyleColor` 換顏色

```cpp=
ImGui::Begin("Sample Window");

ImGui::PushStyleColor(ImGuiCol_Button, (ImVec4)ImColor::HSV(0.0f, 0.6f, 0.6f));
ImGui::PushStyleColor(ImGuiCol_ButtonHovered, (ImVec4)ImColor::HSV(0.0f, 0.7f, 0.7f));
ImGui::PushStyleColor(ImGuiCol_ButtonActive, (ImVec4)ImColor::HSV(0.0f, 0.8f, 0.8f));

ImGui::Button("Red");

ImGui::PopStyleColor(3);
```

![](https://i.imgur.com/MFLHVZQ.png)

> [RGB 轉換 HSV 及 HSL](https://www.ginifab.com.tw/tools/colors/rgb_to_hsv_hsl.html)

### 小按鈕 SmallButton

沒有 `FramePadding` 的按鈕

```cpp
ImGui::Button("A normal btn");
ImGui::SmallButton("A small btn");
ImGui::NewLine();
ImGui::Text("This is a text "); ImGui::SameLine();
ImGui::SmallButton("Press me"); ImGui::SameLine();
ImGui::Text("another line");
```

![](https://i.imgur.com/azaLNiY.png)

### InvisibleButton

隱形的按鈕，一個按鈕該有的行為它都有，通常會搭配 `IsItemActive()` 或 `IsItemHover()` 等 Query Status 的函式

> 參考 Demo Window 的 Widgets->Querying Status

```cpp=
if(ImGui::InvisibleButton("1", ImVec2(100, 100)))
{
    std::cout << "Pressed" << '\n';
}

isActive = ImGui::IsItemActive();
isHover = ImGui::IsItemHovered();

ImGui::Text("Active: %d Hover: %d", isActive, isHover);
```

![](https://i.imgur.com/yYK9Lo0.gif)

### 箭頭按鈕 ArrowButton

![](https://i.imgur.com/jfZnHYr.png)

正方形的按鈕，上頭的圖案是箭頭，通常用在要切換的地方

```cpp
ImGui::ArrowButton("##Left", ImGuiDir_Left);
ImGui::ArrowButton("##Right", ImGuiDir_Right);
```

* e.g.

```cpp
static int counter = 0;
float spacing = ImGui::GetStyle().ItemInnerSpacing.x;
//
ImGui::PushButtonRepeat(true); // 開啟 repeat
if (ImGui::ArrowButton("##left", ImGuiDir_Left))
    counter--;
ImGui::SameLine(0.0f, spacing); // 使用 ItemInnerSpacing 作為間距
if (ImGui::ArrowButton("##right", ImGuiDir_Right))
    counter++;
ImGui::PopButtonRepeat(); // 關閉 repeat
ImGui::SameLine();
ImGui::Text("%d", counter);
```

![](https://i.imgur.com/URf28Rn.gif)

## 文字與按鈕對齊

直接使用 `SameLine()` 文字與元件之間仍然會有高度差，而 `AlignTextToFramePadding()` 則可以解決這件事情

```cpp=
ImGui::Text("text 1"); ImGui::SameLine();
ImGui::Button("btn1");

ImGui::AlignTextToFramePadding();

ImGui::Text("text 2"); ImGui::SameLine();
ImGui::Button("btn2");
```

![](https://i.imgur.com/9sQ7gzj.png)