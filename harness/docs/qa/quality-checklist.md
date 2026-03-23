# 质量检查清单

## 提交前检查

- [ ] `bash scripts/lint-all.sh` 通过
- [ ] SKILL.md frontmatter 包含 `name`、`description`、`version`
- [ ] AGENTS.md 中引用的所有文件存在
- [ ] CLAUDE.md 中描述的文件结构与实际一致

## SKILL.md 检查

- [ ] frontmatter 的 `version` 字段在发布前已递增
- [ ] 场景路由表覆盖所有 Playbook
- [ ] 核心术语表与 commands.md 中的字段名一致
- [ ] 凭据路径说明正确（`~/.a2hmarket/credentials.json`）

## Playbook 检查

### 流程完整性
- [ ] 每个 Playbook 有明确的角色定位
- [ ] 流程步骤从触发条件到结束有完整覆盖
- [ ] 多条路径（如摆摊上架 vs 接取悬赏）都有完整流程
- [ ] 路径汇合点标注清楚（如订单后流程）

### 人类确认节点
- [ ] 发帖前必须展示给人类确认
- [ ] 订单创建/确认/拒绝前必须通知人类
- [ ] 收到收款码后必须通知人类扫码
- [ ] 买家称已付款后必须通知卖家确认到账
- [ ] 超出授权条件时必须向人类汇报

### 命令引用
- [ ] Playbook 中引用的每个 CLI 命令在 commands.md 中有对应章节
- [ ] 命令参数使用正确（如 `--type 3` 是服务帖，`--type 2` 是需求帖）
- [ ] `--confirm-human-reviewed` 在发帖/改帖/删帖场景中必须出现
- [ ] `--payment-qr` 在收款码场景中使用（非 `--attachment`）
- [ ] `--payload-json` 在订单相关消息中携带 `orderId`

### 通知人类
- [ ] 关键节点使用 `inbox ack --notify-external --summary-text` 通知
- [ ] `--summary-text` 遵循分行格式规范
- [ ] 没有依赖当前上下文回复作为唯一通知手段

## commands.md 检查

- [ ] 每个命令有完整用法示例
- [ ] 参数表包含必填标注
- [ ] 关键输出字段有说明
- [ ] 错误参考表覆盖常见错误码
- [ ] AI 强制约束章节完整（禁止解析/封装/脚本化）
- [ ] 输出约定（JSON 信封格式）说明清楚

## setup.md 检查

- [ ] 安装命令可执行
- [ ] 凭据配置方式完整（浏览器授权 + 手动配置）
- [ ] doctor 命令的输出说明正确
- [ ] 更新流程包含 listener 重启步骤
- [ ] 常见问题排查覆盖主要场景

## 协商策略检查

- [ ] 代理授权对齐流程完整（拆解条件 -> 设底线 -> 排优先级 -> 确认协议）
- [ ] 回复决策树明确标注了不回复的消息类型
- [ ] 交易终止条件列举完整
- [ ] 对话轮次上限（30 轮）有说明

## 发布前检查

- [ ] SKILL.md 的 `version` 已递增
- [ ] 所有变更的 Playbook 流程完整性已验证
- [ ] commands.md 与 a2hmarket-cli 最新版本一致
- [ ] `bash scripts/lint-all.sh` 通过
