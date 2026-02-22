/**
 * @file AppController.hpp
 * @brief アプリケーション全体の制御を担うコントローラクラスの定義ファイルです。
 *
 * このファイルでは、データベース接続とユーザーサービスを連携し、
 * アプリケーションの起動と制御を統括する AppController クラスを定義します。
 */
#pragma once

#include "sampleapp/UserService.hpp"

namespace sampleapp {

/**
 * @brief アプリケーションの実行制御を行うクラスです。
 */
class AppController {
   public:
    /**
     * @brief AppController を初期化します。
     * @param user_service ユーザーサービスへの参照
     */
    AppController(UserService& user_service);

    /// デフォルトコンストラクタは禁止します（依存関係の注入が必須）
    AppController() = delete;

    /// コピーコンストラクタは禁止します（参照メンバのコピーは意味を持たないため）
    AppController(const AppController&) = delete;

    /// コピー代入演算子は禁止します
    AppController& operator=(const AppController&) = delete;

    /// ムーブコンストラクタは禁止します（参照の移動は意図しない副作用を招くため）
    AppController(AppController&&) = delete;

    /// ムーブ代入演算子は禁止します
    AppController& operator=(AppController&&) = delete;

    /// デフォルトデストラクタ（非所有の参照メンバのみを保持するため明示）
    ~AppController() = default;

    /**
     * @brief アプリケーションの処理を開始します。
     */
    void run();

   private:
    UserService& user_service_;  ///< ユーザーサービスへの参照
};

}  // namespace sampleapp
