---
name: cpp-docs
description: "C++ の Doxygen ドキュメンテーションコメント記述規約。@brief/@param/@return/@throws などのタグ記述、ファイル・クラス・関数へのコメント追加・レビューをするときに使用する。"
argument-hint: "[対象ファイル名またはクラス名（任意）]"
---

# C++ ドキュメンテーションコメント規約

このプロジェクトでは **Doxygen** を使ってドキュメンテーションコメントからドキュメントを自動生成します。
コメント形式は以下の3種類を使い分けます。

| 形式 | 記法 | 用途 |
|------|------|------|
| 複数行 | `/** ... */` | クラス・関数など詳細な説明が必要な要素 |
| 単一行（前置き） | `///` | 関数・変数など1行で説明が完結する要素の直前 |
| 単一行（後置き） | `///<` | 構造体・列挙体のメンバ変数など、宣言と同じ行の後ろ |

```cpp
/// ユーザーを ID で検索します。
User find_by_id(int id) const;

struct User {

    int id;           ///< ユーザーの一意識別子
    std::string name; ///< ユーザー名（255文字以内）
    bool is_active;   ///< 有効フラグ
};
```

## ドキュメント生成

```bash
cmake --build build --target doc
# 出力先： docs/html/index.html
```

## コメント形式

### ファイルコメント（各 .hpp / .cpp の先頭）

```cpp
/**
 * @file UserService.hpp
 * @brief ユーザー管理ビジネスロジック層のインターフェース定義です。
 * @details IUserRepository を通じてユーザーの取得・登録・削除を行います。
 *          依存性注入（DI）パターンにより、テスト時にモックへ差し替えられます。
 */
```

- `@author`・`@date` は記述しません（バージョン管理は Git で行うため）

### クラスコメント

```cpp
/**
 * @brief ユーザー管理に関するビジネスロジックを提供するサービスクラスです。
 * @details UserRepository を通じてユーザーの取得・登録・削除を行います。
 *          依存性注入（DI）パターンにより IUserRepository のモックに差し替えられます。
 *          バリデーションはこのクラスで実施し、データアクセスには直接触れません。
 *
 * @see IUserRepository
 */
class UserService {
    // ...
};
```

### メンバ関数コメント

```cpp
/**
 * @brief 指定した ID のユーザーを取得します。
 *
 * @param id 検索対象のユーザー ID（1以上の正の整数）
 * @return 見つかったユーザー情報
 * @throws std::invalid_argument id が0以下の場合
 * @throws UserNotFoundException 指定した ID のユーザーが存在しない場合
 *
 * @note ID が存在しない場合は例外を投げます。オプショナル取得には
 *       find_user_by_id() を使用してください。
 */
User get_user_by_id(int id) const;
```

`@param` は方向指定子（`[in]`・`[out]`・`[in,out]`）を**使用しません**。
常に `@param name` の形式で記述します。

### コンストラクタ・デストラクタコメント

`@brief` はコンストラクタ種別に応じた定型文で統一します。

| 種別 | `@brief` の形式 |
|------|-----------------|
| 通常コンストラクタ | `コンストラクタです。` |
| デフォルトコンストラクタ | `デフォルトコンストラクタです。` |
| コピーコンストラクタ | `コピーコンストラクタです。` |
| ムーブコンストラクタ | `ムーブコンストラクタです。` |
| デストラクタ | `デストラクタです。` |

```cpp
/**
 * @brief コンストラクタです。
 *
 * @param repository ユーザーデータアクセスオブジェクト（非 null）
 * @pre repository は有効なポインタでなければなりません
 */
explicit UserService(std::shared_ptr<IUserRepository> repository);

/// コピーコンストラクタです。
UserService(const UserService&) = delete;

/// ムーブコンストラクタです。
UserService(UserService&&) noexcept = default;
```

### インターフェース（純粋仮想関数）コメント

```cpp
/**
 * @brief ユーザーリポジトリのインターフェースです。
 * @details データアクセス層の抽象化を提供します。
 *          テスト時は MockUserRepository に差し替えて使用します。
 */
class IUserRepository {
public:
    /**
     * @brief デストラクタです。
     * @details 派生クラスのデストラクタが確実に呼ばれるよう、仮想デストラクタとして定義します。
     */
    virtual ~IUserRepository() = default;

    /**
     * @brief ID でユーザーを検索します。
     * @param id 検索対象のユーザー ID
     * @return 見つかったユーザー情報
     */
    virtual User find_by_id(int id) const = 0;
};
```

