###############################################################################
# cmake 版本最小需求
# 當中有使用到一些2.8.3才出現的新東西
# 所以最小需求不能再往下了
###############################################################################
cmake_minimum_required( VERSION 2.8.3 )

###############################################################################
# 設定會用到的全域變數
# 全大寫，然後是 III 開頭的就是了
#
# CMAKE 開頭的，則是 cmake 自己的系統變數
# CMAKE_CURRENT_LIST_DIR 指的就是目前這個 CMakeLists.txt 所在的目錄
# 每個 CMakeLists.txt 都會有不同的 CMAKE_CURRENT_LIST_DIR 的值
# 現在這個檔案的話，就是 trunk / repo 的根目錄
###############################################################################
set(III_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")

set(III_QUAGGA_TAR_FILE       "quagga.tar.gz")
set(III_ASN1_TAR_FILE         "ossasn1.tar.bz2")
set(III_FREEDIAMETER_TAR_FILE "freeDiameter.tar.bz2")

set(III_LIB_SRC_PATH        "${III_ROOT_DIR}/ulibs")
set(III_APP_SRC_PATH        "${III_ROOT_DIR}/apps")
set(III_3RD_PARTY_SRC_PATH  "${III_ROOT_DIR}/third_party")

set(III_BUILD_PATH          "${CMAKE_BINARY_DIR}")

###############################################################################
# 這裡的 install dir，其實是指 CMAKE_INSTALL_PREFIX 底下的 dir
# 也就是說，真正的 app install dir 其實是 output/
# 真正的 lib install dir 其實是 output/lib/
# 真正的 etc install dir 其實是 output/etc/
###############################################################################
set(III_APP_INSTALL_DIR  "./")
set(III_LIB_INSTALL_DIR  "lib")
set(III_CONF_INSTALL_DIR "etc")

###############################################################################
# 設定 make install 的安裝路徑
###############################################################################
set(CMAKE_INSTALL_PREFIX "${III_ROOT_DIR}/output")

###############################################################################
# 設定 install 後，app 在執行時找尋 library 的 runtime path (rpath)
###############################################################################
set(CMAKE_INSTALL_RPATH  ${III_LIB_INSTALL_DIR})

###############################################################################
# 在利用下面的 find_package 功能時
# 會先利用 cmake 預設有提供的 (在 /usr/share/cmake-x.x.x/Modules)
# 如果 cmake 預設沒有提供的話，可以自己寫
# 這裡自己寫的 find_package 放在 cmake/Modules 目錄底下
###############################################################################
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${III_ROOT_DIR}/cmake/Modules")

###############################################################################
# cmake / default.cmake 裡面寫了一些自定義的 cmake function
###############################################################################
include( "cmake/default.cmake" )

###############################################################################
# 檢查該裝的東西有沒有裝
# 加了 REQUIRED 的話，檢查失敗就會直接強制中斷跳出
# 不加的話，就只是單純檢查，印個錯誤訊息，不影響後續的動作
###############################################################################
find_package( GCC REQUIRED )
find_package( GXX REQUIRED )
find_package( SSL REQUIRED )
find_package( INDENT REQUIRED )
find_package( AUTOCONF REQUIRED )
find_package( AUTOMAKE REQUIRED )
find_package( READLINE REQUIRED )
find_package( LIBTOOL REQUIRED )
find_package( LIBIDN REQUIRED )
find_package( PV REQUIRED )
find_package( CHRPATH REQUIRED )

###############################################################################
# 檢查系統是否為 32 bit linux
# 因為 3rd party 裡面 asn1 只有買 binary 檔
# 而 binary 檔給的是 32 bit 的
# 所以就被限制了
###############################################################################
iii_is_32bit_system(result)
if(result)
    message(STATUS "Check if the system is 32-bit -- OK")
else()
    message(FATAL_ERROR "Check if the system is 32-bit -- FAILED")
    return()
endif()

###############################################################################
# 因為 cmake 預設不提供 uninstall 所以自己加一個
# 把 output 資料夾利用 rm -rf 清空
###############################################################################
add_custom_target("uninstall"
                  COMMAND rm -rf ${CMAKE_INSTALL_PREFIX}/*
                  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                  COMMENT "[MME] Clean ${CMAKE_INSTALL_PREFIX}"
                  )

###############################################################################
# 因為 cmake 預設不提供 distclean 所以自己加一個
# 先做 uninstall (depends 的關係)
# 做 make clean
# 最後把 build 這個目錄也清空
###############################################################################
add_custom_target("distclean"
                  ${CMAKE_MAKE_PROGRAM} clean
                  COMMAND rm -rf *
                  WORKING_DIRECTORY ${III_BUILD_PATH}
                  COMMENT "[MME] Uninstall, make clean, and clean CMake generated files"
                  DEPENDS "uninstall"
                  )

###############################################################################
# 依據到這三個目錄底下，找尋目錄當中的 CMakeLists.txt，並繼續執行動作
# 由於 dependency 設定的關係
# 順序一定要是 third_party -> ulibs -> apps，不可以變換
###############################################################################
add_subdirectory ( third_party )
add_subdirectory ( ulibs )
add_subdirectory ( apps )
