# GitHub Copilot Instructions

## コミットメッセージ形式

このプロジェクトでは、以下の形式でコミットメッセージを記述してください：

### フォーマット
```
<type>: :<emoji>: <description>
```

- **type**: Semantic Commit Messagesの接頭辞（feat, fix, docs, など）
- **emoji**: Gitmojiのコード（`:sparkles:`, `:bug:`, など）
- **description**: 1文の日本語で説明

### 主なタイプとGitmoji

| タイプ | Gitmoji | 説明 | 例 |
|--------|---------|------|-----|
| feat | `:sparkles:` | 新機能追加 | `feat: :sparkles: プロジェクト検索機能を追加` |
| fix | `:bug:` | バグ修正 | `fix: :bug: プロジェクト一覧の表示エラーを修正` |
| docs | `:memo:` | ドキュメント更新 | `docs: :memo: READMEを更新` |
| style | `:art:` | コードフォーマット | `style: :art: インデントを統一` |
| refactor | `:recycle:` | リファクタリング | `refactor: :recycle: 関数を整理` |
| perf | `:zap:` | パフォーマンス改善 | `perf: :zap: 読み込み速度を改善` |
| test | `:white_check_mark:` | テスト追加・修正 | `test: :white_check_mark: テストを追加` |
| build | `:package:` | ビルドシステム変更 | `build: :package: 依存関係を更新` |
| ci | `:construction_worker:` | CI設定変更 | `ci: :construction_worker: GitHub Actionsを改善` |
| chore | `:wrench:` | 設定ファイル変更 | `chore: :wrench: 設定ファイルを更新` |
| security | `:lock:` | セキュリティ修正 | `security: :lock: 脆弱性を修正` |
| init | `:tada:` | 初期コミット | `init: :tada: プロジェクトを初期化` |

### その他の便利なGitmoji

- `:fire:` - コード/ファイル削除
- `:lipstick:` - UI/スタイル更新
- `:wheelchair:` - アクセシビリティ改善
- `:green_heart:` - CI修正
- `:arrow_up:` - 依存関係アップグレード
- `:arrow_down:` - 依存関係ダウングレード
- `:pushpin:` - 依存関係を特定バージョンに固定
- `:pencil2:` - タイポ修正
- `:rewind:` - コミット取り消し

## コーディング規約

- JavaScriptでは厳格な型チェックとエスケープ処理を実施
- セキュリティを最優先（XSS対策、URLサニタイズなど）
- Pythonではデータバリデーションを必ず実装

## 参考

- [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
- [Gitmoji](https://gitmoji.dev/)
