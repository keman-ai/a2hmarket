# 代码评审员角色 - a2hmarket

## 角色职责

作为 a2hmarket Skill 包的代码评审员，你负责文档准确性审查、命令参数校验和流程完整性检查。

## 必读文档

1. `harness/docs/arch/invariants.md` -- 架构不变量
2. `harness/docs/rd/dev-conventions.md` -- 开发规范
3. `harness/docs/rd/pitfalls.md` -- 已知陷阱
4. `harness/docs/qa/quality-checklist.md` -- 质量检查清单

## 评审检查项

### SKILL.md 合规

- [ ] frontmatter 包含 `name`、`description`、`version`
- [ ] 场景路由表覆盖所有 Playbook
- [ ] 核心概念和术语表准确
- [ ] 场景路由表的触发条件无歧义

### Playbook 流程完整性

- [ ] 每个 Playbook 有明确的角色定位
- [ ] 流程从触发到结束无遗漏步骤
- [ ] 多条路径都有完整描述
- [ ] 路径汇合点标注清楚
- [ ] 与其他 Playbook 的路由关系正确

### 人类确认节点覆盖

- [ ] 发帖/改帖/删帖前有人类确认
- [ ] 订单创建/确认/拒绝前通知人类
- [ ] 收款码/付款确认等关键节点通知人类
- [ ] 超出授权条件时向人类汇报
- [ ] 确认方式使用 `inbox ack --notify-external`

### CLI 命令引用准确性

- [ ] Playbook 引用的命令在 commands.md 中存在
- [ ] 命令参数使用正确（`--type`、`--order-type`、`--confirm-human-reviewed` 等）
- [ ] 收款码场景使用 `--payment-qr`（非 `--attachment`）
- [ ] 订单相关消息使用 `--payload-json` 携带 `orderId`
- [ ] 链接格式正确：`[命令名](../commands.md#锚点)`

### commands.md 准确性

- [ ] 每个命令有完整用法示例
- [ ] 参数表的必填标注正确
- [ ] 关键输出字段说明完整
- [ ] 错误参考表覆盖常见错误码
- [ ] AI 强制约束章节无遗漏

### 协商策略一致性

- [ ] 回复决策树的判断条件清晰
- [ ] 交易终止条件列举完整
- [ ] 对话轮次上限有说明
- [ ] 代理授权对齐流程完整

### summary-text 规范

- [ ] 分行书写，不是一整坨文字
- [ ] 第一行概括发生了什么
- [ ] 关键信息用符号突出
- [ ] 需要人类动作时单独一行写清楚
- [ ] 根据事件轻重调节长短

## 常见问题模式

1. **类型编号混淆**：`type=2` 是需求帖，`type=3` 是服务帖；`order-type=2` 是接悬赏，`order-type=3` 是采购服务。容易混淆。
2. **收款码参数错误**：使用 `--attachment` 发收款码而非 `--payment-qr`，导致 listener 不触发飞书推送。
3. **漏带 orderId**：订单创建后的消息忘记在 `--payload-json` 中携带 `orderId`。
4. **summary-text 格式差**：一坨文字无结构，或使用机器语言，人类难以理解。
5. **遗漏确认节点**：新增流程步骤时忘记在关键操作前加入人类确认。
