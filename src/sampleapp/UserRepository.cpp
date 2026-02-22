/**
 * @file UserRepository.cpp
 * @brief UserRepository クラスの実装ファイルです。
 *
 * この実装には、実際のデータベース接続やクエリ処理は含まれていません。
 * 代わりに、ユーザーの登録と検索の動作を模擬するためのダミー実装が提供されています。
 */
#include "sampleapp/UserRepository.hpp"

#include <iostream>

namespace sampleapp {

/**
 * @copydoc UserRepository::insert_user
 */
void UserRepository::insert_user(const User& user) {
    std::cout << "Inserting user: " << user.name << " (" << user.email << ")" << std::endl;
}

/**
 * @copydoc UserRepository::find_user_by_id
 */
std::optional<User> UserRepository::find_user_by_id(int id) {
    std::cout << "Finding user by ID: " << id << std::endl;

    // ダミーデータを返す
    if (id == 1) {
        return User{1, "Shiver", "shiver@example.com"};
    } else {
        return std::nullopt;  // ユーザーが見つからない場合は nullopt を返す
    }
}

}  // namespace sampleapp
