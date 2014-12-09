cmake_minimum_required( VERSION 2.8.3 )

###############################################################################
# 找尋底下所有的子目錄 (第一層而已)，然後儲存在 _sub_directoires 這個變數當中
# _sub_directoires 是個 list
###############################################################################
iii_get_subdirs("./" _sub_directoires)

###############################################################################
# 針對底下的每個子目錄，再去看子目錄內的 CMakeLists.txt
# 其實可以用 subdirs(${_sub_directoires}) 一口氣全加
#
# 不過我比較喜歡 foreach + add_subdirectory 的作法
# 看起來比較容易懂？
###############################################################################
subdirs(${_sub_directoires})

# foreach(_dir ${_sub_directoires})
#     add_subdirectory(${_dir})
# endforeach()

###############################################################################
# third party 底下的三個目錄，對應到三種不同的型態的 third party 處理
# 作法都不同
#
# (1) asn1
# 不需要任何編譯，裡面已經放著早就編好的 binary 檔與 header 檔
# 只需要做解壓縮、並在 make install 時複製到該放的位置去即可
#
# (2) quagga
# 需要編譯，make系統是利用 autoconf / automake 做的
# 需要最多步驟
#
# 產生 configure -> 利用 configure 產生 Makefile -> 利用 Makefile 產生 binary
# -> install 時把 binary 複製到相對應的位置去
#
#
# (3) free diameter
# 需要編譯，但因為 free diameter 也是用 cmake 在寫的
# 所以只需要把它的 CMakeLists.txt 做些小修改
# 納入我們的 cmake 系統去即可
###############################################################################
