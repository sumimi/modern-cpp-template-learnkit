#!/bin/bash
###############################################################################
# generate_coverage.sh
#
# プロジェクトのカバレッジ情報を収集・整形して、HTMLレポートを生成するスクリプト
#
# 実行場所: プロジェクトルート
#
# 実行手順:
#   bash tools/generate_coverage.sh
#
# 実行手順(CMakeから自動実行する場合):
#   cmake --build build --target coverage
#
# 生成物:
#   - build/coverage.info              (生のカバレッジデータ)
#   - build/coverage_filtered.info     (不要ファイル除外後のカバレッジデータ)
#   - build/coverage_report/           (HTML形式のカバレッジレポート)
#
# 注意事項:
#   - ビルド済み（カバレッジオプション付き）のオブジェクトファイルが必要
#   - CTestが成功している必要あり
#   - lcov, genhtml, ctest, xsltproc など必須ツールの事前インストールが必要
###############################################################################

set -e  # 1コマンドでも失敗したら即終了

#==============================================================================
# 設定項目
BUILD_DIR="build"
UNIT_TEST_EXEC="$BUILD_DIR/bin/unit_tests"
COVERAGE_DIR="coverage_report"
COVERAGE_INFO="coverage.info"
FILTERED_INFO="coverage_filtered.info"

#==============================================================================
# 必須コマンド存在チェック
echo "🔍 必須コマンドの存在チェック中..."
REQUIRED_CMDS=("lcov" "genhtml" "ctest" "xsltproc")

for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "❗ エラー: 必須コマンド [$cmd] が見つかりません。インストールしてください。"
    exit 1
  fi
done

#==============================================================================
# ユニットテストバイナリ存在チェック
echo "🔍 ユニットテストバイナリ存在チェック中..."
if [ ! -f "$UNIT_TEST_EXEC" ]; then
  echo "❗ エラー: [$UNIT_TEST_EXEC] が存在しません。ビルドしてください。"
  exit 1
fi

#==============================================================================
# カバレッジビルド確認 (静的リンク対応)
echo "🔍 カバレッジビルド検知中..."
if ! strings "$UNIT_TEST_EXEC" | grep -q "__gcov"; then
  echo "⚠️ 警告: [$UNIT_TEST_EXEC] にはカバレッジ情報が埋め込まれていない可能性があります。"
  echo "   （make clean後、カバレッジ有効なオプションで再ビルドを推奨）"
fi

#==============================================================================
# 初回クリーン処理
echo "🧹 古いカバレッジデータを削除中..."
rm -rf "$BUILD_DIR/$COVERAGE_DIR" "$BUILD_DIR/$COVERAGE_INFO" "$BUILD_DIR/$FILTERED_INFO"

#==============================================================================
# ユニットテスト実行
echo "🧪 ユニットテストを実行中..."
ctest --test-dir "$BUILD_DIR" --output-on-failure

#==============================================================================
# カバレッジデータ収集
echo "📈 カバレッジデータを収集中..."

# src/ 以下の gcda/gcno に対応するため明示的にサブディレクトリも指定
lcov --capture --directory "$BUILD_DIR" --directory "$BUILD_DIR/src" --output-file "$BUILD_DIR/$COVERAGE_INFO"

#==============================================================================
# 不要ファイル除外（標準ライブラリ等）
echo "🚫 不要ファイル（標準ライブラリ・gtest等）を除外中..."
lcov --remove "$BUILD_DIR/$COVERAGE_INFO" \
    '/usr/include/*' \
    '*/gtest/*' \
    '*/c++/*' \
    '*/cxxopts/*' \
    '*/test/*' \
    -o "$BUILD_DIR/$FILTERED_INFO"

#==============================================================================
# HTMLレポート生成
echo "📝 HTMLカバレッジレポートを生成中..."
genhtml "$BUILD_DIR/$FILTERED_INFO" --output-directory "$BUILD_DIR/$COVERAGE_DIR"

echo "✅ カバレッジレポートが [$BUILD_DIR/$COVERAGE_DIR] に生成されました！"
