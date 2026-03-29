# Conan 2.x パッケージ管理 セットアップガイド

## 概要

本プロジェクトでは **Conan 2.x** を使用して C++ の外部ライブラリを管理します。  
取得したパッケージは **`vendor/`** ディレクトリに展開し、git で管理（vendor 化）します。

これにより、**初回セットアップ後は Conan なしでビルド**できる自己完結型の環境を実現します。

---

## 管理パッケージ一覧

| パッケージ | バージョン | 用途 |
|-----------|-----------|------|
| `spdlog` | 1.12.0 | 高速ロギングライブラリ |
| `libpqxx` | 7.7.5 | PostgreSQL C++ クライアント |
| `cxxopts` | 3.1.1 | コマンドライン引数パーサ（header-only） |
| `nlohmann_json` | 3.11.3 | JSON パーサ・シリアライザ（header-only） |
| `libsodium` | 1.0.20 | 暗号化・署名・ハッシュライブラリ |

---

## 前提条件

| ツール | バージョン | 確認コマンド |
|--------|-----------|-------------|
| Python | 3.9 以上 | `python3 --version` |
| pip | 21 以上 | `pip3 --version` |
| GCC | 11 以上 | `gcc --version` |
| インターネット接続 | — | 初回セットアップ時のみ必要 |

---

## 初回セットアップ手順

