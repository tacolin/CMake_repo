cmake_minimum_required( VERSION 2.8.3 )

#############################################################################
# 先建立 include 會用到的目錄
# 原因在 asn1 的 CMakeLists.txt 裡面有說
#############################################################################
execute_process( COMMAND mkdir -p quagga/lib
                 WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
               )

#############################################################################
# 解壓縮
#############################################################################
add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/quagga/quagga-untared"
                   "${CMAKE_CURRENT_LIST_DIR}/quagga/"
                   COMMAND rm -rf quagga/
                   COMMAND pv ${III_QUAGGA_TAR_FILE} | tar -xz -f - -C ./
                   COMMAND touch quagga/quagga-untared
                   WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                   COMMENT "[QUAGGA] Untar quagga source code"
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${III_QUAGGA_TAR_FILE}"
                   )

#############################################################################
# 利用 autoreconf 產生 configure 這個執行檔
#
# autoreconfig -i --force 的這個動作
# 是從原本 epc trunk 裡面 quagga 的 Makefile 上抄來的
# 有興趣可以回 epc trunk 去翻 quagga 的 Makefile
#############################################################################
add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/quagga/configure"
                   COMMAND autoreconf -i --force
                   WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/quagga"
                   COMMENT "[QUAGGA] Generate quagga configure file"
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/quagga/quagga-untared"
                   )

#############################################################################
# 更新 zebra.h 檔 及 vty.c 檔
#
# 這裡的更新是原本 epc 沒有的，主要更新了：
# (1) 原本的 epc quagga 用的是絕對路徑，這邊改成相對路徑
# (2) 原本的 epc quagga 所使用的 readline library 是舊版的
#     而這邊是新版的，目前已知有兩個 define 不同，在 Patch 檔裡有修改
#############################################################################
add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/quagga/quagga-patched"
                  COMMAND cp -f patch/lib/zebra.h quagga/lib/zebra.h
                  COMMAND cp -f patch/lib/vty.c quagga/lib/vty.c
                  COMMAND touch quagga/quagga-patched
                  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                  COMMENT "[QUAGGA] Patch quagga zebra.h and vty.c"
                  DEPENDS "${CMAKE_CURRENT_LIST_DIR}/quagga/configure"
                  DEPENDS "${CMAKE_CURRENT_LIST_DIR}/patch/lib/zebra.h"
                  DEPENDS "${CMAKE_CURRENT_LIST_DIR}/patch/lib/vty.c"
                  )

#############################################################################
# 利用 configure 產生 makefile
#
# 這邊的話有幾個嘗試錯誤的點
# (1) 我有試著把 enable-user 及 enable-group 改成去抓取當下編譯的使用者名稱
#     不過即使成功編過了，執行也會跑起來，但是卻會莫名其妙的死在 find_pid()
#     這個 function，所以最後還是使用原本的 root
#
# (2) --prefix 的這個安裝目錄，在原本的 quagga Makefile 裡面是沒有加的
#     但因為我後面有利用 chrpath (change rpath) 去修改 zebra 及 vtysh 的
#     runtime path。這裡需要先用　--prefix 先讓他們兩個產生預設的　rpath
#     後面才能修改。
#
#     如果沒加 --prefix 的話， zebra 與 vtysh 的 rpath 會是空的
#     而 chrpath 會失敗。
#
#     有另外的方法可以在空的情況下，添加新的 rpath，但很麻煩，所以這邊
#     就保留 --prefix
#############################################################################
add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/quagga/quagga-makefile-genearated"
                   COMMAND ./configure --enable-user=root --enable-group=root --prefix=${CMAKE_INSTALL_PREFIX}  --enable-vtysh --disable-ipv6 --disable-bgpd --disable-ripd --disable-ripngd --disable-ospfd --disable-ospf6d --disable-watchquagga --disable-ospfapi --disable-ospfclient --disable-bgp-announce --disable-rtadv --disable-capabilities --disable-snmp --sysconfdir=${CMAKE_INSTALL_PREFIX}/${III_CONF_INSTALL_DIR}
                   # COMMAND ./configure --enable-user=root --enable-group=root --enable-vtysh --disable-ipv6 --disable-bgpd --disable-ripd --disable-ripngd --disable-ospfd --disable-ospf6d --disable-watchquagga --disable-ospfapi --disable-ospfclient --disable-bgp-announce --disable-rtadv --disable-capabilities --disable-snmp --sysconfdir=${CMAKE_INSTALL_PREFIX}/${III_CONF_INSTALL_DIR}
                   COMMAND touch quagga-makefile-genearated
                   WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/quagga"
                   COMMENT "[QUAGGA] Generate quagga makefile"
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/quagga/quagga-patched"
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/quagga/configure"
                   )

#############################################################################
# 利用 makefile 編 code
# 編完以後，把 vtysh 與 zebra 的 rpath，從絕對路徑改成相對路徑
#############################################################################
add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/quagga/quagga-built"
                   COMMAND make
                   # COMMAND chrpath -r lib/ ${CMAKE_CURRENT_LIST_DIR}/quagga/zebra/.libs/zebra
                   # COMMAND chrpath -r lib/ ${CMAKE_CURRENT_LIST_DIR}/quagga/vtysh/.libs/vtysh
                   COMMAND touch quagga-built
                   WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/quagga"
                   COMMENT "[QUAGGA] Build quagga, and modify runtime path"
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/quagga/quagga-makefile-genearated"
                   VERBATIM
                   )

add_custom_target("quagga"
                   ALL
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/quagga/quagga-built"
                   )

#############################################################################
# 在 make install 的時候
# (1) 把 .a .so .sa 複製到相對應的位置 (output/lib) 去
# (2) 把會用到的 config 檔，複製到相對應的位置 (output/etc) 去
# (3) 把執行檔，複製到相對應的位置 (output/) 去
#
# 事實上大部分的 config 檔可能都用不到
# 但懶得花時間去釐清 XD
#
# 嚴格講起來，zebra 跟 vtysh 這兩個執行檔似乎不需要用？
# 這也不是很清楚 ... XD
#############################################################################
install(FILES "quagga/lib/.libs/libzebra.so.0.0.0"
        "quagga/lib/.libs/libzebra.so.0"
        "quagga/lib/.libs/libzebra.so"
        "quagga/lib/.libs/libzebra.la"
        "quagga/lib/libzebra.la"
        DESTINATION ${III_LIB_INSTALL_DIR}
        )

install(DIRECTORY "config_files/"
        USE_SOURCE_PERMISSIONS
        DESTINATION ${III_CONF_INSTALL_DIR}
        )

# install(PROGRAMS "quagga/zebra/.libs/zebra"
#         "quagga/vtysh/.libs/vtysh"
#         DESTINATION ${III_APP_INSTALL_DIR}
#         )

