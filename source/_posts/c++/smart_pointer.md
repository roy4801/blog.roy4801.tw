---
title: Smart Pointer 介紹/用法
date: 2020-06-04 19:23:16
categories:
- [學習紀錄, C/C++]
tags:
- C++
- Smart Pointer
- 智慧指標
- 程式
- 教學

---

## Overview

* `unique_ptr`
  * move construct only
* `shared_ptr`
  * reference counting
* `weak_ptr`
  * weak references
* `boost:scoped_ptr`
  * only in one scope

## Smart Pointer ?

在 C/C++ 中，最令人頭痛的事情是：「管理記憶體」，必須自己手動管理物件的生命週期，如果忘記 `delete` 或是拋出了 exception ，會造成記憶體洩漏(Memory Leak)；或是 `delete` 後，pointer 並沒有清空，後面的 code 又再度使用而導致 Use-After-Free 發生；或是一個 pointer 被重複 delete 了一次以上 (double free)。

```cpp=
void foo()
{
  auto ptr = new Foo();

  func_throw_exception(); // 丟出 exception, ptr 大爆死（不會 delete)

  delete ptr;
}
```

這些種種都會考驗到程式設計師的能力，更何況程式碼是由多人維護的，可能程式碼很長，指標指的 object 生命週期很長，但是在途中被 delete 了；又或者是兩個不同的 pointer 指向了同一塊 object ，那麼要由誰來 delete 呢（誰才擁有 ownership），如果誤刪了則可能導致程式崩潰或可能不會（undefinied behavior）。

```cpp=
Foo* genFoo()
{
  return new Foo();
}

Foo *a = genFoo();
// 誰來 delete 他？

delete a;

freeFoo(a);
```

