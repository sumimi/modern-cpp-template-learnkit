# Modern C++ Template LearnKit 利用ガイド

このドキュメントは、`modern-cpp-template-learnkit` テンプレートから新しい C++ プロジェクトを立ち上げる際の手順をまとめたものです。

## 📚 このガイドの使い方

### C++学習者の方

まず**セクション0（必要なツールのインストール）を必ず実施**してから、学習を始めます：

1. **セクション0を実施**：開発ツールとGoogleTestをインストール（初回のみ、必須）
2. **テンプレートを複製**：`cp -r modern-cpp-template-learnkit my-study`
3. **ビルド＆実行**：`cmake -S . -B build && cmake --build build && ./build/bin/main`
4. **学習開始**：README.md の「活用シナリオ」を参考に学習を進める

**セクション1～5は不要です**（プロジェクト名変更などは学習には必要ありません）。

### 実プロジェクトで利用する方

**セクション0～5を順に実施**し、プロジェクトをカスタマイズします：

1. セクション0：開発ツールのインストール
2. セクション1：テンプレートの複製とリネーム
3. セクション2：プロジェクト名の変更
4. セクション3：ドキュメント設定の更新
5. セクション4～5：その他のカスタマイズ

---

## 0. 前提条件：必要なツールとライブラリのインストール

このテンプレートを利用するには、以下のツールとライブラリが必要です。

**必須ツール：**
- GCC / Clang（C++17対応）
- CMake（3.15以上）
- GoogleTest & GoogleMock
- Doxygen
- lcov / genhtml

**任意ツール（機能を使う場合）：**
- xsltproc：テストレポートHTML化
- clang-tidy：静的解析
- valgrind：メモリリーク検出

**ライブラリ：**
- cxxopts（ヘッダオンリー、テンプレートに同梱済み）


> **🚀 急いでいる方へ：クイックスタート**
>
> 以下のコマンドで必要なツールを一括インストールできます：
> ```bash
> sudo dnf groupinstall "Development Tools" -y
> sudo dnf install cmake doxygen lcov -y
> ```
> 詳細は各セクションを参照してください。

---

### 0.0 環境要件

このテンプレートは **Rocky Linux 9.x** を前提として作成されています。

```bash
# OSバージョンの確認
cat /etc/rocky-release
# 例：Rocky Linux release 9.3 (Blue Onyx)
```

他のLinuxディストリビューション（Ubuntu、Debian、Fedoraなど）でも動作しますが、パッケージ名やインストールコマンドが異なる場合があります。

---

### 0.1 開発ツールのインストール

#### 基本開発ツール（Development Tools）のインストール

GCC、make、autoconf などの基本的な開発ツールをインストールします。

```bash
# Development Tools グループのインストール
sudo dnf groupinstall "Development Tools" -y

# 確認
gcc --version
make --version
```

#### CMake のインストール

CMake 3.15以上が必要です。Rocky Linux 9.x標準のCMakeで十分です。

```bash
# CMake のインストール
sudo dnf install cmake -y

# バージョン確認（3.20以上が推奨）
cmake --version
```

#### Doxygen のインストール

ドキュメント自動生成ツールです。

```bash
# Doxygen のインストール
sudo dnf install doxygen -y

# バージョン確認
doxygen --version
```

#### lcov / genhtml のインストール

コードカバレッジ測定ツールです。

```bash
# lcov のインストール（genhtmlも含まれる）
sudo dnf install lcov -y

# バージョン確認
lcov --version
```

#### xsltproc のインストール（任意）

テストレポートをHTMLに変換するツールです。

```bash
# xsltproc のインストール
sudo dnf install libxslt -y

# バージョン確認
xsltproc --version
```

#### clang-tidy のインストール（任意）

静的解析ツールです。clang-toolsパッケージに含まれています。

```bash
# clang-tidy のインストール
sudo dnf install clang-tools-extra -y

# バージョン確認
clang-tidy --version
```

