cmake_minimum_required( VERSION 2.8.3 )

project(tnl)

#############################################################################
# 由於 tnl WBT 的部分會多編譯一些 code
# 而那些 code 年久失修，反而會編不過 XD
# 所以這邊針對 WBT 的部分特別定出來，讓年久失修的 code 不要編
#############################################################################
set(tnl_wbt FALSE)

#############################################################################
#############################################################################
include_directories( "${III_LIB_SRC_PATH}/oswrapper/inc" )
include_directories( "${III_LIB_SRC_PATH}/utilities/inc" )

#############################################################################
#############################################################################
include_directories( "${CMAKE_CURRENT_LIST_DIR}/inc" )

#############################################################################
# auto gen code 的部分
# tnl 最麻煩的就是 auto gen code 的部分
#
# 會依據 txt 的內容，利用 makefile 一些 gcc 的 pre-process 的技巧
# 把 code 產生出來
#
# 做 autogen 的觸發條件有
# (1) 應該要 gen 出來的檔案不存在的時候
# (2) txt 檔有變動的時候
#############################################################################
set(_txt_files_list  "emm.txt" "esm.txt" "test.txt")
set(_txt_dir         "${CMAKE_CURRENT_LIST_DIR}/autogen")
set(_output_dir      ${CMAKE_CURRENT_LIST_DIR})

set(_generated_files "")

foreach(_txt_file ${_txt_files_list})
    get_filename_component( _basename ${_txt_file} NAME_WE )
    list(APPEND _generated_files
         "${_output_dir}/src/tnl_codec_${_basename}.c")

    add_custom_command( OUTPUT "${_output_dir}/src/tnl_codec_${_basename}.c"
                       "${_output_dir}/inc/tnl_codec_${_basename}.h"
                       "${_output_dir}/inc/tnl_mask.h"
                        COMMAND make -C ${_txt_dir} -f Makefile.tnl-u SRC=${_txt_file} SRC_DIR=${_txt_dir} OBJ_DIR=${_output_dir}
                        DEPENDS "${_txt_dir}/${_txt_file}"
                      )
endforeach()

#############################################################################
# 把原本的 soruce code
# 以及 auto gen 產生的 code 加到要 _src_files 去
#
# 由於在 cmake ../ 的時候，檔案還沒被 gen 出來
# 使用 aux_source_directory 會找不到
# 所以這裡是手動硬加入 "目前還不存在" "未來會被gen出來" 的檔案
#############################################################################
aux_source_directory( "${CMAKE_CURRENT_LIST_DIR}/src" _src_files )
set(_src_files ${_generated_files} ${_src_files})

iii_get_obj_files("${CMAKE_CURRENT_LIST_DIR}/src" _obj_files )

#############################################################################
# 這動作有點算是保險吧 去除掉清單當中重複的項目
#############################################################################
list(REMOVE_DUPLICATES _src_files)

#############################################################################
# 處理 WBT
# 如果 WBT 不做的話，把 test 的檔案從 _src_files 及 _obj_files 裡面移除
#
# if ( 變數名 ) 可以判斷清單是否為空，不是空的才會進去 if
#############################################################################
if(tnl_wbt)
    add_definitions("-DTNL_WBT=1")
else()
    if (_src_files)
        list(REMOVE_ITEM _src_files
             "${CMAKE_CURRENT_LIST_DIR}/src/tnl_header_test.c"
             "${CMAKE_CURRENT_LIST_DIR}/src/tnl_codec_test_ext.c"
             "${CMAKE_CURRENT_LIST_DIR}/src/tnl_codec_test.c"
             "${CMAKE_CURRENT_LIST_DIR}/src/tnl_test.c"
             )
    endif()

    if (_obj_files)
        list(REMOVE_ITEM _obj_files
             "${CMAKE_CURRENT_LIST_DIR}/src/tnl_header_test.c.o"
             "${CMAKE_CURRENT_LIST_DIR}/src/tnl_codec_test_ext.c.o"
             "${CMAKE_CURRENT_LIST_DIR}/src/tnl_codec_test.c.o"
             "${CMAKE_CURRENT_LIST_DIR}/src/tnl_test.c.o"
             )
    endif()
endif()

#############################################################################
#############################################################################
add_library( ${PROJECT_NAME} SHARED ${_src_files} ${_obj_files} )
set_target_properties( ${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C )

#############################################################################
#############################################################################
iii_osw_config()

#############################################################################
#############################################################################
install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${III_LIB_INSTALL_DIR})
