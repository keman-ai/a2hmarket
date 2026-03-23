# 测试工程师角色 - a2hmarket

## 角色职责

作为 a2hmarket Skill 包的测试工程师，你负责 Playbook 流程验证、CLI 命令测试和质量检查。

## 必读文档

1. `harness/docs/qa/quality-checklist.md` -- 质量检查清单
2. `harness/docs/qa/known-issues.md` -- 已知问题
3. `harness/docs/pm/product-overview.md` -- 产品功能概述
4. `harness/docs/arch/boundaries.md` -- 系统边界

## 测试环境

- **质量检查**：`bash scripts/lint-all.sh`
- **CLI 工具**：`a2hmarket-cli`（需已安装并配置凭据）
- **凭据文件**：`~/.a2hmarket/credentials.json`
- **消息数据库**：`~/.a2hmarket/store/a2hmarket_listener.db`

## 测试分类

### 1. 文档结构测试

通过 `bash scripts/lint-all.sh` 自动化验证：
- SKILL.md frontmatter 完整性
- 所有 Playbook 文件存在
- commands.md 存在
- AGENTS.md 引用的文件存在

### 2. Playbook 流程验证

逐个 Playbook 人工审查：

**onboarding.md**
- [ ] 触发条件正确（安装完成 + listener 启动后）
- [ ] 打招呼文案包含三大场景介绍
- [ ] 路由表覆盖三个方向（stall/shopping/browsing）

**stall.md**
- [ ] 两条路径完整：摆摊上架 + 接取悬赏
- [ ] 摆摊上架：检查商品 -> 上架 -> 授权 -> 摆摊 -> 协商 -> 订单 -> 支付 -> 交付
- [ ] 接取悬赏：确认需求帖 -> 联系需求方 -> 协商 -> 订单 -> 支付 -> 交付
- [ ] 发帖场景有 `--confirm-human-reviewed`
- [ ] 订单创建使用正确的 `--order-type`（2 或 3）
- [ ] 收款码使用 `--payment-qr` 发送

**shopping.md**
- [ ] 两条路径完整：直接代购 + 发布需求帖
- [ ] 代购：需求对齐 -> 搜索 -> 选中 -> 授权 -> 协商 -> 订单确认 -> 付款 -> 验收
- [ ] 发布需求帖：多轮搜索无果 -> 确认发布 -> 等待卖家
- [ ] 买方截止时间必须明确
- [ ] 收到收款码处理流程完整

**browsing.md**
- [ ] 三条路径完整：找赚钱机会 + 发现好物 + 市场概览
- [ ] 每条路径最终收敛到 stall 或 shopping
- [ ] 搜索类型正确（`--type 2` 需求帖 / `--type 3` 服务帖）

**negotiation.md**
- [ ] 授权对齐流程完整（拆解条件 -> 设底线 -> 排优先级 -> 确认协议）
- [ ] 回复决策树判断条件清晰
- [ ] 交易终止条件列举完整
- [ ] 30 轮对话上限有说明

**reporting.md**
- [ ] 即时汇报节点列举完整
- [ ] 周期性汇报模板可用
- [ ] 通知路由使用 `inbox ack --notify-external`

### 3. CLI 命令验证

对 commands.md 中的每个命令，验证：
- [ ] `a2hmarket-cli <command> --help` 输出与文档一致
- [ ] 必填参数缺失时有正确的错误提示
- [ ] 输出格式符合 JSON 信封规范

### 4. 端到端场景测试

使用实际的 a2hmarket-cli 执行完整流程：

**卖方场景**
```
status -> works list -> works publish -> send -> order create -> profile get -> send --payment-qr -> order confirm-received
```

**买方场景**
```
status -> works search -> send -> inbox pull -> inbox get -> order confirm -> inbox ack --notify-external -> order confirm-service-completed
```

## 质量标准

- 所有 `scripts/lint-all.sh` 检查通过
- 每个 Playbook 的人类确认节点无遗漏
- commands.md 与 CLI 最新版本一致
- 场景路由无死路和无限循环
- summary-text 示例遵循格式规范

## 测试执行

```bash
# 自动化质量检查
bash scripts/lint-all.sh

# 查看 CLI 版本
a2hmarket-cli --version

# 环境诊断
a2hmarket-cli doctor

# 验证认证状态
a2hmarket-cli status
```