#### valgrind のインストール（任意）

メモリリーク検出ツールです。

```bash
# valgrind のインストール
sudo dnf install valgrind -y

# バージョン確認
valgrind --version
```

#### インストール確認（まとめ）

すべてのツールが正しくインストールされたか確認します。

```bash
# 必須ツール
gcc --version
cmake --version
doxygen --version
lcov --version

# 任意ツール（インストールした場合）
xsltproc --version
clang-tidy --version
valgrind --version
```

#### 一括インストールコマンド（推奨）

上記のツールをまとめてインストールする場合は、以下のコマンドを実行してください。

```bash
# 必須ツールの一括インストール
sudo dnf groupinstall "Development Tools" -y
sudo dnf install cmake doxygen lcov -y

# 任意ツールも含めて全てインストールする場合
sudo dnf groupinstall "Development Tools" -y
sudo dnf install cmake doxygen lcov libxslt clang-tools-extra valgrind -y

# インストール確認
echo "=== 必須ツール ==="
gcc --version | head -1
cmake --version | head -1
doxygen --version | head -1
lcov --version | head -1
echo "=== 任意ツール ==="
xsltproc --version 2>&1 | head -1
clang-tidy --version 2>&1 | head -1
valgrind --version | head -1
```

---

### 0.2 必要な OSS ライブラリ

以下のライブラリは、ヘッダオンリーであり、ソースコードに同梱されています：

