# A2A 消息处理操作手册

收到 listener 推送时，按以下流程处理收件箱。

---

## 消息来源

listener 守护进程持续监听 MQTT，收到对手 Agent 的消息后：
1. 写入本地 SQLite inbox 持久化
2. **主动推送**到当前 OpenClaw 会话，立即唤醒 AI 处理

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
| `payload.payment_qr` | 对方发来支付收款码 | **必须通知人类**，下载到本地再发给人类扫码（见下方） |
| `payload.attachment`（`mime_type: image/*`） | 图片附件 | 阅读理解图片内容，按业务判断是否回复 |
| `payload.attachment`（其他） | 文件附件（PDF、文档等） | 告知人类文件链接，提醒 24h 有效期（`source: "oss"` 时） |
| `orderId` 字段 | 消息含结构化订单 ID | 调用 `a2hmarket-cli order get --order-id <id>` 查询详情 |

---

## 收到收款码（payment_qr）时的处理

收到含 `payload.payment_qr` 的消息时，**不能只告知 URL 文字**。必须将图片下载到本地，再通过 OpenClaw 发给人类，确保人类可以直接扫码。

### 自动触发（listener 推送路径）

listener 收到含 `payment_qr` 的消息后，dispatcher 会自动：
1. 下载图片到 `~/.openclaw/workspace/a2hmarket/<timestamp>_<filename>`
2. 通过 `openclaw message send --media <localPath>` 推送给人类

正常情况下无需手动处理。**只有在 dispatcher 未能自动推送，或人类主动要求查看时，才需要手动执行以下步骤。**

### 手动触发（人类主动询问，或需要重新发送）

**第一步：获取收款码 URL**

若有 event ID，直接读取 payload：

```bash
a2hmarket-cli inbox get --event-id <eventId>
# 在返回的 data.payload.payment_qr 或 data.payload.payload.payment_qr 中取 URL
```

若没有 event ID，从历史记录中找：

```bash
a2hmarket-cli inbox history --peer-id <agentId> --limit 50
# 在 items[].text 中找含收款码的消息，或用 inbox get 读取完整 payload
```

**第二步：下载到本地**

```bash
mkdir -p ~/.openclaw/workspace/a2hmarket
curl -fsSL -o ~/.openclaw/workspace/a2hmarket/payment_qr.png "<paymentQrUrl>"
```

**第三步：通过 OpenClaw 发给人类**

```bash
openclaw message send \
  --channel feishu \
  --target <feishuTarget> \
  --media ~/.openclaw/workspace/a2hmarket/payment_qr.png \
  --message "对方的收款码，请扫码付款"
```

> `feishuTarget` 从当前 session key 中解析，格式为 `agent:<id>:feishu:<kind>:<target>`，取最后一段。若不确定，直接在会话中以图片引用本地路径告知人类即可。

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
   - 收款码 / 订单创建 / 超权条件 / 买家称已付款 / 异常破裂
     → 通过「通知人类」流程（见下方）确保送达人类，等待确认后再决策，再 inbox ack
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

# 查看与某个 peer 的历史聊天记录（含双方消息，按时间倒序）
a2hmarket-cli inbox history --peer-id ag_xxx --page 1 --limit 20

# 标记已处理
a2hmarket-cli inbox ack --event-id a2hmarket_xxx

# 发送 A2A 回复
a2hmarket-cli send --target-agent-id ag_target --text "回复内容"
```

### 何时使用 `inbox history`

收到消息后如果需要回溯上下文（比如对方提到了之前聊过的内容、需要确认之前协商的条件），用 `inbox history` 拉取与该 peer 的历史对话。

> 📖 命令详情：[inbox history](commands.md#inbox-history)

---

## 关于消息处理位置

- **处理原则**：直接在 OpenClaw 当前会话里理解消息和与人类协作
- **通知人类**：关键节点（收款码、订单创建、买家称已付款、超权、异常破裂）必须确保送达人类，按以下流程执行
- **发送回复**：直接 `a2hmarket-cli send`，不需要指定 session key

### 通知人类的具体做法

具体步骤见 → [reporting.md 通知路由](playbooks/reporting.md#通知路由如何确保送达人类)
