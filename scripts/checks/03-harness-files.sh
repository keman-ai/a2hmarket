#!/bin/bash
# 检查 harness 工程文件完整性

PROJECT_DIR="${1:-.}"
EXIT_CODE=0

# 检查 AGENTS.md 和 CLAUDE.md
for file in AGENTS.md CLAUDE.md; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo "  OK: $file"
    else
        echo "  错误: $file 不存在"
        EXIT_CODE=1
    fi
done

# 检查 harness 核心文件
REQUIRED_FILES=(
    "harness/registry.yaml"
    "harness/workflow.md"
    "harness/docs/arch/invariants.md"
    "harness/docs/arch/boundaries.md"
    "harness/docs/pm/product-overview.md"
    "harness/docs/rd/dev-conventions.md"
    "harness/docs/rd/pitfalls.md"
    "harness/docs/qa/quality-checklist.md"
    "harness/docs/qa/known-issues.md"
    "harness/roles/product-manager.md"
    "harness/roles/architect.md"
    "harness/roles/coder.md"
    "harness/roles/code-reviewer.md"
    "harness/roles/qa.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo "  OK: $file"
    else
        echo "  错误: $file 不存在"
        EXIT_CODE=1
    fi
done

exit $EXIT_CODE
