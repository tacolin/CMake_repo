##############################################################################
# 因為不知道 g++ 的 library 叫什麼
# 然後 iostream 好像也不是一個 header 檔
#
# 所以就只找執行檔
##############################################################################
find_program(GXX_BINARAY "g++")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GXX
                                  DEFAULT_MSG
                                  GXX_BINARAY
                                  )
