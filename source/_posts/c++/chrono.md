---
title: C++ - chrono 計時
date: 2020-07-20 22:42:03
categories:
- [學習紀錄, C/C++]
tags:
- C++
- STL
- 程式
- 教學

---

C++11 提供了 [`<chrono>`](http://www.cplusplus.com/reference/chrono/) 作為時間的 library，除了能夠獲取時間，且可以在多個單位轉換。

這個 Library 是只有時間 e.g. 小時、分鐘、秒..等，如果要日期則要使用其他 Library e.g. [HowardHinnant/date](https://github.com/HowardHinnant/date) 或是 `ctime()`

* `duration`
    * 時間的長度，可自由決定儲存的單位
* `time_point`
    * 時間點，相減會得到時間長度(`duration`)
* Clocks
    * 根據物理時間回傳時間點(`time_point`)
    * 提供不同精度的 clock

標頭檔：
```cpp
#include <chrono>
```

所有的東西在 `std:chrono` 這個 namespace 底下。

## TL;DR

```cpp
// skip std::chrono::
auto start = steady_clock::now();

// do things

auto elasped = steady_clock::now() - start;

auto mili = duration_cast<miliseconds>(elapsed); // int
auto sec = duration_cast<seconds>(elapsed);      // int

auto sec_float = duration<float>(elapsed);       // float
auto sec_double = duration<double>(elapsed);     // double
```

```cpp
duraiton_cast<duration<float>>(elapsed); // 也可以
```

* 或是封裝一下
    * 參考 https://www.learncpp.com/cpp-tutorial/8-16-timing-your-code/

```cpp
class Timer
{
private:
  using clock_type = std::chrono::high_resolution_clock;
  using second_type = std::chrono::duration<double, std::chrono::seconds::period>;

  std::chrono::time_point<clock_type> m_startTime;

public:
  Timer() : m_startTime(clock_type::now())
  {
  }

  double reset()
  {
    double dt = getElapsed();
    m_startTime = clock_type::now();
    return dt;
  }

  double getElapsed() const
  {
    return std::chrono::duration_cast<second_type>(clock_type::now() - m_startTime).count();
  }
};
// Timer t;
// t.getElasped();
```

## duration

```cpp
template <class Rep, class Period = ratio<1> >
class duration;
```

儲存著時間的長度，並可以根據單位不同做選擇

```cpp=
typedef duration<long long, nano>  nanoseconds;  // 10^-9
typedef duration<long long, micro> microseconds; // 10^-6
typedef duration<long long, milli> milliseconds; // 10^-3
typedef duration<long long>        seconds;      // 基準點
typedef duration<int, ratio<60>>   minutes;      // 1 min  = 60 s
typedef duration<int, ratio<3600>> hours;        // 1 hour = 3600 s
```

* `count()` 獲得 duration 的值（時間長度）

```cpp
milliseconds s(1000);
// s.count() == 1000
```

* `duration_cast<T>()` 轉換時間長度單位

```
seconds a(4);
// duration_cast<milliseconds>(a) == 4000
```

轉換是透過一開始定義的 `ratio`

* `std::ratio<N, D>` 比例
    * 用來表示分數的 class
    * `N` 是分子(numerator)，`D` 是分母(denominator)

    ```cpp
    typedef std::ratio<1,3> one_third;
    // one_third::num == 1
    // one_third::den == 3
    ```
    * 並且由提供一些預設的 ratio
        ![](https://i.imgur.com/FMrJvlG.png)

可以用 `::period` 拿到 dutaion 的 ratio

```cpp
duration<double, miliseconds::period> s; // 宣告了用 double 儲存的 milisecond
```

## Clock

時鐘，標準庫有三種時鐘：

* `system_clock`
    * 系統時間
* `steady_clock`
    * 單調：下一個時間點永遠不會小於上一個
* `high_resolution_clock`
    * 更高精度
    * 有些平台上就是 `steady_clock`

`now()` 可以獲得現在時間，會回傳 `time_point`

```cpp
auto a = system_clock::now();
auto b = steady_clock::now();
auto c = high_resolution_clock::now();
```

## time_point

```cpp
template <class Clock, class Duration = typename Clock::duration>
class time_point;
```

儲存著時間點（相對於時鐘的開始時間），內部會儲存著 `duration`。幾乎不會有需要自己 contruct `time_point` 的機會，通常都是使用 clock 的 alias，例如：

```cpp
// ignore std::chrono::
system_clock::time_point today = system_clock::now();
steady_clock::time_point t1 = steady_clock::now();
high_resolution_clock::time_point t1 = high_resolution_clock::now();
```

`time_point` 運算後會得到 `duration`

```cpp=
chrono::steady_clock::time_point s = chrono::steady_clock::now();
// do some work
chrono::steady_clock::time_point e = chrono::steady_clock::now();
chrono::microseconds dt = 
    chrono::duration_cast<chrono::microseconds>(e - s);
```

另外還有 `time_point_case<T>()` 可以轉換 time_point 但較少用到所以省略。

`time_point` 可以跟 `duration` 做運算：
* 例子：10 分鐘後
    ```cpp
    auto n = steady_clock::now();
    auto fu = n + minutes(10);
    ```

## 其他

* 轉成日期

```cpp
auto now = system_clock::now();
time_t t = system_clock::to_time_t(now);
printf("%s\n", ctime(t));
// Mon Jul 20 21:53:33 2020
```

* 獲得 clock 的精度

```cpp
printf("%e\n", (double)steady_clock::period::num/steady_clock::period::den);
```

## 參考

LeanCpp 8.16 — Timing your code
https://www.learncpp.com/cpp-tutorial/8-16-timing-your-code/

C++11 STL 的時間函式庫：chrono
https://kheresy.wordpress.com/2013/12/27/c-stl-chrono/
