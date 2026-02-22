# =============================================================================
# tools/coverage.cmake
#
# このスクリプトは、GCCコンパイラを使用している場合にカバレッジ測定を有効化する
# ヘルパー関数を提供します。
#
# 主な機能:
# - `--coverage` オプションを有効化
# - 最適化を無効化 (-O0)
# - デバッグ情報を付加 (-g)
#
# 使用方法:
# - CMakeLists.txt 内で `enable_coverage_if_gcc(<ターゲット名>)` を呼び出す
#
# 注意事項:
# - このスクリプトは GCC 環境でのみ動作します。
# - `ENABLE_COVERAGE` オプションが ON の場合にのみ有効化されます。
# =============================================================================

# 関数: enable_coverage_if_gcc
# 指定されたターゲットに対してカバレッジ測定を有効化します。
# 
# 引数:
# - target_name: カバレッジを有効化するターゲット名
function(enable_coverage_if_gcc target_name)
    # `ENABLE_COVERAGE` オプションが ON で、コンパイラが GCC の場合にのみ実行
    if(ENABLE_COVERAGE AND CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        # カバレッジ有効化のメッセージを出力
        message(STATUS "🔧 Coverage enabled for target: ${target_name}")

        # コンパイルオプションに `--coverage` を追加し、最適化を無効化 (-O0)、デバッグ情報を付加 (-g)
        target_compile_options(${target_name} PRIVATE --coverage -O0 -g)

        # リンクオプションに `--coverage` を追加
        target_link_options(${target_name} PRIVATE --coverage)
    endif()
endfunction()
