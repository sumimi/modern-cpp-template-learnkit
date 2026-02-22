# コントリビューションガイド

このプロジェクトへのコントリビューションを歓迎します！バグ報告、機能提案、プルリクエストなど、あらゆる形での貢献をお待ちしています。

---

## 📋 コントリビューション方法

### 1. Issue を作成する

バグ報告や機能提案は、まず [GitHub Issues](https://github.com/sumimi/modern-cpp-template-learnkit/issues) で Issue を作成してください。

**バグ報告時に含めてほしい情報：**
- 再現手順
- 期待される動作と実際の動作
- 環境情報（OS、コンパイラバージョン、CMakeバージョンなど）

**機能提案時に含めてほしい情報：**
- 実現したい機能の説明
- なぜその機能が必要か
- 可能であれば実装案

### 2. プルリクエストを送る

1. このリポジトリをフォーク
2. 機能ブランチを作成（`git checkout -b feature/amazing-feature`）
3. コミット（コミットメッセージ形式については後述）
4. ブランチにプッシュ（`git push origin feature/amazing-feature`）
5. プルリクエストを作成

---

## ✍️ コミットメッセージ形式

このプロジェクトでは、**Semantic Commit Messages + Gitmoji** 形式でコミットメッセージを統一しています。

### フォーマット

```
<type>: :<emoji>: <1文の日本語で説明>
```

### 主なタイプとGitmoji

| タイプ | Gitmoji | 説明 | 例 |
|--------|---------|------|-----|
| feat | `:sparkles:` | 新機能追加 | `feat: :sparkles: カバレッジ測定機能を追加` |
| fix | `:bug:` | バグ修正 | `fix: :bug: ビルドエラーを修正` |
| docs | `:memo:` | ドキュメント更新 | `docs: :memo: セットアップガイドを更新` |
| style | `:art:` | コードフォーマット | `style: :art: clang-format適用` |
| refactor | `:recycle:` | リファクタリング | `refactor: :recycle: ディレクトリ構造を整理` |
| perf | `:zap:` | パフォーマンス改善 | `perf: :zap: ビルド時間を短縮` |
| test | `:white_check_mark:` | テスト追加・修正 | `test: :white_check_mark: UserServiceのテストを追加` |
| build | `:package:` | ビルドシステム変更 | `build: :package: CMake最小バージョンを更新` |
| ci | `:construction_worker:` | CI設定変更 | `ci: :construction_worker: GitHub Actionsを追加` |
| chore | `:wrench:` | 設定ファイル変更 | `chore: :wrench: .gitignoreを更新` |

### その他の便利なGitmoji

- `:fire:` - コード/ファイル削除
- `:pencil2:` - タイポ修正
- `:lipstick:` - UI/スタイル更新
- `:wheelchair:` - アクセシビリティ改善
- `:green_heart:` - CI修正
- `:lock:` - セキュリティ修正

**詳細は `.github/copilot-instructions.md` を参照してください。**

### Gitコミットテンプレートの設定

コミットメッセージテンプレートを使用すると便利です：

```bash
git config commit.template .gitmessage
```

これにより、`git commit`（メッセージなし）を実行したときに、自動的にテンプレートが表示されます。

---

## 🎨 コーディング規約

### C++コーディングスタイル

- **[Google C++ Style Guide](https://ttsuki.github.io/styleguide/cppguide.ja.html)** に準拠
- **clang-format** による自動整形を推奨
- 保存時に自動整形されるよう、`.vscode/settings.json` が設定済み

### コードフォーマット

プルリクエスト前に、以下を実行してください：

```bash
# 全ファイルをclang-formatで整形
find src include test -name "*.cpp" -o -name "*.hpp" | xargs clang-format -i
```

### テストの追加

新機能を追加する場合は、必ずユニットテストを追加してください：

1. `test/unit/` ディレクトリに対応するテストファイルを作成
2. Google Test を使用してテストを記述
3. `cmake --build build --target run_tests` でテストが通ることを確認

### カバレッジの確認

以下のコマンドでカバレッジを確認できます：

```bash
cmake -DENABLE_COVERAGE=ON -S . -B build
cmake --build build
cmake --build build --target coverage
```

`build/coverage_report/index.html` を開いて、新しいコードがテストでカバーされていることを確認してください。

---

## 📖 ドキュメントの更新

コードの変更に伴ってドキュメントも更新してください：

- **README.md**: プロジェクト全体の説明や使い方に変更がある場合
- **docs/SETUP_GUIDE.md**: セットアップ手順に変更がある場合
- **コードコメント**: Doxygen形式でコメントを記述

---

## 🔍 プルリクエストレビュー基準

プルリクエストは以下の基準でレビューされます：

- ✅ コミットメッセージが規約に従っているか
- ✅ コードがコーディング規約に従っているか
- ✅ 新機能にユニットテストが追加されているか
- ✅ 既存のテストが全て通るか
- ✅ ドキュメントが更新されているか（必要な場合）
- ✅ 変更内容が明確に説明されているか

---

## 🙏 謝辞

このプロジェクトへのコントリビューションに感謝します！

質問や不明点があれば、遠慮なく [GitHub Issues](https://github.com/sumimi/modern-cpp-template-learnkit/issues) で質問してください。

---

## 📚 参考資料

- [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
- [Gitmoji](https://gitmoji.dev/)
- [Google C++ Style Guide](https://ttsuki.github.io/styleguide/cppguide.ja.html)
- [GitHub Flow](https://docs.github.com/ja/get-started/quickstart/github-flow)
