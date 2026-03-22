---
name: cpp-format
description: "clang-format / clang-tidy によるコードフォーマットと静的解析のガイド。コード整形・命名規則チェック・静的解析警告の修正、clang-format/clang-tidy の設定や実行方法を確認・適用するときに使用する。"
argument-hint: "[対象ファイル名または修正したい警告内容（例: UserService.hpp / readability-identifier-naming）]"
---

# コードフォーマット・静的解析ガイド

このプロジェクトでは **clang-format**（フォーマット）と **clang-tidy**（静的解析）の
2つのツールでコード品質を維持します。

## clang-format と clang-tidy の違い

| ツール | 役割 | 対象 |
|--------|------|------|
| `clang-format` | コードの見た目を整える（インデント・空白・改行） | スタイル規約 |
| `clang-tidy` | コードの問題を検出する（バグ・非推奨API・規約違反） | 品質規約 |

---

## clang-format（コード整形）

### 設定ファイル（`.clang-format`）

プロジェクトルートの `.clang-format` で **Google C++ Style** ベースの整形ルールを定義しています。

主要な設定内容：

| 設定項目 | 値 | 意味 |
|---------|----|----|
| `BasedOnStyle` | `Google` | Google C++ Style Guide ベース |
| `IndentWidth` | `4` | インデント: スペース4つ |
| `ColumnLimit` | `100` | 1行の文字数上限: 100文字 |
| `AllowShortFunctionsOnASingleLine` | `None` | 短い関数も複数行に展開 |
| `SortIncludes` | `true` | `#include` を自動ソート |

### VS Code での自動整形（保存時）

`.vscode/settings.json` に以下が設定済みで、**ファイル保存時に自動整形**されます：

```json
{
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "llvm-vs-code-extensions.vscode-clangd",
    "[cpp]": {
        "editor.defaultFormatter": "llvm-vs-code-extensions.vscode-clangd"
    }
}
```

### コマンドラインでの整形

```bash
# 特定ファイルを整形（上書き）
clang-format -i src/sampleapp/UserService.cpp

# すべての C++ ファイルを整形
find src include test -name "*.cpp" -o -name "*.hpp" | xargs clang-format -i

# 整形後の差分だけ確認（上書きしない）
clang-format --dry-run -Werror src/sampleapp/UserService.cpp
```

### よくある整形ルール

```cpp
// ✅ インデント: スペース4つ
void foo() {
    if (condition) {
        doSomething();
    }
}

// ✅ ポインタ/参照の位置: 型側に付ける
void process(const std::string& name);
std::unique_ptr<User> createUser();

// ✅ 関数の波括弧は同行に
void foo() {     // ✅ (Google Style)
    // ...
}

// ✅ コンストラクタ初期化リストのインデント
UserService::UserService(std::shared_ptr<IUserRepository> repository)
    : repository_(std::move(repository)) {}
```

---

## clang-tidy（静的解析）

### 実行コマンド

```bash
cmake --build build --target clang_tidy
# 結果は build/clang_tidy.log に出力
```

### 有効なチェック項目（主なもの）

| チェック | 内容 |
|---------|------|
| `modernize-use-nullptr` | `NULL` → `nullptr` |
| `modernize-use-auto` | 明らかな型宣言を `auto` に |
| `modernize-use-override` | 仮想関数に `override` を付ける |
| `modernize-smart-ptr` | 裸のポインタ → スマートポインタ |
| `cppcoreguidelines-avoid-c-arrays` | C スタイル配列を避ける |
| `readability-identifier-naming` | 命名規則チェック（camelCase等） |
| `performance-unnecessary-copy-initialization` | 不要なコピーを参照に |
| `bugprone-use-after-move` | ムーブ後の使用を検出 |
| `bugprone-null-dereference` | nullptr 参照を検出 |

### よくある警告と修正例

```cpp
// ⚠️  modernize-use-nullptr
if (ptr == NULL)   // ← 警告
if (ptr == nullptr) // ← 修正

// ⚠️ modernize-use-override
virtual void process();          // ← 警告（派生クラスで）
virtual void process() override; // ← 修正

// ⚠️ performance-unnecessary-copy-initialization
std::string name = getName();        // ← 名前付き return value の場合
const auto& name = getName();        // ← 参照で受ける（コピーなし）

// ⚠️ modernize-use-auto
std::vector<User>::iterator it = users.begin();  // ← 警告
auto it = users.begin();                         // ← 修正

// ⚠️ cppcoreguidelines-avoid-c-arrays
int arr[10];                    // ← 警告
std::array<int, 10> arr;        // ← 修正
std::vector<int> arr(10);       // ← 可変長の場合
```

### 警告を無効化する（本当に必要な場合のみ）

```cpp
// NOLINT: 特定行の警告を無効化
auto p = reinterpret_cast<char*>(ptr);  // NOLINT(cppcoreguidelines-pro-type-reinterpret-cast)

// NOLINTNEXTLINE: 次の行の警告を無効化
// NOLINTNEXTLINE(modernize-use-trailing-return-type)
int getValue() { return value_; }
```

---

## 整形ルールに違反した場合の対処

1. **保存時に自動修正**（通常はこれで解決）: ファイルを保存するだけ
2. **コマンドラインで一括修正**: `clang-format -i` で上書き整形
3. **clang-tidy の警告**: 手動で修正するか、`--fix` オプションで自動修正

```bash
# clang-tidy の自動修正（一部のチェックのみ対応）
clang-tidy --fix src/sampleapp/UserService.cpp -- -I include -std=c++17
```

---

## 参考

- [clang-format ドキュメント](https://clang.llvm.org/docs/ClangFormat.html)
- [clang-tidy ドキュメント](https://clang.llvm.org/extra/clang-tidy/)
- [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
- [C++ Core Guidelines チェック一覧](https://clang.llvm.org/extra/clang-tidy/checks/list.html)
