---
title: OpenGL 筆記 - Camera
date: 2020-07-17 16:50:00
categories:
- [學習紀錄, OpenGL]
tags:
- OpenGL
- 程式
- 筆記
- 圖學
- Camera

---

OpenGL 中模擬相機的方法是，把場景(整個世界)照相機想移動的相反方向移動，來模擬出相機的感覺。

## View(Camera) Space

![](https://i.imgur.com/tUknQue.png)

View Space 是指把相機當作原點的座標，一個相機可以用以下三個東西定義出來:

* 相機(Camera)
    * 位置
    * 觀察的方向
    * 相機頭頂的方向向量

第三個軸可以用外積求出，於是我們定義出了一個以相機為原點的座標系，接下來就是要構造 View Matrix 來把世界座標轉換過去。

* 位置

```cpp
glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, 3.0f);
```

* 觀察的方向

```cpp
glm::vec3 cameraTarget = glm::vec3(0.0f, 0.0f, 0.0f);
glm::vec3 cameraDirection = glm::normalize(cameraPos - cameraTarget);
// 這裡其實是反向(往相機插的向量) i.e. 圖 2 的藍色向量
// 也就是 View Space 的 z 向量
```

* 右向量(對於相機)
    * 這裡會用世界的 $y$ 軸向量(向上)跟 觀察方向做外積
    * 拿到的向量會朝向 View Space 的 $+x$ ，也就是相機的右邊

```cpp
glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f);
glm::vec3 cameraRight = glm::normalize(glm::cross(up, cameraDirection));
```

* 上向量(對於相機)
    * 我們已經有 View Space 的 $x$ 軸和 $z$ 軸的向量

```cpp
glm::vec3 cameraUp = glm::cross(cameraDirection, cameraRight);
```

這三個向量構成了 View Space。

* 為什麼要世界的上向量
    * 先用外積求出 View Space 的右向量(Right Vector)
    * 再算出 View Space 之上向量
    * https://stackoverflow.com/questions/5717654/glulookat-explanation
    * https://www.scratchapixel.com/lessons/mathematics-physics-for-computer-graphics/lookat-function

上面的數學知識是: [Gram-Schmidt process](https://en.wikipedia.org/wiki/Gram%E2%80%93Schmidt_process)

### Look At 矩陣

$$
LookAt = \begin{bmatrix} \color{red}{R_x} & \color{red}{R_y} & \color{red}{R_z} & 0 \\\\ \color{green}{U_x} & \color{green}{U_y} & \color{green}{U_z} & 0 \\\\ \color{blue}{D_x} & \color{blue}{D_y} & \color{blue}{D_z} & 0 \\\\ 0 & 0 & 0  & 1 \end{bmatrix} * \begin{bmatrix} 1 & 0 & 0 & -\color{purple}{P_x} \\\\ 0 & 1 & 0 & -\color{purple}{P_y} \\\\ 0 & 0 & 1 & -\color{purple}{P_z} \\\\ 0 & 0 & 0  & 1 \end{bmatrix}
$$

$\color{Red}{R}$ 是右向量、$\color{Green}{U}$是上向量、$\color{Blue}{D}$是方向向量，$\color{purple}{P}$ 是相機位置，注意位移是相反方向，是因為前面提到我們希望將世界往相機的相反方向移動(因為 OpenGL 的相機在 $(0, 0, 0)$)

* GLM 提供了直接產生 Look At Matrix 的實用功能，只要提供相機位置、觀察目標、跟世界空間的上向量
    * [glm::lookAt(eye, center, up)](https://glm.g-truc.net/0.9.9/api/a00668.html#gaa64aa951a0e99136bba9008d2b59c78e)

```cpp
glm::mat4 view;
view = glm::lookAt(
    glm::vec3(0.0f, 0.0f, 3.0f),  // 相機位置
    glm::vec3(0.0f, 0.0f, 0.0f),  // 觀察目標
    glm::vec3(0.0f, 1.0f, 0.0f)   // 上向量
);
```

* [7.1.camera_circle](https://github.com/rishteam/OpenGL_learning/blob/master/LearnOpenGL/src/1.getting_started/7.1.camera_circle/main.cpp)
    * 這個範例示範了，把 Camera 繞 $x-z$ 平面旋轉

![](https://i.imgur.com/SmEhgiZ.gif)

## 自由移動

上面只示範了旋轉，如果能自由移動的話會更有趣，但是我們要改一下 Camera 的實作

```cpp
glm::vec3 cameraPos   = glm::vec3(0.0f, 0.0f,  3.0f);
glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
glm::vec3 cameraUp    = glm::vec3(0.0f, 1.0f,  0.0f);
glm::vec3 cameraRight = glm::normalize(glm::cross(cameraFront, cameraUp));
```

`lookAt` 變成了:

```cpp
view = glm::lookAt(cameraPos, cameraPos+cameraFront, cameraUp);
```

接下來新增移動功能

```cpp
if(sf::Keyboard::isKeyPressed(sf::Keyboard::W))
    cameraPos += cameraSpeed * cameraFront;
else if(sf::Keyboard::isKeyPressed(sf::Keyboard::S))
    cameraPos -= cameraSpeed * cameraFront;
//
if(sf::Keyboard::isKeyPressed(sf::Keyboard::A))
    cameraPos -= cameraSpeed * cameraRight;
else if(sf::Keyboard::isKeyPressed(sf::Keyboard::D))
    cameraPos += cameraSpeed * cameraRight;
//
if (sf::Keyboard::isKeyPressed(sf::Keyboard::Space))
    cameraPos += cameraSpeed * cameraUp;
else if (sf::Keyboard::isKeyPressed(sf::Keyboard::LControl))
    cameraPos -= cameraSpeed * cameraUp;
```

當我們按下 WASD 時，Camera 就會在遊戲世界中移動，按 Shift 時 Camera 會加速

* [7.2.camera_move](https://github.com/rishteam/OpenGL_learning/blob/master/LearnOpenGL/src/1.getting_started/7.2.camera_move/main.cpp)

![](https://imgur.com/qaapYwr.gif)

除了按鍵移動之外，我們還改了移動速度的 code，根據處理器不同，每個 loop 的時間會不同，通常都會用 delta time 去乘上某個東西的時間變化量(e.g. 速度)，來更新當前的狀態。

```cpp
if(sf::Keyboard::isKeyPressed(sf::Keyboard::LShift))
    cameraSpeed = dt * 5;
else
    cameraSpeed = dt * 3;
```

## 視角移動
### 歐拉角

歐拉角(Euler Angle)可以表示空間中三軸的旋轉。俯仰角(Pitch)、偏擺角(Yaw)和翻滾角(Roll)

![](https://i.imgur.com/UsGZvz5.png)

在傳統 FPS 中不會有 Roll 所以這裡不討論，有了歐拉角後就可以算出旋轉後的新的方向向量

![](https://i.imgur.com/CzPYyQC.jpg)

```cpp
glm::vec3 dir;
dir.x = cos(glm::radians(pitch)) * cos(glm::radians(yaw));
dir.y = sin(glm::radians(pitch));
dir.z = cos(glm::radians(pitch)) * sin(glm::radians(yaw));
```

有了方向向量，我們就可以把 `cameraFront` 設定成方向向量，來把相機轉過去了。

### 滑鼠輸入

通常根據滑鼠輸入變動視角的處理方法是:

* 計算滑鼠位置的偏移量(相對上個 frame)
* 把偏移量加到 `pitch` 跟 `yaw` 中
* 限制最大跟最小值
* 計算方向向量

```cpp
// 滑鼠目前為位置
auto [x, y] = sf::Mouse::getPosition(window);
glm::vec2 nowCursorPos(x, window.getSize().y - y);
// 螢幕中心
static glm::vec2 screenCenter(window.getSize().x / 2, window.getSize().y / 2);
sf::Mouse::setPosition({window.getSize().x / 2, window.getSize().y / 2} , window);
// 偏移量
glm::vec2 off = nowCursorPos - screenCenter;
```

把偏移量乘上滑鼠敏感度

```cpp=
off *= sensitivity;
```

把角度加上偏移量，並限制最大、最小 (不限制水平旋轉是因為古早 FPS 都是視角轉 = 人轉)

```cpp=
static float pitch  = 0.f;
static float yaw = -90.f;  // 面向 -z
static float sensitivity = 0.05f;

pitch += off.y;
yaw += off.x;
// 避免 yaw 因為 float 精度問題
if(yaw > 360.f || yaw < -360.f) yaw = glm::mod(yaw, 360.f);
// 限制 pitch
if(pitch > 89.f) pitch = 89.f;
if(pitch < -89.f) pitch = -89.f;
```

最後計算 Camera 新的方向向量

```cpp=
glm::vec3 newCameraFront;
newCameraFront.x = cos(glm::radians(yaw)) * cos(glm::radians(pitch));
newCameraFront.y = sin(glm::radians(pitch));
newCameraFront.z = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
cameraFront = newCameraFront;
```

![](https://imgur.com/X0WdzL2.gif)

* 隱藏滑鼠游標
    * [ref](https://github.com/ocornut/imgui/issues/2375)

```cpp
window.setMouseCursorVisible(false); // 因為 imgui 的緣故，滑鼠還是會被畫出來
window.setMouseCursorGrabbed(true);  // 讓滑鼠不能超出視窗範圍

while(running)
{
    // ...
    
    // 必須叫 imgui 不要畫滑鼠
    ImGui::SetMouseCursor(ImGuiMouseCursor_None);
    
    windiw.draw();
}
```

## 視角縮放

把 FOV 變小時，會產生一種放大的感覺，我們使用滑鼠滾輪來進行縮放。SFML 裏頭偵測滑鼠滾輪只能用事件

```cpp
// Event update
if(event.type == sf::Event::MouseWheelScrolled)
{
    mouseWheelDelta = event.mouseWheelScroll.delta;
}

// In Update
if(mouseWheelDelta != 0.f)
{
    fov += mouseWheelDelta;
    if(fov < 1.f) fov = 1.f;
    if(fov > 45.f) fov = 45.f;
    mouseWheelDelta = 0.f;
}
```

![](https://imgur.com/yCDJixe.gif)

* [Example 7.3 Camera](https://github.com/rishteam/OpenGL_learning/blob/master/LearnOpenGL/src/1.getting_started/7.3.camera_rotate/main.cpp)

* 使用歐拉角的 Camera 會有[萬向鎖(Gimbal Lock)](https://www.youtube.com/watch?v=zc8b2Jo7mno)的問題
    * 更好的是使用四元數(Quaternions)
        * https://github.com/cybercser/OpenGL_3_3_Tutorial_Translation/blob/master/Tutorial%2017%20Rotations.md

## Lab
### 將 Camera 封裝成 class

* [Example 7.5 Camera class](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/7.5.lab_camera_class)

### 試著自己實作看看 `lookAt()`

* OpenGL 矩陣是 **Column-major**，所以 LookAt 公式要改寫成


$$
LookAt = \begin{bmatrix}
\color{red}{R_x} & \color{green}{U_x} & \color{blue}{D_x} & 0 \\\\
\color{red}{R_y} & \color{green}{U_y} & \color{blue}{D_y} & 0 \\\\
\color{red}{R_z} & \color{green}{U_z} & \color{blue}{D_z} & 0 \\\\
0 & 0 & 0  & 1
\end{bmatrix} * 
\begin{bmatrix}
1 & 0 & 0 & 0 \\\\
0 & 1 & 0 & 0 \\\\
0 & 0 & 1 & 0 \\\\
-\color{purple}{P_x} & -\color{purple}{P_y} & -\color{purple}{P_z}  & 1 
\end{bmatrix}
$$

我卡了一整天幹zz

* [Example 7.4 Make your own LookAt Matrix](https://github.com/rishteam/OpenGL_learning/blob/master/LearnOpenGL/src/1.getting_started/7.4.lab_1/main.cpp)

![](https://imgur.com/0uOFyaC.gif)
