cmake_minimum_required( VERSION 2.8.3 )

#############################################################################
# 與 asn1 和 quagga 不同
# 由於我們希望把 freeDiameter 直接拉入我們原本的 cmake 系統當中
#
# 所以不能等到 make 的時候才解壓縮，需要在在 cmake ../ 時就先解壓縮
#
# execute_process 的 COMMAND 不能使用 pipe，所以也不能用 pv(pipeview)
# 但 add custom command 可以
#############################################################################

if(NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/freeDiameter/")
    execute_process( COMMAND tar -jx -f ${III_FREEDIAMETER_TAR_FILE} -C "./"
                     WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                   )
endif()

#############################################################################
# 同上，所以更新的動作，也要在 cmake ../ 的時候就做
# 不能等到 make 才做
#
# 更新 freeDiameter 裡面的 兩個 CMakeLists.txt
# 主要更新的部分有
# (1) 原本 freeDiameter 會產生 client 與 server 兩個 daemon，拿掉
# (2) 原本 freeDiameter 會產生一些測試程式，拿掉
#############################################################################
if(NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/freeDiameter/freeDiameter-patched")
    execute_process( COMMAND cp -f patch/include/freeDiameter/CMakeLists.txt freeDiameter/include/freeDiameter/CMakeLists.txt
                     WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                   )
    execute_process( COMMAND cp -f patch/CMakeLists.txt freeDiameter/CMakeLists.txt
                     COMMAND touch freeDiameter/freeDiameter-patched
                     WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                   )
endif()

#############################################################################
# 把上面的解壓縮、與更新的動作加入 target
# 主要是為了 make clean 的時候會自動清掉
# 正常的流程下，會因為 depends 的關係，在 make 時並不會重作一次
#############################################################################
add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/freeDiameter/"
                   COMMAND rm -rf freeDiameter/
                   COMMAND pv ${III_FREEDIAMETER_TAR_FILE} | tar -jx -f - -C ./
                   WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                   COMMENT "[FREE-DIAMETER] Untar freeDiameter source code"
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${III_FREEDIAMETER_TAR_FILE}"
                   )

add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/freeDiameter/freeDiameter-patched"
                  COMMAND cp -f patch/CMakeLists.txt freeDiameter/CMakeLists.txt
                  COMMAND touch freeDiameter/freeDiameter-patched
                  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                  COMMENT "[FREE-DIAMETER] Patch freeDiameter CMakeLists.txt"
                  DEPENDS "${CMAKE_CURRENT_LIST_DIR}/patch/CMakeLists.txt"
                  )

add_custom_target("freeDiameter-prepare"
                   ALL
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/freeDiameter/"
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/freeDiameter/freeDiameter-patched"
                  )

#############################################################################
# 往下找下一層的 CMakeLists.txt，把 freeDiameter 拉入我們的 cmake 系統中
#############################################################################
add_subdirectory( freeDiameter )
