#
# @file test/sampleapp/CMakeLists.txt
# @brief sampleapp モジュールのユニットテストを定義する CMake ファイルです。
#
# このファイルでは、GoogleTest を用いた sampleapp モジュールのテストをビルド・実行し、
# カバレッジ取得などの補助処理を含めた構成を定義します。
#

# sampleapp モジュールのテスト対象ソースを収集
file(GLOB SAMPLEAPP_TEST_SOURCES CONFIGURE_DEPENDS *.cpp)

# テスト用実行バイナリを作成
add_executable(sampleapp_tests ${SAMPLEAPP_TEST_SOURCES})

# C++17 を有効化（PRIVATE: このターゲット内でのみ有効）
target_compile_features(sampleapp_tests PRIVATE cxx_std_17)

# インクルードパスの設定（本体ヘッダ + テスト用モック）
target_include_directories(sampleapp_tests PRIVATE
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/test/sampleapp/mock
)

# ライブラリ探索パスを明示（環境依存で必要なケースに対応）
link_directories(/usr/lib64)

# テスト実行ファイルが依存するライブラリ群をリンク
# GoogleTest + 本体モジュール（logger, pgdb, sampleapp）
target_link_libraries(sampleapp_tests
    PRIVATE
        sampleapp
        GTest::gtest
        GTest::gtest_main
        GTest::gmock
        GTest::gmock_main
)

# GoogleTest の検出と統合
include(GoogleTest)
gtest_discover_tests(sampleapp_tests DISCOVERY_TIMEOUT 30)

# カバレッジ取得のためのビルド拡張（GCC環境かつ ENABLE_COVERAGE オン時）
include(${CMAKE_SOURCE_DIR}/tools/coverage.cmake)
enable_coverage_if_gcc(sampleapp_tests)
