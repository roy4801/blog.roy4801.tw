---
title: dear imgui 安裝 - 使用 imgui-SFML
date: 2020-03-25 02:40:42
categories:
- [學習紀錄, C/C++]
tags:
- C++
- 程式
- 教學
- C++ Library
- imgui

---

<img src="https://raw.githubusercontent.com/wiki/ocornut/imgui/web/v167/v167-misc.png" width="50%">

Dear imgui 並沒有侷限底層使用的繪圖 API，其本身及提供很多支援，甚至可以很方便地移植到其他繪圖 API 上。

* 官方維護的 bindings:
  * DirectX 9~12
  * OpenGL 2/3/ES/ES2
  * Vulkan
  * Metal

官方推薦使用方式是到 [imgui/examples](https://github.com/ocornut/imgui/tree/master/examples) 挑你要的 example 整合到你的專案裡頭。

## imgui-SFML

由於我使用了 [SFML](https://www.sfml-dev.org/) 這個函式庫來開發，所以使用由 [eliasdaler](https://github.com/eliasdaler) 維護的 [imgui-SFML](https://github.com/eliasdaler/imgui-sfml) binding。
imgui-SFML 提供了 CMake 支援，可以很容易的整合進 CMake 專案裡頭。

```cmake
find_package(ImGui-SFML REQUIRED)
target_link_libraries(my_target PRIVATE ImGui-SFML::ImGui-SFML)
```

### Setup

將 [imgui](https://github.com/ocornut/imgui) 與 [imgui-SFML](https://github.com/eliasdaler/imgui-sfml) clone 下來，並 cd 到 `imgui-sfml/`

```bash
git clone https://github.com/eliasdaler/imgui-sfml.git
git clone https://github.com/ocornut/imgui.git
cd imgui-sfml
```

建立目錄 `build/` 之後 `cmake` 產生編譯檔案（我用 msys2 作為 Windows 下的編譯環境，因為有良好的 package system 以及 gnu-toolchain）。

```
mkdir build && cd build
cmake -G "MSYS Makefiles" -DIMGUI_DIR=`pwd`/../../imgui -DBUILD_SHARED_LIBS=OFF -DIMGUI_SFML_BUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX:PATH=/mingw32 ..
make -j6
make install
```

* cmake 參數解釋
  * `-DIMGUI_DIR=` imgui 所在之路徑（絕對路徑）
  * `-DBUILD_SHARED_LIBS=` 指定是否建立共享函式庫（dll/so/dylib)
  * `-DIMGUI_SFML_BUILD_EXAMPLES=` 是否要建置 imgui-SFML 的範例
  * `-DCMAKE_INSTALL_PREFIX:PATH=` 安裝目錄的前綴

* `CMakeLists.txt`

    ```cmake
    cmake_minimum_required(VERSION 3.1)

    project(imgui_sfml_example
        LANGUAGES CXX
    )

    set(CMAKE_CXX_STANDARD 14)

    add_executable(imgui_sfml_example
        main.cpp
    )

    if(APPLE)
        set(SFML_STATIC_LIBRARIES False)
        set(SFML_DIR "/usr/local/Cellar/sfml/2.5.1")
    elseif(MSYS)
        set(SFML_STATIC_LIBRARIES False)
        set(SFML_DIR "/mingw32/lib/cmake/SFML")
    else()
        message(WARNING "Not supported")
    endif()

    find_package(SFML 2.5 COMPONENTS system window graphics network audio REQUIRED)
    target_link_libraries(imgui_sfml_example
        sfml-system sfml-window sfml-graphics sfml-network sfml-audio
    )

    find_package(ImGui-SFML REQUIRED)
    target_link_libraries(imgui_sfml_example
        ImGui-SFML::ImGui-SFML
    )

    if(MSYS)
        target_link_libraries(imgui_sfml_example
            # -mconsole / -mwindows
        )
    endif()
    ```

* `main.cpp`

    ```cpp
    #include <imgui.h>
    #include <imgui-SFML.h>

    #include <SFML/Graphics/RenderWindow.hpp>
    #include <SFML/System/Clock.hpp>
    #include <SFML/Window/Event.hpp>

    int main()
    {
        sf::RenderWindow window(sf::VideoMode(1280, 720), "");
        window.setVerticalSyncEnabled(true);
        ImGui::SFML::Init(window);

        sf::Color bgColor;

        float color[3] = { 0.f, 0.f, 0.f };

        // let's use char array as buffer, see next part
        // for instructions on using std::string with ImGui
        char windowTitle[255] = "ImGui + SFML = <3";

        window.setTitle(windowTitle);
        window.resetGLStates(); // call it if you only draw ImGui. Otherwise not needed.
        sf::Clock deltaClock;
        while (window.isOpen()) {
            sf::Event event;
            while (window.pollEvent(event)) {
                ImGui::SFML::ProcessEvent(event);

                if (event.type == sf::Event::Closed) {
                    window.close();
                }
            }

            ImGui::SFML::Update(window, deltaClock.restart());

            // begin window
            ImGui::Begin("Sample window");

            // Background color edit
            if (ImGui::ColorEdit3("Background color", color)) {
                // this code gets called if color value changes, so
                // the background color is upgraded automatically!
                bgColor.r = static_cast<sf::Uint8>(color[0] * 255.f);
                bgColor.g = static_cast<sf::Uint8>(color[1] * 255.f);
                bgColor.b = static_cast<sf::Uint8>(color[2] * 255.f);
            }

            // Window title text edit
            ImGui::InputText("Window title", windowTitle, 255);

            if (ImGui::Button("Update window title")) {
                // this code gets if user clicks on the button
                // yes, you could have written if(ImGui::InputText(...))
                // but I do this to show how buttons work :)
                window.setTitle(windowTitle);
            }
            ImGui::End(); // end window

            window.clear(bgColor); // fill background with color
            ImGui::SFML::Render(window);
            window.display();
        }

        ImGui::SFML::Shutdown();
    }
    ```

* 將 `CMakeLists.txt` 與 `main.cpp` 放於同一目錄，並執行以下指令進行編譯

    ```bash
    mkdir build && cd build
    cmake ..
    make
    ```

![](https://i.imgur.com/xmpWTFl.gif)
![](https://i.imgur.com/wjqwu7Q.png)