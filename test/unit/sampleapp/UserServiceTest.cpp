/**
 * @file UserServiceTest.cpp
 * @brief sampleapp::UserService のユニットテストです。
 */
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "mock/MockUserRepository.hpp"
#include "sampleapp/User.hpp"
#include "sampleapp/UserService.hpp"

using namespace sampleapp;
using namespace sampleapp::mock;
using ::testing::Return;
using ::testing::Truly;

namespace sampleapp::test {
// 無名（匿名）namespace を使用して、以下のテストケースがこのソースファイル内だけで有効であることを示す。
// C++における「内部リンケージ」として機能し、他の翻訳単位との名前衝突を防止する。
namespace {

/**
 * @brief register_user() が IUserRepository::insert_user を正しく呼び出すことを確認します。
 *
 * @details
 * - テスト対象関数: UserService::register_user
 * - テスト目的: ユーザー名からユーザー構造体を生成し、リポジトリに渡す処理を確認する
 * - 入力: 名前 "Alice"
 * - 期待結果: name="Alice", email="Alice@example.com" を持つ User が insert_user() に渡されること
 * - 検証方法:
 *   1. モックリポジトリを生成し UserService に注入
 *   2. insert_user() の呼び出しを EXPECT_CALL で監視
 *   3. 名前とメールが一致することを Truly() により検証
 */
TEST(UserServiceTest, RegisterUserDelegatesToRepository) {
    // モックリポジトリを生成し、UserService に依存性注入（DI）
    // ※ std::make_shared で生成し、UserService に shared_ptr で渡します。
    auto mockRepo = std::make_shared<MockUserRepository>();
    UserService service(mockRepo);

    // insert_user が正しく呼び出されるかを EXPECT_CALL で定義します。
    // - 引数の検証には GoogleMock の Truly() を使い、User の name/email を確認
    // - この呼び出しが1回だけ行われることを Times(1) で指定しています。
    EXPECT_CALL(*mockRepo, insert_user(Truly([](const User& actual) {
        return actual.name == "Alice" && actual.email == "Alice@example.com";
    }))).Times(1);

    // テスト対象の関数を呼び出します。
    // - ここで mockRepo->insert_user(...) が内部的に呼ばれることになります。
    service.register_user("Alice");
}

/**
 * @brief get_user_by_id() が IUserRepository::find_user_by_id を呼び出し、正しいユーザー情報を返すことを確認します。
 *
 * @details
 * - テスト対象関数: UserService::get_user_by_id
 * - テスト目的: モックが返すユーザーを get_user_by_id() がそのまま返すかを確認
 * - 入力: ユーザーID = 42
 * - 期待結果: ID=42, name="Bob", email="bob@example.com" のユーザーが返されること
 * - 検証方法:
 *   1. モックが find_user_by_id(42) に対し User を返すよう設定
 *   2. get_user_by_id(42) を呼び出し、戻り値が一致するか ASSERT/EXPECT で確認
 */
TEST(UserServiceTest, FindUserReturnsExpectedUser) {
    // モックリポジトリを生成し、UserService に依存性注入
    auto mockRepo = std::make_shared<MockUserRepository>();
    UserService service(mockRepo);

    // 期待されるユーザーオブジェクトを定義（テストの正解データ）
    User expected{42, "Bob", "bob@example.com"};

    // find_user_by_id(42) が呼び出されたときに expected を返すよう設定します。
    // - WillOnce(Return(...)) により、モック呼び出し時の戻り値を定義できます。
    EXPECT_CALL(*mockRepo, find_user_by_id(42)).WillOnce(Return(expected));

    // テスト対象関数の呼び出しと、戻り値の検証を行います。
    // - std::optional の中身があるかを ASSERT_TRUE で確認し
    // - 中身の値を EXPECT_EQ で expected と比較します。
    auto result = service.get_user_by_id(42);

    ASSERT_TRUE(result.has_value());
    EXPECT_EQ(result.value(), expected);  // operator== が必要（User.hppに定義済）
}

}  // namespace
}  // namespace sampleapp::test
