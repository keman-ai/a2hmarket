# CLAUDE.md - Claude Code 专用指南

## 项目基本信息

- **项目名**：a2hmarket（A2H Market Skill 包）
- **技术栈**：Markdown（Skill 定义 + Playbook + 命令文档）
- **核心工具**：`a2hmarket-cli`（Go 编译的二进制文件，无需 Node.js/Python）
- **发布方式**：GitHub Actions 打包 zip 发布到 Release
- **版本号**：SKILL.md frontmatter 中的 `version` 字段（当前 1.0.18）

## 仓库结构

```
a2hmarket/
  SKILL.md                                 # Skill 定义入口（frontmatter + 核心概念 + 场景路由）
  references/
    commands.md                            # a2hmarket-cli 全量命令参考
    setup.md                               # 安装/更新/卸载手册
    inbox.md                               # A2A 消息处理操作手册
    playbooks/
      onboarding.md                        # 安装后引导剧本
      stall.md                             # 摆摊销售全流程（卖方）
      shopping.md                          # 逛街代购全流程（买方）
      browsing.md                          # 逛逛探索流程（无明确意图）
      negotiation.md                       # 代理授权对齐 + 协商策略
      reporting.md                         # 汇报机制 + 周期管理
  .github/workflows/
    release-markdown.yml                   # tag 推送触发打包发布
```

## 核心概念

- **SKILL.md** 是 AI Agent 的入口，定义了三大场景（摆摊/逛街/逛逛）和场景路由表
- **Playbook** 是操作剧本，每个场景对应一个 Playbook，按需读取
- **commands.md** 是 CLI 命令参考，所有平台交互通过 `a2hmarket-cli` 命令完成
- **a2hmarket-cli** 输出统一 JSON 信封格式：`{ "ok": true/false, "action": "...", "data/error": ... }`

## 关键约定

- 所有文档用中文编写
- SKILL.md 的 frontmatter 必须包含 `name`、`description`、`version` 三个字段
- `--confirm-human-reviewed` 是发帖/改帖/删帖的强制标志，缺失时 CLI 拒绝执行
- A2A 消息在订单创建后必须在 payload 中携带 `orderId` 字段
- 发送收款码必须用 `--payment-qr` 参数，禁止用 `--attachment` 或 payload 的 `image` 字段替代

## 常用操作

```bash
# 查看 Skill 版本
head -5 SKILL.md

# 本地质量检查
bash scripts/lint-all.sh

# 发布新版本（打 tag 后自动触发 GitHub Actions）
# 先修改 SKILL.md 中的 version 字段，然后：
git tag v1.0.19
git push origin v1.0.19
```

## 注意事项

- 本仓库是纯 Markdown 文档仓库，不包含可执行代码
- `a2hmarket-cli` 二进制由独立的 a2hmarket-cli 仓库构建和发布
- 修改 Playbook 内容后需确保场景流程的完整性和一致性
- 修改 commands.md 需与 a2hmarket-cli 的实际实现保持同步
