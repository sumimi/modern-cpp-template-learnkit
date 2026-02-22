/**
 * @file UserService.hpp
 * @brief ユーザー登録・検索処理を提供するサービスクラスのヘッダファイルです。
 *
 * このファイルでは、ユーザー登録や検索などアプリケーションロジックを扱う
 * UserService クラスのインターフェースを定義します。
 */
#pragma once

#include <memory>
#include <optional>
#include <string>

#include "sampleapp/User.hpp"
#include "sampleapp/interfaces/IUserRepository.hpp"

namespace sampleapp {

/**
 * @brief ユーザー関連のビジネスロジックを提供するサービスクラスです。
 */
class UserService {
   public:
    /**
     * @brief サービスを初期化します。
     * @param repository ユーザーリポジトリの共有インスタンス
     */
    explicit UserService(std::shared_ptr<IUserRepository> repository);

    /// デフォルトコンストラクタは禁止します（依存性の注入が必須なため）
    UserService() = delete;

    /// コピーコンストラクタは禁止します（サービスの意図しない複製を防止）
    UserService(const UserService&) = delete;

    /// コピー代入演算子は禁止します
    UserService& operator=(const UserService&) = delete;

    /// ムーブコンストラクタは禁止します（サービスの移動による副作用を防止）
    UserService(UserService&&) = delete;

    /// ムーブ代入演算子は禁止します
    UserService& operator=(UserService&&) = delete;

    /// デフォルトデストラクタ（リソースはshared_ptrにより自動管理）
    ~UserService() = default;

    /**
     * @brief 指定された名前でユーザーを新規登録します。
     * @param name ユーザー名
     */
    void register_user(const std::string& name);

    /**
     * @brief 指定されたIDのユーザー情報を取得します。
     *
     * 該当ユーザーが存在しない場合は std::nullopt を返します。
     * @param id ユーザーID
     * @return 該当ユーザー（存在しない場合は std::nullopt）
     */
    std::optional<User> get_user_by_id(int id);

   private:
    std::shared_ptr<IUserRepository> repository_;  ///< ユーザー情報にアクセスするリポジトリ
};

}  // namespace sampleapp
