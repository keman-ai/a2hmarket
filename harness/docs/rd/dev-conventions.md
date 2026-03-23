# 开发规范

## 通用规范

- 所有文档用中文编写
- 变更后运行 `bash scripts/lint-all.sh` 验证
- 提交信息格式：`docs/feat/fix: 简要描述`
- SKILL.md 的 frontmatter 必须包含 `name`、`description`、`version` 字段

## SKILL.md 规范

### frontmatter 格式

```yaml
---
name: a2hmarket
description: Connect your AI Agent to A2H Market...
version: 1.0.18
---
```

- `name`：Skill 标识，不可变更
- `description`：英文描述，供 Skill Router 触发匹配
- `version`：语义化版本号，每次发布 tag 前递增

### 内容结构

1. 重要提示（核心工具和使用原则）
2. 概念介绍（三大场景、核心术语表）
3. 首次使用（初始化指引、凭据说明）
4. 场景路由表（按用户意图路由到对应 Playbook）
5. 消息处理入口（收到消息时的处理指引）

## Playbook 规范

### 文件组织

- 每个场景一个 Playbook 文件，放在 `references/playbooks/` 目录下
- 文件名使用小写英文，与场景概念对应

### 内容结构

每个 Playbook 应包含：

1. **角色定位**：一句话说明 AI Agent 在此场景中的角色
2. **路径判断**：如果有多条路径，给出判断表
3. **分步流程**：每一步的操作指引，引用具体的 CLI 命令
4. **确认节点**：明确标注需要人类确认的位置
5. **参考文案**：给出通知人类的文案模板（可根据上下文润色）
6. **流程全景图**：Mermaid 时序图（如有）

### 命令引用

- Playbook 中引用 CLI 命令时使用 Markdown 链接指向 commands.md 的对应章节
- 格式：`[命令名](../commands.md#章节锚点)`
- 示例：`[works publish](../commands.md#works-publish)`

### 人类确认文案

- 使用 Markdown 引用块格式（`>`）标记参考文案
- 文案可包含 emoji 增强可读性
- 明确标注需要人类做什么（确认/选择/操作）

## commands.md 规范

### 命令文档结构

每个命令应包含：

1. 命令名和简要说明
2. 完整用法示例（`bash` 代码块）
3. 参数表（参数名 | 必填 | 说明）
4. 关键输出字段表（字段名 | 说明）

### 输出约定

所有命令的输出遵循统一 JSON 信封格式：

```json
{ "ok": true, "action": "<command>", "data": { ... } }
{ "ok": false, "action": "<command>", "error": "<message>" }
```

### 错误码

平台错误码使用 `PLATFORM_` 前缀，本地错误使用 `RUNTIME_ERROR` 或 `[a2hmarket-cli]` 前缀。新增错误码时更新 commands.md 底部的错误参考表。

## 版本管理

- 版本号遵循语义化版本：`主版本.次版本.修订号`
- 新增场景/Playbook：次版本号递增
- 修改现有文档/修复：修订号递增
- 破坏性变更（CLI 命令不兼容）：主版本号递增
- 版本号仅在 SKILL.md 的 frontmatter 中维护

## Git 提交规范

```
docs: 更新 stall playbook 的支付流程
feat: 新增 browsing 场景 playbook
fix: 修复 commands.md 中 order create 参数说明
chore: bump version to 1.0.19
```
