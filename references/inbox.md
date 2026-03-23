# A2A 消息处理操作手册

收到 listener 推送时，按以下流程处理收件箱。

> 📖 命令参考：[commands.md](commands.md)

---

## 消息来源

listener 守护进程持续监听 MQTT，收到对手 Agent 的消息后：
1. 写入本地 SQLite inbox 持久化
2. **主动推送**到当前 OpenClaw 会话，立即唤醒 AI 处理

---

## 拉取与查看

- 用 [`inbox pull`](commands.md#inbox-pull) 拉取未读事件列表
- 用 [`inbox get`](commands.md#inbox-get) 查看单条消息的完整 payload（含附件元信息、收款码 URL 等）

---

## 消息类型识别

| payload 字段 | 含义 | 处理要点 |
|-------------|------|---------|
| `payload.payment_qr` | 对方发来支付收款码 | **必须通知人类**，下载到本地再发给人类扫码（见下方） |
| `payload.attachment`（`mime_type: image/*`） | 图片附件 | 阅读理解图片内容，按业务判断是否回复 |
| `payload.attachment`（其他） | 文件附件（PDF、文档等） | 告知人类文件链接，提醒 24h 有效期（`source: "oss"` 时） |
| `orderId` 字段 | 消息含结构化订单 ID | 用 [`order get`](commands.md#order--订单) 查询详情 |

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

- 若有 event ID，用 [`inbox get`](commands.md#inbox-get) 读取 payload，从 `data.payload.payment_qr` 或 `data.payload.payload.payment_qr` 中取 URL
- 若没有 event ID，用 [`inbox history`](commands.md#inbox-history) 从历史记录中找含收款码的消息

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

用 [`inbox get`](commands.md#inbox-get) 查看完整 payload，附件在 `data.payload.attachment` 字段：

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
     → 静默 ack，不回复，不通知人类
   - 普通协商消息 → send 回复，再 ack + 通知人类（摘要）
   - 收款码 / 订单创建 / 超权条件 / 买家称已付款 / 异常破裂
     → ack + 通知人类（详细摘要），等待确认后再决策
   - 含附件 → 按上方「收到附件时的处理」执行

3. 每条消息处理完毕后立即 ack（避免重复消费）
```

### ack 的两种用法

- **静默 ack**（不需要通知人类的消息）：调用 [`inbox ack`](commands.md#inbox-ack)，仅传 `--event-id`
- **ack + 通知飞书**（需要人类知道的消息）：调用 `inbox ack` 时加 `--notify-external --summary-text "摘要内容"`

> **重要**：`--notify-external --summary-text` 是把消息同步到飞书的唯一方式。不加这两个参数，人类在飞书上看不到这条消息的处理结果。对于所有非垃圾/非重复的消息，都应该带上 `--notify-external`，让人类在飞书里能看到协商进展。

### `--summary-text` 写法要求

这段文字直接出现在飞书聊天界面里，人类在手机/电脑上阅读。写法要求：

**格式原则**：
- 用换行分段，不要写成一整坨
- 关键信息用「」或数字突出
- 如果需要人类动作，单独一行写清楚要做什么
- 根据事件轻重调节长短：普通进展 2-3 行，关键节点 4-6 行

**结构**：
1. 第一行：发生了什么（一句话概括）
2. 中间：关键细节（价格、条件、时间等）
3. 末尾：需要人类做什么（如果需要的话）

**示例——普通协商进展（简短）**：

```
对方回复：同意「150 元」成交
要求 3 天内交付，我已接受并回复确认
```

**示例——需要人类操作（详细）**：

```
对方发来收款码
· 金额：200 元
· 商品：Python 编程一对一教学

请打开图片扫码付款
```

**示例——订单创建（需确认）**：

```
对方创建了订单，需要你确认
· 商品：UI 设计外包
· 金额：500 元
· 交付时间：5 个工作日

请回复「确认」接受订单，或告诉我你的意见
```

**示例——紧急事件（突出urgency）**：

```
对方称已付款 200 元
请核实是否收到，确认后我会通知对方发货
```

**示例——交易异常（短促）**：

```
对方取消了订单「UI 设计外包」
原因：找到了其他服务商
需要你确认是否同意取消
```

**反面示例（不要这样写）**：
- ❌ `"对方说他同意了价格是150元然后要求3天内交付我已经回复了"` — 一坨文字没有结构
- ❌ `"msg received from ag_xxx, price=150, delivery=3d"` — 机器语言，人类看不懂
- ❌ 把对方原文复制粘贴 — 应该是你的理解摘要

---

### 何时使用 `inbox history`

收到消息后如果需要回溯上下文（比如对方提到了之前聊过的内容、需要确认之前协商的条件），用 [`inbox history`](commands.md#inbox-history) 拉取与该 peer 的历史对话。

---

## 回复对方

用 [`send`](commands.md#send--发送-a2a-消息) 发送 A2A 回复，不需要指定 session key。

---

## 关于消息处理位置

- **处理原则**：直接在 OpenClaw 当前会话里理解消息和与人类协作
- **通知人类**：关键节点（收款码、订单创建、买家称已付款、超权、异常破裂）必须确保送达人类，按以下流程执行
- **发送回复**：直接用 `send` 命令，不需要指定 session key

### 通知人类的具体做法

具体步骤见 → [reporting.md 通知路由](playbooks/reporting.md#通知路由如何确保送达人类)
