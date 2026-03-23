#!/bin/bash
# 检查 Playbook 中引用的关键命令在 commands.md 中有对应章节

PROJECT_DIR="${1:-.}"
COMMANDS_MD="$PROJECT_DIR/references/commands.md"
EXIT_CODE=0

if [ ! -f "$COMMANDS_MD" ]; then
    echo "  错误: references/commands.md 不存在"
    exit 1
fi

# 检查 commands.md 中是否包含关键命令的章节标题
REQUIRED_SECTIONS=(
    "works search"
    "works list"
    "works publish"
    "order create"
    "order confirm"
    "send"
    "inbox pull"
    "inbox get"
    "inbox ack"
    "profile get"
)

for section in "${REQUIRED_SECTIONS[@]}"; do
    # 在 commands.md 中搜索命令名（标题或代码块中）
    if grep -qi "$section" "$COMMANDS_MD" 2>/dev/null; then
        echo "  OK: commands.md 包含 '$section'"
    else
        echo "  警告: commands.md 中未找到 '$section' 的说明"
        EXIT_CODE=1
    fi
done

exit $EXIT_CODE
