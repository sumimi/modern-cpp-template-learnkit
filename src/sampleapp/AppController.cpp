/**
 * @file AppController.cpp
 * @brief AppController クラスの実装ファイルです。
 *
 * このファイルでは、アプリケーション全体の制御を行う AppController クラスの
 * メンバ関数の定義を行います。
 */
#include "sampleapp/AppController.hpp"

#include <iostream>

namespace sampleapp {

/**
 * @copydoc AppController::AppController
 */
AppController::AppController(UserService& user_service) : user_service_(user_service) {
}

/**
 * @copydoc AppController::run
 */
void AppController::run() {
    try {
        // ユーザー登録
        user_service_.register_user("Shiver");

        // ユーザー検索
        auto user = user_service_.get_user_by_id(1);

    } catch (...) {
        std::cerr << "An error occurred during application execution." << std::endl;
        throw;
    }
}

}  // namespace sampleapp
