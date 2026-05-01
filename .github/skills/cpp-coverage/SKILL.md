---
name: cpp-coverage
description: "lcov/genhtml によるカバレッジ測定と LCOV 除外コメントの使用ガイド。カバレッジレポートの生成・確認方法、LCOV_EXCL_LINE/LCOV_EXCL_BR_LINE 等の正しい使用基準と禁止パターンを実装・レビューするときに使用する。"
argument-hint: "[対象ファイル名または問題の種類（例: UserService.cpp / 仮想デストラクタ / EH分岐）]"
---

# カバレッジ測定・LCOV 除外コメントガイド

このプロジェクトでは **lcov / genhtml** を使ってカバレッジレポートを生成します。
C1（分岐）カバレッジは `.lcovrc` で有効化されており、HTML レポートは `build/coverage_report/` に出力されます。

---

## カバレッジの実行

```bash
# 初回設定（カバレッジ有効化）
cmake -DENABLE_COVERAGE=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -S . -B build -DCMAKE_TOOLCHAIN_FILE=vendor/conan_toolchain.cmake

# ビルド → テスト → カバレッジレポート生成
cmake --build build
cmake --build build --target run_tests
cmake --build build --target coverage
```

推奨は `cmake --build build --target coverage` の実行です。`tools/generate_coverage.sh` 側で lcov/genhtml のオプション互換（例：`--branch-coverage`、`--ignore-errors`）を吸収します。

レポートを開く：`build/coverage_report/index.html`

---

## カバレッジ対象スコープ

`tools/generate_coverage.sh` は `lcov --extract` でプロジェクトファイルのみを抽出します。

| 対象 | 説明 |
|------|------|
| `$PROJECT_ROOT/src/*` | 実装ファイル（常に対象） |
| `$PROJECT_ROOT/include/*` | プロジェクトヘッダ（テンプレート・インライン実装を含む場合は対象） |
| vendor/ / /usr/include/ 等 | 自動除外（extract で除外される） |

---

## LCOV 除外コメント マーカー一覧

| マーカー | 効果 | 使用単位 |
|---------|------|---------|
| `// LCOV_EXCL_LINE` | 行全体（行・関数・分岐）を除外 | 1行 |
| `// LCOV_EXCL_BR_LINE` | 分岐のみ除外（行・関数は計測） | 1行 |
| `// LCOV_EXCL_START` / `// LCOV_EXCL_STOP` | ブロック全体を除外 | 複数行 |
| `// LCOV_EXCL_BR_START` / `// LCOV_EXCL_BR_STOP` | ブロックの分岐のみ除外 | 複数行 |

---

## LCOV コメントの使用判断フロー

```
分岐/関数がカバーされていない
        │
        ├─ テストを追加すれば到達できる？
        │       └─ YES → テストを追加する（LCOV コメント不要）
        │
        └─ NO → 原因を特定する
                ├─ コンパイラ生成アーティファクト（D0デストラクタ / EH分岐）
                │       └─ LCOV_EXCL_LINE / LCOV_EXCL_BR_LINE を付与 ＋ 理由コメント
                ├─ 設計上ありえないパス（default throw 等）
                │       └─ LCOV_EXCL_START / STOP ＋ 理由コメント
                └─ プラットフォーム固有コード
                    ├─ まず有効化ビルド/テスト（ビルドマトリクス・フラグON）を検討
                    └─ それでも検証不能な場合のみ LCOV_EXCL_LINE または ifdef ブロック除外
```

---

## パターン別ガイド

### パターン1：仮想デストラクタの D0 アーティファクト

**原因：** `virtual ~Foo() = default` に対してコンパイラが D0（削除デストラクタ）と D2（基底デストラクタ）の2シンボルを生成する。vtable 経由では D2 のみが呼ばれるため D0 は到達不可能。

```cpp
// 純粋仮想インターフェースのデストラクタ — D0 は vtable 経由で到達不可
virtual ~IUserRepository() = default;  // LCOV_EXCL_LINE
```

**適用条件：** genhtml の未達行と生成シンボル（D0 由来）を確認し、テスト追加で到達不能と判断できた場合のみ適用する。

---

### パターン2：例外安全コードの EH 分岐アーティファクト

**原因：** コンパイラが例外スタック巻き戻し用の「例外パス」を分岐として生成する。テストで例外を意図的に発生させない限り到達不可能。論理的な `if/switch` がないのに branches 50% になっている場合がこれにあたる。

```cpp
void UserService::register_user(const std::string& name) {
    // コンパイラ生成の EH 分岐（例外スタック巻き戻しパス）を除外
    User user{/* id */ 0, name, name + "@example.com"};  // LCOV_EXCL_BR_LINE
    repository_->insert_user(user);                       // LCOV_EXCL_BR_LINE
}
```

**適用条件：** 行に論理分岐（if/switch/三項演算子）が一切なく、branches だけが未達になっている場合のみ。

---

### パターン3：到達不可能な default / エラーハンドリング

**原因：** `enum class` が完全に列挙されており、`default` が論理的に到達しないが、コンパイラ警告回避のために記述する場合。

```cpp
std::string to_string(Status s) {
    switch (s) {
        case Status::OK:    return "ok";
        case Status::ERROR: return "error";
        // enum class が完全列挙されているため default は到達不可
        // LCOV_EXCL_START
        default:
            throw std::logic_error("unknown status");
        // LCOV_EXCL_STOP
    }
}
```

**適用条件：** `enum class` の全列挙子が case で網羅されていることを確認してから適用する。

---

### パターン4：プラットフォーム / ビルドフラグ固有コード

**原因：** 現在のビルド設定では有効にならないコードパス。

```cpp
bool has_feature() {
#ifdef ENABLE_OPTIONAL_FEATURE
    return check_feature();  // LCOV_EXCL_LINE — このビルド設定では無効
#else
    return false;
#endif
}
```

---

## 禁止パターン

```cpp
// NG: テストを書けば到達できるのに除外している
std::optional<User> get_user_by_id(int id) {
    auto result = repo_->find(id);
    if (!result) return std::nullopt;  // LCOV_EXCL_LINE ← テストを書くべき
    return result;
}

// NG: 理由コメントなしのブロック除外
// LCOV_EXCL_START
void complex_logic() { /* ... */ }
// LCOV_EXCL_STOP

// NG: 関数全体を丸ごと除外（テスト設計の放棄）
void important_function() {  // LCOV_EXCL_LINE
    /* ... */
}
```

**原則：** LCOV コメントには「なぜテストで到達できないか」の説明を添えること。説明できない場合はテストを書く。

---

## レビューチェックリスト

コードに `LCOV_EXCL` が含まれる場合、以下を確認する：

- [ ] コンパイラアーティファクト（D0/EH分岐）であることを確認したか
- [ ] テスト追加で解決できないことを確認したか
- [ ] 除外理由（カバレッジレポート上の未達箇所・根拠）をコード内コメントとして残したか
- [ ] マーカーの直前または同行に理由コメントを記述しているか
- [ ] `LCOV_EXCL_BR_LINE`（分岐のみ除外）で足りる場合に `LCOV_EXCL_LINE`（全除外）を使っていないか
- [ ] `LCOV_EXCL_START/STOP` ブロックは最小範囲に絞られているか
