# =============================================================================
# Modern C++ Template LearnKit - CMake Configuration
#
# 本プロジェクトは、モダンなC++開発を支援するCMakeビルド構成を提供します。
# ユニットテスト、静的解析、カバレッジ測定、ドキュメント生成、レポート出力
# など、開発・検証・保守に必要な機能を包括的に統合しています。
#
# 対応機能:
#   - C++17 対応
#   - 出力ディレクトリの分離（lib / bin）
#   - Google Test + Google Mock によるユニットテストとCTest連携
#   - Clang-Tidy による静的解析（存在時のみ有効）
#   - Valgrind によるメモリリーク検出
#   - lcov によるカバレッジ測定（HTML出力付き）
#   - Doxygen によるドキュメント生成
#   - テスト結果 (gtest XML) の HTMLレポート変換（xsltproc利用）
#   - clean_all によるビルド成果物の一括削除
#
# カスタムターゲット（以下のコマンドで実行）:
#   cmake -S . -B build                                # 初期構成
#   cmake --build build                                # ビルド
#   cmake --build build --target run_tests             # ユニットテストの実行
#   cmake --build build --target test_report           # テスト結果HTMLレポート生成
#   cmake --build build --target coverage              # カバレッジ測定とHTML出力 (SETUP_GUIDE.mdを参照)
#   cmake --build build --target doc                   # ドキュメント生成
#   cmake --build build --target clang_tidy            # 静的解析の実行
#   cmake --build build --target valgrind              # メモリリーク検出
#   cmake --build build --target clean_all             # 全成果物の削除
#
# ディレクトリ構成（推奨）:
#   project_root/
#   ├── include/        - ヘッダファイル
#   ├── src/            - ソースコード
#   ├── test/           - テストコード
#   ├── docs/           - ドキュメント関連
#   ├── tools/          - 各種スクリプト
#   └── build/          - ビルド出力先（外部生成）
#
# 必須ツール（事前にインストールが必要）:
#   - CMake 3.15 以上
#   - GCC または Clang（C++17 対応必須）
#   - Google Test および Google Mock (導入方法について README.md を参照)
#   - Doxygen（ドキュメント生成用）
#   - lcov, genhtml（カバレッジ解析用）
#   - xsltproc（HTMLレポート変換用）
#   - clang-tidy（静的解析用）
#   - valgrind（メモリリーク解析用）
# =============================================================================

cmake_minimum_required(VERSION 3.15)
project(ModernCppProject VERSION 1.0.0 LANGUAGES CXX)

# ----------------------------------------------------------------------------- 
# ライブラリ形式の選択肢：STATIC or SHARED（デフォルトは STATIC） 
#
# SHARED を選択すると、動的ライブラリ（DLL）としてビルドされます。
# cmake -DBUILD_SHARED_LIBS=ON -S . -B build_shared
# ----------------------------------------------------------------------------- 
option(BUILD_SHARED_LIBS "Build libraries as shared (DLL) or static" OFF)

# -----------------------------------------------------------------------------
# 出力先ディレクトリ設定
# （アーカイブ(lib), ライブラリ(lib), 実行バイナリ(bin)）
# -----------------------------------------------------------------------------
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# -----------------------------------------------------------------------------
# clang-tidy静的解析設定
# （clang-tidyが存在する場合、ビルド時に自動チェック）
# -----------------------------------------------------------------------------
find_program(CLANG_TIDY_EXE NAMES "clang-tidy")
if(CLANG_TIDY_EXE)
    set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
endif()

# -----------------------------------------------------------------------------
# テスト有効化
# （Google Testを利用するためにCTestサポートを有効にする）
# -----------------------------------------------------------------------------
enable_testing()

# -----------------------------------------------------------------------------
# サブディレクトリ追加
# -----------------------------------------------------------------------------
add_subdirectory(src)
add_subdirectory(test)

