---
name: git-commit
description: "Semantic Commits + Gitmoji 形式でコミットメッセージを作成するガイド。コミットメッセージを作成するとき、type・Gitmoji・説明文の形式を確認・決定するときに使用する。"
argument-hint: "[#issue番号 issueタイトル（例: #123 ユーザー登録機能の追加）|省略時はステージ内容から自動生成]"
---

# Git コミットメッセージ作成ガイド

このプロジェクトは **Semantic Commits + Gitmoji** 形式でコミットメッセージを統一します。
変更内容を明確に伝え、自動 CHANGELOG 生成ツールにも対応できる形式です。

## フォーマット

```
<type>: :<emoji>: <1文の日本語で説明>

- <変更内容1>
- <変更内容2>
```

- 1行目（サマリ）は必須
- 空行を挟んだ後の箇条書き（ボディ）は任意。ステージした変更から抽出・整理して記述する

### 説明文のルール

- **言語**：日本語で記述する
- **文体**：**体言止め**または**「である」調**で統一する（「です・ます」調は禁止）
- **内容**：「何をどうした」を具体的に1文で記述する
- **Issue 番号が提供された場合**：`#123 issueタイトル` をそのまま採用する

| 良い例 ✅ | 悪い例 ❌ |
|-----------|----------|
| `UserService にユーザー登録機能を追加` | `ユーザー登録機能を追加しました` |
| `nullptr 参照によるクラッシュを修正` | `バグを直した` |
| `IUserRepository モックテストを追加` | `テスト追加` |
| `#123 ユーザー登録フォームのバリデーション追加`（Issue 指定時） | `issue 123 対応` |

## タイプ・Gitmoji 一覧

### 開発系

| タイプ | Gitmoji コード | 絵文字 | 用途 |
|--------|---------------|--------|------|
| `init` | `:tada:` | 🎉 | 初期コミット、プロジェクト作成 |
| `feat` | `:sparkles:` | ✨ | 新機能追加 |
| `fix` | `:bug:` | 🐛 | バグ修正 |
| `perf` | `:zap:` | ⚡ | パフォーマンス改善 |
| `refactor` | `:recycle:` | ♻️ | リファクタリング（機能変更なし） |
| `remove` | `:fire:` | 🔥 | コード・ファイルの削除 |

### 品質・テスト系

| タイプ | Gitmoji コード | 絵文字 | 用途 |
|--------|---------------|--------|------|
| `test` | `:white_check_mark:` | ✅ | テスト追加・修正 |
| `style` | `:art:` | 🎨 | コードフォーマット整形（機能変更なし） |
| `lint` | `:rotating_light:` | 🚨 | 静的解析・Linter 警告の修正 |

### ドキュメント・設定系

| タイプ | Gitmoji コード | 絵文字 | 用途 |
|--------|---------------|--------|------|
| `docs` | `:memo:` | 📝 | ドキュメント追加・更新 |
| `build` | `:package:` | 📦 | ビルドシステム・依存関係の変更 |
| `ci` | `:construction_worker:` | 👷 | CI/CD 設定の変更 |
| `chore` | `:wrench:` | 🔧 | 設定ファイルの軽微な変更 |
| `revert` | `:rewind:` | ⏪ | 以前のコミットの取り消し |

### その他の便利な Gitmoji

| Gitmoji コード | 絵文字 | 用途 |
|---------------|--------|------|
| `:construction:` | 🚧 | 作業中（WIP） |
| `:arrow_up:` | ⬆️ | 依存関係のアップグレード |
| `:arrow_down:` | ⬇️ | 依存関係のダウングレード |
| `:pushpin:` | 📌 | 依存関係を特定バージョンに固定 |
| `:pencil2:` | ✏️ | タイポ修正 |
| `:lock:` | 🔒 | セキュリティ修正 |
| `:green_heart:` | 💚 | CI ビルドの修正 |
| `:bookmark:` | 🔖 | バージョンタグ・リリース |
| `:bulb:` | 💡 | コードのコメント追加・更新 |
| `:see_no_evil:` | 🙈 | .gitignore の追加・更新 |
| `:loud_sound:` | 🔊 | ログ追加 |
| `:mute:` | 🔇 | ログ削除 |
| `:children_crossing:` | 🚸 | ユーザー体験・使いやすさの改善 |
| `:goal_net:` | 🥅 | エラーハンドリングの追加・改善 |

## 使用例

### 複数行の場合

```
feat: :sparkles: UserService にユーザー登録機能を追加

- UserService::registerUser() を実装
- IUserRepository::save() を呼び出す処理を追加
- 重複登録時は DuplicateUserException を送出
```

### 単一行の場合

```
fix: :bug: UserService のメモリリーク問題を修正
test: :white_check_mark: UserRepository のユニットテストを追加
refactor: :recycle: AppController の責務を UserService に移動
docs: :memo: README のクイックスタート手順を更新
build: :package: Google Test を v1.14.0 にアップグレード
chore: :wrench: .clang-format の設定を更新
style: :art: clang-format によるコード整形を適用
init: :tada: Modern C++ プロジェクトを初期化
```

## 良い例 vs 悪い例

| 良い例 ✅ | 悪い例 ❌ | 理由 |
|-----------|----------|------|
| `feat: :sparkles: ユーザー一覧取得 API を追加` | `update: update code` | タイプが不明確、説明が不十分 |
| `fix: :bug: nullptr 参照によるクラッシュを修正` | `fix: バグを直した` | 体言止め・である調でない、何のバグか不明 |
| `test: :white_check_mark: IUserRepository モックテストを追加` | `test: テスト` | 何のテストか不明 |
| `refactor: :recycle: getUserById を UserService に移動` | `refactor: リファクタ` | 何をリファクタしたか不明 |

## 作成手順（対話フロー）

コミットメッセージを作成するとき、以下の順で決定します：

1. **変更の種類を特定** → `type` を選択（feat / fix / test / ...）
2. **対応する Gitmoji を選択** → 上記一覧から選ぶ
3. **説明文を決定する**
   - Issue 番号が渡された場合 → `#123 issueタイトル` をそのまま採用
   - Issue 番号がない場合 → 変更内容から要約して体言止め・である調で記述
4. **フォーマットに当てはめる** → `<type>: :<emoji>: <説明>`
5. **ボディを追加する（任意）** → ステージした変更から箇条書きで変更内容を列挙

## 参考

- [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
- [Gitmoji](https://gitmoji.dev/)
