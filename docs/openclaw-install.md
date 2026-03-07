# OpenClaw PPT Agent 安装说明

本仓库已经按 OpenClaw 官方 PI 文档中的 agent workspace 结构进行了整理，核心文件包括：

- `AGENTS.md`
- `SOUL.md`
- `TOOLS.md`
- `USER.md`
- `IDENTITY.md`
- `HEARTBEAT.md`
- `skills/presentation-workflow/SKILL.md`
- `skills/ppt-generation/SKILL.md`
- `skills/ppt-review/SKILL.md`
- `skills/speaker-notes/SKILL.md`
- `skills/deck-polish/SKILL.md`

## 设计说明

- 这个 agent 被定位为一个 **PPT / 演示文稿专用 agent**。
- 根目录的 prompt 文件负责定义人格、工作方式、输出风格与工具使用规范。
- `HEARTBEAT.md` 负责定义周期性检查时的最小主动行为，避免 agent 在无人值守时产生噪音。
- `presentation-workflow` 负责统筹任务入口。
- `ppt-generation`、`ppt-review`、`speaker-notes`、`deck-polish` 提供更强的专用能力。
- `scripts/install_openclaw_agent.sh` 负责检查环境、安装 OpenClaw CLI（若缺失）并注册当前仓库为一个 OpenClaw agent workspace。

## 规则分层

- `AGENTS.md`：主规则、输出契约、审稿标准、技能选择规则、心跳行为约束
- `SOUL.md`：人格与风格
- `TOOLS.md`：工具使用规则与 heartbeat 安全边界
- `HEARTBEAT.md`：定时检查时的最小触发条件与响应格式
- `presentation-workflow`：总工作流
- `ppt-generation`：从资料生成 deck 结构
- `ppt-review`：结构化审稿
- `speaker-notes`：讲稿与问答
- `deck-polish`：标题压缩、措辞强化、老板风格化

## 假设

- 当前机器已经安装 `Node.js 22+`。
- 你希望把当前仓库路径作为 OpenClaw agent workspace。
- 你希望这个 agent 具备“低噪音、可长期运行”的主动检查能力。
- 你希望这个 agent 不只是基础结构，而是具备更强的 PPT 生产能力。
- 你接受默认 agent 名称为 `ppt-agents`，或者可在安装时传入自定义名称。

## 安装方式

在仓库根目录执行：

```bash
./scripts/install_openclaw_agent.sh
```

如果你想指定 agent 名称：

```bash
./scripts/install_openclaw_agent.sh my-ppt-agent
```

## 验证方式

先验证工作区结构：

```bash
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
```

如果 `OpenClaw CLI` 尚未安装，安装脚本会自动执行：

```bash
npm install -g openclaw@latest
```

然后会执行工作区注册命令：

```bash
openclaw agents add <agent-name> --workspace <repo-path>
```

## 关于 HEARTBEAT.md

`HEARTBEAT.md` 不是为了让 agent 频繁打扰用户，而是为了定义“什么时候值得主动提醒”。
当前实现遵循以下原则：

- 没有明确需要提醒的事项时，返回 `HEARTBEAT_OK`
- 只有在临近交付、用户明确要求 follow-up、或者被关键输入阻塞时才主动提醒
- 主动提醒必须简短、明确、低噪音

## 后续扩展建议

- 增加与真实 `.pptx` 文件操作相关的能力。
- 增加行业模板库，例如销售方案、融资路演、项目周报、技术评审。
- 结合具体渠道绑定与模型配置，把这个 agent 升级成真正长期运行的生产 agent。
