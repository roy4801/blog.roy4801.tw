---
title: OpenGL 筆記 - 第一個三角形
date: 2020-06-30 02:10:45
categories:
- [學習紀錄, OpenGL]
tags:
- OpenGL
- 程式
- 筆記
- 圖學

---

* 在 OpenGL 中，所有東西都在 3D 的空間中，而螢幕是 2D 的陣列
    * OpenGL 負責將 3D 座標經過一系列操作轉換成 2D 螢幕的座標
        * 稱作「圖形渲染管線(Graphics Render Pipeline)」
            * 圖形數據經過一個管道，中間經過各種轉換，最後輸出在畫面上
        * 可以分成兩個部分:轉換座標(3D -> 2D)、把 2D 座標轉換成有顏色的像素(pixel)

* Render Pipeline 被劃分成多個階段，前一個階段的輸出會作為下一個階段的輸入，每個階段都是高度專門化的
    * GPU 中有成千上萬個小處理核心，為 Pipeline 上的每個階段處理
    * 跑在 GPU 中的小程式稱作 [Shader (著色器)](https://zh.wikipedia.org/wiki/%E7%9D%80%E8%89%B2%E5%99%A8)
    * OpenGL 使用的 Shader 語言是: OpenGL Shading Language (GLSL)

## Render Pipeline 的大概流程

![](https://i.imgur.com/PemIOSu.png)

* 輸入 Vertex Data
    * 一個頂點是 Vertex 是 3D 座標的數據的集合
    * Vertex Attribute 頂點屬性表示了一個頂點的資料

* Vertex Shader 頂點著色器
    * 輸入一個頂點(Vertex)，把 3D 座標轉換成另一種座標
    * 對 Vertex Attribute 做一些處理

* Shape Assembly 圖元裝配
    * 輸入 Vertex Shader 輸出之所有頂點
    * 將 Vertex 裝成指定的形狀

* Geometry Shader
    * 產生新的頂點用來構造出圖元來生成其他形狀

* Rasterization 光柵化
    * 轉換成像素(Pixel)

* 裁切(Clipping)
    * 將畫面外的像素丟掉

* Fragment Shader 片段著色器
    * 計算最後 pixel 的顏色

* Test and Belending 測試與混合
    * Depth Test
        * pixel 的深度(Depth)，決定像素的前後
    * Alpha Test
    * 各種 Test
    * Blending
        * 物體會有透明度

在現代 OpenGL 中，必須定義*至少*一個 Vertex Shader 以及至少一個 Fragment Shader

## 頂點輸入

OpenGL 只會處理 3D 座標在值在 $[-1.0, 1.0]$ 的座標，稱作 *標準化設備座標 Normalized Device Coordinates (NDC)*，只有在此座標內的頂點最終才會顯示在螢幕上。

```cpp
float vertices[] = {
    -0.5f, -0.5f, 0.0f,
     0.5f, -0.5f, 0.0f,
     0.0f,  0.5f, 0.0f
};
```

![](https://learnopengl-cn.github.io/img/01/04/ndc.png)

 NDC座標在「頂點後處理階段」會被轉換成 螢幕空間座標(Screen-space Coordinate)
 * 經由 Viewport Transform 得到螢幕空間座標
     * 細節參考: https://www.khronos.org/opengl/wiki/Vertex_Post-Processing#Viewport_transform

有了頂點資料後，接著要把這些頂點資料放到「顯示記憶體」中，交給 Vertex Shader 處理。可以透過 Vertex Buffer Object (VBO) 來管理。

### VBO

* Vertex Buffer Object (VBO) 頂點緩衝物件
    * OpenGL 最常用到的緩衝物件
    * 用來在 GPU 記憶體中儲存大量頂點
        * 每個頂點的資料通常含有
            * 座標、顏色、貼圖座標、法向量...等
    * 可以一次性的發送一堆頂點到顯卡上(CPU 發送資料相對較慢，因此我們希望一次性發送盡可能多的資料)
    * OpenGL 中以 `GL_ARRAY_BUFFER` 表示

產生、綁定、傳送資料

```cpp
uint32_t VBO;
glGenBuffer(1, &VBO); // number, array to object id
glBindBuffer(GL_ARRAY_BUFFER, VBO); // 綁定
glBufferData(GL_ARRAY_BUFFER, sizeof(vertives), vertices, GL_STATIC_DRAW); //傳輸資料
```

* 產生
    * `glGenBuffers(GLsizei n, GLuint *buffer)`
    * `n`: 要產生幾個緩衝物件
    * `buffers`: 存產生出來的名字陣列
* 綁定
    * `glBindBuffer(GLenum target, GLuint buffer)`
    * `target`: 綁定到哪種緩衝器的綁定點
    * `buffer`: 要綁定緩衝物件名字

* 分配儲存空間
    * `glBufferData(GLenum target, GLsizeptr size, const GLvoid *data, GLenum usage)`
    * `target`: 目前緩衝物件綁定到的目標
    * `size`: 給定緩衝物件的大小
    * `data`: 要存入資料的 pointer
    * `usage`: 設定存入資料的使用方式

| Usage | 描述 |
| -------- | -------- |
| `STATIC`   | 資料只被設定一次，但會被使用很多次 |
| `DYNAMIC`  | 資料被改變很多次，也被使用很多次 |
| `STREAM`   | 資料每次繪製都會改變 |

## Vertex Shader 頂點著色器

使用現在 OpenGL 至少需要一個以上的 Vertex Shader，以下是 Vertex Shader 的一個例子

```glsl
#version 330 core  // version
layout (location = 0) in vec3 aPos;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
```

* `in` 指得是輸入資料
* `vec[1,4]` 指得是向量，有 `.x`, `.y`, `.z`, `.w` 這幾個 `float` 分量
* `layout(location = 0` 設定了這個變數的 index，在把資料傳入 shader (GPU)時會用到
* GLSL 的其他 type 可以[參考](https://www.khronos.org/opengl/wiki/Data_Type_(GLSL))

### 編譯 Shader

在編譯 shader 並傳入 GPU 執行之前，要先根據 type 創建 Shader 並拿到 shader id。

```cpp
uint32_t vertexShader;
vertexShader = glCreateShader(GL_VERTEX_SHADER)
```

之後把原始碼綁定到該 Shader 上，然後編譯它:

```cpp
glShaderSource(vertexShader, 1, &vertexShader, nullptr);
glCompileShader(vertexShader);
```

* 建立 Shader
    * `GLuint glCreateShader(GLenum shaderType);`
    * `shaderType` shader 的類型
        * `GL_VERTEX_SHADER`
        * `GL_FRAGMENT_SHADER`
        * 其他 shader 類型省略
* 給 Shader Source
    * `void glShaderSource(GLuint shader, GLsizei count, const GLchar **string, const GLint *length);`
        * `shader` Shader ID
        * `count` 幾個 source code
        * `string` char* 陣列(原始碼)
        * `length` 長度 (如果為 0 則看 `\0` 結尾)
* 編譯 Shader
    * `void glCompileShader(GLuint shader);`
    * `shader` Shader ID

如何查看編譯狀況? 用 `glGetShaderiv()` 以及 `glGetShaderInfoLog()`
```cpp
int success;
char log[512];
glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
if(!success)
{
    glGetShaderInfoLog(shader, 512, nullptr, log);
    printf("Error Shader %s compile error\n%s\n",
        type == GL_VERTEX_SHADER ? "Vertex" : "Fragment", log);
}
```

## Fragment Shader 片段著色器

Fragment Shader 輸出的是最後像素的顏色

```glsl
#version 330 core
out vec4 FragColor;

void main()
{
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
```

* `out` 指定變數為輸出
* `FragColor` 對應到的分量分別是 R, G, B, A

* 編譯跟 Vertex Shader 一樣
    * type 是 `GL_FRAGMENT_SHADER`

```cpp
uint32_t fragmentShader;
fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
glCompileShader(fragmentShader);
```

## Linking Shader Program

會把編譯好的 Shader 連結(Link)成一個 **Shader Program Object**
當我們要渲染時啟用該 Shader Program ，之後呼叫的渲染指令便會去調用該 Shader Program

* 建立 Shader Program
    * [`glCreateProgram()`](http://docs.gl/gl4/glCreateProgram)

    ```cpp
    uint32_t program;
    program = glCreateProgram();
    ```

* 將 Shader Attach 到 Program 上

    ```cpp
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    ```

* Attach 上 Program 後可以把舊的單獨 Shader 刪掉(如果之後沒有要用到的話)

    ```cpp
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    ```

* 啟用 Shader Program

    ```cpp
    glUseProgram(program);
    ```

到了這裡，我們已經把頂點資料存在 GPU 中，而且也指定了要怎麼處理這些資料(Shader)，但是 OpenGL 還不知道要如何解析傳入的資料，以及該怎麼將頂點資料連接到 Shader 的參數上，我們指定給 OpenGL。

* 如何查看連接(Linking)狀況? 用 `glGetProgramiv()` 及 `glGetProgramInfoLog()`

    ```cpp
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if(!success)
    {
        glGetProgramInfoLog(program, 512, nullptr, log);
        printf("Error Shader Linking error\n%s\n", log);
    }
    ```

## Link Vertex Attribute

![](https://i.imgur.com/edtm6a4.png)

由於 OpenGL 沒有規定傳入頂點資料的格式，這意味著我們可以自己決定，但也必須要我們手動指定給 OpenGL。

根據我們上面訂出的頂點陣列 `vertices[]` ，有底下幾種屬性是必須告訴 OpenGL 的:

* 頂點資料是儲存在 `float` 大小是 `sizeof(float)`
* 每個頂點有 3 個 `float` 資料，分別是 x, y, z
* 每個頂點之間沒有空隙或是其他的資料，是緊密排列(Tightly Packed)
* 開始位置是 0

可以使用 `glVertexAttribPointer` 將頂點資料的資訊告訴 OpenGL 它該怎麼解析這些頂點資料:

```cpp
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);
```

* `glVertexAttribPointer()`

```cpp
void glVertexAttribPointer(
    GLuint index,
    GLint size,
    GLenum type,
    GLboolean normalized,
    GLsizei stride,
    const GLvoid * pointer);
```

* `index` 屬性的 index
    * 可以在 Shader 中指定 `layout (location = #)`，在程式中可以用 [`glGetAttribLocation()`](http://docs.gl/gl4/glGetAttribLocation) 拿到 index
    * 或是使用 `glBindAttribLocation()` 綁定

* `size` 該頂點屬性(Attribute)的大小
    * size $\in [1, 4]$
    * 範例是 `vec3` 所以是 3

* `type` 頂點屬性的型別
    * `vec*` 是 float

* `normalized` 是否 normalize
    * `True` unsigned $[0, 1]$, signed $[-1, 1]$

* `stride`
    * 一個 vertex 的大小
    * $+$ `stride` bytes 會到下個 vertex 的同個資料

* `pointer`
    * 開頭的偏移量
    * 一個 Vertex 可能會有多種 Attribute 資料

可以參考 http://docs.gl/gl4/glEnableVertexAttribArray 底下的 Example

每個 VertexAttribute 是從 VBO 中拿頂點資料的，是哪一個 VBO 則看目前綁到哪一個 `GL_ARRAY_BUFFER`

所以到了這裡，我們已經有能力繪製東西在螢幕上了，你的 code 可能會長這樣:

```cpp
// 建立 VBO 複製頂點資料
glBindBuffer(GL_ARRAY_BUFFER, VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
// 設定頂點屬性
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);
// 使用 shader program
glUseProgram(shaderProgram);
// 畫東西
someOpenGLFunctionThatDrawsOurTriangle();
```

也許畫小東西看起來不多，但如果頂點屬性(Vertex Attribute)一多，或是有很多物體呢?
設定頂點屬性就會很麻煩，因此有 **Vertex Array Object (VAO)** 來將這些狀態都儲存起來，並可以透過綁定此物件來快速設定頂點屬性。

### VAO

Notice: 如果沒有綁定 VAO 則 OpenGL 可能不會畫出任何東西

頂點陣列物件 Vertex Array Object (VAO)，就像 VAO 或是其他 OpenGL 的東西一樣可以被綁定，綁定後的任何 Vertex Attribute 設定都會儲存在此 VAO 中。這讓設定 Vertex Attribute 變得只要綁定不同的 VAO 就好，繁雜的 Vertex Attribute 就只要設定一次就好。

![](https://i.imgur.com/0bPvnGF.png)

* 一個 VAO 會儲存以下狀態
    * VAO 是否啟用
        * `glEnableVertexAttribArray()`/`glDisableVertexAttribArray()`
    * 透過 `glVertexAttribPointer` 設定的頂點屬性
    * 頂點屬性設定時綁定之VBO

* 建立 VAO
    ```cpp
    uint32_t vao;
    glGenVertexArrays(1, &vao);
    ```
* 綁定 VAO
    ```cpp
    glBindVertexArray(vao);
    ```

綁定 VAO 後，接著綁定與設定 VBO 的頂點屬性，之後解綁 VAO ，等到要繪製時再綁定 VAO 就好。
有了 VAO 後，整個流程看起來是這樣:

```cpp
// 建立並綁定 VAO
glGenVertexArray(1, &VAO);
glBindVertexArray(VAO);

// 建立 VBO 複製頂點資料
glBindBuffer(GL_ARRAY_BUFFER, VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

// 設定頂點屬性
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);

// ...

// 繪製
glUseProgram(shaderProgram);
glBindVertexArray(VAO);
glDrawArrays(GL_TRIANGLES, 0, 3); // 三角形，從0開始，畫3個
```

## EBO / IBO

Element Buffer Object (EBO) 或 Index Buffer Object (IBO)
假設要畫一個矩形，用兩個三角形來組成一個矩形(OpenGL 主要處理三角形):

```cpp
float vertices[] = {
    // 第一個三角形
    0.5f, 0.5f, 0.0f,   // 右上角
    0.5f, -0.5f, 0.0f,  // 右下角
    -0.5f, 0.5f, 0.0f,  // 左上角
    // 第二個三角形
    0.5f, -0.5f, 0.0f,  // 右下角
    -0.5f, -0.5f, 0.0f, // 左下角
    -0.5f, 0.5f, 0.0f   // 左上角
};
```

可以發現左上角與右下角被儲存了兩次，如此以來多了 50% 的額外開銷，這在有上千上萬個三角形的模型中會更糟糕。更好的方法是:儲存單獨的頂點，用另外一個陣列來表示頂點的順序。這正是 EBO 的功能。

EBO 就跟 VBO 一樣，它也是個 Buffer，但 **EBO 專門儲存索引(Index)**

```cpp
float vertices[] = {
    0.5f, 0.5f, 0.0f,    // 右上角
    0.5f, -0.5f, 0.0f,   // 右下角
    -0.5f, -0.5f, 0.0f,  // 左下角
    -0.5f, 0.5f, 0.0f    // 左上角
};

uint32_t indices[] = {
    {0, 1, 3}, // 第一個三角形
    {1, 2, 3}  // 第二個三角形
};
```

* 建立/綁定 EBO
    ```cpp
    // 建立
    uint32_t ebo;
    ebo = glGenBuffers(1, &ebo);
    // 綁定
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    ```

* 繪製
    ```cpp
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glDrawElements(GL_TRIANGLES,  // 形狀
        6,               // 頂點數量
        GL_UNSIGNED_INT, // EBO 的 value type
        0                // offset
    );
    ```
    * `glDrawElement()` 從當前綁定的 `GL_ELEMENT_ARRAY_BUFFER` EBO 中拿到 index
    * VAO 也會儲存綁定的 EBO

![](https://i.imgur.com/ook5kIT.png)

加入 EBO 後，你的 OpenGL code 可能會長像這樣:

```cpp
// 建立並綁定 VAO
glGenVertexArray(1, &VAO);
glBindVertexArray(VAO);

// 建立 VBO 複製頂點資料
glBindBuffer(GL_ARRAY_BUFFER, VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

// 建立 EBO 並複製
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

// 設定頂點屬性
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);

// ...

// 繪製
glUseProgram(shaderProgram);
glBindVertexArray(VAO);
glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
// 三角形，畫6個，EBO的type，從0開始
```

![](https://i.imgur.com/OEkVb9E.png)

## Lab

* [1.1.hello_window](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/1.1.hello_window)
* [2.1.hello_triangle](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/2.1.hello_triangle)
* [2.2.hello_triangle_indexed](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/2.2.hello_triangle_indexed)

* 練習
    * 用 `glDrawArrays` 嘗試添加更多頂點 e.g. 彼此相連的三角形
    * 新增兩個相同的三角形，但是不同的 VAO, VBO
    * 新增兩個 Fragmanet Shader 輸出兩個不同顏色的三角形

## 小結

* 如何現代 OpenGL 畫東西？
    * 建立並綁定 Vertex Array Object (VAO)
    * 建立並綁定 Vertex Buffer Object (VBO)
        * 設定頂點資料
        * 設定頂點屬性(Vertex Attribute)
    * 建立並綁定 Element Buffer Object (EBO)
    * 編譯/連結 Shader
    * 綁定 Shader 與 VAO
    * 畫東西
