cmake_minimum_required( VERSION 2.8.3 )

project(utl)

#############################################################################
#############################################################################
include_directories( "${CMAKE_CURRENT_LIST_DIR}/inc" )
include_directories( "${III_LIB_SRC_PATH}/oswrapper/inc" )

#############################################################################
#############################################################################
include_directories( "${III_3RD_PARTY_SRC_PATH}/quagga/")
include_directories( "${III_3RD_PARTY_SRC_PATH}/quagga/quagga" )
include_directories( "${III_3RD_PARTY_SRC_PATH}/quagga/quagga/lib/" )

#############################################################################
#############################################################################
aux_source_directory( "${CMAKE_CURRENT_LIST_DIR}"  _src_files )
iii_get_obj_files("${CMAKE_CURRENT_LIST_DIR}" _obj_files )

#############################################################################
#############################################################################
add_library( ${PROJECT_NAME} SHARED ${_src_files} ${_obj_files} )
set_target_properties( ${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE C )

#############################################################################
#############################################################################
add_dependencies( ${PROJECT_NAME} quagga )

#############################################################################
#############################################################################
iii_osw_config()

#############################################################################
#############################################################################
install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${III_LIB_INSTALL_DIR})
