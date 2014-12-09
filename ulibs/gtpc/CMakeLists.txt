cmake_minimum_required( VERSION 2.8.3 )

project(gtpc)

#############################################################################
# include_directories 就等同於在 CFLAGS 裡面加入 -I<目錄>
#
# 不過在 asn1 的 CMakeLists.txt 也有提過
# include_directories 會同時檢查這個目錄是否存在
# 如果不存在的話，就不會加進去
#
# 加入 gptc 底下的 inc 目錄
#############################################################################
include_directories( "${CMAKE_CURRENT_LIST_DIR}/inc" )

#############################################################################
# 加入其他 ulibs include
#############################################################################
include_directories( "${III_LIB_SRC_PATH}/oswrapper/inc" )
include_directories( "${III_LIB_SRC_PATH}/utilities/inc" )
include_directories( "${III_LIB_SRC_PATH}/plibs/inc" )

#############################################################################
# 加入 third_party 的 include
#############################################################################
include_directories( "${III_3RD_PARTY_SRC_PATH}/quagga/")
include_directories( "${III_3RD_PARTY_SRC_PATH}/quagga/quagga/")
include_directories( "${III_3RD_PARTY_SRC_PATH}/quagga/quagga/lib/")

#############################################################################
# aux_source_directory 的第一個 [in] argument 是目錄
# 第二個 [out] argument 是目錄底下 source code 的清單
# 有兩點要注意：
# (1) 它只會找該目錄，並不會 recursive 再往底下找
# (2) 它只會找 .c 跟 .cpp 檔
#############################################################################
aux_source_directory( ${CMAKE_CURRENT_LIST_DIR}  _src_files )

#############################################################################
# 這個是自己寫的，會把目錄底下的 object code (.o檔) 找出來
#############################################################################
iii_get_obj_files( ${CMAKE_CURRENT_LIST_DIR} _obj_files )

#############################################################################
# 把 .c 檔與 .o 檔一起加入編譯
# add_library 就是指要編成 LIBRARY
# SHARED 是 shared library 而 STATIC 則是 static library
#############################################################################
add_library( ${PROJECT_NAME} SHARED ${_src_files} ${_obj_files} )

#############################################################################
# 如果你只要加 .c 檔的話，這行是不必寫的
# 但因為有加入 .o 檔， cmake 無法判斷 .o 檔是什麼語言寫的
# 所以要告訴它 .o 檔是 c 語言編出來的 .o 檔
#############################################################################
set_target_properties( ${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C )

#############################################################################
# 由於 gptc 需要用到 quagga
# 所以在編 gtpc 前，要先編 quagga
# 加入 dependencies
#############################################################################
add_dependencies( ${PROJECT_NAME} quagga )

#############################################################################
# 針對 osw 的部分做一些 flag 的設定
# 詳情可以看 cmake/default.cmake
#############################################################################
iii_osw_config()

#############################################################################
# 指定安裝的路徑
# 由於 project(gtpc)，所以 PROJECT_NAME 就是 gtpc
# 最後產生出來的 library 也會叫做 libgtpc.so
#############################################################################
install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${III_LIB_INSTALL_DIR})
