---
title: OpenGL 筆記 - Coordinate System
date: 2020-07-13 12:44:00
categories:
- [學習紀錄, OpenGL]
tags:
- OpenGL
- 程式
- 筆記
- 圖學
- Coordinate

---

OpenGL 座標的值在 經過 Vertex Shader 之後變成 $[-1.0, 1.0]$ 的座標，稱作 *標準化設備座標 Normalized Device Coordinates (NDC)*，只有在此座標內的頂點最終才會顯示在螢幕上。

座標在被轉換成螢幕座標(Screen-Space)時還會經過多次轉換

* 座標系統
    * 局部空間 Local Space 或是 物體空間(Object Space)
    * 世界空間 World Space
    * 觀察空間 View Space 或 Eye Space
    * 裁剪空間 Clip Space
    * 螢幕空間 Screen Space

![](https://i.imgur.com/JDYXqSI.png)

為了轉換坐標系，需要用到幾個變換矩陣(Transforma Matrix)，分別是 Model(模型)、View(觀察)、Projection(投影)三個矩陣。

* Local Space
    * 物體相對於局部原點的座標
* World Space
    * 相對於世界的原點，會和其他物體相對於原點擺放
* View Space
    * 從 Camera (觀察者) 的角度進行觀察的頂點座標
* Clip Space
    * View Space 經過投影後，裁剪座標會被處理到 NDC 空間 $[-1.0, 1.0]$
* Screen Space
    * 經過 Viewport Transform，將 $[-1.0, 1.0]$ 內的座標變換到 `glViewport` 所定義的座標範圍內
    * 出來的座標會送到 Rasterizer 變成 Fragment (Pixel)

之所以把頂點在不同坐標系中轉換，是因為有些操作在特定的坐標系中才有意義且方便。例如，需要對物體修改時，在 Local Space 比較方便；如果需要相對其他物體時，在 World Space 比較方便。

## Local Space 局部空間

物體所在的座標空間，一個物體的原點在 $(0, 0, 0)$ 但最後可能出現在世界的不同地方(座標)，它的所有頂點都是相對於 Local Space 的原點，這些座標都是局部(Local)的。

## World Space 世界空間

頂點相對於遊戲世界原點的座標。從 Local Space 變換到 World Space 是由 **Model Matrix** 來完成的
把物體從 Local Space 經過位移、縮放、旋轉來把物體擺在世界的位置

## View Space 觀察空間

觀察空間是將世界座標轉成使用者視野(攝影機 Camera)前方的座標。經由位移和旋轉**場景**，使得特定的物體變換到攝影機(Camera)的前方，此種變換的矩陣稱作 **View Matrix**

## Clip Space 裁剪空間

在經過 Vertex Shader 後 OpenGL 希望所有的座標都在 $[-1.0, 1.0]$ 內，超出的會被裁剪(Clip) 掉(忽略掉)，在此座標內的頂點最後會被光柵化成 Fragment

為了將頂點座標變換到 NDC 空間，要經由 **Projection Matrix 投影矩陣**，它指定了一個範圍的座標 e.g. [-1000, 1000]，投影矩陣會將在範圍內的座標轉成 NDC。超出範圍的座標，轉出的座標會超出 -1.0 或 1.0，最後會被剪裁掉。

因此會有個範圍內的頂點都會被轉換，這個範圍叫做 **觀察箱Viewing Box**又稱作 [Frustum](https://en.wikipedia.org/wiki/Frustum)

![](https://i.imgur.com/rTn70Lq.png)

這個轉換的過程稱作 *投影 Projection*

有兩種不同的投影方式:正射投影、透視投影

<img src="https://i.imgur.com/jxqR4tP.png" width=400>

### 正射投影 Orthographic Projection

![](https://i.imgur.com/QzARlUo.png)

正射投影定義了一個像長方體的觀察箱，超出這個觀察箱外的頂點會被剪裁掉，在此觀察箱內的頂點會被轉成 NDC 座標。
由寬、高及近(Near)平面和遠(Far)平面定義

```cpp=
// glm::ortho(left, right, bottom, top, zNear, zFar)
glm::ortho(0.0f, 800.0f, 0.0f, 600.0f, 0.1f, 100.0f);
```

![](https://i.imgur.com/liQTbaD.png)

<details>
<summary>matrix 長相</summary>

出來的矩陣是:
$\begin{pmatrix}
\frac{2}{\text{right}-\text{left}} & 0 & 0 & t_x \\\\
0 & \frac{2}{\text{top} - \text{bottom}} & 0 & t_y \\\\
0 & 0 & \frac{2}{\text{zFar} - \text{zNear}} & t_z \\\\
0 & 0 & 0 & 1
\end{pmatrix}$
$t_x = - \frac{\text{right}+\text{left}}{\text{right}-\text{left}} \\\\
t_y = - \frac{\text{top} + \text{bottom}}{\text{top} - \text{bottom}} \\\\
t_z = - \frac{\text{zFar} + \text{zNear}}{\text{zFar} - \text{zNear}}$

</details>

### 透視投影 Perspective Projection

![](https://i.imgur.com/kvDeMeT.png)

遠處的東西看起來很小，近處的物品看起來很大，稱為透視(Perspective)。上圖是一個無限長的鐵軌，由於透視的關係，兩條線在很遠的地方看起來會相交。

透視投影除了將觀察箱內的座標映射到 Clip Space ，還修改了座標的 $w$ 分量，讓離觀察者遠的頂點之 $w$ 分量越大，經由透視除法，離觀察者越遠的頂點則會越小。

* Perspective Division 透視除法
    * 在轉換到 Clip Space 的頂點，每個座標的 $(x, y, z)$ 會都除上 $w$ 分量
    * 也就是 $(\frac{x}{w}, \frac{y}{w}, \frac{z}{w})$
    * 將 4D 的 Clip Space 座標轉換成 3D NDC 座標
    * 在 Vertex Shader 的最後會被 自動執行

![](https://i.imgur.com/gwf7D4X.png)

```cpp
glm::mat4 proj = glm::perspective(
    glm::radians(45.0f),       // Field Of View
    (float)width/(float)height // 寬高比
    , 0.1f, 100.0f);           // 近平面, 遠平面
```

* [`glm::perspective(fovy, aspect, near, far)`](https://glm.g-truc.net/0.9.9/api/a00665.html#ga747c8cf99458663dd7ad1bb3a2f07787)
    * `fovy` Field of View 視野大小
    * `aspect` 寬高比 $\frac{\text{width}}{\text{height}}$
    * `near` 近平面 (距離)
    * `far` 遠平面 (距離)

![](https://i.imgur.com/B9NOE3n.png)

### 比較

![](https://i.imgur.com/PKEC0y9.png)

正射投影(Orthographic)不會產生透視(w分量是1.0)所以看起來遠處的物體跟近處是一樣的大小，主要用在渲染 2D 或是建築、工程、或建模的應用。

透視投影(Perspective)遠處的的物體就看起來較小。

## 組合在一起

一個頂點座標會經過下列算式轉成 Clip Space。注意矩陣運算式從右往左。

$V_{clip} = M_{projection} \cdot M_{view} \cdot M_{model} \cdot V_{local}$

## 進入 3D 世界

因為之前範例的圖片都是貼在 $x-y$ 平面上，要看起來有 3D 的效果的話，則要旋轉物體 e.g. 讓它看起來躺在地板上。(在這個例子中，我們箱子也擺在世界座標的 $(0, 0, 0)$ 因此沒有 translate)

```cpp
glm::mat4 model(1.f);
model = glm::rotate(model, glm::radians(-55.0f), glm::vec(1.0f, 0.0f, 0.0f));
// 繞 x 軸旋轉 -55 度
```

* 右手坐標系
    * OpenGL 的座標系
    ![](https://i.imgur.com/jDb8Vkg.gif)
    ![](https://i.imgur.com/gkxRYPr.png)

在 OpenGL 中，看出去的視野(Camera)永遠是**朝向 $-z$ 方向**，且**位在 $(0, 0, 0)$**，且**不能移動**

> 想像頭是 Camera，坐標系是你用中二的手勢(上圖)，中指指著自己，食指指著天，拇指指著右邊，因此視野射出去是 $-z$ 方向

* 那我們想要把 Camera 擺在 $(0, 0, 3)$ 然後往 $-z$ 方向看要怎麼辦?
    * 我們不能移動 Camera
    * 那就移動物體，往相反於 Camera 移動的方向，移動整個場景
    * View Matrix

```cpp=
glm::mat4 view(1.f);
view = glm::translate(view, glm::vec3(0.0f, 0.0f, -3.0f));
```

最後，根據想要的效果選擇 Projection Matrix

```cpp
glm::mat4 projection(1.0f);
projection = glm::perspective(glm::radians(45.0f), width / height, 0.1f, 100.f);
```

建好 Matrix 後，應該要把它們傳到 Vertex Shader 中:

```glsl=
#version 330 core
layout (location = 0) in vec3 aPos;
// ...
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    // 注意矩陣乘法
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    ...
}
```

最後的效果:

![](https://i.imgur.com/qmNcDZz.png)

## Examples

* [6.1.coordinate_systems](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/6.1.coordinate_systems)

![](https://i.imgur.com/p5zlsrx.gif)

---

* 3D 的立方體
    * 要畫一個立方體需要 [36 個頂點](https://learnopengl.com/code_viewer.php?code=getting-started/cube_vertices)
    * 改用 `glDrawArrays()` 因為沒有 EBO
    * [6.2.cube](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/6.2.cube)


![](https://imgur.com/ctvQ53t.gif)

可以發現奇怪的地方，該畫在後面的面卻畫在了前面，形成了很奇怪的結果。解決的方法是使用 OpenGL 的 Z-Buffer (Z 緩衝)，它讓 OpenGL 知道一個像素的深度 (Depth)(可以想像成圖層那樣)，進行深度測試(Depth Test)。

* 啟用 Depth Test
    ```cpp
    glEnable(GL_DEPTH_TEST);
    ```

* 每一 frame 都要清掉 Z-Buffer 的內容
    ```cpp
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    ```

![](https://imgur.com/Th4I7FW.gif)

* [6.3.cube_depth](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/6.3.cube_depth)

---

* 顯示更多的立方體
    * 每次畫一個立方體時，就算出一個 Model Matrix

```cpp
glBindVertexArray(VAO);
for(unsigned int i = 0; i < 10; i++)
{
  glm::mat4 model(1.f);
  model = glm::translate(model, cubePositions[i]);
  float angle = 20.0f * i; 
  model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
  UploadMat4("vModel", model);

  glDrawArrays(GL_TRIANGLES, 0, 36);
}
```

## Labs

* 將觀察矩陣在各個方向上進行位移，來看看場景是如何改變的。

![](https://imgur.com/zdnL17H.gif)

* 對 GLM 的`projection`函數中的 FoV 和 aspect-ratio 參數進行實驗。看能否搞懂它們是如何影響透視 frustum 的。

![](https://imgur.com/NDmehQs.gif)

#### 參考

http://docs.gl/gl3/glOrtho
http://www.songho.ca/opengl/gl_projectionmatrix.html
https://www.itread01.com/content/1547164287.html

https://blog.csdn.net/chy19911123/article/details/45476821
