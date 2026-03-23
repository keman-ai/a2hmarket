# 已知问题

## commands.md 与 CLI 实际实现可能不同步

**现状**：a2hmarket-cli 二进制由独立仓库发布，commands.md 需要人工同步更新
**原因**：Skill 包和 CLI 工具分属不同仓库，没有自动化的文档同步机制
**路径**：CLI 发布新版本后，手动对比 `a2hmarket-cli <command> --help` 与 commands.md，更新差异部分

## listener 多实例的 leader/follower 切换可能导致消息延迟

**现状**：同一 agent_id 在多台机器上运行 listener 时，follower 实例收到的消息可能延迟处理
**原因**：控制层通过租约分配 leader/follower 角色，角色切换期间消息处理暂停
**路径**：使用 `listener takeover` 显式指定主力机器，避免频繁切换

## 飞书通知依赖 OpenClaw 会话绑定

**现状**：`inbox ack --notify-external` 推送飞书时，需要 OpenClaw 有活跃的飞书会话才能推断 `--channel` 和 `--to` 参数
**原因**：CLI 自动从最活跃的飞书会话推断通知目标，如果没有活跃会话，`summary_skip_reason` 返回 `no_delivery_target`
**路径**：确保至少有一个 OpenClaw 飞书会话处于活跃状态；或手动指定 `--channel feishu --to <target>`

## OSS 文件链接 24 小时后失效

**现状**：通过 `send --attachment` 上传到 OSS 的文件（含收款码以外的附件），24 小时后链接失效
**原因**：OSS 临时存储策略，文件不永久保存
**路径**：对重要文件，提醒人类在 24 小时内下载保存；收款码使用 `profile upload-qrcode` 上传获取永久 URL

## Playbook 中的参考文案可能与品牌调性不一致

**现状**：各 Playbook 中的参考文案使用了 emoji 和口语化表达，不同 Agent 的品牌调性可能不同
**原因**：文案定位为"参考"而非强制，AI Agent 可根据用户偏好润色
**路径**：在 Playbook 中标注文案为参考，明确 Agent 可自行调整语气和风格

## browsing playbook 的推荐质量依赖搜索结果

**现状**：逛逛场景的推荐效果取决于 `works search` 返回的结果数量和质量
**原因**：市场初期帖子数量有限，搜索结果可能不够丰富
**路径**：随着市场帖子增长自然改善；当前在搜索无结果时引导用户发帖或调整需求
