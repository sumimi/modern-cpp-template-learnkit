/**
 * @file main.cpp
 * @brief Modern C++ サンプルアプリケーションのエントリーポイントです。
 *
 * このファイルでは、以下の機能を順に初期化してアプリケーションを起動します：
 * - コマンドライン引数の解析（cxxoptsを使用します）
 * - ドメインロジックのサービスおよびコントローラの構築・実行
 */

#include <iostream>

#include "cxxopts/cxxopts.hpp"
#include "sampleapp/AppController.hpp"
#include "sampleapp/UserRepository.hpp"
#include "sampleapp/UserService.hpp"

/**
 * @brief アプリケーションのエントリーポイント関数です。
 *
 * - 引数解析により `--name` オプションを受け取り、myapp であることを検証します。
 * - AppController を通じてアプリケーション本体を起動します。
 *
 * @param argc 引数の数
 * @param argv 引数配列
 * @return int 成功時はEXIT_SUCCESS、失敗時はEXIT_FAILUREを返します。
 */
int main(int argc, char* argv[]) {
    std::cout << "Starting Modern C++ Sample Application..." << std::endl;
    try {
        // コマンドライン引数の解析
        // cxxoptsを利用したサンプル実装です。
        cxxopts::Options options("ModernCppApp", "Sample app with DI");
        options.add_options()("name", "Application name (must be 'myapp')",
                              cxxopts::value<std::string>()->default_value("myapp"))("help", "Print usage");

        auto result = options.parse(argc, argv);

        if (result.count("help")) {
            std::cout << options.help() << std::endl;
            return 0;
        }

        // ロガー識別子として使うアプリ名を取得します。
        const std::string app_name = result["name"].as<std::string>();

        // 許可されるのは myapp のみです。
        if (app_name != "myapp") {
            std::cerr << "Error: Invalid application name '" << app_name << "'. Expected 'myapp'." << std::endl;
            return EXIT_FAILURE;
        }

        // リポジトリ & サービス（接続はAppController経由でセットアップされる）を生成します。
        auto repo = std::make_shared<sampleapp::UserRepository>();
        sampleapp::UserService user_service(repo);

        // コントローラを実行し、ドメインロジックを起動します。
        sampleapp::AppController controller(user_service);
        controller.run();

    } catch (const std::exception& e) {
        // 想定外のエラーが発生した場合はログ出力して終了します。
        std::cerr << "An unexpected error occurred: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    std::cout << "Application finished successfully." << std::endl;

    return EXIT_SUCCESS;
}
