---
title: OpenGL 筆記 - Shader
date: 2020-07-08 00:31:45
categories:
- [學習紀錄, C/C++]
tags:
- OpenGL
- 程式
- 筆記
- 圖學
- Shader

---

## GLSL

GLSL(OpenGL Shading Language Language)是 OpenGL 的著色器語言，它長得有點像C語言，一個 Shader 通常長這樣:

```glsl
#version version_number
in type in_variable_name;
in type in_variable_name;

out type out_variable_name;

uniform type uniform_name;

int main()
{
  // 處理輸入並進行一些圖形操作
  ...
  // 輸出處理過的結果到輸出變數
  out_variable_name = weird_stuff_we_processed;
}
```

輸入的變數叫頂點屬性(Vertex Attribute)，可以用 `glVertexAttribPointer()` 來描，OpenGL 通常保證有 16 個的頂點屬性可以使用，在大多數情況都夠用

```cpp
int nrAttributes;
glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;
```

## 數據類型

GLSL 有C語言及其他語言大多都有的 type:`int`, `float`, `double`, `uint`, `bool`，另位還有兩種容器 type: 向量(Vector)跟矩陣(Matrix)

* 向量
    * 可以有 $[1, 4]$ 個分量
    * `vecn` 包含 $n$ 個 `float`
    * `bvecn` 包含 $n$ 個 `bool`
    * `ivecn` 包含 $n$ 個 `int`
    * `uvecn` 包含 $n$ 個 `unsigned int`
    * `dvecn` 包含 $n$ 個 `double`

* 分量用 `.x`, `.y`, `.z`, `.w` 來存取分量，或是`rgba`(顏色)跟`stpq`(材質)來存取。

* 重組(Swizzling)
    * 可以用分量的組合來建立新的 vec
    ```glsl
    vec2 someVec;
    vec4 differentVec = someVec.xyxx;
    vec3 anotherVec = differentVec.zyw;
    vec4 otherVec = someVec.xxxx + anotherVec.yxzy;
    ```

## 輸入與輸出

GLSL 可以用 `in`, `out` 來標示一個變數是傳入還是傳出，上個 Shader 所指定的 `out` 會對應到下個 Shader 所指定的 `in` 變數，名稱要相同。

* Vertex Shader
```glsl
#version 330 core
layout (location = 0) in vec3 aPos;

out vec3 vertexColor; // to Fragment Shader

void main()
{
    gl_Position = vec4(aPos, 1.0);
    vertexColor = vec4(0.5, 0.0, 0.0, 1.0)
}
```
* Fragment Shader
```glsl
#version 330 core
in vec3 vertexColor; // from Vertex Shader

out vec4 FragColor;

void main()
{
    FragColor = vertexColor;
}
```

`layout (location = 0)` 可以指定 Vertex Attribute 的 Index 這在傳入 Vertex Data 之後，可以用 `glVertexAttribPointer()` 來描述頂點資料是怎麼排列的，讓 OpenGL 可以正確的繪製

![](https://i.imgur.com/TQBZBTS.png)

## Uniform

Uniform 是 CPU 向 GPU 的 Shader 發送數據的方式，但跟 Vertex Attribute 有點不同。
Uniform 可以在**所有的 Shader 中存取**，而不用像 Vertex Attribute 是要用 `in`, `out` 傳資料，意思是 Uniform 是 Global 的變數，它必須是 **獨特的(Unique)** 的。

```glsl
#version 330 core
out vec4 FragColor;

uniform vec4 ourColor; // 在 Code 中傳入

void main()
{
    FragColor = ourColor;
}
```

* 如果宣告了一個 `uniform` 卻沒有使用，編譯器可能會移除該變數，導致在最後編譯出的版本不會包含它

* 傳入 uniform
    * 使用 [`glGetUniformLocation()`](http://docs.gl/gl4/glGetUniformLocation) 以及 [`glUniform4f()`](http://docs.gl/gl4/glUniform)
    ```cpp
    float green = /* expression for calculating green */;
    // 查詢 ourColor 的位置
    int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
    // 啟用 shader
    glUseProgram(shaderProgram);
    // 傳入 ourColor 的值 (vec4)
    glUniform4f(vertexColorLocation, 0.0f, green, 0.0f, 1.0f);
    ```

因為 OpenGL 是 C 的 Library，所以不支援 Overloading ，因此同樣功能但參數不同的 Function 是以後綴的形式存在：

| 後綴 | 意義 |
| -------- | -------- |
| `f` | float |
| `i` | int |
| `ui` | unsigned int |
| `3f` | 三個 float |
| `fv` | array of float |

* [範例 3.1 Shader Uniform](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/3.1.shader_uniform)

![](https://i.imgur.com/q10ZdBc.gif)

## 多個頂點屬性

前面講過了要如何建立 VBO，而現在我們想把顏色的資料加到頂點資料當中

```cpp
float vertices[] = {
    // 位置              // 顏色
     0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // 右下
    -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // 左下
     0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // 上方
};
```

* Vertex Shader
    ```glsl
    #version 330 core
    layout (location = 0) in vec3 aPos;
    layout (location = 1) in vec3 aColor;

    out vec3 ourColor; // 輸出到 Fragment Shader

    void main() {
        gl_Position = vec4(aPos, 1.0);
        ourColor = aColor;
    }
    ```

* Fragment Shader
    ```glsl
    #version 330 core
    out vec4 FragColor;

    in vec3 ourColor;   // 從 Vertex Shader 輸入的顏色，名稱要一樣

    void main() {
        FragColor = ourColor;
    }
    ```

因為我們的頂點資料配置不同了，所以要重新指定，使用 `glVertexAttribPointer()`

![](https://i.imgur.com/d1vwqTg.png)

```cpp
// Position        index,size,  type, normalize, stride,        offset 
glVertexPointerAttrib(0, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), (void*)0);
glEnableVertexAttribArray(0);
// Color
glVertexPointerAttrib(1, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), (void*)(3*sizeof(float)));
glEnableVertexAttribArray(1);
```

![](https://i.imgur.com/BRDiEj0.png)

只指定三個頂點的顏色，但是顯示出來的顏色是連續的是因為 OpenGL 在 Fragment Shader 中進行了片段插植(Fragment Interpolation)

* [3.3.lab1](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/3.3.lab1)
* [3.4.lab2](https://github.com/rishteam/OpenGL_learning/tree/master/LearnOpenGL/src/1.getting_started/3.4.lab2)
