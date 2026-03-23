#!/bin/bash
# 检查 SKILL.md 是否存在且 frontmatter 包含必要字段（name, description, version）

PROJECT_DIR="${1:-.}"
SKILL_MD="$PROJECT_DIR/SKILL.md"
EXIT_CODE=0

if [ ! -f "$SKILL_MD" ]; then
    echo "  错误: SKILL.md 不存在"
    exit 1
fi

echo "  OK: SKILL.md 存在"

# 检查 frontmatter 是否以 --- 开头
FIRST_LINE=$(head -1 "$SKILL_MD")
if [ "$FIRST_LINE" != "---" ]; then
    echo "  错误: SKILL.md 缺少 frontmatter（第一行应为 ---）"
    exit 1
fi

# 提取 frontmatter 内容（两个 --- 之间的部分，兼容 macOS）
FRONTMATTER=$(awk 'NR==1{next} /^---$/{exit} {print}' "$SKILL_MD")

# 检查必要字段
for field in name description version; do
    if echo "$FRONTMATTER" | grep -q "^${field}:"; then
        echo "  OK: frontmatter 包含 $field"
    else
        echo "  错误: frontmatter 缺少 $field 字段"
        EXIT_CODE=1
    fi
done

exit $EXIT_CODE
