/**
 * @file IUserRepository.hpp
 * @brief ユーザーリポジトリのインターフェースを定義するヘッダファイルです。
 *
 * このファイルでは、ユーザーエンティティの永続化・検索に関する抽象インターフェースを提供し、
 * データアクセス層とサービス層の依存を分離します。
 */
#pragma once

#include <optional>

#include "sampleapp/User.hpp"

namespace sampleapp {

/**
 * @interface IUserRepository
 * @brief ユーザー情報に対するデータ操作を抽象化するインターフェースです。
 */
class IUserRepository {
   public:
    /**
     * @brief 仮想デストラクタです。
     * @details 派生クラスでのリソース解放を行うため、仮想デストラクタとしています。
     */
    virtual ~IUserRepository() = default;

    /**
     * @brief ユーザーを登録します。
     * @param user 登録するユーザー情報
     */
    virtual void insert_user(const User& user) = 0;

    /**
     * @brief 指定されたIDに一致するユーザーを検索します。
     *
     * 該当ユーザーが存在しない場合は std::nullopt を返します。
     * @param id ユーザーID
     * @return 該当ユーザー（存在しない場合は std::nullopt）
     */
    virtual std::optional<User> find_user_by_id(int id) = 0;
};

}  // namespace sampleapp
