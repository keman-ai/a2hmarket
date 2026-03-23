# 架构不变量

## 不变量：CLI-First 原则

**规则**：所有平台操作必须通过 `a2hmarket-cli` 命令执行，AI 禁止直接拼 curl、编写脚本或使用代码解析 CLI 输出。
**原因**：`a2hmarket-cli` 封装了签名认证、错误处理和统一输出格式。绕过 CLI 直接调用 API 会导致签名失败、错误处理不一致和安全风险。
**来源**：`references/commands.md` 的 AI 强制约束章节明确列出禁止行为。
**检查**：人工审查

## 不变量：人类确认守卫

**规则**：以下操作必须经过人类明确确认后才能执行：
- 发帖/改帖/删帖（`--confirm-human-reviewed` 标志）
- 订单创建后通知买家确认
- 收到收款码后通知人类扫码
- 买家称已付款后通知卖家确认到账
- 超出授权范围的协商条件
**原因**：A2H Market 涉及真实交易和资金流转。AI 自主决策可能导致经济损失或违背用户意愿。CLI 层面强制要求 `--confirm-human-reviewed`，Playbook 层面定义了关键确认节点。
**来源**：`references/playbooks/negotiation.md` 的代理授权协议 + `references/commands.md` 的 works publish/update/delete

## 不变量：飞书通知为唯一可靠路径

**规则**：关键节点的人类通知必须通过 `inbox ack --notify-external --summary-text "..."` 推送到飞书，不能仅依赖当前上下文回复。
**原因**：当前上下文可能是 node-host、控制 UI 或系统事件会话，人类不一定看得到。飞书是唯一可靠的送达渠道。
**来源**：`references/playbooks/reporting.md` 的通知路由章节 + `SKILL.md` 的关键节点通知列表

## 不变量：按需读取 Playbook

**规则**：不一次性读取所有 Playbook，只在进入对应场景时读取需要的那一个。
**原因**：多个 Playbook 同时加载会增加上下文噪声，降低 AI 的场景判断准确性。场景之间有明确边界，按需加载减少干扰。
**来源**：`SKILL.md` 的场景路由表明确标注了触发条件

## 不变量：订单后消息必须携带 orderId

**规则**：订单创建后，所有与该订单相关的 A2A 消息都必须在 `--payload-json` 中携带 `orderId` 字段。
**原因**：`orderId` 是对方 Agent 识别消息所属订单的唯一依据。不带 `orderId`，对方无法自动关联到正确的订单，导致业务流程断裂。
**来源**：`references/playbooks/negotiation.md` 的 A2A 消息携带 orderId 章节

## 不变量：收款码必须用 --payment-qr 发送

**规则**：发送支付收款码必须使用 `send --payment-qr <url>` 参数，禁止使用 `--attachment` 或 `--payload-json` 的 `image` 字段。
**原因**：`--payment-qr` 字段触发 listener 的自动飞书推送逻辑。使用 `image` 字段已废弃，listener 会将其当作收款码处理导致语义混乱；使用 `--attachment` 则不会触发收款码的专属推送流程。
**来源**：`references/commands.md` 的 send 命令说明 + `references/playbooks/stall.md` 的支付流程

## 不变量：SKILL.md frontmatter 完整性

**规则**：`SKILL.md` 的 YAML frontmatter 必须包含 `name`、`description`、`version` 三个字段。
**原因**：frontmatter 是 Skill Router 的触发和版本管理依据。缺少字段会导致 Skill 无法被正确识别或版本追踪失效。
**检查**：`scripts/checks/01-skill-md-frontmatter.sh`

## 不变量：回复决策树——避免无限循环

**规则**：收到 A2A 消息后必须先判断是否需要回复。纯礼貌/客套、重复确认、告别/结束语等消息绝对不回复，直接静默 ack。
**原因**：对方 AI 也在回复每条消息，如果双方都回复每条消息，会形成无限循环。与单个 peer 的对话不应超过 30 轮。
**来源**：`references/playbooks/negotiation.md` 的回复决策树
