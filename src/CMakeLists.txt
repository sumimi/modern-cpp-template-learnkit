#
# @file src/CMakeLists.txt
# @brief ビルド構成を定義するファイルです。
#
# 本ファイルは、ソースディレクトリ(src)内のビルド対象を定義します。
# - main.cpp の有無により実行ファイルをビルド
# - インクルードディレクトリの指定
# - C++17 をターゲット単位で指定
#

# モジュール登録
add_subdirectory(sampleapp)

# main.cpp を含む構成であれば実行ファイルをビルド
file(GLOB MAIN_SRC CONFIGURE_DEPENDS main.cpp)
if(MAIN_SRC)
    add_executable(main ${MAIN_SRC})

    target_include_directories(main PRIVATE ${CMAKE_SOURCE_DIR}/include)
    target_compile_features(main PRIVATE cxx_std_17)

    # sampleapp がアプリ全体を構成する場合
    target_link_libraries(main
        PRIVATE
            sampleapp
    )

    # カバレッジ取得のためのビルド拡張（GCC環境かつ ENABLE_COVERAGE オン時）
    include(${CMAKE_SOURCE_DIR}/tools/coverage.cmake)
    enable_coverage_if_gcc(main)
endif()
