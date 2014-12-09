#############################################################################
# 要利用 find_package 的話，除了預設的
# /usr/share/cmake.x.x.x/Modules/ 底下有寫好的以外
# 也可以自己寫，然後再指定路徑
#
# 自己寫的重點
#
# 檔名：一定要是 Find????.cmake
# 如果是 FindTaco.cmake 的話
# 在使用 find_package() 的時候，一定要用 find_package(Taco)
# Taco 的大小寫都要相同
#
# 剩下的可以去看一下 find_program - 找執行檔
# find_path - 找 header 檔
# find_library - 找 .so / .a 檔
# 利用這三個來判斷 package 是否有安裝應該就夠了
#
# 像 autoconf 就只需要判斷執行檔就好  其他的不重要
# 如果有找到的話，前面的 AUTOCONF_BINARY 這個變數，就會被設成 True
# 沒有則是 False
##############################################################################
find_program(AUTOCONF_BINARY "autoconf")

##############################################################################
# 最後再呼叫 find_package_handle_standard_args
# 把前面的變數丟進去即可
##############################################################################
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(AUTOCONF
                                  DEFAULT_MSG
                                  AUTOCONF_BINARY
                                  )
