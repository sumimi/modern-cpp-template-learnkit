#!/bin/bash
###############################################################################
# generate_test_report.sh - GoogleTest XML出力をHTMLに変換するスクリプト
#
# - ユニットテストを --gtest_output=xml で実行し、XMLレポートを生成
# - XSLT (xsltproc) によって HTML形式のレポートに変換
# - 出力先は build/test_report/ に出力
#
# 実行場所: プロジェクトルート
#
# 実行手順:
#   bash tools/generate_test_report.sh
#
# 実行手順(CMakeから自動実行する場合):
#   cmake --build build --target test_report
#
# 生成物:
#   - build/test_report/test_report.xml   (XML形式のテストレポート)
#   - build/test_report/test_report.html  (HTML形式のテストレポート)
###############################################################################

set -e  # 1コマンドでも失敗したら即終了

# プロジェクトルートに移動
cd "$(dirname "$0")/.."

# 出力先ディレクトリ
OUT_DIR=build/test_report
mkdir -p "$OUT_DIR"

# 1. XMLレポート出力
./build/bin/unit_tests --gtest_output=xml:"$OUT_DIR/test_results.xml"

# 2. XSLTによりHTML化
xsltproc tools/gtest_report.xsl "$OUT_DIR/test_results.xml" > "$OUT_DIR/test_report.html"

echo "✅ HTMLレポートを生成しました：$OUT_DIR/test_report.html"
