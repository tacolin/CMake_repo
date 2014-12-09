cmake_minimum_required( VERSION 2.8.3 )

iii_get_subdirs("./" _sub_directoires)

subdirs(${_sub_directoires})

# foreach(_dir ${_sub_directoires})
#     add_subdirectory(${_dir})
# endforeach()

