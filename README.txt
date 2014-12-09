===============================================================================

【來源】

這個 mme 專用的 trunk / repository 來源如下

(1) freeDiameter
hg version 1.2.0 (疑似)
http://www.freediameter.net/

(2) 其他的部分 epc trunk version 1229
http://140.92.62.236/svn_pool/LTE_EPC_repos/trunk/

===============================================================================

【執行環境 與 編譯環境】

已經驗證過的：Ubuntu 14.04 i386 (32位元) 版本，server 或 desktop 都行

其他的：自己想辦法

由於裡面用到的 asn1 這個 library，只有 binary code (當初花錢買的)
而當初買的時候，只有買 32 位元的，想換 64 位元當環境的人請自己三思

===============================================================================

【編譯前請先安裝】

$ sudo apt-get install -y git tree cmake gcc g++ libsctp1 libsctp-dev libssl-dev indent autoconf automake libreadline6 libreadline-dev libtool flex bison libgnutls-dev libgcrypt-dev libidn11-dev pv chrpath bridge-utils

其中 git 跟 tree 是個人喜好，不裝也行

===============================================================================

【編譯前請先移除】

$ sudo apt-get remove quagga

這包程式當中自帶quagga，所以系統上已安裝quagga的，請移除

===============================================================================

【編譯】

(1) 切換到 build 目錄
$ cd build/

(2) 利用 cmake 產生真正的 makefile
$ cmake ../

在 cmake ../ 的時候，會檢查上面「請先安裝」的東西有沒有安裝好
檢查不通過會強制中斷，不讓你再繼續下去

(3) 利用產生出來的 makefile 編 code
$ make

(4) 把編好的 code 安裝到 output 目錄去
$ make install

在 make install 之後，安裝的檔案會放在 output 底下
理論上 output 目錄可以移到本台主機上的任何位置去
也可以把 output 的名稱改掉
對執行都不會有影響

甚至在另一台 Ubuntu 14.04 i386 主機上，把該安裝的東西都裝好
也可以直接複製過去執行 (應該啦)

===============================================================================

【開發程式時的編譯】

當你修改已經存在的檔案，只需要利用產生過的 makefile 重編即可
$ make
即可

如果你有新增 / 刪除 / 移動檔案的話，則需要重新產生 makefile
$ cmake ../
$ make

cd build/ + cmake ../ 的相反是 rm -rf build/*
make 的相反是 make clean
make install 的相反是 make uninstall
而 make distclean = make uninstall + make clean + rm -rf build/*

如果出現一些奇怪的問題，編不過的話，你可以先這樣做
$ make clean
$ make

還是不行的話，就只好
$ make distclean
$ cmake ../
$ make

連這樣都不行的話，應該就是哪裡寫錯了 ... XD

利用版本控管退回到舊的(可以編得過)的版本去比對，進行debug

===============================================================================

【執行】

$ cd output
$ sudo ./etc/netconf_br0
$ sudo ./mmectrl

這裡一定要使用 sudo 來做，不然會無法執行，測試後發現應該跟quagga有關
詳情可以看 third_party/quagga/CMakeLists.txt 裡面的說明

新增另一種執行方法，其實也就只是把上面的動作 sudo ./mmectrl
寫到 Makefile 裡面去而已

$ cd build/
$ make run-mmectrl

這種主要是可以配合編譯一起使用

$ make
$ make install
$ make run-mmectrl

如果要再短一點，就這樣打
all 不可以省略

$ make all install run-mmectrl

就會做到 compile -> install -> run 一口氣完成