- [cxxopts](https://github.com/jarro2783/cxxopts)：コマンドラインオプション解析

---

### 0.3 GoogleTest のインストール（ローカルインストール）

本テンプレートは GoogleTest / GoogleMock を外部から取得せず、あらかじめローカルにインストールされたパッケージとして使用します。

#### 事前手順（初回のみ）

以下の手順で GoogleTest を `/opt/gtest/gtest-1.14` にインストールしてください：

```bash
# ソース取得とビルド
wget https://github.com/google/googletest/archive/refs/tags/v1.14.0.tar.gz
tar -xvzf v1.14.0.tar.gz
cd googletest-1.14.0
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gtest/gtest-1.14
make -j
sudo make install
```

#### クリーンアップ（任意）

インストール後、ダウンロードしたファイルを削除できます：

```bash
# インストールディレクトリから戻る
# cd googletest-1.14.0/build から戻る
cd ../..

# ダウンロードしたファイルとディレクトリを削除
rm -rf googletest-1.14.0 v1.14.0.tar.gz
```

#### 動作確認（任意）

```bash
ls /opt/gtest/gtest-1.14/include/gtest
ls /opt/gtest/gtest-1.14/lib*/libgtest*.a
```

#### 利用側のCMake設定（自動で反映）

本テンプレートでは `CMAKE_PREFIX_PATH` を自動的に参照し、`find_package(GTest REQUIRED)` によって GoogleTest を認識します。

必要に応じて手動指定も可能です：

```bash
export CMAKE_PREFIX_PATH=/opt/gtest/gtest-1.14
```

---

### 0.4 トラブルシューティング

#### CMakeが見つからない / バージョンが古い

```bash
# CMakeのバージョン確認
cmake --version

# Rocky Linux 9標準のCMakeは3.20以上なので十分です
# もし古い場合は、EPELリポジトリを有効化して最新版をインストール
sudo dnf install epel-release -y
sudo dnf update cmake -y
```

#### GoogleTestが見つからない

CMake実行時に `Could NOT find GTest` というエラーが出る場合：

```bash
# GoogleTestがインストールされているか確認
ls /opt/gtest/gtest-1.14/lib*/libgtest*.a

# 環境変数を設定
export CMAKE_PREFIX_PATH=/opt/gtest/gtest-1.14

# 再度CMakeを実行
cmake -S . -B build
```

#### コンパイルエラー（C++17非対応）

GCCのバージョンが古い可能性があります。

```bash
# GCCバージョン確認（7.0以上が必要）
gcc --version

# Rocky Linux 9のGCCは11.x以上なので問題ありません
# もし古い場合は、Development Toolsを再インストール
sudo dnf groupinstall "Development Tools" -y
```

#### lcovやvalgrindが見つからない

```bash
# パッケージが正しくインストールされているか確認
rpm -q lcov valgrind

# インストールされていない場合
sudo dnf install lcov valgrind -y
```

---

## 1. プロジェクトの複製とリネーム

```bash
# AwesomeTool という名前のプロジェクトを作成
cp -r modern-cpp-template-learnkit AwesomeTool
cd AwesomeTool
```

## 2. プロジェクト名の変更

### CMakeLists.txt（ルート）内の `project(...)` を修正：

**変更前：**
```
project(ModernCppProject VERSION 1.0.0 LANGUAGES CXX)
```
**変更後：**
```
project(AwesomeTool VERSION 1.0.0 LANGUAGES CXX)
```

## 3. ドキュメント構成の更新（Doxygen）

`Doxyfile` の以下を修正：
```
PROJECT_NAME           = "AwesomeTool"
PROJECT_BRIEF          = "次世代C++ツールのドキュメント"
```

## 4. Git 無視設定の確認

`.gitignore` に以下が含まれていることを確認：
```
/build/
/docs/
/coverage_report/
/Testing/
/logs/
*.info
*.log
```

## 5. 不要ファイルの削除（任意）

- テンプレート固有のファイル（例: `/src/sampleapp` 等）を削除または置き換え


## 🔧 カスタムビルドターゲット一覧

| ターゲット              | 説明                                  |
| ------------------------| ------------------------------------- |
| `run_tests`             | CTest によるユニットテスト実行        |
| `test_report`           | GTest XML を HTML に変換              |
| `coverage`              | カバレッジ測定と HTML レポート生成      |
| `doc`                   | Doxygen ドキュメント生成              |
| `clang_tidy`            | 静的解析レポート出力（clang-tidy）    |
| `valgrind`              | メモリリーク検出                      |
| `clean_all`             | すべての成果物削除（build, docs/html等）|

---

## ✅ 初期セットアップコマンド

```bash
# ビルド環境の構築
cmake -S . -B build

# ビルド実行
cmake --build build

# テスト実行
cmake --build build --target run_tests
```

### 🎯 動作確認

ビルドが成功したら、サンプルアプリケーションを実行して確認します：

```bash
# サンプルアプリケーションの実行
./build/bin/main

# 以下のような出力が表示されれば成功です：
# Application started.
# Fetched user: Alice (alice@example.com)
# Application finished.
```

### 🛠️ その他のビルドターゲット

必要に応じて以下のターゲットも利用できます：

```bash
# 静的解析
cmake --build build --target clang_tidy

# ドキュメント生成
cmake --build build --target doc

# メモリリーク検出
cmake --build build --target valgrind

# テストレポートHTML化
cmake --build build --target test_report
```

#### カバレッジ測定（要：事前設定）

カバレッジ測定を行う場合は、**CMake構成時に専用オプションが必要**です：

```bash
# 1. ビルド成果物をクリーンアップ
cmake --build build --target clean_all

# 2. カバレッジ有効でCMake構成
cmake -DENABLE_COVERAGE=ON -S . -B build

# 3. ビルド＆テスト実行
cmake --build build
cmake --build build --target run_tests

# 4. カバレッジレポート生成
cmake --build build --target coverage

# 5. レポート確認
# build/coverage_report/index.html をブラウザで開く
```

> **💡 ヒント**: カバレッジ測定の詳細な使い方は、README.md の「📈 カバレッジ測定の手順」を参照してください。

---

## 🎓 次のステップ

環境構築が完了したら、README.md の「🎯 活用シナリオ」を参考に、学習を進めてください！

---
