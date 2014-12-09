cmake_minimum_required( VERSION 2.8.3 )

#############################################################################
# 由於 cmake 在建立 makefile ，指定 include 的路徑時
# 如果 include 的路徑不存在，那 include 就會失敗
#
# 這裡的 ossasn1 的解壓縮，其實是在 make 時才解壓縮的
# 時間上比 cmake 產生還要晚，這樣的話會有問題
# 只好先把空的 include 目錄建立出來
#
# execute_process 後面的動作，是在 cmake 產生 makefile 的時候就做了
#
# WORKING_DIRECTORY 的話，就是表示目前的動作會先切換到這個目錄下才開始做
# 也就是等同於
# cd ${CMAKE_CURRENT_LIST_DIR}
# mkdir -p ossasn1/linux-glibc2.2.tgt/5.3.2/include/
#############################################################################
execute_process( COMMAND mkdir -p ossasn1/linux-glibc2.2.tgt/5.3.2/include/
                 WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
               )

#############################################################################
# 真正的 ossasn1 解壓縮
# 在 make 的時候才做
#
# 這裡把解壓縮出來的目錄 ossasn1/ 也放到 OUTPUT
# 是因為期待在做 make clean 的時候，這個目錄會自動被刪除
#
# 這裡用 pv 只是個人興趣，因為很討厭那種 tar 就吐一大堆訊息出來的行為
#
# 會有人說，訊息吐出來才方便debug
# 通常講的人，大部分時間都沒有在看 XD
# 真的有bug的話，再特別把pv改掉處理就好了 (話說untar是會有什麼bug?)
#
# 由於 depends 壓縮檔
# 壓縮檔有變動的話，解壓縮的動作就會重新做一次
#############################################################################
add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/ossasn1/ossasn1-untared"
                   "${CMAKE_CURRENT_LIST_DIR}/ossasn1/"
                   COMMAND rm -rf ossasn1/
                   COMMAND pv ${III_ASN1_TAR_FILE} | tar -jx -f - -C ./
                   COMMAND touch ossasn1/ossasn1-untared
                   WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                   COMMENT "[ASN1] Untar ossasn1 source code"
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/${III_ASN1_TAR_FILE}"
                   )

#############################################################################
# 更新 asn1code.h 檔
# 在 make 的時候才做
#############################################################################
add_custom_command(OUTPUT "${CMAKE_CURRENT_LIST_DIR}/ossasn1/ossasn1-patched"
                  COMMAND cp -f asn1_patch/asn1code.h ossasn1/linux-glibc2.2.tgt/5.3.2/include/asn1code.h
                  COMMAND touch ossasn1/ossasn1-patched
                  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                  COMMENT "[ASN1] Patch ossasn1 asn1code.h"
                  DEPENDS "${CMAKE_CURRENT_LIST_DIR}/ossasn1/ossasn1-untared"
                  "${CMAKE_CURRENT_LIST_DIR}/asn1_patch/asn1code.h"
                  )

#############################################################################
# 加入一個 target asn1，也就是說
# 在 Makefile 當中，會出現 make asn1 這個選項
# ALL 的意思就是 make asn1 會在 make (make all) 的時候一併被執行
#
# 由於 asn1 depends ossasn1-pathced 這兩個檔案
# 所以會先執行上面的 patch，而 patch 又 depends untar
# 所以執行的順序會是 untar -> patch -> asn1 (其實是空的)
#############################################################################
add_custom_target("asn1"
                   ALL
                   DEPENDS "${CMAKE_CURRENT_LIST_DIR}/ossasn1/ossasn1-patched"
                   # "${CMAKE_CURRENT_LIST_DIR}/ossasn1/ossasn1-untared"
                   )

#############################################################################
# 由於 ossasn1 並沒有真的 compile code
# 而是把已經編好的 binary code 解壓縮而已
# 在 make install 的時候把 .a .so .sa 複製到相對應的位置去
#############################################################################
install(DIRECTORY "ossasn1/linux-glibc2.2.tgt/5.3.2/lib/"
        DESTINATION ${III_LIB_INSTALL_DIR}
        FILES_MATCHING
        PATTERN "*.a"
        PATTERN "*.sa"
        PATTERN "*.so"
        )
