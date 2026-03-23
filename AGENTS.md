# AGENTS.md - a2hmarket Skill 包 Agent 协作指南

## 项目概述

a2hmarket 是 A2H Market 的核心 Skill 包，将 FindU 平台的交易市场能力提供给外部 AI Agent 使用。AI Agent 通过 `a2hmarket-cli` 命令行工具代理人类在市场中进行买卖交易，包括摆摊出售、逛街代购、市场探索三大场景。

## Agent 角色定义

本项目支持以下 Agent 角色协作，各角色职责定义见 `harness/roles/` 目录：

| 角色 | 文件 | 核心职责 |
|------|------|---------|
| 产品经理 | `harness/roles/product-manager.md` | 场景定义、Playbook 设计、人机交互流程 |
| 架构师 | `harness/roles/architect.md` | Skill 架构设计、CLI-Playbook 分层守护 |
| 开发者 | `harness/roles/coder.md` | Playbook 编写、命令文档维护、版本发布 |
| 代码评审员 | `harness/roles/code-reviewer.md` | 文档准确性审查、命令参数校验 |
| 测试工程师 | `harness/roles/qa.md` | Playbook 流程验证、CLI 命令测试 |

## 工程入口

- 注册表：`harness/registry.yaml` -- 项目元信息与组件清单
- 工作流：`harness/workflow.md` -- 端到端协作流程
- 架构文档：`harness/docs/arch/` -- 架构与约束
- 产品文档：`harness/docs/pm/` -- 产品概述
- 研发文档：`harness/docs/rd/` -- 开发规范与陷阱
- 质量文档：`harness/docs/qa/` -- 质量检查清单与已知问题

## 文件结构

| 文件/目录 | 说明 |
|----------|------|
| `SKILL.md` | Skill 定义入口（含 frontmatter、核心概念、场景路由） |
| `references/commands.md` | a2hmarket-cli 全量命令参考 |
| `references/setup.md` | 安装/更新/卸载手册 |
| `references/inbox.md` | A2A 消息处理操作手册 |
| `references/playbooks/onboarding.md` | 安装后引导剧本 |
| `references/playbooks/stall.md` | 摆摊销售全流程 |
| `references/playbooks/shopping.md` | 逛街代购全流程 |
| `references/playbooks/browsing.md` | 逛逛探索流程 |
| `references/playbooks/negotiation.md` | 代理授权与协商策略 |
| `references/playbooks/reporting.md` | 汇报机制与周期管理 |
| `.github/workflows/release-markdown.yml` | GitHub Actions 发布工作流 |

## 关键约束

1. **CLI-First**：所有平台操作通过 `a2hmarket-cli` 命令执行，禁止 AI 直接拼 curl 或编写脚本调用
2. **人类确认守卫**：发帖（`--confirm-human-reviewed`）、订单确认、付款确认等关键操作必须人类确认后执行
3. **按需读取 Playbook**：不一次性读取所有 Playbook，只在进入对应场景时读取需要的那一个
4. **飞书通知为唯一可靠路径**：关键节点必须通过 `inbox ack --notify-external --summary-text` 推送到飞书

## 快速检查

```bash
# 质量检查
bash scripts/lint-all.sh
```
