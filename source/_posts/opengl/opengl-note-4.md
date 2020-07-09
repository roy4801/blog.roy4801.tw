---
title: OpenGL 筆記 - Texture
date: 2020-07-09 15:46:00
categories:
- [學習紀錄, OpenGL]
tags:
- OpenGL
- 程式
- 筆記
- 圖學
- Texture

---

可以用為每個頂點增加顏色來為圖形添增細節，來建構有趣的圖像。但必須要有足夠多的頂點、顏色，這會帶來很多開銷，每個模型的頂點就會變得很多。

紋理(Texture)是一個 2D 的圖片，可以用來增添物體的細節，可以想像 Texture 就像是個有圖案的紙，貼合在 3D 的物體上，這樣就可以讓物體不用增加頂點就增加細節。
題外話，Texture 除了圖像之外還能用來儲存大量資訊發送到 Shader 上。

![](https://i.imgur.com/dl5nCAc.png)

為了將紋理(Texture)映射(Map)到頂點上，需要指定頂點分邊對應到紋理的哪個部分，所以每個頂點都會關聯著一個紋理座標(Texture Coordinate)，用來表示該從 Texture 的哪個地方採樣(Sampling)(fragment 的顏色)，之後其他的 Fragment 會插值其 Texture Coordinate。

![](https://i.imgur.com/pRw6fBr.png)

* Texture Coordinate 紋理座標
    * 把紋理貼在第一象限，從 $(0, 0)$ 到 $(1, 1)$
    * $u$ 是 x 軸，$v$ 是 y 軸

![](https://i.imgur.com/PVK5oZB.png)

```cpp
float texCoords[] = {
    0.0f, 0.0f, // bottom left
    1.0f, 0.0f, // bottom right
    0.5f, 1.0f  // middle
};
float vertices[] = {
    // 位置  
     0.5f, -0.5f, 0.0f,
    -0.5f, -0.5f, 0.0f,
     0.0f,  0.5f, 0.0f
};
```

## 材質環繞方式

![](https://i.imgur.com/MIwTxEj.png)

材質座標的範圍是 $[0, 1]$(第一象限) ，如果超出這個座標之外預設的行為是重複，但其實 OpenGL 提供了更多的選擇:

| 環繞方式 | 描述 |
| -------- | -------- |
| `GL_REPEAT` | 預設，重複材質圖像 |
| `GL_MIRRORED_REPEAT` | 一樣是重複材質，但圖片是鏡像的 |
| `GL_CLAMP_TO_EDGE` | 材質座標會被約束在 $[0,1]$，超出的部分會重複邊緣<br>並產生拉伸的效果 |
| `GL_CLAMP_TO_BORDER` | 超出的座標為指定的顏色 |

這些選項都可以對單獨的材質座標軸設定，s, t 和 r 軸(如果是 3D 的話)

```cpp
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
// glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, GL_MIRRORED_REPEAT);
```

* 選擇 `GL_CLAMP_TO_BORDER` 則還需要指定一個顏色

```cpp
float borderColor[] = {1.0f, 1.0f, 0.0f, 1.0f};
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
```

## 紋理濾波 (Texture Filter)

紋理座標跟解析度無關，所以 OpenGL 要知道怎麼將紋理像素(Texture Pixel, Texel)映射到紋理座標(Texture Coordinate)。
如果一個很大的物體，可是紋理解析度很低，就會有明顯的瑕疵出現。

* 紋理濾波 Texture Filter
    * `GL_NEAREST`
    * `GL_LINEAR`
    * 其他過濾方式，[參見](https://zh.wikipedia.org/wiki/%E7%BA%B9%E7%90%86%E6%BB%A4%E6%B3%A2)

* 鄰近濾波 Nearest Neighbor Filtering
    * OpenGL 預設使用 `GL_NEAREST`
    * 選 Texture Coordinate 最接近的 紋素(Texel)

![](https://i.imgur.com/y8MnkAO.png)

* [雙線性過濾 Bilinear Filtering](https://zh.wikipedia.org/wiki/%E5%8F%8C%E7%BA%BF%E6%80%A7%E8%BF%87%E6%BB%A4)
    * `GL_LINEAR`
    * 基於紋理座標附近的紋理像素，計算插值，近似出這些紋理像素們之間的顏色
    * 紋理座標離該紋理像素越接近則對最終顏色貢獻越大

![](https://i.imgur.com/BHEaZfy.png)

看起來像是:

* `GL_NEAREST`
    * 產生了顆粒狀

* `GL_LINEAR`
    * 平滑

![](https://i.imgur.com/MDqCMdT.png)

* OpenGL 可以設定紋理在放大或縮小時要使用的過濾方式
    * `GL_TEXTURE_MIN_FILTER` 縮小
    * `GL_TEXTURE_MAG_FILTER` 放大

```cpp
// 縮小使用 GL_NEAREST
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
// 放大使用 GL_LINEAR
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
```

### Mipmapping

假如說場景在開闊的地方，有上千個物體，每個物體上都有紋理，近處的物體的紋理解析度很高，但遠處的物體可能只產生很小的片段(Fragment)，在高解析度的紋理中這種物體的顏色通常都不正確，並且也浪費記憶體。

![](https://i.imgur.com/voF4WPi.png)

多級漸遠紋理(Mipmap)是一系列的紋理圖像，後一個的大小是前個的二分之一。當觀察者的距離超過一定的閾值(threshold)，自動切換至適合該距離的紋理。距離遠用解析度比較小的，也不容易被察覺。

Mipmap 可以自己手動產生，不過 OpenGL 可以幫我們自動產生。

* 紋理過濾等級 + Mipmap
    * `_MIPMAP_NEAREST`
        * 使用最接近的 Mip Level
    * `_MIPMAP_LINEAR`
        * 在兩個最接近的 Mip Level 插值

```cpp
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
```

放大過濾不可以使用 Mipmap ，因為 Mipmap 是給縮小紋理使用的

## 載入圖片

### stb_image.h

[stb_image.h](https://github.com/nothings/stb/blob/master/stb_image.h) 是一個 header-only 的圖片載入 library 是 [stb](https://github.com/nothings/stb) 系列的其中之一，支援 jpg, png, tga, bmp, psd, gif, hdr, pic 等格式。

* 下載 `stb_image.h` 並加到你的專案中，並另新增一個 `.cpp` 輸入代碼
    ```cpp
    #define STB_IMAGE_IMPLEMENTATION
    #include "stb_image.h"
    ```

* 載入圖片

```cpp
int width, height, nrChannels;
unsigned char *data = stbi_load("example.jpg", &width, &height, &nrChannels, 0);

// free
stbi_image_free(data);
```

### 使用 SFML

```cpp
// 載入圖片
sf::Image wall;
wall.loadFromFile("../src/1.getting_started/4.1.texture/wall.jpg");
wall.flipVertically();
// 設定材質及參數
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, wall.getSize().x, wall.getSize().y, 0, GL_RGBA, GL_UNSIGNED_BYTE, (const void*)wall.getPixelsPtr());
glGenerateMipmap(GL_TEXTURE_2D);
```

## 生成紋理

* 建立紋理 object

```cpp
uint32_t texture;
glGenTexture(1, &texture);
```

* 綁定

```cpp
glBindTexture(GL_TEXTURE_2D, texture);
```

* 生成紋理
    * [glTexImage2D(target, level, internalFormat, width, height, border,  format,  type, * data)](http://docs.gl/gl4/glTexImage2D)
        * Target
        * Mipmap Level
            * 0 = base
        * internalFormat 儲存格式
        * width 寬度, height 高度
        * border 永遠 = 0 (歷史遺留)
        * format 原圖格式
        * type 資料類型
        * data 真正的圖像資料

```cpp
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
glGenerateMipmap(GL_TEXTURE_2D);
```

呼叫完 `glTexImage2D()` 便會把紋理圖像(Texture Image)綁定上紋理物件(Texture Object)，由於只有基本 Mipmap 等級(Base-Level)的紋理圖像被綁定，如果要用 Mipmap 的話，則要用 `glGenerateMipmap()` 讓 OpenGL 自動產生 Mipmap。

* 完整產生紋理的流程:

```cpp
unsigned int texture;
glGenTextures(1, &texture);
glBindTexture(GL_TEXTURE_2D, texture);
//
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);   
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//
unsigned char *data = load_image("example.jpg"); // 自訂載入圖片方式
uint32_t width = /* 圖片的寬 */;
uint32_t height = /* 圖片的高 */;
if (data)
{
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
    glGenerateMipmap(GL_TEXTURE_2D);
}
else
{
    std::cout << "Failed to load texture" << std::endl;
}
free_image(data); // 釋放圖片
```

## 使用紋理

延續 [2.2.hello_triangle_indexed](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/2.2.hello_triangle_indexed) 的範例，為頂點加入 Texture Coordinate 的屬性，讓 OpenGL 知道要如何採樣(Sample)紋理。

```cpp
float vertices[] = {
//     ---- 位置 ----       ---- 顏色 ----     - 紋理座標 -
     0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
     0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
    -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
    -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // 左上
};
```

![](https://i.imgur.com/9kS8ABB.png)

* 設定頂點屬性

```cpp
uint32_t aPos = glGetAttribLocation(program, "aPos");
glVertexAttribPointer(aPos, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)0);
glEnableVertexAttribArray(aPos);
uint32_t aVertColor = glGetAttribLocation(program, "aVertColor");
glVertexAttribPointer(aVertColor, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(3 * sizeof(float)));
glEnableVertexAttribArray(aVertColor);
uint32_t aTexCoord = glGetAttribLocation(program, "aTexCoord");
glVertexAttribPointer(aTexCoord, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6*sizeof(float)));
glEnableVertexAttribArray(aTexCoord);
```

* Vertex Shader
    * 把 `aTexCoord` 傳到 fragment shader

```glsl=
#version 450 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aVertColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 VertColor;
out vec2 TexCoord;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    TexCoord = aTexCoord;
    VertColor = aVertColor;
}
```

* Fragment Shader
    * GLSL 中有個類型叫 `Sampler`
        * `Sampler1D`, `Sampler2D`, `Sampler3D`

```glsl=
#version 450 core
out vec4 FragColor;

in vec2 TexCoord;
in vec3 VertColor;

uniform sampler2D texture1;

uniform vec4 fColor;

void main()
{
    FragColor = texture(texture1, TexCoord) * fColor;
}
```

GLSL 內建 `texture()` 函數來採樣，第一個參數是採樣的紋理，第二個參數是紋理座標，輸出去紋理座標(插值後)並且經過 Filter 後的顏色。

* 使用

```cpp
glBindTexture(GL_TEXTURE_2D, texture);
glBindVertexArray(vao);
glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
```

![](https://i.imgur.com/OJxIHJm.png)

* 可以把紋理的顏色跟頂點顏色混和，只要在 Fragment Shader 中將顏色相乘

    ```glsl
    FragColor = texture(texture1, TexCoord) * vec4(VertColor, 1.0);
    ```

![](https://i.imgur.com/aEjJEY1.png)

* Example 4.1

![](https://imgur.com/eO3E0dt.gif)

## 紋理單元 Texture Unit

在 Fragment Shader 中如果想要使用多個紋理，則要給紋理一個位置值，稱作紋理單元(Texture Unit)。

> 但是在上個範例中並沒有用 `glUniform` 給值(因為預設是 0)

```cpp
glActiveTexture(GL_TEXTURE0); // 啟用第 0 號 texture
glBindTexture(GL_TEXTURE_2D, texture); // 將紋理綁定上 GL_TEXTURE0
```

OpenGL 保證有 16 個紋理單元可以使用，且紋理單元的編號是連續的，意味著可以用 `GL_TEXTURE0 + n` 來存取(也可以直接用 `GL_TEXTUREn`)

* 例子:混和兩張紋理
    * Fragment Shader
    ```glsl=
    #version 450 core

    uniform sampler2D tex1;
    uniform sampler2D tex2;

    void main()
    {
        FragColor = mix(texture(tex1, TexCoord), texture(tex2, TexCoord), 0.2);
    }
    ```

    * `mix(a, b, alpha)` 混和(線性插值)
        * $\text{color} = a \alpha + b (1-\alpha)$

* 在開始渲染之前要設定 texture 的編號
    * 如此一來在 fragment shader 裡頭的 `tex1`, `tex2` 才會參考到綁定在紋理單元的 Texture

```cpp
glUseProgram(program);
glUniform1i(glGetUniformLocation(program, "tex1"), 0);
glUniform1i(glGetUniformLocation(program, "tex2"), 1);
```

渲染流程會變成:

```cpp
/* Create, Load Texture */
/* ... */
glUseProgram(program);
// Set Texture units
glUniform1i(glGetUniformLocation(program, "tex1"), 0);
glUniform1i(glGetUniformLocation(program, "tex2"), 1);

while(...)
{
    /* ... */

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2);

    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}
```

* [4.2.texture_combined](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/4.2.texture_combined)

![](https://imgur.com/OcWfEVb.gif)

* Labs
    * 修改 Fragment Sahder **只**讓第二個圖案翻轉
        <details>
            <summary>Ans</summary>
        ```glsl
        #version 450 core
        out vec4 FragColor;

        in vec2 TexCoord;
        in vec3 VertColor;

        uniform sampler2D tex1;
        uniform sampler2D tex2;

        uniform vec4 fColor;
        uniform float fMix;

        void main()
        {
            vec4 resultColor = mix(texture(tex1, TexCoord), texture(tex2, vec2(-TexCoord.x, TexCoord.y)), fMix) * fColor;
            FragColor = resultColor;
        }
        ```
        ![](https://i.imgur.com/iqejGwI.png)
        </details>
    * 嘗試用不同的紋理環繞方式
        <details>
            <summary>Ans</summary>
        ```cpp
        float vertices[] = {
        //     ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
             0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   2.0f, 2.0f,   // 右上
             0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   2.0f, 0.0f,   // 右下
            -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
            -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 2.0f    // 左上
        };
        ```
        * `GL_MIRRORED_REPEAT`
        ![](https://i.imgur.com/C2C5nFc.png)
        * `GL_CLAMP_TO_EDGE`
        ![](https://i.imgur.com/bJVn825.png)
        * `GL_CLAMP_TO_BORDER`
        ![](https://i.imgur.com/j0Z61gj.png)
        </details>
    * 嘗試在矩形上只顯示紋理圖像的中間一部分，修改紋理坐標，達到能看見單個的像素的效果。嘗試使用GL_NEAREST的紋理過濾方式讓像素顯示得更清晰
        <details>
            <summary>Ans</summary>
        * `GL_NEAREST`
        ![](https://i.imgur.com/ekXUvki.png)
        * `GL_LINEAR`
        ![](https://i.imgur.com/ZePNhxk.png)
        </details>
    * 使用一個uniform變量作為mix函數的第三個參數來改變兩個紋理可見度，使用上和下鍵來改變箱子或笑臉的可見度
        * see example 4.2

## Reference

How do opengl texture coordinates work?
https://stackoverflow.com/questions/5532595/how-do-opengl-texture-coordinates-work

https://zh.wikipedia.org/wiki/%E7%BA%B9%E7%90%86%E6%BB%A4%E6%B3%A2
