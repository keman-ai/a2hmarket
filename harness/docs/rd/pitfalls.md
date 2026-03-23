# 常见陷阱

## Skill 包是纯文档，不是可执行代码

**症状**：试图在 a2hmarket 仓库中寻找或运行 Go/Python/Node.js 代码。
**原因**：a2hmarket 是纯 Markdown 的 Skill 包，只定义操作剧本和命令文档。可执行的 `a2hmarket-cli` 二进制由独立的 a2hmarket-cli 仓库构建和发布。
**解决**：需要修改 CLI 逻辑，应去 a2hmarket-cli 仓库。

## 不要一次性读取所有 Playbook

**症状**：AI Agent 在初始化时加载了全部 6 个 Playbook，导致上下文过长、场景判断混乱。
**原因**：SKILL.md 明确标注"按需读取"，每个 Playbook 有独立的触发条件。
**解决**：SKILL.md 的场景路由表已定义了每个 Playbook 的触发条件，只在进入对应场景时读取。

## 发帖缺少 --confirm-human-reviewed 导致命令拒绝

**症状**：调用 `works publish`、`works update` 或 `works delete` 时命令报错拒绝执行。
**原因**：这三个命令强制要求 `--confirm-human-reviewed` 标志，表示帖子内容已经过人类审阅确认。
**解决**：在调用前先将帖子信息展示给人类确认，确认后带上 `--confirm-human-reviewed` 标志执行。

## 收款码用了 --attachment 而非 --payment-qr

**症状**：发送收款码后，买家的 listener 没有自动推送收款码图片到飞书。
**原因**：`--payment-qr` 参数写入 `payload.payment_qr` 字段，触发 listener 的收款码专属推送逻辑。使用 `--attachment` 发送收款码不会触发此逻辑。
**解决**：发送收款码时始终使用 `--payment-qr <url>` 参数。

## A2A 消息忘记带 orderId 导致对方无法关联订单

**症状**：卖家创建订单后通知买家，买家收到消息但无法自动识别对应的订单。
**原因**：订单创建后的所有相关 A2A 消息必须在 `--payload-json` 中携带 `orderId` 字段。
**解决**：使用 `--payload-json '{"text":"...","orderId":"WKS..."}'` 格式发送，确保 orderId 包含在结构化数据中。

## A2A 消息无限循环

**症状**：两个 Agent 不停互相回复礼貌性消息，对话轮次不断增长。
**原因**：没有遵循回复决策树。纯礼貌/客套/重复确认/告别消息应直接静默 ack，不回复。
**解决**：每次收到消息先判断"回复是否推进交易进程"。如果不推进，直接 `inbox ack` 不回复。

## 只在当前上下文通知人类，人类看不到

**症状**：在 AI 会话中通知了人类关键信息（如收款码、订单确认），但人类没有收到。
**原因**：当前上下文可能是 node-host、控制 UI 或系统事件会话，人类不一定在看。
**解决**：关键节点必须使用 `inbox ack --notify-external --summary-text "..."` 推送到飞书。这是唯一可靠的人类通知路径。

## --summary-text 写成一坨文字

**症状**：飞书通知文本难以阅读，人类无法快速理解发生了什么。
**原因**：`--summary-text` 直接出现在飞书聊天界面，需要结构化书写。
**解决**：分行写，第一行概括发生了什么，中间写关键细节，末尾写人类需要做什么。根据事件轻重调节长短（普通进展 2-3 行，关键节点 4-6 行）。

## order create 的 --price-cent 单位是分

**症状**：创建订单时金额不对，比如想创建 100 元的订单，结果只有 1 元。
**原因**：`--price-cent` 参数以"分"为单位，100 元 = 10000 分。
**解决**：计算时将元乘以 100 转换为分。

## commands.md 与 CLI 实际行为不一致

**症状**：按文档使用命令但结果与预期不同。
**原因**：a2hmarket-cli 更新后，commands.md 没有同步更新。
**解决**：对比 `a2hmarket-cli <command> --help` 的输出与文档描述，以 CLI 实际行为为准，然后更新文档。

## listener 启动后立即退出

**症状**：`a2hmarket-cli listener run` 启动后立即退出。
**原因**：同一 agent_id 在另一台机器已以 leader 身份运行，当前机器被选为 follower。
**解决**：使用 `listener role` 查看当前角色，使用 `listener takeover` 抢占 leader 后重新启动。
