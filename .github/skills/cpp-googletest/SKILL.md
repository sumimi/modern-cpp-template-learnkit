---
name: cpp-googletest
description: "Google Test / Google Mock を使ったユニットテストのベストプラクティス。TEST/TEST_F/TEST_P の使い分け、モッククラスの作成、EXPECT/ASSERT アサーション、テスト設計について実装・確認するときに使用する。"
argument-hint: "[テスト対象クラス名またはテスト種別（例: UserService / パラメータ化テスト / モック）]"
---

# Google Test / Mock ベストプラクティス

このプロジェクトでは **Google Test（gtest）** と **Google Mock（gmock）** を使って
ユニットテストを記述します。テストは `test/unit/<module>/` 以下に配置します。

## テストの実行

```bash
cmake --build build --target run_tests   # 全テストを実行
cmake --build build --target test_report # 結果を HTML に変換
```

## テストファイルの構成

```
test/unit/<module>/FooTest.cpp
```

- ファイル名は `<ClassName>Test.cpp`（PascalCase + `Test` サフィックス）
- クラス対応： `UserService` → `UserServiceTest.cpp`

## 基本テスト構造（Arrange-Act-Assert パターン）

テストは必ず **Arrange（準備）→ Act（実行）→ Assert（検証）** の順で記述します。

```cpp
#include <gtest/gtest.h>
#include "sampleapp/UserService.hpp"

TEST(UserServiceTest, GetUserByIdReturnsCorrectUser) {
    // Arrange（準備）
    UserService service;
    const int userId = 42;

    // Act（実行）
    auto user = service.getUserById(userId);

    // Assert（検証）
    EXPECT_EQ(user.id, userId);
    EXPECT_FALSE(user.name.empty());
}
```

## TEST vs TEST_F vs TEST_P の使い分け

| マクロ | 用途 |
|--------|------|
| `TEST(Suite, Name)` | 状態を共有しない単純なテスト |
| `TEST_F(Fixture, Name)` | `SetUp/TearDown` で共通の前後処理が必要なテスト |
| `TEST_P(Fixture, Name)` | パラメータ化テスト（複数の入力パターンを検証） |

### TEST_F（フィクスチャ）の例

```cpp
class UserServiceTest : public ::testing::Test {
protected:
    void SetUp() override {
        // 各テスト前に実行（共通の初期化）
        repository_ = std::make_shared<UserRepository>();
        service_ = std::make_unique<UserService>(repository_);
    }

    void TearDown() override {
        // 各テスト後に実行（クリーンアップ）
    }

    std::shared_ptr<UserRepository> repository_;
    std::unique_ptr<UserService> service_;
};

TEST_F(UserServiceTest, AddUserIncreasesCount) {
    // Arrange
    const auto initialCount = service_->getUserCount();

    // Act
    service_->addUser({"Alice"});

    // Assert
    EXPECT_EQ(service_->getUserCount(), initialCount + 1);
}
```

### TEST_P（パラメータ化テスト）の例

```cpp
class UserValidationTest : public ::testing::TestWithParam<std::string> {};

TEST_P(UserValidationTest, InvalidNamesAreRejected) {
    const auto& invalidName = GetParam();
    EXPECT_FALSE(UserValidator::isValidName(invalidName));
}

INSTANTIATE_TEST_SUITE_P(
    InvalidNames,
    UserValidationTest,
    ::testing::Values("", "  ", "a", std::string(256, 'x'))
);
```

## Google Mock によるモック

依存性はインターフェース経由で注入し、テスト時にモックに差し替えます。

### インターフェース定義（`include/sampleapp/IUserRepository.hpp`）

```cpp
class IUserRepository {
public:
    virtual ~IUserRepository() = default;
    virtual User findById(int id) const = 0;
    virtual void save(const User& user) = 0;
};
```

### モッククラス定義（`test/unit/sampleapp/mock/MockUserRepository.hpp`）

```cpp
#include <gmock/gmock.h>
#include "sampleapp/IUserRepository.hpp"

class MockUserRepository : public IUserRepository {
public:
    MOCK_METHOD(User, findById, (int id), (const, override));
    MOCK_METHOD(void, save, (const User& user), (override));
};
```

### モックを使ったテスト