## よく使うタグ一覧

| タグ | 用途 |
|------|------|
| `@brief` | 一行の概要説明（必須） |
| `@details` | `@brief` に続く詳細説明（ファイル・クラス・複雑な関数に使用） |
| `@param name` | パラメータの説明（方向指定子なし） |
| `@return` | 戻り値の説明 |
| `@throws ExceptionType` | 送出する例外の説明 |
| `@note` | 補足説明・注意事項 |
| `@warning` | 重要な警告メッセージ |
| `@see OtherClass` | 関連クラス・関数への参照 |
| `@since 1.0.0` | 機能が追加されたバージョン |
| `@deprecated` | 非推奨マーク（代替案を記述） |
| `@pre` | 事前条件（呼び出し前に満たすべき条件） |
| `@post` | 事後条件（呼び出し後に保証される条件） |
| `@todo` | 今後の課題・未実装事項 |

## インラインコード・コードブロック

```cpp
/**
 * @brief ユーザー名をバリデーションします。
 * @details 名前は @c std::string 型で受け取り、以下の規則で検証します。
 *          - 1文字以上255文字以下であること
 *          - 先頭・末尾に空白を含まないこと
 *
 * 使用例：
 * @code
 * bool result = UserValidator::is_valid_name("Alice");  // true
 * bool result = UserValidator::is_valid_name("");        // false
 * @endcode
 */
static bool is_valid_name(const std::string& name);
```

## ドキュメント記述の原則

- **すべてのコメント文は「です/ます」調で統一**： `@brief`・`@details`・`@note`・`@warning` など、すべての記述文を日本語の丁寧体（です/ます）で記述します。
- **`@brief` は1文で簡潔に**： 何をするクラス/関数かを1行で表現します（例： `〜します。` `〜です。`）。
- **`@details` で補足**： ファイル・クラス・複雑な関数では `@details` でアルゴリズムや使用上の注意を記述します。
- **パラメータは全て記述**： `@param` はすべての引数に記述します。方向指定子（`[in]`・`[out]`・`[in,out]`）は使用しません。
- **例外は明示**： `@throws` で例外の型と条件を必ず記述します。
- **`void` 戻り値は省略**： 戻り値なしの関数は `@return` 不要です。
- **`@author`・`@date` は記述しない**： バージョン管理は Git で行うため不要です。

## ドキュメント記述の優先順位

1. **必須**： クラス・構造体・`public` / `protected` / `private` のすべてのメンバ
2. **任意**： 自明な `private` メンバ（単純な値の getter/setter など、名前から動作が完全に明らかなもの）

> **自明の判断基準**： メソッド名と型だけを見て、動作・副作用・例外の有無がすべて明確に推測できる場合のみ省略可とします。
> 例： `int get_id() const`（省略可）、`void set_name(const std::string& name)`（省略可）

## ヘッダファイルと実装ファイルの記述方針

ヘッダファイル（`.hpp`）は API 仕様書として機能するため完全な記述が必須ですが、
実装ファイル（`.cpp`）は補足的な位置づけであるため簡易的な記述にとどめます。

| ファイル | ファイルコメント | メンバの記述 |
|---------|---------------|--------------|
| `.hpp`（ヘッダ） | **必須**（完全形式） | **必須**（完全なドキュメンテーションコメント） |
| `.cpp`（実装） | **必須**（完全形式） | **必須**（1行なら `///`、複数行なら `/** @brief */` 形式。詳細タグは省略） |

`.cpp` での記述例：

```cpp
/**
 * @file UserService.cpp
 * @brief UserService の実装ファイルです。
 * @details ビジネスロジック層の実装を提供します。
 */

/// 指定した ID のユーザーを取得します。
User UserService::get_user_by_id(int id) const {
    // ...
}

/**
 * @brief コンストラクタです。
 * @details repository_ を初期化し、依存オブジェクトの所有権を移譲します。
 */
UserService::UserService(std::shared_ptr<IUserRepository> repository)
    : repository_(std::move(repository)) {}
```

`.cpp` での `@param`・`@return`・`@throws` などの詳細タグは `.hpp` に集約するため省略します。

## 参考

- [Doxygen ドキュメント](https://www.doxygen.nl/manual/index.html)
- [Doxygen コマンド一覧](https://www.doxygen.nl/manual/commands.html)
