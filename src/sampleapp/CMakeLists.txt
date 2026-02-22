#
# @file src/sampleapp/CMakeLists.txt
# @brief sampleapp モジュールのビルド構成を定義するファイルです。
#
# この CMake ファイルでは、ドメインロジックおよびアプリケーション層を担う
# sampleapp モジュールのソースをビルドします。
#

# sampleapp モジュール（ライブラリ）を定義
file(GLOB SAMPLEAPP_SOURCES CONFIGURE_DEPENDS *.cpp)  # このディレクトリ内のすべての cpp ファイルを対象

add_library(sampleapp ${SAMPLEAPP_SOURCES})           # 'sampleapp' ライブラリを構築

# C++17 を有効化
# sampleapp は他のモジュールからも使われるため PUBLIC 指定
target_compile_features(sampleapp PUBLIC cxx_std_17)

# インクルードディレクトリを指定
# 外部からも利用されるため PUBLIC
target_include_directories(sampleapp PUBLIC
    ${CMAKE_SOURCE_DIR}/include
)

# カバレッジ取得のためのビルド拡張（GCC環境かつ ENABLE_COVERAGE オン時）
include(${CMAKE_SOURCE_DIR}/tools/coverage.cmake)
enable_coverage_if_gcc(sampleapp)
