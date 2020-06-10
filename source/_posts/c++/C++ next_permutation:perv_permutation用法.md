---
title: next_permutation/perv_permutation用法
date: 2018-08-23 17:48:03
categories:
- [學習紀錄, C/C++]
tags:
- C++
- STL
- 程式
- 教學

---

## C++ STL 組合

STL中提供了兩個template function可以舉出一組資料的所有組合：分別是`next_permutation()`與`prev_permutation()`

組合順序交換的依據是照**字典排序**(*lexicographically*)

> 有如有一組資料是`{'a', 'b', 'c'}`
> 那麼next_permutation()的順序就會是：
> abc < acb < bac < bca < cab < cba
> 就如字典排列的順序一般

以上面的例子說明：`abc`是開頭，而`cba`是結束
`next_permutation()`是找出右邊的組合（以字典序來說比較大），而`prev_permutation()`是找出左邊的組合（以字典序來說比較小），碰到開始或結束就return false，否則return true（代表還有沒有舉出的組合）。

### 用法

要使用`next_permutation()`與`prev_permutation()`必須include標頭檔algorithm
```cpp
#include <algorithm>
```
跟許多STL的function一樣，輸入的iterator是$[first, last)$的形式。

另外，此函式有兩個版本，一個是預設使用operator<來進行大小判斷；而另一個是則是可以自訂比較的方法。
看個人的需求使用即可。

##### 要注意的事
由於`next_permutation()`實作的關係，如果要求出*全部的組合*，資料必須要先*遞增*(ascending)排序過才行。

#### 1. 預設(Default)
```cpp=
template <class BidirectionalIterator>
bool next_permutation(BidirectionalIterator first, BidirectionalIterator last);
```

```cpp=
int arr[] = {1, 2, 3};

do
{
    // Do something
    for(const int i : arr)
        printf("%d ", i);
}
while(next_permutation(arr, arr+3));
```
輸出
```
1 2 3 
1 3 2 
2 1 3 
2 3 1 
3 1 2 
3 2 1 
```


#### 2. 自訂(Custom)
```cpp=
template <class BidirectionalIterator, class Compare>
  bool next_permutation(BidirectionalIterator first, BidirectionalIterator last, Compare comp);
```
有時候在自訂的class/struct需要用到自訂判斷的function，或是標準庫的東西行為不是開發者所預期的，這是自訂判斷的版本就派上用場了。

範例：假設有一組這樣的資料，我們想求出pair有多少種組合
```cpp=
vector<pair<int, int> > v;
    
v.push_back(pair<int, int>(1, 3000));
v.push_back(pair<int, int>(3, 5000));
v.push_back(pair<int, int>(2, 9000));
```

在用上`next_permutation()`之前，要先自訂判斷的struct。
```cpp=
struct ComparePair
{
    // overloading operator()
    bool operator()(const pair<int, int> &lhs, const pair<int, int> &rhs)
    {
        return lhs.first < rhs.first;
    }
}comparePair;
```

才使用`next_permutation()`
```cpp=
sort(v.begin(), v.end(), comparePair);
    
do
{
    for(const auto &i : v)
    {
        cout << i.first << ' ' << i.second << endl;
    }
}
while(next_permutation(v.begin(), v.end(), comparePair));
```

輸出

```
1 3000 2 9000 3 5000 
1 3000 3 5000 2 9000 
2 9000 1 3000 3 5000 
2 9000 3 5000 1 3000 
3 5000 1 3000 2 9000 
3 5000 2 9000 1 3000 
```

#### [Source Code](https://ideone.com/ioPYEH)

### 參考

cplusplus.com -- std::next_permutation
http://www.cplusplus.com/reference/algorithm/next_permutation/

next_permutation compare function
https://stackoverflow.com/questions/24150840/next-permutation-compare-function

【STL】next_permutation的原理和使用
http://leonard1853.iteye.com/blog/1450085

next_permutation(全排列算法)
https://blog.csdn.net/c18219227162/article/details/50301513