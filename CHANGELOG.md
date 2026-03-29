# 変更履歴（Changelog）

このファイルには、本プロジェクトにおけるすべての重要な変更を記録しています。

本形式は [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
[セマンティック バージョニング](https://semver.org/lang/ja/) に従って運用しています。

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

