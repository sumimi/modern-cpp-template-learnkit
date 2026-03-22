#!/usr/bin/env bash
# governance-audit.sh
#
# C++ コーディング規約の自動ガバナンス監査フック
# PostToolUse イベントで .cpp / .hpp への変更後に自動実行されます。
#
# 検出する違反:
#   [規約系]
#   - using namespace std;        （名前空間汚染）
#   - 裸の new                    （スマートポインタを使うべき）
#   - 裸の delete                 （スマートポインタを使うべき）
#   - NULL                        （nullptr を使うべき）
#   - typedef                     （using エイリアスを使うべき）
#   - #define 数値定数             （constexpr を使うべき）
#   - C スタイルキャスト           （static_cast 等を使うべき）
#   - #ifndef インクルードガード   （#pragma once を使うべき）
#   [廃止・削除機能系]
#   - std::auto_ptr               （C++17 で削除済み）
#   - register キーワード         （C++17 で削除済み）
#   [セキュリティ系]
#   - system()                    （コマンドインジェクションリスク）
#   - gets()                      （バッファオーバーフローリスク）
#   - strcpy / strcat / sprintf   （バッファオーバーフローリスク）
#   - rand() / srand()            （脆弱な乱数生成）
#   - atoi / atof / atol          （エラー検出不可 → std::stoi 等を使用）
#   [パフォーマンス・スタイル系]
#   - memcpy / memset / memcmp    （std::copy / std::fill 等を使うべき）
#   - std::endl 多用              （"\n" を使うべき）
#   - void*                       （テンプレートまたは具体型を使うべき）
#   - printf / fprintf            （spdlog またはストリームを使うべき）

set -uo pipefail

# stdin から JSON 入力を受け取る
INPUT=$(cat)

# tool_name を取得
TOOL_NAME=$(echo "$INPUT" | python3 -c \
    "import sys, json; d=json.load(sys.stdin); print(d.get('tool_name',''))" \
    2>/dev/null || echo "")

# ファイル編集ツール以外はスキップ
case "$TOOL_NAME" in
    editFiles|create_file|write_file|str_replace_based_edit_tool|replace_string_in_file|multi_replace_string_in_file)
        ;;
    *)
        echo '{"continue": true}'
        exit 0
        ;;
esac

# 変更ファイルのリストを取得
FILES=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
# editFiles: files[], create_file/write_file: filePaths[] or filePath
# str_replace_based_edit_tool / replace_string_in_file: filePath (単数)
# multi_replace_string_in_file: replacements[].filePath
files = (
    ti.get('files') or
    ti.get('filePaths') or
    ([ti['filePath']] if ti.get('filePath') else None) or
    [r['filePath'] for r in ti.get('replacements', []) if r.get('filePath')] or
    []
)
if isinstance(files, str):
    files = [files]
for f in files:
    print(f)
" 2>/dev/null || echo "")

# .cpp / .hpp ファイルのみ対象
CPP_FILES=()
while IFS= read -r f; do
    [[ -n "$f" ]] && [[ "$f" == *.cpp || "$f" == *.hpp ]] && CPP_FILES+=("$f")
done <<< "$FILES"