> **注意:** このセットアップは「パッケージを追加・更新するとき」のみ実行します。  
> 通常の開発者は「[通常のビルド手順](#通常のビルド手順)」のみを使用します。

### 1. セットアップスクリプトを実行する

```bash
bash tools/conan_setup.sh
```

スクリプトが以下を自動実行します：

1. `requirements.txt` の内容で Conan をインストール（`conan==2.7.1` で固定）
2. Conan ビルドプロファイル（`profiles/linux-rhel9`）を適用
3. `conan install` でパッケージを取得・ビルド
4. `vendor/full_deploy/` への full_deploy（パッケージファイルの展開）

### 2. vendor/ を git にコミットする

```bash
git add vendor/
git commit -m "build: :package: Conan vendor パッケージを追加"
```

> `vendor/full_deploy/` にパッケージのヘッダ・ライブラリが含まれます。  
> これを git で管理することで、以降は **Conan 不要でビルド**できます。

> **⚠️ 再実行時の注意（べき等性について）**  
> `bash tools/conan_setup.sh` は何度実行しても安全ですが、`vendor/` の内容は毎回**上書き**されます。  
> パッケージのバージョンや設定を変えていなくても、タイムスタンプなどのメタデータ変化により  
> `git status` で `vendor/` が `dirty`（変更あり）になることがあります。  
> 意図しない差分が出た場合は以下で元に戻してください：
> ```bash
> git restore vendor/
> ```

---

## 通常のビルド手順

`vendor/` がコミット済みの場合、Conan は不要です。

```bash
# 初期構成（toolchain ファイルで Conan パッケージを有効化）
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=vendor/conan_toolchain.cmake

# ビルド
cmake --build build

# テスト実行
cmake --build build --target run_tests
```

---

## ディレクトリ構造

```
project_root/
├── conanfile.txt             # パッケージ依存定義（git 管理）
├── requirements.txt          # Conan バージョン固定（git 管理）
├── profiles/
│   └── linux-rhel9           # Conan ビルドプロファイル（git 管理）
├── vendor/
│   ├── .gitkeep              # git 管理のためのプレースホルダ
│   ├── conan_toolchain.cmake # Conan 生成ツールチェーン（参照用）
│   └── full_deploy/
│       └── host/
│           ├── spdlog/1.12.0/      # headers + libs
│           ├── libpqxx/7.7.5/      # headers + libs
│           ├── cxxopts/3.1.1/      # headers (header-only)
│           ├── nlohmann_json/3.11.3/ # headers (header-only)
│           └── libsodium/1.0.20/   # headers + libs
└── tools/
    └── conan_setup.sh        # 初回セットアップスクリプト
```

### vendor/ の CMake 統合の仕組み

`CMakeLists.txt` は以下のロジックで vendor パッケージを自動検出します：

```cmake
# vendor/full_deploy/host/<pkg>/<version>/ を CMAKE_PREFIX_PATH に追加
file(GLOB CONAN_VENDOR_DIRS "${CMAKE_SOURCE_DIR}/vendor/full_deploy/host/*/*")
list(PREPEND CMAKE_PREFIX_PATH ${CONAN_VENDOR_DIRS})

# cmake/ 配下のカスタム Find モジュールを有効化（cmake/FindSodium.cmake 等）
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
```

`spdlog`・`cxxopts`・`nlohmann_json`・`libpqxx` は自身の cmake config ファイルを同桁するため  
`find_package` で直接解決されます。  
`libsodium` は cmake config を同桁しないため、`cmake/FindSodium.cmake` カスタムファインダー経由で解決します。

---

## バイナリへの同桁について

`[options]` で `shared=False`（スタティックリンク）を指定しているため、  
各ライブラリのコードは実行ファイルに直接組み込まれます。

| パッケージ | タイプ | バイナリへの同桁 |
|---------|------|----------------|
| `spdlog` | コンパイル済みライブラリ | `.a` がリンク時に埋め込まれる |
| `cxxopts` | header-only | ビルド時にコンパイルされ埋め込まれる |
| `nlohmann_json` | header-only | ビルド時にコンパイルされ埋め込まれる |
| `libsodium` | コンパイル済みライブラリ | `.a` がリンク時に埋め込まれる |
| `libpqxx` | コンパイル済みライブラリ | `.a` がリンク時に埋め込まれる |

> **注意: libpqxx の libpq 依存について**  
> `libpqxx` は内部で PostgreSQL の C クライアントライブラリ（`libpq`）を利用します。  
> Conan の `--build=missing` で `libpq` をソースからビルドするか、  
> システムの `libpq` (例: `dnf install libpq-devel`) が必要になる場合があります。

---

## 動作確認テスト

各パッケージが正しくリンクされていることを確認するスモークテストが  
`test/unit/packages/ConanPackagesTest.cpp` に定義されています。

```bash
cmake --build build --target run_tests
```

| テスト名 | 内容 |
|--------|------|
| `SpdlogTest.*` | ストリームへの出力・ログレベルフィルター |
| `CxxoptsTest.*` | オプションパース・デフォルト値 |
| `NlohmannJsonTest.*` | JSON パース・シリアライズ・エラーハンドリング |
| `LibsodiumTest.*` | 初期化・乱数生成・ SHA-256 ハッシュの再現性 |
| `LibpqxxTest.*` | ヘッダリンク確認（DB接続不要） |

## パッケージの追加・更新手順

### パッケージを追加する

1. `conanfile.txt` の `[requires]` に追加する：

    ```ini
    [requires]
    spdlog/1.12.0
    libpqxx/7.7.5
    cxxopts/3.1.1
    newpackage/x.y.z   ← 追加
    ```

2. `CMakeLists.txt` に `find_package` を追加する：

    ```cmake
    find_package(newpackage REQUIRED)
    ```

3. セットアップスクリプトを再実行して vendor を更新する：

    ```bash
    bash tools/conan_setup.sh
    git add vendor/ conanfile.txt CMakeLists.txt
    git commit -m "build: :package: newpackage を Conan で追加"
    ```

### パッケージバージョンを更新する

1. `conanfile.txt` のバージョン番号を変更する
2. `bash tools/conan_setup.sh` を再実行する
3. 変更を commit する

---

## Conan バージョンの管理

Conan のバージョンは `requirements.txt` で固定されています：

```
conan==2.7.1
```

Conan バージョンを更新する場合：
1. `requirements.txt` のバージョンを変更する
2. `bash tools/conan_setup.sh` を再実行する
3. `requirements.txt` を commit する

---

## トラブルシューティング

### `vendor/full_deploy が見つかりません` エラー

```
CMake Error: [Conan] vendor/full_deploy が見つかりません。
```

**原因:** `vendor/` が設定されていない（初回クローン直後など）  
**対処:** `bash tools/conan_setup.sh` を実行して `vendor/` をセットアップしてください。

---

### `find_package(spdlog) failed` エラー

**原因:** vendor パッケージが破損または古い  
**対処:** vendor を再生成してください：

```bash
rm -rf vendor/full_deploy
bash tools/conan_setup.sh
```

---

### `conan: command not found`

**原因:** `~/.local/bin` が `PATH` に未追加  
**対処:**

```bash
export PATH="$HOME/.local/bin:$PATH"
# または ~/.bashrc に追記
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

### GCC バージョン不一致エラー

**原因:** `profiles/linux-rhel9` の `compiler.version=11` と実際の GCC バージョンが異なる  
**対処:** `profiles/linux-rhel9` の `compiler.version` を実際のバージョンに合わせてください：

```bash
gcc --version  # バージョン確認
```
