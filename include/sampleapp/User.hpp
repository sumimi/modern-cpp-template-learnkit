/**
 * @file User.hpp
 * @brief ユーザー情報を表現するエンティティ構造体の定義ファイルです。
 *
 * このファイルでは、ユーザーID・名前・メールアドレスなど、
 * 基本的なユーザー情報を保持する構造体と比較演算子を定義します。
 */
#pragma once

#include <string>

namespace sampleapp {

/**
 * @brief ユーザー情報を表現する構造体です。
 */
struct User {
    int id;             ///< ユーザーID
    std::string name;   ///< ユーザー名
    std::string email;  ///< メールアドレス
};

/**
 * @brief ユーザー情報の同値比較を行う演算子です。
 *
 * すべてのメンバ（ID、名前、メールアドレス）が一致するかを比較します。
 * @param lhs 左辺のユーザー情報
 * @param rhs 右辺のユーザー情報
 * @return すべての項目が一致すれば true、それ以外は false
 */
inline bool operator==(const User& lhs, const User& rhs) {
    return lhs.id == rhs.id && lhs.name == rhs.name && lhs.email == rhs.email;
}

}  // namespace sampleapp
