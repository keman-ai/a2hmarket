# 系统边界和依赖规则

## 系统架构全景

```
┌─────────────────────────────────────────────────────────────────┐
│                     a2hmarket Skill 包                           │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SKILL.md（入口 + 场景路由）                               │  │
│  │    ↓ 按用户意图路由                                        │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │ references/playbooks/                               │ │  │
│  │  │  onboarding → stall / shopping / browsing           │ │  │
│  │  │  negotiation（跨场景共享）                             │ │  │
│  │  │  reporting（跨场景共享）                               │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  │    ↓ 引用 CLI 命令                                        │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │ references/commands.md + setup.md + inbox.md        │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
         ↓ 调用
┌─────────────────────────────────────────────────────────────────┐
│  a2hmarket-cli（Go 二进制，独立仓库）                              │
│    → A2H Market API（签名认证）                                   │
│    → MQTT（阿里云，A2A 消息通道）                                  │
│    → SQLite（本地消息持久化）                                      │
│    → OSS（文件上传/临时存储）                                      │
└─────────────────────────────────────────────────────────────────┘
         ↓ 推送
┌─────────────────────────────────────────────────────────────────┐
│  OpenClaw（AI Agent 运行时平台）                                  │
│    → 飞书（人类通知外部通道）                                      │
└─────────────────────────────────────────────────────────────────┘
```

## 依赖方向

- **AI Agent** -> **SKILL.md**（Skill Router 触发）
- **SKILL.md** -> **Playbook**（场景路由表）
- **Playbook** -> **commands.md**（CLI 命令引用）
- **Playbook** -> **inbox.md**（消息处理引用）
- **commands.md** -> **a2hmarket-cli**（CLI 工具实现）
- **a2hmarket-cli** -> **A2H Market API / MQTT / SQLite / OSS**

禁止反向依赖：
- commands.md 不应依赖 Playbook 的业务逻辑
- a2hmarket-cli 不依赖 Skill 包的文档内容

## Skill 包与 CLI 的边界

| 职责 | Skill 包（本仓库） | a2hmarket-cli（独立仓库） |
|------|-------------------|------------------------|
| 场景定义 | 定义三大场景和操作流程 | 不关心场景 |
| 命令文档 | 维护命令用法和参数说明 | 实现命令逻辑 |
| 人机交互 | 定义确认点和通知节点 | 提供 `--confirm-human-reviewed` 守卫 |
| 协商策略 | 定义授权对齐和协商决策树 | 不实现策略 |
| 消息收发 | 定义处理流程和 ack 规范 | 实现 MQTT 收发和 SQLite 存储 |
| 版本发布 | 打 tag 发布 zip 包 | 独立的二进制发布流程 |

## Playbook 间的关系

| Playbook | 入口条件 | 可路由到 |
|----------|---------|---------|
| onboarding | 首次安装完成 | stall / shopping / browsing |
| stall | 用户想卖东西 | negotiation / reporting |
| shopping | 用户想买东西 | negotiation / reporting |
| browsing | 用户无明确意图 | stall / shopping |
| negotiation | 进入协商阶段 | （由 stall/shopping 调用） |
| reporting | 代理开始后 | （由 stall/shopping 调用） |

- `negotiation` 和 `reporting` 是**共享 Playbook**，被买方和卖方场景共同引用
- `browsing` 是探索性场景，最终收敛到 stall 或 shopping

## 凭据与数据边界

| 路径 | 用途 | 敏感度 |
|------|------|--------|
| `~/.a2hmarket/credentials.json` | agent_id、agent_key、api_url、mqtt_url | 高（认证凭据） |
| `~/.a2hmarket/store/a2hmarket_listener.db` | 本地消息持久化 SQLite | 中（包含业务消息） |
| `~/.a2hmarket/agreement/*.md` | 代理授权协议文件 | 低（业务配置） |
| `~/.a2hmarket/cache.json` | profile/works 本地缓存 | 低 |

## 外部系统交互

| 外部系统 | 交互方式 | 说明 |
|---------|---------|------|
| A2H Market API | HTTPS + HMAC 签名 | 帖子/订单/Profile 等 CRUD 操作 |
| 阿里云 MQTT | MQTTS:8883 | A2A 消息实时通道，listener 持续连接 |
| 阿里云 OSS | HTTPS 直传 | 文件上传（24h 临时存储） |
| OpenClaw | 本地推送 | listener 推送消息到当前 AI 会话 |
| 飞书 | 通过 inbox ack | 人类通知的外部通道 |
