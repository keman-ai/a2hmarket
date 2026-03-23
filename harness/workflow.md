# 工作流 - a2hmarket Skill 包端到端协作流程

## 原则

a2hmarket 是纯 Markdown 的 Skill 包，定义了 AI Agent 在 A2H 交易市场中的操作剧本。开发工作主要是文档编写和维护，必须确保 Playbook 流程的完整性、命令参考的准确性，以及与 a2hmarket-cli 实际实现的一致性。

## 场景路由

| 场景 | 查看 |
|------|------|
| 项目元信息与组件清单 | [registry.yaml](registry.yaml) |
| 架构约束和不变量 | [docs/arch/invariants.md](docs/arch/invariants.md) |
| 系统边界和依赖规则 | [docs/arch/boundaries.md](docs/arch/boundaries.md) |
| 产品概览 | [docs/pm/product-overview.md](docs/pm/product-overview.md) |
| 开发规范 | [docs/rd/dev-conventions.md](docs/rd/dev-conventions.md) |
| 常见陷阱 | [docs/rd/pitfalls.md](docs/rd/pitfalls.md) |
| 提交前检查 | [docs/qa/quality-checklist.md](docs/qa/quality-checklist.md) |

## 新增/修改 Playbook 流程

```
需求（新增或修改业务场景的操作剧本）
    |
    v
产品经理：定义场景触发条件、用户交互流程、关键决策点
    |
    v
架构师：评审 Playbook 与现有场景的边界、路由一致性
    |
    v
开发者：编写/修改 Playbook Markdown
    |-- 确保流程步骤完整（从触发到结束）
    |-- 确保引用的 CLI 命令与 commands.md 一致
    |-- 确保场景路由表（SKILL.md）更新
    |
    v
代码评审员：检查流程完整性、命令准确性、人类确认点覆盖
    |-- Commit message 必须使用英文（release notes 从 commit 自动生成）
    |
    v
运行 bash scripts/lint-all.sh 验证
```

## CLI 命令文档同步流程

```
a2hmarket-cli 发布新版本（新增/修改命令）
    |
    v
开发者：更新 references/commands.md
    |-- 新增命令的用法、参数、输出字段
    |-- 修改已有命令的参数或行为描述
    |
    v
开发者：检查所有 Playbook 中引用的命令是否仍然正确
    |
    v
代码评审员：对比 CLI --help 输出与文档描述
    |
    v
更新 SKILL.md 中的 version 字段
    |
    v
运行 bash scripts/lint-all.sh 验证
```

## 版本发布流程

```
确认所有文档变更已合入 main
    |
    v
修改 SKILL.md frontmatter 中的 version 字段
    |
    v
git tag v{version}
    |
    v
git push origin v{version}
    |
    v
GitHub Actions 自动打包 zip 并发布到 Release
```

> **强制规则：文档变更合入 main 后必须立即打 tag 触发 Release。**
> 用户和 AI Agent 通过 GitHub Release 获取最新 Skill 包，若不打 tag 则变更无法到达。
> 版本号规则：除非特殊指定，否则只递增最后一位（patch），例如 `1.0.18` → `1.0.19`。
> tag 版本必须与 SKILL.md frontmatter 中的 `version` 字段一致（同时更新 `harness/registry.yaml`）。

## 检查点

每次变更后，执行 `bash scripts/lint-all.sh` 确保：
1. SKILL.md 存在且 frontmatter 包含必要字段
2. 所有 Playbook 文件存在
3. commands.md 存在
4. AGENTS.md 中引用的所有文件存在
5. Playbook 中引用的命令在 commands.md 中有对应章节

## 知识归档

| 变更内容 | 更新位置 |
|---------|---------|
| 新增场景/Playbook | SKILL.md 场景路由表 + `harness/registry.yaml` |
| CLI 命令变更 | `references/commands.md` + 受影响的 Playbook |
| 架构决策 | `harness/docs/arch/boundaries.md` 或 `invariants.md` |
| 发现新陷阱 | `harness/docs/rd/pitfalls.md` |
| 新约束 | `harness/docs/arch/invariants.md` |
| 已知问题 | `harness/docs/qa/known-issues.md` |