```cpp
#include "mock/MockUserRepository.hpp"

TEST(UserServiceTest, FindUserCallsRepository) {
    // Arrange
    auto mockRepo = std::make_shared<MockUserRepository>();
    UserService service(mockRepo);

    User expectedUser{42, "Alice"};
    EXPECT_CALL(*mockRepo, findById(42))
        .Times(1)
        .WillOnce(::testing::Return(expectedUser));

    // Act
    auto user = service.getUserById(42);

    // Assert
    EXPECT_EQ(user.name, "Alice");
}
```

### `ON_CALL` と `EXPECT_CALL` の使い分け

| マクロ | 用途 |
|--------|------|
| `EXPECT_CALL` | **呼び出しを期待する**。テスト終了時に指定回数呼ばれたか検証する |
| `ON_CALL` | **デフォルト動作の設定のみ**。呼び出し回数は問わない |

```cpp
// EXPECT_CALL: 必ず1回呼ばれることを検証しつつ戻り値を設定する
EXPECT_CALL(*mockRepo, findById(42))
    .Times(1)
    .WillOnce(::testing::Return(expectedUser));

// 複数回呼ばれる場合は WillRepeatedly で毎回同じ戻り値を返す
EXPECT_CALL(*mockRepo, findById(::testing::_))
    .WillRepeatedly(::testing::Return(defaultUser));

// ON_CALL: 呼び出し回数を問わずデフォルト動作だけ設定する
// （SetUp での共通設定など、呼び出し回数を検証しない場合に使う）
// ::testing::_ はワイルドカードで、任意の引数値にマッチする
ON_CALL(*mockRepo, findById(::testing::_))
    .WillByDefault(::testing::Return(defaultUser));
```

### 呼び出し順序の検証（`InSequence`）

複数のモックメソッドが特定の順序で呼ばれることを強制する。

```cpp
TEST(OrderTest, OperationsAreCalledInOrder) {
    auto mockRepo = std::make_shared<MockUserRepository>();
    ::testing::InSequence seq;

    EXPECT_CALL(*mockRepo, findById(1)).Times(1);
    EXPECT_CALL(*mockRepo, save(::testing::_)).Times(1);

    // findById → save の順で呼ばれることを強制する
    UserService service(mockRepo);
    service.updateUser(1, newData);
}
```

## アサーションの使い方

| マクロ | 用途 | 特徴 |
|--------|------|------|
| `EXPECT_EQ(a, b)` | 等値確認 | 失敗しても継続 |
| `EXPECT_NE(a, b)` | 非等値確認 | 失敗しても継続 |
| `EXPECT_TRUE(cond)` | 真確認 | 失敗しても継続 |
| `EXPECT_FALSE(cond)` | 偽確認 | 失敗しても継続 |
| `EXPECT_THROW(expr, type)` | 例外送出確認 | 失敗しても継続 |
| `EXPECT_NO_THROW(expr)` | 例外なし確認 | 失敗しても継続 |
| `ASSERT_EQ(a, b)` | 等値確認 | 失敗したら即停止 |
| `ASSERT_NE(a, b)` | 非等値確認 | 失敗したら即停止 |
| `FAIL()` | 無条件失敗 | 到達してはいけないコードパスの明示 |

`ASSERT_*` は以降の処理がポインタ参照など「失敗したら続けられない」場合に使い、
通常は `EXPECT_*` を使って失敗を複数まとめて確認する。

`FAIL()` は `switch` の `default` ブランチや「このパスには来ないはず」という箇所に使う。
`<< "メッセージ"` で失敗理由を付与できる。

```cpp
// switch の default で想定外の値を検知する
switch (state) {
    case State::Active:   /* ... */ break;
    case State::Inactive: /* ... */ break;
    default:
        FAIL() << "想定外の State 値: " << static_cast<int>(state);
}

// 例外が送出されないはずの処理で想定外のエラーを検知する
try {
    service.process();
} catch (const std::exception& e) {
    FAIL() << "例外が発生してはいけない: " << e.what();
}
```

## マッチャーを使ったアサーション（`EXPECT_THAT`）

`EXPECT_THAT(value, matcher)` は `EXPECT_EQ` より表現力が高く、コレクション・文字列・複合条件の検証に適している。

