# 开发者角色 - a2hmarket

## 角色职责

作为 a2hmarket Skill 包的开发者，你负责 Playbook 编写、命令文档维护和版本发布。

## 必读文档

1. `CLAUDE.md` -- 仓库结构与编码指南
2. `harness/docs/rd/dev-conventions.md` -- 开发规范
3. `harness/docs/rd/pitfalls.md` -- 常见陷阱
4. `harness/docs/arch/invariants.md` -- 架构约束

## 开发流程

### 1. 新增 Playbook

```
1. 在 references/playbooks/ 目录下创建新 Playbook 文件
2. 编写内容：
   - 角色定位（一句话）
   - 路径判断表（如有多条路径）
   - 分步流程（引用 commands.md 命令）
   - 人类确认节点（标注需确认的位置）
   - 参考文案（Markdown 引用块格式）
   - 流程全景图（Mermaid 时序图，如有）
3. 更新 SKILL.md 场景路由表
4. 更新 harness/registry.yaml 注册
5. 更新 AGENTS.md 文件结构表
6. 运行 bash scripts/lint-all.sh 验证
```

### 2. 修改现有 Playbook

```
1. 理解现有流程和场景路由关系
2. 修改 Playbook 内容：
   - 确保流程步骤完整
   - 确保引用的 CLI 命令正确
   - 确保人类确认节点完整
3. 检查修改是否影响其他 Playbook 的路由
4. 运行 bash scripts/lint-all.sh 验证
```

### 3. 同步 CLI 命令文档

```
1. 获取 a2hmarket-cli 最新版本的变更日志
2. 对比 commands.md 与 CLI --help 输出
3. 更新 commands.md：
   - 新增命令的用法、参数、输出字段
   - 修改已有命令的参数或行为描述
   - 更新错误参考表
4. 检查所有 Playbook 中引用的命令是否仍然正确
5. 运行 bash scripts/lint-all.sh 验证
```

### 4. 版本发布

```
1. 确认所有文档变更已合入 main
2. 修改 SKILL.md frontmatter 中的 version 字段
3. git tag v{version}
4. git push origin v{version}
5. 确认 GitHub Actions 成功打包并发布 Release
```

## 编写模板

### Playbook 骨架

```markdown
# 场景名称

> 触发条件说明
> 命令参考：[commands.md](../commands.md)

## 角色定位

你是用户的**角色名**，...

## 流程

### 步骤一：...

（操作说明，引用 CLI 命令）

### 步骤二：...

（需要人类确认的操作，标注确认节点）

## 交易流程全景图

（Mermaid 时序图）
```

### summary-text 模板

```
第一行：发生了什么（一句话概括）
中间：关键细节（价格、条件、时间等）
末尾：需要人类做什么（如果需要的话）
```

## 关键注意事项

1. **命令引用使用链接**：`[命令名](../commands.md#章节锚点)`
2. **人类确认用显眼标注**：使用 `⚠️` 或加粗标注确认节点
3. **参考文案用引用块**：`>` 格式，允许 emoji
4. **类型编号不要记混**：`type=2` 是需求帖，`type=3` 是服务帖
5. **价格单位注意分**：`--price-cent` 以分为单位

## 常用命令

```bash
# 质量检查
bash scripts/lint-all.sh

# 查看 Skill 版本
head -5 SKILL.md

# 发布新版本
git tag v1.0.19
git push origin v1.0.19
```
