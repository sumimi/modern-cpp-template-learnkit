/**
 * @file UserService.cpp
 * @brief UserService クラスの実装ファイルです。
 *
 * このファイルでは、ユーザー登録および検索処理を提供するサービスクラス UserService の
 * 各メソッドの定義を行います。
 */
#include "sampleapp/UserService.hpp"

namespace sampleapp {

/**
 * @copydoc UserService::UserService
 */
UserService::UserService(std::shared_ptr<IUserRepository> repo) : repository_(std::move(repo)) {
}

/**
 * @copydoc UserService::register_user
 */
void UserService::register_user(const std::string& name) {
    User user{/* id */ 0, name, name + "@example.com"};
    repository_->insert_user(user);
}

/**
 * @copydoc UserService::get_user_by_id
 */
std::optional<User> UserService::get_user_by_id(int id) {
    return repository_->find_user_by_id(id);
}

}  // namespace sampleapp
