cmake_minimum_required( VERSION 2.8.3 )

project("mmectrl")

#############################################################################
# 由於 mmectrl 裡面的 header 檔散布各處 (?)
# 除了第一層有 inc 目錄外，裡面自己的目錄還有自己的 inc
#
# iii_get_header_dirs 會把目錄底下所有的 header 檔找出來 (recursively)
# 然後把所有 header 檔的路徑取出，存在 _hdr_dirs 這個清單當中
#############################################################################
iii_get_header_dirs(${CMAKE_CURRENT_LIST_DIR} _hdr_dirs)
include_directories(${_hdr_dirs})

#############################################################################
#############################################################################
include_directories("${III_LIB_SRC_PATH}/oswrapper/inc")
include_directories("${III_LIB_SRC_PATH}/utilities/inc")
include_directories("${III_LIB_SRC_PATH}/plibs/inc")
include_directories("${III_LIB_SRC_PATH}/gtpc/inc")
include_directories("${III_LIB_SRC_PATH}/tnl/inc" )
include_directories("${III_LIB_SRC_PATH}/tlvkit/inc" )
include_directories("${III_LIB_SRC_PATH}/param/inc" )

#############################################################################
#############################################################################
include_directories("${III_3RD_PARTY_SRC_PATH}/quagga/")
include_directories("${III_3RD_PARTY_SRC_PATH}/quagga/quagga/")
include_directories("${III_3RD_PARTY_SRC_PATH}/quagga/quagga/lib/")
include_directories("${III_3RD_PARTY_SRC_PATH}/asn1/ossasn1/linux-glibc2.2.tgt/5.3.2/include")
include_directories("${III_3RD_PARTY_SRC_PATH}/freeDiameter/freeDiameter/include/")
include_directories("${III_3RD_PARTY_SRC_PATH}/freeDiameter/freeDiameter/include/freeDiameter")

#############################################################################
# 這裡加入 gcc -g 的原因是增加一些 debug 用的資料進去
# 日後用 gdb / valgrind 之類的 trace code 比較方便
#############################################################################
add_definitions(-g)

#############################################################################
# 同上，因為 .c 檔也是散落各處
# 所以做了跟 iii_get_header_dirs 同樣的事，把存在 .c 檔的所有目錄
# 存成一份清單
#############################################################################
iii_get_src_dirs(${CMAKE_CURRENT_LIST_DIR} _src_dirs)

set(_obj_files "")

foreach(_dir ${_src_dirs})
    aux_source_directory( ${_dir} _src_files )
    iii_get_obj_files(${_dir} objs )
    set(_obj_files ${objs} ${_obj_files})
endforeach()

#############################################################################
#############################################################################
add_executable( ${PROJECT_NAME} ${_src_files} ${_obj_files})
set_target_properties( ${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C )

#############################################################################
# 因為 mmectrl 需要 quagga asn1 與 freeDiameter 三個 third_party 的 lib
# 所以加上 dependencies
#
# ulibs 雖然也需要，但後面的 target_link_libraries 會自動加上 dependencies
# 所以不必加也沒關係 (應該?)
#############################################################################
add_dependencies( ${PROJECT_NAME} quagga asn1 freeDiameter )

#############################################################################
#############################################################################
iii_osw_config()

#############################################################################
#############################################################################
target_link_libraries( ${PROJECT_NAME} osw )
target_link_libraries( ${PROJECT_NAME} utl )
target_link_libraries( ${PROJECT_NAME} plibs )
target_link_libraries( ${PROJECT_NAME} gtpc )
target_link_libraries( ${PROJECT_NAME} tnl )
target_link_libraries( ${PROJECT_NAME} tlvkit )
target_link_libraries( ${PROJECT_NAME} param )

#############################################################################
# freeDiameter 雖然是 third party
# 但因為當初已經把它加到自己的 cmake 系統當中
# 所以可以直接利用 target_link_libraries 來做 link
#############################################################################
target_link_libraries( ${PROJECT_NAME} libfdcore )
target_link_libraries( ${PROJECT_NAME} libfdproto )

#############################################################################
# 這三個是主機上本來就有的 library
# 也可以用 target_link_libraries 直接 link
#############################################################################
target_link_libraries( ${PROJECT_NAME} crypto )
target_link_libraries( ${PROJECT_NAME} sctp )
target_link_libraries( ${PROJECT_NAME} pthread )


#############################################################################
# 由於 quagga 跟 asn1 並沒有被納入 cmake 系統
# 所以要指定絕對路徑去進行 link
#
# 這裡的 link 只是編譯的時候的 link
# 真正 runtime 執行的時候，是看 rpath 的
#############################################################################
target_link_libraries( ${PROJECT_NAME} "${III_3RD_PARTY_SRC_PATH}/quagga/quagga/lib/.libs/libzebra.so" )
target_link_libraries( ${PROJECT_NAME} "${III_3RD_PARTY_SRC_PATH}/asn1/ossasn1/linux-glibc2.2.tgt/5.3.2/lib/libasn1code.so" )
target_link_libraries( ${PROJECT_NAME} "${III_3RD_PARTY_SRC_PATH}/asn1/ossasn1/linux-glibc2.2.tgt/5.3.2/lib/libasn1spar.so" )
target_link_libraries( ${PROJECT_NAME} "${III_3RD_PARTY_SRC_PATH}/asn1/ossasn1/linux-glibc2.2.tgt/5.3.2/lib/libiaapi.so" )

#############################################################################
#############################################################################
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION "${III_APP_INSTALL_DIR}")

#############################################################################
# 做一個測試用的 make target 這樣 make (all) + make install 完
# 要進行測試的時候，就不必手動切換目錄執行
#
# 下面使用 run-mmectrl (PROEJCT_NAME 就是 mmectrl) 會執行兩行指令，而且照順序
# (1) sudo ./mmectrl
#
# 如果要繼續增加的話，就可以把 add_custom_command 那段複製貼上
# 然後修改 COMMAND 後面的部分、以及 COMMENT 就可以了
#
# 當然以 cmake 的寫法，其實這樣寫有點累贅
# 不過對於不太懂 cmake 的人來說，這樣的寫法會比較容易懂 (應該...吧？)
#############################################################################
add_custom_target("run-${PROJECT_NAME}")

add_custom_command(TARGET "run-${PROJECT_NAME}"
                   COMMAND sudo ./${PROJECT_NAME}
                   WORKING_DIRECTORY "${CMAKE_INSTALL_PREFIX}/${III_APP_INSTALL_DIR}"
                   COMMENT "[MME] Run ${PROJECT_NAME}"
                   )

