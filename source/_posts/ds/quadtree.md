---
title: QuadTree - 使用四叉樹優化碰撞檢測
date: 2020-07-19 02:10:45
categories:
- [學習紀錄, GamePhysics]
tags:
- GamePhysics
- 程式
- 筆記

---

在 2D 遊戲中，常常需要做碰撞檢測(Collision Detection)來檢測兩物體是否產生碰撞，而這類的演算法都很耗時間，如果要檢測整個 Scene 的所有物體是否有碰撞，常見的做法是 $O(n^2)$ 掃過去，這樣很大限制了同屏的物體總數，數量一多就會卡頓。

優化:對於一個物體，只要檢查它周圍的物體就好。那要怎麼時做這個優化呢?為了找出周圍的物體又去掃 $O(n^2)$ 就不是又回到上面的問題了。

那有沒有辦法先用某種資料結構儲存好物體，然後用比較好的複雜度查詢對於一個物體，它周圍的物體的集合? 四叉樹(Quad Tree)就是個用於此問題的資料結構

<img src="https://i.imgur.com/VXyD6Hd.png" width=50%>

QuadTree 是一種樹資料結構，樹上的每個節點都有四個子節點，每個節點都有一個最大容量，當超過這個容量時，會切成四個子節點。對於不同的問題，四叉樹有許多變體:

* Region QuadTree
* Point QuadTree
* Point-Region(PR) QuadTree
* Edge QuadTree
* Polygonal map(PM) QuadTree
* Compressed QuadTree
* ... 等

本文介紹的是 Point-Region QuadTree 用於 2D 碰撞偵測。

## PR QuadTree

![](https://i.imgur.com/7hbIfQO.png)

每個節點有個容量(Capacity) e.g. $C=4$，只要超過容量，就會分成四個區域

![](https://i.imgur.com/T2WCr2I.png)

### 建立

給定 2D 方形 $(X, Y, W, H)$ 以及容量 $C$，根節點是 $(0, 0, w, h)$，插入點 $p = (x, y)$ 

* 從根節點遞迴往下開始看點 p 是否有在方形內 (AABB)
* 對於節點 $i$
    * 如果有在方形內
        * 當前節點容量 $c+1 > C$ 
            * 分割成四個區域
                * 遞迴往下插入
        * $c+1 <= C$
            * 將點 $p$ 放入該節點的點集 $P_i$ 中
    * 沒有在方形內
        * 不在該區域內
* 要注意遞迴的中止點，看是要限制層數，或是看 $w == h == 1$

> TODO 圖

### 查詢

給定一 2D 矩形 $r = (x, y, w, h)$，從根節點開始往下遞迴判斷:
對於每一個節點，判斷矩形 $r$ 與節點的範圍是否有產生交疊(AABB)，如果有則代表該節點的點集是可能會產生碰撞(Possible Collision)的。

<img src="https://i.imgur.com/mkLnVzR.jpg" width=50%>

* $root = (0, 0, 800, 600), r=(100, 100, 200, 200)$
    * 有交疊，$P_{root} \in \text{Possible Collision}$
    * 檢查子節點
        * [x] $R_0 = (0, 0, 400, 300)$
            * $P_{R_0}\in \text{Possible Collision}$
            * 檢查子節點
                * [x] $R_{00} = (0, 0, 200, 150)$
                    * $P_{R_{00}}\in \text{Possible Collision}$
                * [x] $R_{01} = (200, 0, 200, 150)$
                    * $P_{R_{01}}\in \text{Possible Collision}$
                * [x] $R_{02} = (0, 150, 200, 150)$
                    * $P_{R_{02}}\in \text{Possible Collision}$
                * [x] $R_{03} = (200, 150, 200, 150)$
                    * $P_{R_{03}}\in \text{Possible Collision}$
        * [ ] $R_1 = (400, 0, 400, 300)$
        * [ ] $R_2 = (0, 300, 400, 300)$
        * [ ] $R_3 = (400, 300, 400, 300)$

### 實作

https://github.com/rishteam/QuadTree

![](https://imgur.com/UT4KtB2.gif)

## 感想

QuadTree 本質上就是對點照空間分類，鄰近的點分在同一類，如此一來變比較好查詢對於一個點其鄰近的點有哪些

## Reference

碰撞檢測的優化-四叉樹(Quadtree)
http://davidhsu666.com/archives/quadtree_in_2d/

https://en.wikipedia.org/wiki/Quadtree
https://www.cs.cmu.edu/~ckingsf/bioinfo-lectures/quadtrees.pdf

Coding Challenge #98.1: Quadtree - Part 1
https://www.youtube.com/watch?v=OJxEcs0w_kE

Make Your Game Pop With Particle Effects and Quadtrees
https://gamedevelopment.tutsplus.com/tutorials/quick-tip-use-quadtrees-to-detect-likely-collisions-in-2d-space--gamedev-374