if [[ ${#CPP_FILES[@]} -eq 0 ]]; then
    echo '{"continue": true}'
    exit 0
fi

VIOLATIONS=()

for f in "${CPP_FILES[@]}"; do
    [[ -f "$f" ]] || continue

    # --- 規約系 ---

    # using namespace std;
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'using namespace std;' は禁止 → 明示的な std:: を使用してください")
    done < <(grep -n "using namespace std;" "$f" 2>/dev/null)

    # 裸の new（= new ClassName パターン）
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 裸の 'new' は禁止 → std::make_unique / std::make_shared を使用してください")
    done < <(grep -nE "=\s*new\s+[A-Z][A-Za-z0-9_]*" "$f" 2>/dev/null)

    # 裸の delete
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 裸の 'delete' は禁止 → スマートポインタで自動管理してください")
    done < <(grep -nE "\bdelete\s+[a-zA-Z_]|\bdelete\[\s*\]" "$f" 2>/dev/null)

    # NULL
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'NULL' は禁止 → 'nullptr' を使用してください")
    done < <(grep -nE "\bNULL\b" "$f" 2>/dev/null)

    # typedef
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'typedef' は非推奨 → 'using' エイリアスを使用してください")
    done < <(grep -nP "\btypedef\b" "$f" 2>/dev/null)

    # #define 数値定数（UPPER_SNAKE_CASE + 数値リテラル）
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] '#define' による数値定数は禁止 → 'constexpr' を使用してください")
    done < <(grep -nP "^#\s*define\s+[A-Z][A-Z0-9_]+\s+\d+" "$f" 2>/dev/null)

    # C スタイルキャスト
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] C スタイルキャストは禁止 → 'static_cast' / 'reinterpret_cast' 等を使用してください")
    done < <(grep -nP "\((?:int|char|short|long|float|double|unsigned|signed)\s*\*?\s*\)" "$f" 2>/dev/null)

    # #ifndef インクルードガード
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] '#ifndef' ガードは禁止 → '#pragma once' を使用してください")
    done < <(grep -nP "^#ifndef\s+\w+_(H|HPP|H_|HPP_)\b" "$f" 2>/dev/null)

    # --- 廃止・削除機能系 ---

    # std::auto_ptr（C++17 で削除済み）
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'auto_ptr' は C++17 で削除済み → 'std::unique_ptr' を使用してください")
    done < <(grep -nP "\bauto_ptr\b" "$f" 2>/dev/null)

    # register キーワード（C++17 で削除済み）
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'register' は C++17 で削除済みのキーワードです → 削除してください")
    done < <(grep -nP "\bregister\b" "$f" 2>/dev/null)

    # --- セキュリティ系 ---

    # system()
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'system()' はコマンドインジェクションリスクがあります → 使用を避けてください")
    done < <(grep -nP "\bsystem\s*\(" "$f" 2>/dev/null)

    # gets()
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'gets()' はバッファオーバーフローの危険があります → 'std::getline' を使用してください")
    done < <(grep -nP "\bgets\s*\(" "$f" 2>/dev/null)

    # strcpy / strcat / sprintf
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 安全でない文字列関数は禁止 → 'std::string' / 'snprintf' を使用してください")
    done < <(grep -nP "\b(strcpy|strcat|sprintf)\s*\(" "$f" 2>/dev/null)

    # rand() / srand()
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'rand()' / 'srand()' は脆弱です → <random> の std::mt19937 等を使用してください")
    done < <(grep -nP "\b(rand|srand)\s*\(" "$f" 2>/dev/null)

    # atoi / atof / atol
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'atoi' 等はエラー検出ができません → 'std::stoi' / 'std::stod' 等を使用してください")
    done < <(grep -nP "\b(atoi|atof|atol|atoll)\s*\(" "$f" 2>/dev/null)

    # --- パフォーマンス・スタイル系 ---

    # memcpy / memset / memcmp / memmove
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] C スタイルメモリ関数は非推奨 → 'std::copy' / 'std::fill' / 'std::equal' を使用してください")
    done < <(grep -nP "\b(memcpy|memset|memcmp|memmove)\s*\(" "$f" 2>/dev/null)

    # std::endl 多用（不要な flush）
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] '<< endl' は不要な flush を発生させます → '\"\\n\"' を使用してください")
    done < <(grep -nP "<<\s*(?:std::)?endl\b" "$f" 2>/dev/null)

    # void*
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'void*' は型安全でありません → テンプレートまたは具体型を使用してください")
    done < <(grep -nP "\bvoid\s*\*" "$f" 2>/dev/null)

    # printf / fprintf
    while IFS=: read -r line _; do
        VIOLATIONS+=("[$f:$line] 'printf' / 'fprintf' は非推奨 → spdlog またはストリーム出力を使用してください")
    done < <(grep -nP "\b(printf|fprintf)\s*\(" "$f" 2>/dev/null)
done

if [[ ${#VIOLATIONS[@]} -eq 0 ]]; then
    echo '{"continue": true}'
    exit 0
fi

VIOLATIONS_STR=$(printf '%s\n' "${VIOLATIONS[@]}")

python3 -c "
import sys, json
violations = sys.stdin.read().strip()
msg = '⚠️ C++ ガバナンス違反を検出しました:\n\n' + violations + '\n\n上記を修正してから続行してください。'
print(json.dumps({'systemMessage': msg}))
" <<< "$VIOLATIONS_STR"

exit 0
