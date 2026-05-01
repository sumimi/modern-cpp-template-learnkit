/**
 * @file ConanPackagesTest.cpp
 * @brief Conan で管理している外部パッケージの動作確認テストです。
 *
 * 各パッケージが正しくリンクされ、基本機能が動作することを検証します。
 * - spdlog      : ストリームへのログ出力
 * - cxxopts     : コマンドライン引数のパース
 * - nlohmann_json: JSON のパース・シリアライズ
 * - libsodium   : 初期化・乱数生成・ハッシュ計算
 * - libpqxx     : ヘッダリンク・文字列ビュー型の動作
 */

#include <gtest/gtest.h>

#include <algorithm>
#include <array>
#include <sstream>
#include <string>

// ============================================================================
// spdlog — 高速ロギングライブラリ
// ============================================================================
#include <spdlog/sinks/ostream_sink.h>
#include <spdlog/spdlog.h>

TEST(SpdlogTest, LogsToOstreamSink) {
    // Arrange
    std::ostringstream oss;
    auto sink = std::make_shared<spdlog::sinks::ostream_sink_st>(oss);
    auto logger = std::make_shared<spdlog::logger>("test_logger", sink);

    // Act
    logger->set_pattern("%v");
    logger->info("hello spdlog");
    logger->flush();

    // Assert
    EXPECT_EQ(oss.str(), "hello spdlog\n");
}

TEST(SpdlogTest, LogLevelFilteringWorks) {
    // Arrange
    std::ostringstream oss;
    auto sink = std::make_shared<spdlog::sinks::ostream_sink_st>(oss);
    auto logger = std::make_shared<spdlog::logger>("filter_logger", sink);
    logger->set_level(spdlog::level::warn);

    // Act: info は出力されない、warn は出力される
    logger->info("should be filtered");
    logger->warn("should appear");
    logger->flush();

    // Assert
    EXPECT_EQ(oss.str().find("should be filtered"), std::string::npos);
    EXPECT_NE(oss.str().find("should appear"), std::string::npos);
}

// ============================================================================
// cxxopts — コマンドライン引数パーサ（header-only）
// ============================================================================
#include <cxxopts/cxxopts.hpp>

TEST(CxxoptsTest, ParsesStringOption) {
    // Arrange
    cxxopts::Options opts("test_app");
    opts.add_options()("name", "Name", cxxopts::value<std::string>()->default_value("world"));
    const char* argv[] = {"test_app", "--name", "conan"};

    // Act
    const auto result = opts.parse(3, const_cast<char**>(argv));

    // Assert
    EXPECT_EQ(result["name"].as<std::string>(), "conan");
}

TEST(CxxoptsTest, DefaultValueUsedWhenOptionOmitted) {
    // Arrange
    cxxopts::Options opts("test_app");
    opts.add_options()("count", "Count", cxxopts::value<int>()->default_value("42"));
    const char* argv[] = {"test_app"};

    // Act
    const auto result = opts.parse(1, const_cast<char**>(argv));

    // Assert
    EXPECT_EQ(result["count"].as<int>(), 42);
}

// ============================================================================
// nlohmann_json — JSON パーサ・シリアライザ（header-only）
// ============================================================================
#include <nlohmann/json.hpp>

TEST(NlohmannJsonTest, ParsesJsonObject) {
    // Arrange
    const auto raw = R"({"name": "cpp", "version": 17})";

    // Act
    const auto j = nlohmann::json::parse(raw);

    // Assert
    EXPECT_EQ(j["name"].get<std::string>(), "cpp");
    EXPECT_EQ(j["version"].get<int>(), 17);
}

TEST(NlohmannJsonTest, SerializesJsonObject) {
    // Arrange
    nlohmann::json j;
    j["key"] = "value";
    j["flag"] = true;

    // Act
    const auto serialized = j.dump();

    // Assert
    EXPECT_NE(serialized.find("\"key\":\"value\""), std::string::npos);
    EXPECT_NE(serialized.find("\"flag\":true"), std::string::npos);
}

TEST(NlohmannJsonTest, ThrowsOnInvalidJson) {
    // Assert — parse が例外を投げることを確認（戻り値は例外により使われない）
    EXPECT_THROW(
        { [[maybe_unused]] const auto result = nlohmann::json::parse("{invalid json}"); }, nlohmann::json::parse_error);
}

// ============================================================================
// libsodium — 暗号化・署名・ハッシュライブラリ
// ============================================================================
#include <sodium.h>

TEST(LibsodiumTest, InitializeSucceeds) {
    // sodium_init() は、初回呼び出しで 0、初期化済みなら 1、失敗なら -1 を返す
    const auto result = sodium_init();
    EXPECT_NE(result, -1) << "sodium_init() の初期化に失敗しました";
}

TEST(LibsodiumTest, RandomBytesGeneratesNonZeroOutput) {
    // Arrange
    std::array<unsigned char, 32> buf{};
    ASSERT_NE(-1, sodium_init()) << "libsodium の初期化に失敗しました";

    // Act
    randombytes_buf(buf.data(), buf.size());

    // Assert: 32バイトがすべて 0 である確率は極めて低い
    const bool any_nonzero = std::any_of(buf.begin(), buf.end(), [](unsigned char b) { return b != 0; });
    EXPECT_TRUE(any_nonzero);
}

TEST(LibsodiumTest, Sha256HashIsConsistent) {
    // Arrange
    ASSERT_NE(-1, sodium_init()) << "libsodium の初期化に失敗しました";
    const std::string input = "hello libsodium";
    std::array<unsigned char, crypto_hash_sha256_BYTES> hash1{};
    std::array<unsigned char, crypto_hash_sha256_BYTES> hash2{};

    // Act: 同じ入力から同じハッシュが生成されることを確認
    crypto_hash_sha256(hash1.data(), reinterpret_cast<const unsigned char*>(input.data()), input.size());
    crypto_hash_sha256(hash2.data(), reinterpret_cast<const unsigned char*>(input.data()), input.size());

    // Assert
    EXPECT_EQ(hash1, hash2);
}

// ============================================================================
// libpqxx — PostgreSQL C++ クライアント（DB接続不要の基本型テスト）
//
// 注意: 実際の DB 接続テストは DB サーバが必要なため、
//       ここでは pqxx::zview 型のリンク確認のみ行います。
// ============================================================================
#include <pqxx/zview>

TEST(LibpqxxTest, ZViewLinksAndWorks) {
    // Arrange
    const pqxx::zview view{"hello pqxx"};

    // Act & Assert — DB 接続なしで利用できる文字列ビュー型の動作確認
    EXPECT_EQ(std::string_view{view}, "hello pqxx");
    EXPECT_EQ(view.size(), 10U);
}
