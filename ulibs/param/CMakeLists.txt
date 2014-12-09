cmake_minimum_required( VERSION 2.8.3 )

project(param)

#############################################################################
# 測試一下目前環境是 big 或是 little TestBigEndian
# 原本這個測試是包含在 iii_osw_config() 裡面的
#
# 但 iii_osw_config() 同時還有做其他的事情
# 而 param 只單純的需要 endian 設定而已，所以特別移出來做
#############################################################################
include(TestBigEndian)
TEST_BIG_ENDIAN(result)
if (${result})
    add_definitions("-D_OSW_BIG_ENDIAN_")
else()
    add_definitions("-D_OSW_LITTLE_ENDIAN_")
endif()

#############################################################################
#############################################################################
include_directories( "${CMAKE_CURRENT_LIST_DIR}/inc" )

#############################################################################
#############################################################################
aux_source_directory( "${CMAKE_CURRENT_LIST_DIR}/src" _src_files )
iii_get_obj_files( "${CMAKE_CURRENT_LIST_DIR}/src" _obj_files )

#############################################################################
#############################################################################
add_library( ${PROJECT_NAME} SHARED ${_src_files} ${_obj_files} )
set_target_properties( ${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C )

#############################################################################
#############################################################################
install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${III_LIB_INSTALL_DIR})
