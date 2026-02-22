/**
 * @file MockUserRepository.hpp
 * @brief IUserRepository インターフェースのモック実装です。
 *
 * @details
 * 本クラスは、ユーザー永続化処理のユニットテストを目的として、
 * sampleapp::IUserRepository インターフェースを GoogleMock により模擬します。
 * ユーザーサービス層（UserService）のテストにおいて、データベース依存を排除するために使用されます。
 */

#pragma once

#include <gmock/gmock.h>

#include "sampleapp/interfaces/IUserRepository.hpp"

namespace sampleapp::mock {

/**
 * @brief ユーザーリポジトリのモッククラスです。
 *
 * IUserRepository を継承し、GoogleMock によるモックメソッドを提供します。
 * 主に UserService の単体テストにおいて使用されます。
 */
class MockUserRepository : public IUserRepository {
   public:
    // MOCK_METHOD の構文：
    // MOCK_METHOD(戻り値の型, メソッド名, (引数の型), (オプション))
    // - override を付けることで、基底クラスの仮想関数をモックとして実装します。
    // - このマクロにより、呼び出し検証や戻り値の設定が可能になります。

    MOCK_METHOD(void, insert_user, (const User& user), (override));           ///< ユーザー登録メソッドのモック
    MOCK_METHOD(std::optional<User>, find_user_by_id, (int id), (override));  ///< ユーザー検索メソッドのモック
};

}  // namespace sampleapp::mock
