---
name: cpp-cmake
description: "CMakeビルドシステム全般の設定とカスタムターゲットに関するガイド。CMakeLists.txtの追加・変更、ビルドエラー・リンクエラーの解決、モジュール・テストターゲットの追加、cmake/build/run_tests/clang_tidy/coverageコマンドの使い方で迷ったときに使用する。"
argument-hint: "[追加したいターゲット or 解決したいビルド問題]"
---

# CMake ビルド設定ガイド

このプロジェクトでは **CMake 3.15+** を使用します。
ビルド設定は `CMakeLists.txt`（ルート）と各サブディレクトリの `CMakeLists.txt` で管理します。

## ディレクトリ構成

```
CMakeLists.txt                    # ルート設定（全体の構成・カスタムターゲット定義）
src/CMakeLists.txt                # main 実行バイナリの設定
src/<module>/CMakeLists.txt       # 各モジュールのライブラリ設定
test/CMakeLists.txt               # テスト全体の設定（GTest 連携）
test/unit/<module>/CMakeLists.txt # 各モジュールのテスト設定
tools/coverage.cmake              # カバレッジ有効化ヘルパー関数
```

## 全ビルドターゲット一覧

| ターゲット | コマンド | 説明 |
|-----------|---------|------|
| （デフォルト） | `cmake --build build` | main 実行バイナリのビルド |
| `run_tests` | `cmake --build build --target run_tests` | 全ユニットテストの実行 |
| `test_report` | `cmake --build build --target test_report` | テスト結果を HTML に変換 |
| `coverage` | `cmake --build build --target coverage` | カバレッジレポート生成 |
| `doc` | `cmake --build build --target doc` | Doxygen ドキュメント生成 |
| `clang_tidy` | `cmake --build build --target clang_tidy` | 静的解析（clang-tidy）実行 |
| `valgrind` | `cmake --build build --target valgrind` | メモリリーク検出 |
| `clean_all` | `cmake --build build --target clean_all` | 全成果物の削除 |

## 初期設定と再構成

```bash
# 通常ビルド
cmake -S . -B build
cmake --build build

# カバレッジ有効ビルド（再構成が必要）
cmake -DENABLE_COVERAGE=ON -S . -B build
cmake --build build

# ビルドを完全にリセット
cmake --build build --target clean_all
# または
rm -rf build
cmake -S . -B build
```

## CMake オプション

| オプション | デフォルト | 説明 |
|-----------|-----------|------|
| `ENABLE_COVERAGE` | `OFF` | GCC カバレッジフラグ（`--coverage`）を有効化 |
| `BUILD_SHARED_LIBS` | `OFF` | 共有ライブラリとしてビルド |

## モジュールライブラリの追加パターン

`src/<module>/CMakeLists.txt`:

```cmake
# ソースを自動収集（新しいファイルを追加しても CMake 再実行のみで OK）
file(GLOB_RECURSE SOURCES "*.cpp")

add_library(mymodule STATIC ${SOURCES})

target_include_directories(mymodule
    PUBLIC
        ${PROJECT_SOURCE_DIR}/include
)

target_compile_features(mymodule PUBLIC cxx_std_17)

# カバレッジ有効化（tools/coverage.cmake の関数）
enable_coverage_if_gcc(mymodule)
```

## テストターゲットの追加パターン

`test/unit/<module>/CMakeLists.txt`:

```cmake
file(GLOB_RECURSE TEST_SOURCES "*.cpp")

add_executable(mymodule_tests ${TEST_SOURCES})

target_link_libraries(mymodule_tests
    PRIVATE
        mymodule          # テスト対象ライブラリ
        GTest::gtest_main
        GTest::gmock
)

target_include_directories(mymodule_tests
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/mock  # モッククラスのパス
)

include(GoogleTest)
gtest_discover_tests(mymodule_tests)
```

## 出力ディレクトリ構成

```
build/
    bin/              # 実行バイナリ（main）
    lib/              # 静的ライブラリ（*.a）
    test_report/      # テストレポート HTML
    coverage_report/  # カバレッジレポート HTML
    clang_tidy.log    # 静的解析ログ
docs/html/            # Doxygen 出力
```

## トラブルシューティング

| 問題 | 対処法 |
|------|--------|
| 新しい `.cpp` ファイルが認識されない | `cmake -S . -B build` で再構成する |
| カバレッジが計測されない | `cmake -DENABLE_COVERAGE=ON -S . -B build` で再構成する |
| テストが古いバイナリで実行される | `cmake --build build` でリビルドしてから実行 |
| clang-tidy が見つからない | `dnf install clang-tools-extra` でインストール |

## ビルド Tips（Linux / RHEL9）

### (1) パラレルビルド（高速化）

```bash
# cmake 経由（推奨）
cmake --build build -- -j$(nproc)

# make 直接（アドホック用途）
cd build && make -j$(nproc)
```

### (2) 詳細ビルドログの表示（エラー調査時）

```bash
# cmake 経由
cmake --build build --verbose

# make 直接
cd build && make VERBOSE=1
```

### (3) クリーンビルド（差分なし）

```bash
cmake --build build --clean-first
```

### (4) `compile_commands.json` の生成（clang-tidy / IDE 連携）

```bash
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -S . -B build
# build/compile_commands.json が生成される
# clang-tidy や clangd（LSP）がインクルードパスを正しく解決できるようになる
```

### (5) 特定ターゲットのみビルド（make 直接）

```bash
cd build && make sampleapp      # 特定モジュールのみ
cd build && make unit_tests     # テストバイナリのみ
```

---

## 参考

- [CMake ドキュメント](https://cmake.org/documentation/)
- [CMake target_link_libraries — PUBLIC/PRIVATE/INTERFACE による推移的依存の制御](https://cmake.org/cmake/help/latest/command/target_link_libraries.html)
- [GoogleTest CMake Integration](https://google.github.io/googletest/quickstart-cmake.html)
