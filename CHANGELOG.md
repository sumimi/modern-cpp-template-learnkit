# 変更履歴（Changelog）

このファイルには、本プロジェクトにおけるすべての重要な変更を記録しています。

本形式は [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
[セマンティック バージョニング](https://semver.org/lang/ja/) に従って運用しています。

---

## [1.3.1] - 2026-05-02

### 変更
- `tools/generate_coverage.sh`：lcov ベースラインキャプチャを追加
  - `lcov --capture --initial` でテスト実行前のベースライン収集を追加
  - `baseline.info` と実測 `coverage.info` を `lcov -a` でマージ
  - `extract` の入力を `merged.info` に変更し、未実行ファイルを 0% として可視化
  - クリーン対象に `coverage_baseline.info` / `coverage_merged.info` を追加
  - 生成物コメントに baseline / merged の説明を追記

---

## [1.3.0] - 2026-05-01

### C1（分岐）カバレッジ対応

lcov の分岐カバレッジ（C1）を標準で有効化し、カバレッジ計測環境を整備。

#### 追加
- `.lcovrc`：C1（分岐）カバレッジをプロジェクトデフォルトで有効化する設定ファイル
- `.github/skills/cpp-coverage/SKILL.md`：lcov/genhtml によるカバレッジ測定・LCOV 除外コメントガイド（新規 Agent Skills）

#### 変更
- `tools/generate_coverage.sh`：`.lcovrc` 対応・除外フィルタ整理
- `tools/coverage.cmake`：CMake 側のカバレッジターゲット設定を改善
- `README.md`・`docs/SETUP_GUIDE.md`：カバレッジ測定手順を更新

---

### Conan 生成ファイルの整理（vendor/ を .gitignore 管理へ）

`conan install` 実行ごとに再生成される `vendor/` 配下のファイルを Git 管理から除外。

#### 変更
- `.gitignore`：`vendor/` 配下の Conan 生成スクリプト・Toolchain ファイルを除外ルールに追加

#### 削除（.gitignore 管理へ移行）
- `vendor/CMakePresets.json`
- `vendor/conan_toolchain.cmake`
- `vendor/conanbuild.sh` / `vendor/conanrun.sh`
- `vendor/conanbuildenv-release-x86_64.sh` / `vendor/conanrunenv-release-x86_64.sh`
- `vendor/deactivate_conanbuild.sh` / `vendor/deactivate_conanrun.sh`

---

### CMake ビルド設定の改善（RelWithDebInfo / MinSizeRel 対応）

Conan 生成ターゲットが `Release` 構成のみを持つ場合でも、カバレッジ用の `RelWithDebInfo` ビルドでリンクできるよう設定を追加。

#### 変更
- `CMakeLists.txt`：`CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO` / `CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL` を追加
- `CMakeUserPresets.json`：`vendor/CMakePresets.json` への依存を排除し、version 2 の独立プリセット形式に刷新
- `test/CMakeLists.txt`：GTest 検出を `/opt/gtest` ハードコードから Conan CMakeDeps の `CONFIG` モードに変更。`RelWithDebInfo` 向け設定マップと `SPDLOG_FMT_EXTERNAL` 定義を追加

---

### テストケースの追加

#### 変更
- `test/unit/sampleapp/UserServiceTest.cpp`：テストケースを 2 件追加
  - `operator==` が異なる `User` 同士を正しく `false` と判定することを検証
  - `get_user_by_id()` がリポジトリ未登録 ID に対して `std::nullopt` を返すことを検証

---

### ドキュメント・Agent Skills 更新

#### 変更
- `.github/copilot-instructions.md`・`.github/skills/cpp-cmake/SKILL.md`：`cpp-coverage` スキル追加に合わせて更新
- `docs/CONAN_SETUP.md`：Conan セットアップ手順を更新

---

### 既存ユーザー向け移行ガイド

このテンプレートをすでにクローンして利用しているユーザーは、以下の手順で変更を反映してください。

#### 1. 新規追加ファイル（そのまま配置）

リポジトリに存在しないファイルです。コピーしてそのまま配置してください。

| ファイル | 内容 |
|----------|------|
| `.lcovrc` | C1（分岐）カバレッジのデフォルト設定 |
| `.github/skills/cpp-coverage/SKILL.md` | カバレッジ測定スキルガイド |

#### 2. 上書き推奨ファイル

独自カスタマイズがなければそのまま上書きしてください。

| ファイル | 内容 |
|----------|------|
| `tools/generate_coverage.sh` | `.lcovrc` 対応・除外フィルタ整理 |
| `tools/coverage.cmake` | CMake カバレッジターゲット設定の改善 |

#### 3. マージが必要なファイル

ユーザー独自の設定が含まれている可能性があります。差分を確認しながらマージしてください。

| ファイル | マージ箇所 |
|----------|-----------|
| `CMakeLists.txt` | `CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO` / `_MINSIZEREL` の 2 行を追加 |
| `CMakeUserPresets.json` | `vendor/CMakePresets.json` の `include` 参照を削除し、独立したプリセット定義に書き換え |
| `test/CMakeLists.txt` | `find_package(GTest)` の形式変更、`foreach` による設定マップ追加、`SPDLOG_FMT_EXTERNAL` 定義追加 |
| `.gitignore` | `vendor/` 配下の Conan 生成ファイルを除外ルールに追加 |

#### 4. Git 管理から除外するファイル（tracked な場合は手動で除外）

`.gitignore` に追加したファイルが既に Git 管理下にある場合、以下を実行してください。

```bash
git rm --cached vendor/CMakePresets.json
git rm --cached vendor/conan_toolchain.cmake
git rm --cached vendor/conanbuild.sh
git rm --cached vendor/conanbuildenv-release-x86_64.sh
git rm --cached vendor/conanrun.sh
git rm --cached vendor/conanrunenv-release-x86_64.sh
git rm --cached vendor/deactivate_conanbuild.sh
git rm --cached vendor/deactivate_conanrun.sh
```

> これらのファイルは `conan install` 実行時に毎回再生成されるため、Git 管理は不要です。

---

## [1.2.3] - 2026-05-01

### 変更
- `.gitignore`：`vendor/` 配下の CMake ビルド成果物を除外ルールに追加
  - `vendor/.cmake/`（VS Code CMake Tools が生成するクエリ/レプライファイル）
  - `vendor/CMakeFiles/`・`vendor/CMakeCache.txt`・`vendor/Makefile`（cmake が生成）
  - `vendor/CMakeDoxyfile.in`・`vendor/CMakeDoxygenDefaults.cmake`（cmake が生成）
  - `vendor/CTestTestfile.cmake`・`vendor/Testing/`（CTest が生成）
  - `vendor/compile_commands.json`・`vendor/cmake_install.cmake`（cmake が生成）
  - `vendor/src/`・`vendor/test/`（cmake のビルド成果物サブディレクトリ）

---

## [1.2.2] - 2026-03-29

### 変更
- `CMakeLists.txt`：`CMAKE_BUILD_TYPE` 未指定時に `Release` をデフォルト設定するよう追加（Conan CMakeDeps の必須設定への対応）
- `CMakeLists.txt`：cmake 構成コマンドのコメントに `-DCMAKE_TOOLCHAIN_FILE` オプションを追記
- `README.md`：関連リポジトリに `modern-cpp-conan-template` を追加
- `docs/CONAN_SETUP.md`：Conan セットアップガイドを更新
- `docs/SETUP_GUIDE.md`：セットアップガイドを更新
- `tools/conan_setup.sh`：セットアップスクリプトを更新

---

## [1.2.1] - 2026-03-29

### 変更
- `CMakeLists.txt`：`CMAKE_EXPORT_COMPILE_COMMANDS ON` を追加（`build/compile_commands.json` を自動生成）
- `.vscode/c_cpp_properties.json`：`includePath` を廃止し `compileCommands` 参照に変更（IntelliSense がパッケージのインクルードパスを自動解決するように修正）

---

## [1.2.0] - 2026-03-29

### 追加
- Conan 2.7.1 による外部パッケージ管理を統合
  - `conanfile.txt`：spdlog / libpqxx / cxxopts / nlohmann_json / libsodium の依存定義（static リンク）
  - `requirements.txt`：Conan バージョン固定（`conan==2.7.1`）
  - `profiles/linux-rhel9`：GCC 11 / x86_64 / RHEL9 向け Conan ビルドプロファイル
  - `tools/conan_setup.sh`：パッケージ取得・vendor 展開スクリプト
  - `docs/CONAN_SETUP.md`：Conan 導入・パッケージ管理・vendor 運用ガイド
- `vendor/`：Conan パッケージの vendor 化（`full_deploy` + CMakeDeps 生成ファイル）
  - `vendor/conan_toolchain.cmake`：CMake toolchain ファイル（`CMAKE_PREFIX_PATH` 設定）
  - `vendor/full_deploy/host/`：spdlog / libpqxx / libpq / cxxopts / nlohmann_json / libsodium / fmt のヘッダ・静的ライブラリ（`.a`）
  - `vendor/*Config.cmake` 等：`find_package` 解決用 CMakeDeps 生成ファイル
  - `vendor/CMakePresets.json`：Conan 生成の CMake プリセット
- `CMakeUserPresets.json`：`vendor/CMakePresets.json` を参照するユーザープリセット
- `test/unit/packages/ConanPackagesTest.cpp`：全 5 パッケージの動作確認スモークテスト（11 テストケース）

### 変更
- `CMakeLists.txt`：Conan toolchain ベースの統合に変更
  - `vendor/conan_toolchain.cmake` の存在チェックを追加（未セットアップ時に `FATAL_ERROR`）
  - `find_package(spdlog / cxxopts / libpqxx / nlohmann_json / libsodium REQUIRED)` を追加
  - cmake 構成コマンドに `-DCMAKE_TOOLCHAIN_FILE=vendor/conan_toolchain.cmake` が必須になった
- `src/CMakeLists.txt`：`cxxopts::cxxopts` のリンクを追加
- `src/main.cpp`：`#include "cxxopts/cxxopts.hpp"` → `#include <cxxopts.hpp>`（Conan 管理パスに変更）
- `test/CMakeLists.txt`：全 5 パッケージを `unit_tests` ターゲットにリンク
- `README.md`：Conan 2.x 対応を特長・クイックスタート・関連資料に追記
- `.gitignore`：Conan キャッシュ（`.conan/`, `.conan2/` 等）を除外に追加

### 削除
- `include/cxxopts/cxxopts.hpp`：Conan 管理に移行（`vendor/full_deploy/` 配下に移動）

---

## [1.1.0] - 2026-03-22

> 本バージョンの Agent Skills・カスタムエージェント・ガバナンス Hook は、
> 別リポジトリ [modern-cpp-agent-skills](https://github.com/sumimi/modern-cpp-agent-skills) で開発した成果をマージしたものです。

### 追加
- `AGENTS.md` を追加（AI エージェント向けリポジトリ操作ガイド）
- `.github/copilot-instructions.md` を全面刷新（プロジェクト規約・スキル一覧・ビルドコマンド早見表・コーディング規約等を大幅拡充）
- Agent Skills 7種を追加（`.github/skills/` 配下）
  - `cpp-architecture`：3層アーキテクチャ・依存性注入パターンガイド
  - `cpp-cmake`：CMake ビルド設定とカスタムターゲットガイド
  - `cpp-docs`：Doxygen ドキュメンテーションコメント規約
  - `cpp-format`：clang-format / clang-tidy コード品質管理ガイド
  - `cpp-googletest`：Google Test / Mock ユニットテストベストプラクティス
  - `cpp-modern-cpp`：C++17 モダン記法・設計パターンガイド
  - `git-commit`：Semantic Commits + Gitmoji コミットメッセージ作成ガイド
- カスタムエージェント2種を追加（`.github/agents/` 配下）
  - `C++ Code Reviewer`：設計・規約・セキュリティ・テスタビリティの多角的レビューエージェント
  - `C++ Debugger`：valgrind / AddressSanitizer / GDB を活用したデバッグ支援エージェント
- `.github/hooks/governance-audit.json` を追加（PostToolUse Hook 設定）
- `.github/hooks/governance-audit.sh` を追加（`.cpp`/`.hpp` 編集後に C++ 規約違反を自動検出するガバナンス監査スクリプト）

---

## [1.0.1] - 2026-02-22

### 追加
- `.editorconfig` を追加（インデント・文字コード等のエディタ設定を統一）
- `.gitmessage` を追加（コミットメッセージテンプレート）
- `.github/copilot-instructions.md` を追加（GitHub Copilot 向けプロジェクトガイドライン）
- `CONTRIBUTING.md` を追加（コントリビューションガイド）
- `.vscode/c_cpp_properties.json` / `.vscode/settings.json` を追加（VS Code C++ 開発環境設定）

### 変更
- `README.md` を更新（詳細説明・バッジ等を拡充）
- `.gitignore` を更新

### 修正
- `README.md` の絵文字文字化けを修正
- `tools/generate_coverage.sh` のカバレッジレポート生成エラーを修正

### 削除
- `test/CMakeLists.txt` から未使用の `spdlog` 依存関係を削除

---

## [1.0.0] - 2025-04-30

### 追加
- 初期テンプレート構成の作成（C++17 / CMake / GTest 対応）

