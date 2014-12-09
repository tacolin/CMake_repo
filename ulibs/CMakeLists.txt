cmake_minimum_required( VERSION 2.8.3 )

#############################################################################
# 詳情可以看 third_party 那層目錄的 CMakeLists.txt
#############################################################################

iii_get_subdirs("./" _sub_directories)

subdirs(${_sub_directories})

# foreach(_dir ${_sub_directories})
#     add_subdirectory(${_dir})
# endforeach()
