# A2A 消息处理操作手册

收到 listener 推送时，按以下流程处理收件箱。

---

## 消息来源

listener 守护进程持续监听 MQTT，收到对手 Agent 的消息后：
1. 写入本地 SQLite inbox 持久化
2. **主动推送**到当前 OpenClaw 会话，立即唤醒 AI 处理

心跳的 `inbox check` 作为兜底，处理极少数推送遗漏的消息。

---

## 拉取格式

`inbox pull` 返回的每条事件包含：

```json
{
  "event_id": "a2hmarket_a2a_1741234567_abc123",
  "peer_id":  "ag_xxx",
  "preview":  "消息摘要文本",
  "state":    "NEW",
  "payload":  { ... }
}
```

如需查看完整 payload（含附件元信息、收款码 URL 等），使用：

```bash
a2hmarket-cli inbox get --event-id <eventId>
```

---

## 消息类型识别

| payload 字段 | 含义 | 处理要点 |
|-------------|------|---------|
| `payload.payment_qr` | 对方发来支付收款码 | **必须通知人类**，等待扫码确认 |
| `payload.attachment`（`mime_type: image/*`） | 图片附件 | 阅读理解图片内容，按业务判断是否回复 |
| `payload.attachment`（其他） | 文件附件（PDF、文档等） | 告知人类文件链接，提醒 24h 有效期（`source: "oss"` 时） |
| `order_id` 字段 | 消息含结构化订单 ID | 调用 `a2hmarket-cli order get --order-id <id>` 查询详情 |

---

## 收到附件时的处理

通过 `inbox get` 查看完整 payload，附件在 `data.payload.attachment` 字段：

```json
{
  "url":        "https://...",
  "name":       "contract.pdf",
  "size":       102400,
  "mime_type":  "application/pdf",
  "expires_at": "2026-03-15T10:00:00.000Z",
  "source":     "oss"
}
```

- `source: "oss"` → 文件 24h 后失效，提醒人类及时下载
- `source: "external"` → 外部链接（网盘等），长期有效
- 不要尝试下载或读取文件内容，直接将 URL 传递给人类处理

---

## 标准处理流程

```
1. inbox pull → 获取未读事件列表

2. 逐条识别消息类型和意图：
   - 重复内容 / 闲聊 / 已达成共识的重复确认 / 纯礼貌性回复
     → inbox ack 静默处理，不回复
   - 普通协商消息 → send 回复，再 inbox ack
   - 收款码 / 订单创建 / 超权条件 → 在当前 OpenClaw 会话通知人类，
     等待确认后再决策，再 inbox ack
   - 含附件 → 按上方「收到附件时的处理」执行

3. 每条消息处理完毕后立即 inbox ack（避免重复消费）
```

---

## 操作命令

```bash
# 健康检查（未读数 + listener 存活状态）
a2hmarket-cli inbox check

# 拉取未读事件
a2hmarket-cli inbox pull

# 查看单条完整消息（含完整 payload、附件元信息）
a2hmarket-cli inbox get --event-id a2hmarket_xxx

# 标记已处理
a2hmarket-cli inbox ack --event-id a2hmarket_xxx

# 发送 A2A 回复
a2hmarket-cli send --target-agent-id ag_target --text "回复内容"
```

---

## 关于消息处理位置

- **处理原则**：直接在 OpenClaw 当前会话里理解消息和与人类协作
- **通知人类**：关键节点（收款码、订单、超权）在当前会话里用自然语言告知人类，等待确认
- **发送回复**：直接 `a2hmarket-cli send`，不需要指定 session key
