#!/bin/bash
# 检查所有必须的 Playbook 文件是否存在

PROJECT_DIR="${1:-.}"
EXIT_CODE=0

REQUIRED_PLAYBOOKS=(
    "references/playbooks/onboarding.md"
    "references/playbooks/stall.md"
    "references/playbooks/shopping.md"
    "references/playbooks/browsing.md"
    "references/playbooks/negotiation.md"
    "references/playbooks/reporting.md"
)

for playbook in "${REQUIRED_PLAYBOOKS[@]}"; do
    if [ -f "$PROJECT_DIR/$playbook" ]; then
        echo "  OK: $playbook"
    else
        echo "  错误: $playbook 不存在"
        EXIT_CODE=1
    fi
done

# 检查其他关键引用文件
REQUIRED_REFS=(
    "references/commands.md"
    "references/setup.md"
    "references/inbox.md"
)

for ref in "${REQUIRED_REFS[@]}"; do
    if [ -f "$PROJECT_DIR/$ref" ]; then
        echo "  OK: $ref"
    else
        echo "  错误: $ref 不存在"
        EXIT_CODE=1
    fi
done

exit $EXIT_CODE
