##############################################################################
##############################################################################
find_program(AUTOMAKE_BINARY "automake")

##############################################################################
##############################################################################
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(AUTOMAKE
                                  DEFAULT_MSG
                                  AUTOMAKE_BINARY
                                  )