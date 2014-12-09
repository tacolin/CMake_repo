##############################################################################
# 要小心 header 檔的路徑 XD
##############################################################################
find_path(READLINE_INCLUDE_DIRS "readline/readline.h")

##############################################################################
##############################################################################
find_library(READLINE_LIBRARIES NAMES "readline")

##############################################################################
##############################################################################
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(READLINE
                                  DEFAULT_MSG
                                  READLINE_LIBRARIES READLINE_INCLUDE_DIRS
                                  )