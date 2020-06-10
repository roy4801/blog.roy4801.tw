---
title: spdlog 介紹與使用
date: 2020-05-17 19:55:35
categories:
- [學習紀錄, C/C++]
tags:
- C++
- 程式
- 教學
- C++ Library
- imgui

---

Fast C++ logging library.
一個輕量且快速的 log library

https://github.com/gabime/spdlog

* 特性
    * [快速](https://github.com/gabime/spdlog#benchmarks)
    * header-only
    * 豐富、自訂的格式化，使用 [fmt](https://github.com/fmtlib/fmt)
    * 單、多線程 logger

## 用法

* header file
```cpp
#include <spdlog/spdlog.h>
```

### 新建 Logger

* 新建一個 console logger

```cpp
#include <spdlog/sinks/stdout_color_sinks.h>
auto logger = spdlog::stdout_color_mt("name");
// type = std::shared_ptr<spdlog::logger>

// stderr logger
auto err_logger = spdlog::stderr_color_mt("stderr");
```

* Rotating Logger 
    * 當 log 超過一定大小，會清空當前 log
    * `spdlog::rotating_logger_mt`

```cpp
#include <spdlog/sinks/rotating_file_sink.h>
auto file_logger = spdlog::rotating_logger_mt("file_logger", "logs/mylogfile", 1048576 * 5, 3);
// logger_name, log file path, max_file_size, max_files
```

* Asynchronous loggers

```cpp
#include "spdlog/async.h"
void async_example()
{
    // default thread pool settings can be modified *before* creating the async logger:
    // spdlog::init_thread_pool(8192, 1); // queue with 8k items and 1 backing thread.
    auto async_file = spdlog::basic_logger_mt<spdlog::async_factory>("async_file_logger", "logs/async_log.txt");
    // alternatively:
    // auto async_file = spdlog::create_async<spdlog::sinks::basic_file_sink_mt>("async_file_logger", "logs/async_log.txt");
}
```

### 手動建立 logger
* 手動建立的 logger 並不會自動註冊到 global 中，要自己手動 `spdlog::register_logger()`

```cpp
auto sink = std::make_shared<spdlog::sinks::stdout_sink_mt>();
auto my_logger= std::make_shared<spdlog::logger>("mylogger", sink);
```

* 建立多個輸出的 logger
    * 將多個 sink 綁定到 `spdlog::logger` 上
    * e.g. 同時輸出 stdout 跟檔案

```cpp=
// 建立 sinks
std::vector<spdlog::sink_ptr> sinks;
sinks.push_back(std::make_shared<spdlog::sinks::stdout_sink_mt>());
sinks.push_back(std::make_shared<spdlog::sinks::basic_file_sink_mt>("name.log", true));
// 建立 logger 並使用 sinks
auto logger = std::make_shared<spdlog::logger>("logger_name", begin(sinks), end(sinks));
// 註冊 logger
spdlog::register_logger(logger);
// 如果已有同名的 logger 則會拋出 `spdlog::spdlog_ex`
```

* 不同的 logger 輸出至同個檔案
    * 使用同個 sink

```cpp
auto sharedSink = std::make_shared<spdlog::basic_file_sink_mt>("log_name.log");
auto firstLogger = std::make_shared<spdlog::logger>("first", sharedSink);
auto secondLogger = std::make_shared<spdlog::logger>("second", sharedSink);
```

* `sink` 是實際負責寫入 log 的 class，每種 `sink` 只負責一種 log 方式。每個 `logger` 存有一個或多個 `sink` (`std::vector<std::shared_ptr<sink>>`)
    * 甚至[自己實作 `sink`](https://github.com/gabime/spdlog/wiki/4.-Sinks#implementing-your-own-sink)
    * [教學](https://github.com/gabime/spdlog/wiki/4.-Sinks)
    * [sinks 列表](https://github.com/gabime/spdlog/tree/v1.x/include/spdlog/sinks)

### 輸出 log

* 輸出 log

```cpp
logger->trace("trace");
logger->info("info");
logger->warn("warning");
logger->error("error");
logger->critical("critical");
```

![](https://i.imgur.com/xsid3xG.png)

* 設定 pattern
    * [pattern 格式](https://github.com/gabime/spdlog/wiki/3.-Custom-formatting)
```cpp
logger->set_pattern("[%T] [%n] %^[%l]%$: %v");
```
    

* 檔案 log

```cpp=
try
{
    auto fileLogger = spdlog::basic_logger_mt("basic_file_logger", "test.log");
    fileLogger->trace("trace");
    fileLogger->info("info");
    fileLogger->warn("warning");
    fileLogger->error("error");
    fileLogger->critical("critical");
}
catch(const spdlog::spdlog_ex &e)
{
    std::cout << "File logger init failed: " << e.what() << '\n';
}
```
![](https://i.imgur.com/huFJAah.png)


* 可以使用 `spdlog::get("name")` 已經註冊過的 Logger
    * 用此方法可能會比較慢，因為會 lock 住 mutex
```cpp
{
    // 新建 stdout logger
    auto testLogger = spdlog::stdout_color_mt("test");
}
spdlog::get("test")->info("hello");
```

* 刪除已註冊的 `logger`

```cpp
// 刪除叫 `logger_name` 的 logger
spdlog::drop("logger_name");
// 刪除全部
spdlog::drop_all();
```

## 參考

gabime/spdlog
https://github.com/gabime/spdlog

spdLog的使用
https://blog.csdn.net/yanxiaobugyunsan/article/details/79088533

spdlog源码阅读 (1): sinks
https://www.cnblogs.com/eskylin/p/6483199.html

log库spdlog简介及使用
https://blog.csdn.net/fengbingchun/article/details/78347105