# =============================================================================
# Doxygen ドキュメント生成ターゲット
# =============================================================================
find_package(Doxygen QUIET)
if(DOXYGEN_FOUND)
    set(DOXYGEN_IN ${CMAKE_SOURCE_DIR}/docs/Doxyfile)
    set(DOXYGEN_OUT ${CMAKE_SOURCE_DIR}/docs/html)
    add_custom_target(doc
        COMMAND ${CMAKE_COMMAND} -E echo "📝 Doxygenドキュメントを生成します..."
        COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_IN}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Doxygenドキュメントを生成"
        VERBATIM
    )
else()
    message(WARNING "Doxygenが見つかりませんでした。'make doc'は使えません。")
endif()

# =============================================================================
# run_tests ユニットテスト実行ターゲット
# =============================================================================
add_custom_target(run_tests
    COMMAND ${CMAKE_COMMAND} -E echo "🧪 ユニットテストを実行します..."
    COMMAND ${CMAKE_CTEST_COMMAND} -R UnitTests --output-on-failure
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "ユニットテスト（UnitTests）を実行"
    VERBATIM
)

# =============================================================================
# test_report ユニットテスト結果HTMLレポート生成ターゲット
# =============================================================================
add_custom_target(test_report
    COMMAND ${CMAKE_COMMAND} -E echo "📄 ユニットテスト結果レポートを生成します..."
    COMMAND bash ${CMAKE_SOURCE_DIR}/tools/generate_test_report.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "GoogleTest の XML結果を HTML に変換"
    VERBATIM
)

# =============================================================================
# run_integration_tests 統合テスト実行ターゲット
# =============================================================================
add_custom_target(run_integration_tests
    COMMAND ${CMAKE_COMMAND} -E echo "🔧 統合テストを実行します..."
    COMMAND ${CMAKE_CTEST_COMMAND} -R IntegrationTests --output-on-failure
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "統合テスト（IntegrationTests）を実行"
    VERBATIM
)

# =============================================================================
# Coverage カバレッジレポート生成ターゲット
# =============================================================================
add_custom_target(coverage
    COMMAND ${CMAKE_COMMAND} -E echo "📈 カバレッジレポートを生成します..."
    COMMAND bash ${CMAKE_SOURCE_DIR}/tools/generate_coverage.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "カバレッジレポートを生成"
    VERBATIM
)

# =============================================================================
# clang_tidy 静的解析ターゲット（build/clang_tidy.logにログ出力）
#
# 参考: ANSIカラーコードを除去するためのコマンド
# cat ./build/clang_tidy.log | sed -r 's/\x1B\[[0-9;]*[mK]//g' > ./build/clang_tidy_cleaned.log
# =============================================================================
if(CLANG_TIDY_EXE)
    add_custom_target(clang_tidy
        COMMAND ${CMAKE_COMMAND} -E echo "🔍 Clang-Tidy による静的解析を実行します..."
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target unit_tests 2>&1 | tee clang_tidy.log
        COMMENT "Clang-Tidy を適用するには、ビルド時に有効化されている必要があります"
        VERBATIM
    )
else()
    message(WARNING "clang-tidy が見つかりません。'clang_tidy' ターゲットは使用できません。")
endif()

# =============================================================================
# valgrind メモリリーク検出ターゲット（tools/run_valgrind.sh 経由）
# =============================================================================
add_custom_target(valgrind
    COMMAND ${CMAKE_COMMAND} -E echo "🧪 Valgrind によるメモリリーク検出を実行します..."
    COMMAND bash ${CMAKE_SOURCE_DIR}/tools/run_valgrind.sh
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Valgrind によるユニットテストの動的解析を実行中..."
    VERBATIM
)

# =============================================================================
# clean_all プロジェクト全体の成果物削除ターゲット
# =============================================================================
add_custom_target(clean_all
    COMMAND ${CMAKE_COMMAND} -E echo "🧹 ビルド・ドキュメント・カバレッジ成果物を全て削除します..."
    COMMAND bash ${CMAKE_SOURCE_DIR}/tools/clean_all.sh
    COMMENT "全てのビルド生成物を削除"
    VERBATIM
)