於是有人便想到了使用 `class` 來將 pointer 封裝，古早年代曾有 `auto_ptr` 嘗試解決這個問題，但[不是很成功](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2005/n1856.html#20.4.5%20-%20Class%20template%20auto_ptr)（在 `c++98` 被加入 `c++17` 時移除），在 C++11 中加入了 `unique_ptr`, `shared_ptr` 以及 `weak_ptr` 。

```cpp=
// 維護 ptr 是你的責任！
T *ptr = new T;
// ...
delete ptr;

// 概念上的 unique_ptr
template<typename T>
class unique_ptr {
  T *p = nullptr;
  /* ... */
  ~unique_ptr() {
    delete p;
  }
};
{
  unique_ptr<int> a(new int{10});
} // 出了 scope 就被 delete 了
```

上面的例子便可以改寫成：

```cpp
unique_ptr<Foo> genFoo()
{
  return unique_ptr<Foo>(new Foo);
}
```

如此一來便不用擔心資源不被釋放了，因為 `unique_ptr` 出了 scope 便會釋放(RAII)

## `unique_ptr<T>`

* Use `std::unique_ptr` for exclusive-ownership resource management
  * unique ownership
    * 一個資源只會被一個 object 所擁有

* `unique_ptr<T>` 不能複製(`operator=`)、不能 copy-construct

* <mark>只能被 move-construct</mark>
  * 代表所有權(Ownership)的轉移

```cpp=
unique_ptr<int> a(new int{10});
unique_ptr<int> b = a; // 這個會噴錯
unique_ptr<int> c;
c = a; // 這個也會噴錯
```

標準庫

```cpp=
unique_ptr<int> a = make_unique<int>(1);
unique_ptr<int> b = std::move(a);

if(a)
  std::cout << "a is good" << '\n';
if(b)
  std::cout << "b is good" << '\n';
```
```
b is good
```

* `unique_ptr<T[]>` unique_ptr 可以放 array types ，並且會被正確釋放 (呼叫 `delete []`)
  * [example](https://wandbox.org/permlink/rsGPPlRrAgCbCgRn)

```cpp=
struct Foo {
  Foo() { puts("ctor()"); }
  ~Foo() { puts("dtor()"); }
};
unique_ptr<Foo[]> a(new Foo[3]);
```

[![](https://i.imgur.com/N2wwSKD.png)](https://en.cppreference.com/w/cpp/memory/unique_ptr)

* 甚至可以自訂 `deleter` （如何刪除 pointer）
  * [example1](https://wandbox.org/permlink/mUh2rUpusxnj68eX), [example2](https://wandbox.org/permlink/l34Y9VvYRBNXkk0r), [example3](https://wandbox.org/permlink/zKWK75zrO8rRyb02)
  * 預設是 `std::default_delete<T>`
    * 就是個 function object 裡頭 call `operator delete()`

```cpp=
unique_ptr<Foo, std::function<void(Foo*)>> p(new Foo, [](Foo *p) {
  puts("custom deleter");
  delete p;
});
```

* 使用 C++11 alias template，可以不用指定 delete 的 type
  * [example](https://wandbox.org/permlink/0mrFvcBWJvwMcGMW)

```cpp=
struct Widget {};

template<typename T>
using uniquePtr = unique_ptr<T, void(*)(T*)>;

uniquePtr<Widget> ptr( new Widget, []( Widget *p ) {
  cout << "delete Widget!" << endl;
  delete p;
});
```

### 使用

* 用起來就跟 raw pointer 沒兩樣
  * [example](https://wandbox.org/permlink/1jDoZ3QAEHBjL59R)

```cpp=
ue_ptr<int> a = make_unique<int>();
*a = 87;

// custom class
unique_ptr<Foo> b = make_unique<Foo>(4801);
cout << b->getId() << '\n';;

// array
unique_ptr<int[]> c = make_unique<int[]>(10);
for(int i = 0; i < 10; i++)
  c[i] = i;
```

* `void reset (pointer p = pointer())` 重設
  * [example](https://wandbox.org/permlink/WI6OZWzC1K4dvhu6)

```cpp=
unique_ptr<int> a = make_unique<int>(123);
a.reset(new int{2}); // destroy 123 and take the ownership of 2
```

* `pointer release()` 釋放所有權
  * 釋放 `unique_ptr` 所維護的指標的所有權(Ownership)
    * 回傳 pointer 並將 `unique_ptr` 內部的 `ptr = nullptr`
  * [Example](https://wandbox.org/permlink/OlGqKGizZIpixNma)

```cpp=
unique_ptr<int> a = make_unique<int>();
*a = 87;

int *b = a.release();
delete b;
```

* `pointer get()` 獲取 `unique_ptr` 底下的 raw pointer
  * [Example](https://wandbox.org/permlink/Bl2NINecJdxywbtr)

```cpp
unique_ptr<int> a = make_unique<int>(10);
int *p = a.get(); // raw pointer
```

### 一些坑

* unique-ownership
  * `unique_ptr` 是獨占資源的，如果用同個 raw pointer 來初始化多個 `unique_ptr` 會被 delete 數次
  * 以下是錯誤的範例

```cpp=
struct Foo {};

Foo *f = new Foo();
unique_ptr<Foo> a(f);
unique_ptr<Foo> b(f);
// f 會被 delete 兩次，導致 undefinied behaviour
```

* Exception 安全
  * 用 Raw pointer 創建 `unique_ptr` 不保證 exception 安全

    ```cpp=
    func(unique_ptr<Foo>(new Foo), func_throw_exception());
    ```

    * C++ 標準並沒有規定對參數的 evaluate 之順序
      * 所以可能出現這樣的順序：
        * `new Foo`
        * `func_throw_exception()`
        * `unique_ptr<Foo>(...)`
      * 在 `func_throw_exception()` 時會拋出 exception，導致無法建構 `unique_ptr` ，造成 `new Foo` 無法回收，導致記憶體洩漏(Memory Leak)
  * 使用 `make_unique<T>()` 則可以解決這個問題

    ```cpp
    func(make_unique<Foo>(), func_throw_exception());
    ```

* 到了 c++14 才有 `make_unique<T>()` 這個 function，並沒有在以前的標準，但是自己實現並不複雜

```cpp=
template<typename T, typename... Args>
std::unique_ptr<T> make_unique(Args&&... args)
{
  return std::unique_ptr<T>( new T(std::forward<Args>(args)...) );
}
```

## `shared_ptr<T>`

跟 `unique_ptr` 不同的是，`shared_ptr` 可以讓同個資源給多個 `shared_ptr` 「共用」，所以 `shared_ptr` **可以複製**。

```cpp=
shared_ptr<int> a = make_shared<int>(10);
shared_ptr<int> b = a;
```

[Example1](https://wandbox.org/permlink/uxTK0I8svtw77PmF)

`shared_ptr` 內部實作 Reference Count ，每當有一個 `shared_ptr` 建立並指向同個資源時，Reference Count 變加一，當一個 `shared_ptr` 被 destruct 時，會把 Reference Count 減一。當最後一個指向資源的 `shared_ptr` 被 destruct 時，則會釋放資源。

![](https://i.imgur.com/5hqJUVf.png)

> 比喻：有一個房間有一盞燈（資源），房間裡有很多人（共享），約定好最後一個出去的關燈（釋放資源）

**指向同個 object** 之所有的 `shared_ptr` 共用一個 Control Block ，上頭有 Reference Count 以及其他 `shared_ptr` 會用到的東西

### 使用

* `shared_ptr` 的用法跟 `unique_ptr` 差不多

* `use_count()` 回傳 `shared_ptr` 的 reference count
  * [Example](https://wandbox.org/permlink/wewpZFc0UJLzTOVw)

  ```cpp
  shared_ptr<int> a = make_shared<int>();
  shared_ptr<int> b = a;
  printf("%d\n", b.use_count()); // 2
  ```

* `unique()` 是否唯一
  * [Example](https://wandbox.org/permlink/NZmY1rRH1mZhK9EG)

  ```cpp
  shared_ptr<int> a = make_shared<int>();
  {
    shared_ptr<int> b = a;
    printf("%d\n", b.unique()); // 0
  }
  printf("%d\n", a.unique()); // 1
  ```

* `shared_ptr` 有提供轉型指標(cast)
  * `static_pointer_cast<T>(sp)`
    * 相當於 `static_cast<T*>(sp.get())`
  * `dynamic_pointer_cast<T>(sp)`
    * 相當於 `dynamic_cast<T*>(sp.get())`
  * `const_pointer_cast<T>(sp)`
    * 相當於 `const_cast<T*>(sp.get())`
  * [Example](https://wandbox.org/permlink/tzrMWn0p5Fxds4Bu)

### 一些坑

但是事情並沒有那麼美好，`shared_ptr` 還是會有些坑

* 用同個 raw pointer 重複初始化 `shared_ptr`
  * 會導致重複釋放資源
  * [Example](https://wandbox.org/permlink/FtJrudxmYldlNfa8)

  ```cpp
  Foo *f = new Foo();
  shared_ptr<Foo> a(f);
  {
    shared_ptr<Foo> b(f);
  }
  ```

  * 結論：用 `make_shared<>()` 就好

* `unique_ptr` 可以轉成 `shared_ptr` ，但是反過來不行

* `shared_ptr` 原生不支援陣列型態
  * 沒有 `operator[]`
  * 沒有特化的 deltetr，必須自己給

* 循環參考 (Circular Reference)
  * [Example](https://wandbox.org/permlink/fTMsKxwRduSe7zCw)

  ```cpp=
  struct Foo{
    /* ... */
    shared_ptr<Foo> next;
  };

  shared_ptr<Foo> a = make_shared<Foo>(1);
  shared_ptr<Foo> b = make_shared<Foo>(2);

  a->next = b;
  b->next = a;
  ```

  * 猜猜上面的 code 到最後有誰會被釋放
    * 答案是 0 個
  * 因為循環參考(Circular Reference)的關係

## `weak_ptr<T>`

`weak_ptr` 並不會增加 `shared_ptr` 的 reference count ，亦不會搶走所有權 (Ownership)

用於解決循環參考(Circular Reference)的問題，跟 `shared_ptr` 搭配使用
將上面的例子改寫成:

[Example](https://wandbox.org/permlink/JSUEZg5sPUhAnhH2)

```cpp=
struct Foo{
  /* ... */
  weak_ptr<Foo> next;
};

shared_ptr<Foo> a = make_shared<Foo>(1);
shared_ptr<Foo> b = make_shared<Foo>(2);

a->next = b;
b->next = a;
```

最後則會正常釋放

### 使用

* `weak_ptr` 並不能直接存取(沒有 `operator->`)，如果要存取的話，必須使用 `.lock()` 轉成 `shared_ptr`

```cpp
shared_ptr<int> a = make_shared<int>(10);
{
  weak_ptr<int> w = a;
  //
  auto ws = w.lock();
  cout << *ws << '\n'; // 10
}
```

* `.expired()` 查看 `weak_ptr` 使否可用
  * [Example](https://wandbox.org/permlink/xKjQ9iOKoAqClBdW)

```cpp=
std::shared_ptr<int> shared (new int(10));
std::weak_ptr<int> weak;

std::cout << "1. weak " << (weak.expired()?"is":"is not") << " expired\n";
// 1. weak is expired

weak = shared;

std::cout << "2. weak " << (weak.expired()?"is":"is not") << " expired\n";
// 2. weak is not expired
```

## 結論

* `unique_ptr` 單獨擁有(Ownership)一個資源，如果要給別人要用 `std::move()`
* `shared_ptr` 在需要多個人共同擁有一個資源時使用
* `weak_ptr` 在不想要給擁有權，但又想要它看的到並摸得到資源時

## 參考

Learncpp
<https://www.learncpp.com/>

Why is auto_ptr being deprecated?
<https://stackoverflow.com/questions/3697686/why-is-auto-ptr-being-deprecated>

CppCon 2019: Arthur O'Dwyer “Back to Basics: Smart Pointers”
<https://www.youtube.com/watch?v=xGDLkt-jBJ4>

深入 C++ 的 unique_ptr
<http://senlinzhan.github.io/2015/04/20/%E8%B0%88%E8%B0%88C-%E7%9A%84%E6%99%BA%E8%83%BD%E6%8C%87%E9%92%88/>

How to implement make_unique function in C++11?
<https://stackoverflow.com/questions/17902405/how-to-implement-make-unique-function-in-c11>

山姆大叔談 C++：從歷史談起，再給個定義—Modern C++ 解惑
<https://ithelp.ithome.com.tw/articles/10213866>
<https://ithelp.ithome.com.tw/articles/10214337>

<https://kheresy.wordpress.com/2012/03/05/c11_smartpointer_p2/>

<https://blog.jaycetyle.com/2019/11/passing-smart-pointer/>