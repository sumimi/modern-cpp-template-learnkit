# AGENTS.md

AI エージェントがこのリポジトリを操作・貢献する際のガイドです。

---

## プロジェクト概要

**Modern C++ Agent Skills** は、C++17 プロジェクト向けの GitHub Copilot Agent Skills コレクションです。  
7 つのドメイン別 `SKILL.md` と `copilot-instructions.md` をセットで提供します。

---

## リポジトリ構成

```
.github/
├── copilot-instructions.md         # カスタムインストラクション（全エージェント共通の規約）
├── agents/                         # カスタムエージェント定義
│   └── *.agent.md
├── hooks/                          # Agent Hooks 設定（PostToolUse 後に自動実行）
│   ├── governance-audit.json       # Hook イベント設定
│   └── governance-audit.sh         # C++ 規約違反を検出するガバナンス監査スクリプト
└── skills/
    ├── <skill-name>/
    │   └── SKILL.md                # スキル定義（frontmatter + 指示本文）
    └── ...
AGENTS.md                           # このファイル（AI エージェント向けガイド）
```

> **注意：** `AGENTS.md` はリポジトリルートに配置します（`.github/` 配下ではありません）。

---

## ビルド・テスト コマンド

| 目的 | コマンド |
|------|---------|
| 初期設定 | `cmake -S . -B build` |
| ビルド | `cmake --build build` |
| テスト実行 | `cmake --build build --target run_tests` |
| 静的解析 | `cmake --build build --target clang_tidy` |

コードを変更したら、必ず上記を順番に実行してすべて成功することを確認すること。

---

## 新しいスキルを追加するとき

1. `.github/skills/<skill-name>/SKILL.md` を作成する
2. `SKILL.md` の frontmatter に `name`・`description`・`argument-hint` を含める
3. `.github/copilot-instructions.md` の「Agent Skills 一覧」テーブルにエントリを追加する

### SKILL.md フォーマット

```markdown
---
name: skill-name
description: 'スキルの説明（10〜1024 文字）'
argument-hint: '[引数のヒント（例: クラス名・ファイル名）]'
---

# スキルタイトル

指示本文...
```

### 命名規則

- フォルダ名・`name` フィールド：`lower-case-with-hyphens`
- C++ ファイル名：PascalCase（`UserService.hpp`）
- 関数・変数名：snake_case

---

## 新しいエージェントを追加するとき

1. `.github/agents/<agent-name>.agent.md` を作成する
2. frontmatter に `name`・`description`・`tools` を含める
3. `.github/copilot-instructions.md` の「カスタムエージェント一覧」テーブルにエントリを追加する

### .agent.md フォーマット

```markdown
---
name: 'エージェントの表示名'
description: 'エージェントの説明'
tools: ['codebase', 'edit/editFiles', 'runCommands', 'runTests', 'search', 'problems']
---

# エージェントの指示本文...
```

---

## コーディング規約

詳細は `.github/copilot-instructions.md` と各 `SKILL.md` を参照すること。

---

## Hooks について

`.github/hooks/governance-audit.json` が定義する **`PostToolUse` Hook** は、
エージェントが `.cpp` / `.hpp` ファイルを編集・作成するたびに `.github/hooks/governance-audit.sh` を自動実行します。

検出する違反：

| カテゴリ | ルール | 検出パターン |
|----------|--------|------------|
| 規約系 | `using namespace std;` 禁止 | `using namespace std;` の存在 |
| 規約系 | 裸の `new` 禁止 | `= new ClassName` パターン |
| 規約系 | 裸の `delete` 禁止 | `delete ptr` / `delete[]` パターン |
| 規約系 | `NULL` 禁止 | `\bNULL\b` の存在 |
| 規約系 | `typedef` 禁止 | `\btypedef\b` の存在 |
| 規約系 | `#define` 数値定数禁止 | `UPPER_SNAKE + 数値リテラル` パターン |
| 規約系 | C スタイルキャスト禁止 | `(int)` / `(char*)` 等のパターン |
| 規約系 | `#pragma once` 必須 | `#ifndef..._HPP_` 形式のガード |
| 廃止機能 | `std::auto_ptr` 禁止 | `\bauto_ptr\b` の存在 |
| 廃止機能 | `register` キーワード禁止 | `\bregister\b` の存在 |
| セキュリティ | `system()` 禁止 | `\bsystem\s*(` パターン |
| セキュリティ | `gets()` 禁止 | `\bgets\s*(` パターン |
| セキュリティ | 安全でない文字列関数禁止 | `strcpy` / `strcat` / `sprintf` |
| セキュリティ | `rand()` / `srand()` 禁止 | `\b(rand\|srand)\s*(` パターン |
| セキュリティ | `atoi` 等禁止 | `\b(atoi\|atof\|atol\|atoll)\s*(` パターン |
| スタイル | C スタイルメモリ関数禁止 | `memcpy` / `memset` / `memcmp` 等 |
| スタイル | `std::endl` 多用禁止 | `<< (std::)?endl` パターン |
| スタイル | `void*` 禁止 | `\bvoid\s*\*` の存在 |
| スタイル | `printf` / `fprintf` 禁止 | `\b(printf\|fprintf)\s*(` パターン |

違反が検出されると `systemMessage` として警告が表示されます。修正してから続行してください。

> Hooks はプレビュー機能です。VS Code の `chat.useCustomAgentHooks: true` 設定が必要です。

---

## Boundaries（行動境界）

### ✅ 常に行うこと

- コード変更後は `cmake --build build` → `run_tests` → `clang_tidy` を順番に実行して成功を確認する
- 新しいクラスは `include/`・`src/`・`test/` の 3 ファイルをセットで作成する
- コーディング規約（`#pragma once` / `nullptr` / スマートポインタ等）を適用する
- clang-format で整形してからコミットする

### ⚠️ 事前にユーザーへ確認すること

- 差分が合計 200 行を超える変更
- 複数ファイルにわたる設計変更・インターフェース変更
- 既存の公開 API の変更

### 🚫 絶対に行わないこと

- `using namespace std;` の記述
- 裸のポインタ（`new` / `delete`）の使用
- シークレット・API キーのコードへの埋め込み
- テストが失敗した状態でのコミット
- `build/` ディレクトリ内のファイルを直接編集すること
- `.github/hooks/` 配下のファイルをユーザー承認なしに編集すること
