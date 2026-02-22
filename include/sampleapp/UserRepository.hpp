/**
 * @file UserRepository.hpp
 * @brief ユーザー情報の永続化処理を提供する具象リポジトリクラスのヘッダファイルです。
 *
 * このファイルでは、PostgreSQLを利用してユーザー情報の登録および検索を行う
 * UserRepository クラスの定義を提供します。
 */
#pragma once

#include <memory>
#include <optional>

#include "sampleapp/User.hpp"
#include "sampleapp/interfaces/IUserRepository.hpp"

namespace sampleapp {

/**
 * @brief PostgreSQLを使用してユーザー情報を管理する具象リポジトリクラスです。
 */
class UserRepository : public IUserRepository {
   public:
    /// デフォルトコンストラクタはデフォルトを使用します。
    UserRepository() = default;

    /// コピーコンストラクタは禁止します（接続リソースの重複利用を防止）
    UserRepository(const UserRepository&) = delete;

    /// コピー代入演算子は禁止します
    UserRepository& operator=(const UserRepository&) = delete;

    /// ムーブコンストラクタは禁止します（リポジトリの一貫性を保持）
    UserRepository(UserRepository&&) = delete;

    /// ムーブ代入演算子は禁止します
    UserRepository& operator=(UserRepository&&) = delete;

    /// デフォルトデストラクタ（共有ポインタによりリソースは自動管理）
    ~UserRepository() = default;

    /**
     * @brief ユーザーをデータベースに登録します。
     * @param user 登録するユーザー情報
     */
    void insert_user(const User& user) override;

    /**
     * @brief 指定されたIDに一致するユーザーを検索します。
     *
     * 該当ユーザーが存在しない場合は std::nullopt を返します。
     * @param id ユーザーID
     * @return 該当ユーザー（存在しない場合は std::nullopt）
     */
    std::optional<User> find_user_by_id(int id) override;
};

}  // namespace sampleapp