| マッチャー | 用途 |
|-----------|------|
| `Eq(val)` | 等値確認 |
| `Gt(val)` / `Lt(val)` | 大小比較 |
| `HasSubstr(str)` | 部分文字列を含む |
| `StartsWith(str)` | 前方一致 |
| `Contains(val)` | コレクションに要素が含まれる |
| `ElementsAre(...)` | コレクションの全要素が順序どおり一致 |
| `SizeIs(n)` | コレクションのサイズ |
| `IsEmpty()` | 空チェック |
| `Not(matcher)` | 否定 |
| `AllOf(m1, m2)` | 複数条件の AND |
| `AnyOf(m1, m2)` | 複数条件の OR |

```cpp
using ::testing::ElementsAre;
using ::testing::HasSubstr;
using ::testing::AllOf;
using ::testing::Gt;
using ::testing::Lt;

TEST(UserServiceTest, GetAllUsersReturnsExpectedList) {
    auto users = service.getAllUsers();
    EXPECT_THAT(users, ElementsAre(User{1, "Alice"}, User{2, "Bob"}));
}

TEST(UserServiceTest, ErrorMessageContainsUserId) {
    auto msg = service.getErrorMessage(42);
    EXPECT_THAT(msg, HasSubstr("42"));
}

TEST(UserServiceTest, ScoreIsInValidRange) {
    auto score = service.calculateScore();
    EXPECT_THAT(score, AllOf(Gt(0), Lt(100)));
}
```

## `SCOPED_TRACE` による失敗箇所の特定

ループや複数の `EXPECT_*` が続く場合に `SCOPED_TRACE` を使うと、失敗時にトレースメッセージが出力され、どの反復・条件で失敗したかが特定しやすくなる。

```cpp
TEST(UserValidationTest, MultipleNamesAreValidated) {
    const std::vector<std::string> validNames = {"Alice", "Bob", "Charlie"};
    for (const auto& name : validNames) {
        SCOPED_TRACE("name = " + name);  // 失敗時にどの name で失敗したか出力される
        EXPECT_TRUE(UserValidator::isValidName(name));
    }
}
```

## テスト命名規則

```
<対象クラス>_<テスト対象メソッド>_<期待する振る舞い>
```

例：
- `GetUserById_ValidId_ReturnsUser`
- `Save_DuplicateUser_ThrowsException`
- `GetUserCount_EmptyRepository_ReturnsZero`

## テスト設計の原則

- **1テスト1振る舞い**： 1つのテストで1つの振る舞いのみ検証する
- **独立性**： テスト間で状態を共有しない
- **再現性**： 何度実行しても同じ結果になる
- **高速性**： 外部依存（DB・ネットワーク）はモックで代替する

## デステスト（Death Tests）

プロセス終了・`abort()` が発生することを検証する。`assert` や `std::terminate` の動作確認に使う。
Google Test の公式用語は **Death Tests**（デステスト）。

```cpp
TEST(UserServiceTest, NullRepositoryAborts) {
    EXPECT_DEATH(
        { UserService service(nullptr); service.getUser(1); },
        ".*"  // stderr に出力されるメッセージにマッチする正規表現
    );
}
```

> **注意**： デステストはサブプロセスを起動するため通常のテストより低速。プロセス終了が保証されている場合のみ使用する。

## カスタムマッチャー

標準マッチャーで表現できない複合条件は `MATCHER` / `MATCHER_P` マクロで定義する。

```cpp
// 引数なしカスタムマッチャー
MATCHER(IsValidUser, "is a valid user") {
    return arg.id > 0 && !arg.name.empty();
}

// 引数ありカスタムマッチャー
MATCHER_P(HasId, expected_id, "") {
    return arg.id == expected_id;
}

TEST(UserServiceTest, CreatedUserIsValid) {
    auto user = service.createUser("Alice");
    EXPECT_THAT(user, IsValidUser());
    EXPECT_THAT(user, HasId(1));
}
```

## 参考

- [GoogleTest ドキュメント](https://github.com/google/googletest)
- [GoogleTest Primer](https://google.github.io/googletest/primer.html)
- [gMock Cookbook](https://google.github.io/googletest/gmock_cook_book.html)
- [GoogleTest Advanced（Death Tests 含む）](https://google.github.io/googletest/advanced.html)
