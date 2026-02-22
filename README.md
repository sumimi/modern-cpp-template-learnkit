<!--
---
number: 001
id: modern-cpp-template-learnkit
slug: modern-cpp-template-learnkit

title: "Modern C++ Template LearnKit"

subtitle_ja: "Modern C++学習用プロジェクトテンプレート"
subtitle_en: "Modern C++ Project Template for Learning"

description_ja: "C++17プロジェクトの環境構築を自動化し、テスト・静的解析・メモリチェック・カバレッジ測定・ドキュメント生成を最初から利用できる学習支援テンプレート"
description_en: "Automated project setup for C++17 with built-in testing, static analysis, memory checking, coverage measurement, and documentation generation"

category_ja:
  - C++/テンプレート
category_en:
  - C++/Template

difficulty: 2

tags:
  - cpp17
  - cmake
  - googletest
  - template
  - learning
  - tdd
  - static-analysis
  - coverage

repo_url: "https://github.com/sumimi/modern-cpp-template-learnkit"
demo_url: ""

hub: true
---
-->

# Modern C++ Template LearnKit

![GitHub Repo stars](https://img.shields.io/github/stars/sumimi/modern-cpp-template-learnkit?style=social)
![GitHub forks](https://img.shields.io/github/forks/sumimi/modern-cpp-template-learnkit?style=social)
![GitHub last commit](https://img.shields.io/github/last-commit/sumimi/modern-cpp-template-learnkit)
![GitHub license](https://img.shields.io/github/license/sumimi/modern-cpp-template-learnkit)

**Modern C++ Template LearnKit** は、Modern C++ プロジェクトの開発・テスト・解析・ドキュメント生成を支援する統合的なスターター構成です。

このテンプレートを使用することで、C++17に準拠した高品質なプロジェクト構造を即座に構築でき、テスト駆動開発（TDD）、静的解析、メモリリーク検出、カバレッジ測定、ドキュメント自動生成といったモダンな開発プラクティスを最初から利用できます。

---

## 🎯 目的

このテンプレートの目的は、 **C++学習者が「環境構築で困ることなく、素早く学習を始められる」** ことです。

### C++学習でよくある課題

C++を学習する際、以下のような「学習を始める前の壁」に直面することがよくあります：

- **環境構築の壁**： CMakeの設定、Google Testの導入、ビルドシステムの構築に数時間～数日かかる
- **「とりあえず動かす」ができない**： 学習を始めたいのに、環境設定でつまずいて本質的な学習に入れない
- **テスト環境の構築が面倒**： ユニットテストを書きたくても、フレームワークの導入と設定が複雑
- **複数ファイルのビルドで詰まる**： Hello Worldは動いても、複数ファイルに分割すると途端にビルドできない

### このテンプレートで実現すること

このテンプレートを使えば、**複製して数分で、すぐに学習を始められます**：

- ✅ **すぐに動く**： `cmake`だけで、ビルド・テスト実行・カバレッジ測定などが即座に使える
- ✅ **環境構築で困らない**： CMake、Google Test、静的解析などがすでに設定済みで、設定ファイルと格闘する必要がない
- ✅ **ユニットテストが最初から書ける**： テストの書き方を調べたり、環境を整えたりする手間なく、すぐにTDDを実践できる
- ✅ **複数ファイルのプロジェクトで学べる**： 最初から適切なディレクトリ構成で、実践的なModern C++開発を体験できる
- ✅ **サンプルコードで動作確認**： 動くコードが最初からあるので、「まず動かす、次に変更する、そして理解する」という学習サイクルが回せる

**学習を始めるための準備時間を最小化し、本質的なC++の学習に集中できる環境**を提供することが、このテンプレートの最大の目的です。

もちろん、使っていく中でプロジェクト構成やテストの書き方も自然に学べますし、実際のプロジェクトでも利用可能ですが、まずは「**困らずに、すぐに学習を始められる**」ことを最優先に設計しています。

---

## 👥 対象ユーザー

### 🎯 主な対象：C++学習者

このテンプレートは、**C++を学習中の方**を主な対象としています。

- 📘 **C++入門者・初学者**
  - C++の基本文法を学び終え、実践的なプロジェクト構成を理解したい方
  - 「Hello World」から次のステップへ進みたい方
  - Modern C++（C++11/14/17）の機能を実際のコードで学びたい方

- 📚 **C++中級学習者**
  - テスト駆動開発（TDD）の実践方法を学びたい方
  - レイヤー設計やDIパターンなどの設計パターンを理解したい方
  - CMakeやビルドシステムの使い方を習得したい方

- 🔄 **他言語からC++を学ぶ開発者**
  - Java、C#などから C++へ移行する方
  - Modern C++のエコシステム（テスト、ビルド、品質管理）を理解したい方

### 📖 副次的な対象

また、以下の方々にも有用です：

- 👨‍🏫 **教育者・研修担当者**
  - C++プログラミング研修での実践的な教材として使いたい方
  - ハンズオン形式の演習環境を素早く提供したい方

- 💼 **実務で使いたい開発者**
  - 新規プロジェクトを素早く立ち上げたい方
  - チーム開発のための標準的なプロジェクト構造を提供したい方

---

## 🚀 特長

このテンプレートは、C++学習をスムーズに始めるための機能がすべて揃っています。

### 🛠️ すぐに使える開発環境

- **C++17対応**： Modern C++の機能（ラムダ、auto、構造化束縛など）を学習できる
- **CMake設定済み**： 複雑なビルド設定を考えず、すぐにビルド・実行可能
- **複数ファイル構成**： ヘッダとソースの分離、モジュール化された構造を体験

### 🧪 テスト環境が完備

- **Google Test / Google Mock**： 業界標準のテストフレームワークでTDDを実践
- **CTest連携**： `run_tests` コマンド一つで全テストを実行
- **モックサンプル付き**： 依存性のテスト方法を実例から学べる

### 📊 品質管理ツール

- **カバレッジ測定**（lcov + genhtml）： テストがどこをカバーしているかHTMLで可視化
- **静的解析**（clang-tidy）： コードの問題を自動検出し、改善提案を受けられる
- **メモリリーク検出**（Valgrind）： C++で重要なメモリ管理を実践的に学習

### 📚 ドキュメント生成

- **Doxygen対応**： コメントから自動でドキュメントを生成
- **テストレポートHTML化**： テスト結果を見やすい形式で出力

すべてのツールが **コマンド1つで実行できる** ため、複雑な設定や操作を覚える必要がありません。

---

## 🧪 サンプル実装と構成紹介

このテンプレートには、**実践的なC++開発を学べるサンプルアプリケーション**が含まれています。

### 💻 サンプルアプリケーションの内容

シンプルな **ユーザー管理アプリ**（`sampleapp`）を例に、以下の実務パターンを実装しています：

- **レイヤー設計**
  - `AppController`： アプリ層（ユーザー入力を受け取る）
  - `UserService`： ビジネスロジック層（処理を実行）
  - `UserRepository`： データアクセス層（DB操作を担当）

- **依存性注入（DI）パターン**
  - インターフェース（`IUserRepository`）と実装を分離
  - テスト時にモックと差し替え可能な設計

- **実践的なテスト**
  - Google Mockを使ったモックオブジェクトの作成例
  - 各レイヤーを独立してテストする方法

### 📚 学習価値

「単一ファイルのHello World」ではなく、**実務で使われるプロジェクト構造**を体験できます：

1. **複数ファイルの構成**：ヘッダとソースの分離、ディレクトリ構造
2. **設計パターン**：レイヤー化、インターフェース分離、DIパターン
3. **テスト設計**：モックを使ったユニットテストの書き方

📁 **ファイル構成**：`include/sampleapp/`、`src/sampleapp/`、`test/sampleapp/`

サンプルコードを読むだけでなく、変更して自分のコードに書き換えることで、実践力が身につきます。

---

## 🎯 活用シナリオ

このテンプレートを使った、代表的な学習シナリオを紹介します。

### 1. 📝 C++の基礎学習：「まず動かす」から始める

**こんな方に：** C++の基本文法を学び終えて、実際にコードを書き始めたい初学者

**学習の流れ：**
1. **テンプレートを複製**： `cp -r modern-cpp-template-learnkit my-study`
2. **即座にビルド・実行**： `cmake -S . -B build && cmake --build build && ./build/bin/main`
3. **動くことを確認**： サンプルアプリが動作し、テストも全て成功することを確認
4. **コードを読む**： `src/sampleapp/` のコードを読んで、クラス設計やヘッダ/ソース分離を理解
5. **少しずつ変更**： 変数名や出力メッセージを変更して、ビルド→実行のサイクルに慣れる

**このシナリオで学べること：**
- 複数ファイルに分かれたC++プロジェクトのビルド方法
- ヘッダファイル（.hpp）とソースファイル（.cpp）の関係
- クラスの定義と実装の分離
- CMakeを使った実践的なビルド体験

---

### 2. 🧪 ユニットテストの学習：TDDを体験する

**こんな方に：** テストの重要性は理解しているが、実際の書き方や実行方法が分からない方

**学習の流れ：**
1. **既存のテストを実行**： `cmake --build build --target run_tests`
2. **テストコードを読む**： `test/unit/sampleapp/` のテストコードを読んで、Google Testの書き方を理解
3. **テストを1つ追加**： 簡単な関数を作り、そのテストを書いてみる
4. **失敗させてみる**： わざと間違ったテストを書いて、失敗時の挙動を確認（Red）
5. **修正して成功させる**： テストが通るようにコードを修正（Green）

**このシナリオで学べること：**
- Google Testの基本的な使い方（`TEST`, `EXPECT_EQ`, `ASSERT_TRUE`など）
- モックオブジェクトを使ったテストの書き方（Google Mock）
- テスト駆動開発（TDD）のRed-Green-Refactorサイクル
- CTestによるテスト管理

---

### 3. 📊 品質管理ツールの学習：プロの開発を体験する

**こんな方に：** 実務レベルの開発プラクティスを学びたい中級学習者

**学習の流れ：**
1. **カバレッジ測定を実行**： `cmake -DENABLE_COVERAGE=ON -S . -B build && cmake --build build --target coverage`
2. **レポートを確認**： `build/coverage_report/index.html` をブラウザで開いて、どの行がテストされているかを確認
3. **カバレッジを上げる**： テストされていない箇所を見つけて、テストを追加してカバレッジを向上
4. **静的解析を実行**： `cmake --build build --target clang_tidy` でコードの改善提案を受ける
5. **ドキュメント生成**： `cmake --build build --target doc` でコードから自動的にドキュメントを生成

**このシナリオで学べること：**
- コードカバレッジの測定と改善方法
- 静的解析ツール（clang-tidy）による品質向上
- Doxygenによる自動ドキュメント生成
- プロの開発現場で使われる品質管理の考え方

---

## ⚠️ 前提条件

セットアップを行う前に、必要なツールとライブラリをインストールしてください。

詳細なインストール手順については、[docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) の「セクション 0」を参照してください。

---

## 🚀 クイックスタート

### 基本的なビルドと実行

```bash
cmake -S . -B build   # 初期設定
cmake --build build   # ビルド実行
./build/bin/main      # 実行
```

## 🔧 カスタムビルドターゲット

```bash
cmake --build build --target run_tests             # テスト実行
cmake --build build --target test_report           # テスト結果をHTMLに変換
cmake --build build --target coverage              # カバレッジ測定と出力
cmake --build build --target doc                   # ドキュメント生成
cmake --build build --target clang_tidy            # 静的解析
cmake --build build --target valgrind              # メモリリークチェック
cmake --build build --target clean_all             # 成果物をすべて削除
```

## 📈 カバレッジ測定の手順

このテンプレートでは `ENABLE_COVERAGE=ON` を付けて CMake 構成を行うことで、カバレッジ測定を有効にできます。

```bash
# 1. CMake構成（カバレッジ有効）
cmake -DENABLE_COVERAGE=ON -S . -B build

# 2. ビルド＆テスト
cmake --build build
cmake --build build --target run_tests

# 3. カバレッジレポート生成
cmake --build build --target coverage
```

※既存のビルド成果物がある場合は、以下のいずれかでクリーンアップしてから実行してください。

* CMakeターゲットによる削除（推奨）：

  ```bash
  cmake --build build --target clean_all
  ```

* CMakeキャッシュごと削除（再構成を行う場合）：

  ```bash
  rm -rf build
  ```

上記により `build/coverage_report/index.html` に HTML レポートが生成されます。

---

## �️ 開発環境のセットアップ

### Gitコミットメッセージテンプレートの設定

このプロジェクトでは、Semantic Commit Messages + Gitmoji 形式でコミットメッセージを統一しています。

#### 設定方法

```bash
git config commit.template .gitmessage
```

または、グローバル設定にする場合：

```bash
git config --global commit.template /path/to/modern-cpp-template-learnkit/.gitmessage
```

#### コミットメッセージ形式

```
<type>: :<emoji>: <1文の日本語で説明>
```

**例：**
- `feat: :sparkles: ユーザー登録機能を追加`
- `fix: :bug: メモリリーク問題を修正`
- `docs: :memo: READMEを更新`

詳細は `.github/copilot-instructions.md` または [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

### GitHub Copilot の利用

このプロジェクトには `.github/copilot-instructions.md` が含まれており、GitHub Copilot が自動的にプロジェクトの規約を参照します。

VS Code で GitHub Copilot を使用している場合、コミットメッセージやコードの提案時に自動的にプロジェクトの規約に従った提案をしてくれます。

### エディタ設定

`.editorconfig` ファイルが含まれており、以下の設定が自動適用されます：

- **C++ファイル**: スペース4つのインデント
- **CMake/YAML/JSON**: スペース2つのインデント
- **UTF-8エンコーディング**、LF改行コード

主要なエディタ（VS Code、CLion、Vim、Emacs など）は `.editorconfig` を自動認識します。

---

## �📖 プロジェクトから始めるには？

このテンプレートを使って新規プロジェクトを始めるには：

1. ディレクトリを複製：

   ```bash
   # AwesomeTool という名前のプロジェクトを作成
   cp -r ModernCppProjectTemplate AwesomeTool
   cd AwesomeTool
   ```

2. `CMakeLists.txt` 内の `project(ModernCppProject ...)` を `project(AwesomeTool ...)` に変更

3. `src/`, `test/` 内のクラスやファイルを新しい機能に合わせて修正

4. `Doxyfile` のプロジェクト名などを変更（任意）

詳細は [docs/SETUP_GUIDE.md](docs/SETUP_GUIDE.md) を参照してください。

## 🎨 コーディングスタイル

このテンプレートでは [Google C++ Style Guide](https://ttsuki.github.io/styleguide/cppguide.ja.html) に準拠し、`.clang-format` により自動整形を行います。

### Visual Studio Code 推奨設定

`.vscode/settings.json` を用意しており、以下の設定が有効です：

* 保存時に clang-format による整形を自動実行
* スタイル設定は `.clang-format` を参照

---

## 📂 ディレクトリ構成

```
modern-cpp-template-learnkit/
├── .github/              # GitHub関連設定
│   └── copilot-instructions.md  # GitHub Copilot用指示ファイル
├── include/              # ヘッダファイル群（*.hpp）
│   ├── sampleapp/        # サンプルアプリケーション
│   │   ├── AppController.hpp
│   │   ├── User.hpp
│   │   ├── UserService.hpp
│   │   └── UserRepository.hpp
│   └── cxxopts/          # cxxopts ライブラリ (OSS header-only)
├── src/                  # ソースファイル群
│   ├── main.cpp          # メインエントリーポイント
│   └── sampleapp/        # サンプルアプリケーション実装
│       ├── AppController.cpp
│       ├── UserService.cpp
│       └── UserRepository.cpp
├── test/                 # テストコード
│   └── unit/             # ユニットテスト
│       └── sampleapp/    # サンプルアプリのテスト
├── tools/                # 補助スクリプト
│   ├── coverage.cmake
│   ├── generate_coverage.sh
│   ├── generate_test_report.sh
│   ├── run_valgrind.sh
│   └── clean_all.sh
├── build/                # ビルド生成先（外部生成）
│   ├── bin/              # 実行ファイル
│   ├── test_report/      # テストレポート出力先
│   ├── coverage_report/  # カバレッジレポート出力先
│   └── clang_tidy.log    # clang-tidy 出力先
├── docs/                 # ドキュメント関連
│   ├── Doxyfile          # Doxygen設定
│   ├── SETUP_GUIDE.md    # セットアップガイド
│   └── html/             # Doxygen 出力先（自動生成）
├── .editorconfig         # エディタ設定（コードスタイル統一）
├── .gitmessage           # Gitコミットメッセージテンプレート
├── CMakeLists.txt        # ルートCMake設定
├── CONTRIBUTING.md       # コントリビューションガイド
├── README.md             # プロジェクト説明
└── LICENSE               # ライセンス（MIT）
```

---

## 📘 関連資料

### 公式ドキュメント
* [GoogleTest](https://github.com/google/googletest) - C++テストフレームワーク
* [CMake Documentation](https://cmake.org/documentation/) - ビルドシステム
* [Doxygen](https://www.doxygen.nl/) - ドキュメント生成ツール
* [lcov](https://github.com/linux-test-project/lcov) - カバレッジ測定ツール
* [Valgrind](https://valgrind.org/) - メモリデバッグツール

### プロジェクト固有ドキュメント
* **[セットアップガイド（SETUP_GUIDE.md）](docs/SETUP_GUIDE.md)** - 詳細なセットアップ手順と設定方法

---

## 📄 ライセンス

MIT License – 詳細は [LICENSE](LICENSE) を参照してください。

本テンプレートは自由に利用・改変・再配布が可能です。商用プロジェクトでも無償で使用できます。

---
