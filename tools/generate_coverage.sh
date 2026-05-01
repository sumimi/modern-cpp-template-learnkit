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
PROJECT_ROOT="$(pwd)"
BUILD_DIR="build"
UNIT_TEST_EXEC="$BUILD_DIR/bin/unit_tests"
COVERAGE_DIR="coverage_report"
COVERAGE_INFO="coverage.info"
FILTERED_INFO="coverage_filtered.info"
LCOV_CONFIG=".lcovrc"

# .lcovrc が存在すればプロジェクト内設定を明示的に適用
LCOV_CONFIG_ARGS=()
if [ -f "$LCOV_CONFIG" ]; then
  LCOV_CONFIG_ARGS=(--config-file "$LCOV_CONFIG")
else
  echo "⚠️ 警告: [$LCOV_CONFIG] が見つかりません。システム設定で実行します。"
fi

# lcov/genhtml の --branch-coverage 対応可否を判定（古い版との互換性確保）
LCOV_BRANCH_ARGS=()
GENHTML_BRANCH_ARGS=()
if lcov --help 2>&1 | grep -q -- '--branch-coverage'; then
  LCOV_BRANCH_ARGS=(--branch-coverage)
fi
if genhtml --help 2>&1 | grep -q -- '--branch-coverage'; then
  GENHTML_BRANCH_ARGS=(--branch-coverage)
fi

# lcov の ignore-errors はバージョンごとに許容値が異なるため動的に切替
LCOV_CAPTURE_IGNORE_ARGS=()
LCOV_REMOVE_IGNORE_ARGS=()
if lcov --help 2>&1 | grep -q -- '--ignore-errors'; then
  if lcov --help 2>&1 | grep -q 'mismatch'; then
    LCOV_CAPTURE_IGNORE_ARGS=(--ignore-errors mismatch)
    LCOV_REMOVE_IGNORE_ARGS=(--ignore-errors mismatch)
  else
    LCOV_CAPTURE_IGNORE_ARGS=(--ignore-errors gcov)
    LCOV_REMOVE_IGNORE_ARGS=(--ignore-errors source)
  fi
fi

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
# --ignore-errors は lcov バージョン互換を見て自動選択
lcov "${LCOV_CONFIG_ARGS[@]}" --capture --directory "$BUILD_DIR" --directory "$BUILD_DIR/src" --output-file "$BUILD_DIR/$COVERAGE_INFO" "${LCOV_CAPTURE_IGNORE_ARGS[@]}" "${LCOV_BRANCH_ARGS[@]}"

#==============================================================================
# プロジェクトファイルのみ抽出（OSS・外部ライブラリを自動除外）
echo "🎯 プロジェクトファイル（src/ / include/）のみ抽出中..."
lcov "${LCOV_CONFIG_ARGS[@]}" --extract "$BUILD_DIR/$COVERAGE_INFO" \
    "$PROJECT_ROOT/src/*" \
    "$PROJECT_ROOT/include/*" \
    "${LCOV_REMOVE_IGNORE_ARGS[@]}" \
    -o "$BUILD_DIR/$FILTERED_INFO"

#==============================================================================
# HTMLレポート生成
echo "📝 HTMLカバレッジレポートを生成中..."
genhtml "${LCOV_CONFIG_ARGS[@]}" "$BUILD_DIR/$FILTERED_INFO" \
    --output-directory "$BUILD_DIR/$COVERAGE_DIR" \
    --prefix "$PROJECT_ROOT/" \
    "${GENHTML_BRANCH_ARGS[@]}"

echo "✅ カバレッジレポートが [$BUILD_DIR/$COVERAGE_DIR] に生成されました！"
