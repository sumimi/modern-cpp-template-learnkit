# 変更履歴（Changelog）

このファイルには、本プロジェクトにおけるすべての重要な変更を記録しています。

本形式は [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
[セマンティック バージョニング](https://semver.org/lang/ja/) に従って運用しています。

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

