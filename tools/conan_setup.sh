#!/usr/bin/env bash
# =============================================================================
# tools/conan_setup.sh — Conan 2.x 初回セットアップスクリプト
#
# 役割:
#   1. Conan 2.x のインストール（requirements.txt のバージョンで固定）
#   2. コンパイラプロファイルの自動検出設定
#   3. conan install による依存パッケージの取得とビルド
#   4. vendor/ への full_deploy（パッケージ資産の git 管理化）
#
# 使い方:
#   bash tools/conan_setup.sh
#
# 実行後:
#   vendor/full_deploy/ に全パッケージが展開されます。
#   この内容を git add して commit してください。
#   以降のビルドでは Conan 不要になります。
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENDOR_DIR="${PROJECT_ROOT}/vendor"
PROFILE="${PROJECT_ROOT}/profiles/linux-rhel9"
REQUIREMENTS="${PROJECT_ROOT}/requirements.txt"

# ----------------------------------------------------------------------------- 
# 色付きログ出力ヘルパー
# ----------------------------------------------------------------------------- 
info()    { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
success() { echo -e "\033[1;32m[OK]\033[0m    $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

# ----------------------------------------------------------------------------- 
# Step 1: Python / pip の確認
# ----------------------------------------------------------------------------- 
info "Python / pip を確認しています..."
if ! command -v python3 &>/dev/null; then
    error "python3 が見つかりません。Python 3.9 以上をインストールしてください。"
    exit 1
fi
if ! command -v pip3 &>/dev/null; then
    error "pip3 が見つかりません。pip をインストールしてください。"
    exit 1
fi
success "Python $(python3 --version | awk '{print $2}'), pip $(pip3 --version | awk '{print $2}')"

# ----------------------------------------------------------------------------- 
# Step 2: Conan のインストール（バージョン固定）
# ----------------------------------------------------------------------------- 
info "Conan をインストールしています（requirements.txt のバージョンで固定）..."
pip3 install --quiet --user -r "${REQUIREMENTS}"
success "$(conan --version)"

# ----------------------------------------------------------------------------- 
# Step 3: Conan プロファイルの初期化（デフォルトプロファイルが未設定の場合）
# ----------------------------------------------------------------------------- 
info "Conan デフォルトプロファイルを確認しています..."
if ! conan profile show default &>/dev/null; then
    warn "デフォルトプロファイルが未設定です。自動検出で生成します..."
    conan profile detect --force
fi
success "Conan プロファイルの確認完了"

# ----------------------------------------------------------------------------- 
# Step 4: conan install — パッケージ取得＋vendor 展開
# ----------------------------------------------------------------------------- 
info "依存パッケージを取得して vendor/ へ展開しています..."
info "  プロファイル : ${PROFILE}"
info "  展開先       : ${VENDOR_DIR}/"

conan install "${PROJECT_ROOT}" \
    --output-folder="${VENDOR_DIR}" \
    --deployer=full_deploy \
    --deployer-folder="${VENDOR_DIR}" \
    --build=missing \
    --profile="${PROFILE}"

success "vendor/full_deploy/ への展開が完了しました！"

# ----------------------------------------------------------------------------- 
# Step 5: 完了メッセージ
# ----------------------------------------------------------------------------- 
echo ""
echo "======================================================================"
echo " セットアップ完了！以下の手順でビルドとコミットを行ってください。"
echo "======================================================================"
echo ""
echo "  1. vendor/ を git に追加してコミットする:"
echo "       git add vendor/"
echo "       git commit -m 'build: :package: Conan vendor パッケージを追加'"
echo ""
echo "  2. プロジェクトをビルドする:"
echo "       cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=vendor/conan_toolchain.cmake"
echo "       cmake --build build"
echo ""
echo "  ※ vendor/ コミット後は Conan 不要でビルドできます。"
echo "======================================================================"
