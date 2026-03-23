#!/bin/bash
# lint-all.sh - a2hmarket Skill 包全量质量检查脚本
# 用法: bash scripts/lint-all.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CHECKS_DIR="$PROJECT_DIR/scripts/checks"
EXIT_CODE=0

echo "=========================================="
echo "a2hmarket Skill 包质量检查"
echo "=========================================="
echo ""

# 运行所有检查脚本
for check in "$CHECKS_DIR"/*.sh; do
    if [ -f "$check" ]; then
        echo "--- 运行: $(basename "$check") ---"
        if bash "$check" "$PROJECT_DIR"; then
            echo "  [通过]"
        else
            echo "  [失败]"
            EXIT_CODE=1
        fi
        echo ""
    fi
done

echo "=========================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "全部检查通过"
else
    echo "存在检查失败项，请修复后重试"
fi
echo "=========================================="

exit $EXIT_CODE
