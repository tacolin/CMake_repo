##############################################################################
##############################################################################
find_program(PV_BINARY "pv")

##############################################################################
##############################################################################
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PV
                                  DEFAULT_MSG
                                  PV_BINARY
                                  )
