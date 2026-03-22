# GitHub Copilot Instructions

このプロジェクトは **Modern C++** をベースとした C++17 プロジェクトテンプレートです。  
Modern C++のベストプラクティス（テスト駆動開発・静的解析・ドキュメント生成・カバレッジ測定）を実践する学習用テンプレートです。  
実行環境は **Linux（RHEL9系）** を前提とします。  
以下の規約・構造を常に意識してコードや提案を生成してください。  

このファイルの情報を信頼してください。情報が不完全または誤りだと判断した場合のみ、追加の探索を行ってください。

---

## 前提条件

- **回答は日本語で行う。**
- コードの追加・変更・削除の差分行数が合計200行を超える見込みの場合は、実行前にユーザーへ確認する。
- 複数ファイルにわたる変更や設計に影響する変更を行う場合は、まず実施計画を立ててユーザーに提案し、承認を得てから実行する。

---

## Agent Skills 一覧

詳細なガイドは `.github/skills/` 配下の各 `SKILL.md` を参照してください。

| スキル | 用途 |
|--------|------|
| `cpp-architecture` | 3層アーキテクチャと依存性注入パターン |
| `cpp-cmake` | CMake ターゲット設計とビルド設定 |
| `cpp-modern-cpp` | Modern C++(C++17)の記法と設計パターン |
| `cpp-format` | clang-format / clang-tidy によるコード品質管理 |
| `cpp-docs` | Doxygen ドキュメンテーションコメントの記述規約 |
| `cpp-googletest` | Google Test / Mock によるユニットテストの書き方 |
| `git-commit` | コミットメッセージの作成ガイド（Gitmoji 全種一覧含む） |

---

## カスタムエージェント一覧

`.github/agents/` 配下の `*.agent.md` で定義された専門エージェントです。  
VS Code Agent モードでエージェント名を選択して呼び出します。

| エージェント | 用途 |
|-------------|------|
| `C++ Code Reviewer` | コードレビュー（設計・規約・セキュリティ・テスタビリティ） |
| `C++ Debugger` | デバッグ支援（valgrind / AddressSanitizer / GDB） |

---

## 利用ツール

| ツール | 必須/任意 | バージョン | 用途 |
|--------|----------|-----------|------|
| CMake | 必須 | >= 3.15 | ビルドシステム |
| g++ / clang++ | 必須 | GCC 11+ / Clang 17+ | C++17 コンパイル |
| Google Test | 必須 | 1.14（`/opt/gtest/gtest-1.14`） | ユニットテスト |
| spdlog | 必須 | システムインストール済み | ログ出力 |
| clang-tidy | 任意 | 17+ | 静的解析 |
| lcov | 任意 | 1.14+ | カバレッジ測定 |
| valgrind | 任意 | 3.21+ | メモリチェック |
| Doxygen | 任意 | 1.9+ | ドキュメント生成 |
| xsltproc | 任意 | - | テストレポートHTML変換 |

---

## プロジェクト構造

```
.github/skills/     # Agent Skills（詳細ガイド、オンデマンド参照）
.github/agents/     # カスタムエージェント定義（*.agent.md）
.github/hooks/      # Agent Hooks 設定・実行スクリプト（PostToolUse 後に自動実行）
include/<module>/   # ヘッダファイル（*.hpp）— クラス定義・インターフェース
src/<module>/       # ソースファイル（*.cpp）— 実装
test/unit/<module>/ # ユニットテスト（*Test.cpp）— Google Test/Mock
tools/              # ビルド補助スクリプト
docs/               # Doxygen 設定・出力
```

## ビルド・テスト コマンド早見表

| 目的 | コマンド |
|------|---------|
| 初期設定 | `cmake -S . -B build` |
| ビルド | `cmake --build build` |
| 実行 | `./build/bin/main` |
| テスト実行 | `cmake --build build --target run_tests` |
| カバレッジ（要 `ENABLE_COVERAGE=ON`） | `cmake --build build --target coverage` |
| 静的解析 | `cmake --build build --target clang_tidy` |
| ドキュメント生成 | `cmake --build build --target doc` |
| メモリチェック | `cmake --build build --target valgrind` |
| 全成果物削除 | `cmake --build build --target clean_all` |

カバレッジ測定には `cmake -DENABLE_COVERAGE=ON -S . -B build` で再構成が必要。

---

## C++ コーディング規約

- **標準**： C++17 準拠（`-std=c++17`）
- **スタイル**： [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html) に準拠し、`.clang-format` で自動整形
- **クラス名**： PascalCase（例： `UserService`）
- **関数・変数名**： snake_case（例： `get_user_by_id`）
- **ファイル名**： PascalCase（例： `UserService.hpp`, `UserService.cpp`）。ただし、エントリポイント（例： `main.cpp`）は例外的にsnake_caseを採用。
- **マクロ・定数**： UPPER_SNAKE_CASE（例： `MAX_RETRY_COUNT`）
- **インデント**： スペース4つ（C++ ファイル）

### 禁止事項

- `using namespace std;`： 名前空間汚染を防ぐため禁止
- 裸のポインタ（`new` / `delete`）： スマートポインタ（`std::unique_ptr`, `std::shared_ptr`）を使用
- `NULL` ： `nullptr` を使用
- C スタイルキャスト `(Type)x` ： `static_cast<Type>(x)` などを使用
- 伝統的なインクルードガード（`#ifndef`/`#define`/`#endif` 形式）： `#pragma once` を使用する

### 推奨事項

- `auto` を積極的に使用（型が文脈から明らか、またはイテレータ等の長い型名の場合）
- `const` を可能な限り付与（変数・参照引数・メンバ関数）
- `constexpr` を定数式に使用（`#define` の代わり）
- リソース管理は RAII パターンで行う
- 依存性はインターフェース（純粋仮想クラス `IFoo`）経由で注入する

---

## 新しいクラスを追加するとき

1つのクラスに対して必ず以下の3ファイルをセットで作成する：

```
include/<module>/Foo.hpp          # クラス定義
src/<module>/Foo.cpp              # 実装
test/unit/<module>/FooTest.cpp    # ユニットテスト
```

CMakeLists.txt は `file(GLOB ...)` でソースを自動収集しているため修正不要。

---

## コミット前チェック（必須）

コードをコミットする前に以下を順番に実行し、すべて成功することを確認する：

1. `cmake --build build` — ビルド成功
2. `cmake --build build --target run_tests` — 全テスト通過
3. `cmake --build build --target clang_tidy` — 静的解析（警告・エラーがないこと）
4. clang-format による自動整形済みであること（`.clang-format` 準拠）

---

## コミットメッセージ規約（要約）

形式： `<type>: :<emoji>: <1文の日本語で説明>`

| タイプ | Gitmoji | 用途 |
|--------|---------|------|
| `feat` | `:sparkles:` | 新機能追加 |
| `fix` | `:bug:` | バグ修正 |
| `docs` | `:memo:` | ドキュメント更新 |
| `test` | `:white_check_mark:` | テスト追加・修正 |
| `refactor` | `:recycle:` | リファクタリング |
| `build` | `:package:` | ビルドシステム変更 |
| `chore` | `:wrench:` | 設定ファイル変更 |
| `init` | `:tada:` | 初期コミット |

詳細な Gitmoji 一覧・作成ガイドは `.github/skills/git-commit/SKILL.md` を参照。

---

## 参考

- [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
- [GoogleTest ドキュメント](https://github.com/google/googletest)
- [CMake ドキュメント](https://cmake.org/documentation/)
- [Doxygen](https://www.doxygen.nl/)
- [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
- [Gitmoji](https://gitmoji.dev/)
