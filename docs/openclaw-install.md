# OpenClaw PPT Agent AI 安装引导

## 执行摘要

本文档不是给普通终端用户看的简略说明，而是给 **AI 安装执行者** 使用的完整 runbook。
目标是让 AI 按固定顺序完成以下两件事：

1. 安装配套仓库 `ppt-master`
2. 将当前仓库注册为 OpenClaw agent workspace

其中：

- `ppt-master` 官方仓库地址：`https://github.com/funenc-lab/ppt-master`
- 当前仓库负责 OpenClaw agent workspace 本身
- `scripts/install_openclaw_agent.sh` **不会** 自动克隆或安装 `ppt-master`
- 因此，AI 不应跳过 `ppt-master` 安装步骤

## 文档定位

当 AI 按本文档执行安装时，应把自己视为“受控执行器”，而不是自由发挥的助手。
这意味着：

- 必须按顺序执行，不跳步
- 每一步失败都要立刻停止并汇报
- 必须区分“官方事实”和“本地建议”
- 必须记录最终使用的绝对路径
- 在完成前必须执行验证命令，不能只根据代码变更推断成功

## 事实、假设与建议

### 已确认事实

以下内容来自当前仓库脚本和 `ppt-master` 官方仓库：

- 当前仓库安装脚本会先校验 workspace，再校验 `ppt-master` companion repo 的路径、origin 和 `requirements.txt`，然后检查 `Node.js 22+`，按需安装 `openclaw`，最后注册 agent workspace
- `ppt-master` 官方 README 当前给出的最低安装前提是：`Python 3.8+`
- `ppt-master` 官方 README 当前给出的依赖安装命令是：`pip install -r requirements.txt`
- `funenc-lab/ppt-master` 的 Git clone 地址当前可用

### 安装假设

执行本文档时，默认采用以下假设：

- 当前 shell 具备 `git`、`python3`、`pip`、`node`、`npm`
- 当前仓库已经存在于本地，且当前工作目录就是本仓库根目录
- 安装执行者有网络访问能力，可以访问 GitHub 与 npm
- 如果用户没有提供 `ppt-master` 安装目录，则把它放在当前仓库的同级目录

### 本地建议

以下是为了让 AI 执行更稳妥而增加的建议，不是 `ppt-master` 官方 README 的硬性要求：

- 优先把 `ppt-master` 安装在当前仓库同级目录，便于后续定位
- 如果用户没有特别要求，AI 应先尝试复用已有仓库，再决定是否重新 clone
- 如果发现已有 `ppt-master` 仓库的远程地址不是 `funenc-lab/ppt-master`，应先停下来汇报，而不是擅自覆盖

## 安装目标

安装完成后，应满足以下状态：

- 当前仓库仍位于其原始路径
- 同级目录存在 `ppt-master` 仓库，且来源为 `https://github.com/funenc-lab/ppt-master.git`
- `ppt-master` 依赖安装命令执行成功
- 当前仓库的 `./scripts/validate_workspace.sh` 执行通过
- 当前仓库的 `./tests/test_workspace_structure.sh` 执行通过
- `openclaw agents list` 中可以看到当前 agent

## 输出目录规范

除非用户明确指定其他路径，AI 在当前 workspace 中应统一使用 `outputs/` 作为生成物根目录。

推荐目录结构：

- `outputs/decks/`
  - 存放 slide blueprint、改写后的 deck 文案、结构化大纲等 deck 主产物
- `outputs/reviews/`
  - 存放 deck review、评分结果、问题清单、整改建议等审稿产物
- `outputs/speaker-notes/`
  - 存放讲稿、过渡语、强调点、Q&A 准备等讲述支持材料
- `outputs/assets/`
  - 存放导出的图片、图表、PDF、附件或其他演示相关资产
- `outputs/tmp/`
  - 存放可再生成的中间文件、草稿文件、临时转换文件

命名规则：

- 路径名与文件名使用英文，不使用中文
- 优先使用小写加连字符的命名方式
- 每个任务放在自己的目录中，推荐格式为 `YYYY-MM-DD-topic-slug`
- 除非用户明确要求，否则不要把生成物直接写到仓库根目录
- 除非任务本身就是在改文档或代码，否则不要把生成物写入 `docs/`、`scripts/`、`skills/`

版本控制规则：

- `outputs/` 目录下的内容默认视为生成物，不应作为稳定源码提交
- AI 在安装完成后可以初始化这些目录，但不应把它们当成核心安装成功条件

示例：

```text
outputs/
  decks/
    2026-03-08-quarterly-business-review/
  reviews/
    2026-03-08-board-deck-review/
  speaker-notes/
    2026-03-08-launch-talk-track/
  assets/
    2026-03-08-launch-figures/
  tmp/
    2026-03-08-import-scratch/
```

## AI 执行顺序

### 第 0 步：确定路径

AI 应先在当前仓库根目录中计算以下路径：

```bash
WORKSPACE_DIR=$(pwd)
PARENT_DIR=$(dirname "$WORKSPACE_DIR")
PPT_MASTER_DIR="${PARENT_DIR}/ppt-master"
```

然后在汇报中明确写出：

- 当前 workspace 路径
- 计划使用的 `ppt-master` 路径

如果用户已明确要求其他安装目录，应优先使用用户指定目录。

### 第 1 步：检查基础工具

AI 应先检查这些命令是否存在：

```bash
command -v git
command -v python3
command -v pip
command -v node
command -v npm
```

再检查关键版本：

```bash
python3 --version
node --version
npm --version
```

判定规则：

- `ppt-master` 需要 `Python 3.8+`
- 当前 workspace 的 OpenClaw 安装脚本要求 `Node.js 22+`

如果 `Node.js` 主版本号低于 `22`，AI 不应继续执行当前仓库安装脚本。
如果 `Python` 版本低于 `3.8`，AI 不应继续执行 `ppt-master` 安装。

### 第 2 步：安装或复用 `ppt-master`

先检查目标路径是否已有仓库：

```bash
if [ -d "$PPT_MASTER_DIR/.git" ]; then
  git -C "$PPT_MASTER_DIR" remote get-url origin
else
  git clone https://github.com/funenc-lab/ppt-master.git "$PPT_MASTER_DIR"
fi
```

执行规则：

- 如果目录不存在，则直接 clone
- 如果目录已存在且远程地址就是 `https://github.com/funenc-lab/ppt-master.git`，则可以复用
- 如果目录已存在但远程地址不是目标地址，应停止并汇报冲突

AI 不应在发现远程不一致时擅自删除目录或强制覆盖。

### 第 3 步：安装 `ppt-master` 依赖

根据 `ppt-master` 官方 README，最低依赖安装方式为：

```bash
cd "$PPT_MASTER_DIR"
python3 -m pip install -r requirements.txt
```

执行要求：

- 必须在 `ppt-master` 仓库根目录执行
- 必须使用成功退出码作为判定依据
- 如果命令失败，AI 必须保留原始报错并停止后续步骤

说明：

- 这里使用 `python3 -m pip` 是为了减少环境歧义
- 这属于对官方 `pip install -r requirements.txt` 的等价执行方式

### 第 4 步：返回当前 workspace 并校验结构

安装完 `ppt-master` 后，回到当前仓库：

```bash
cd "$WORKSPACE_DIR"
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
```

如果任一命令失败，AI 不应继续注册 agent。

### 第 5 步：安装并注册 OpenClaw agent workspace

确认结构校验通过后，执行：

```bash
./scripts/install_openclaw_agent.sh
```

如果用户提供了自定义 agent 名称，则执行：

```bash
./scripts/install_openclaw_agent.sh my-ppt-agent
```

如果 `ppt-master` 不在默认同级目录，可以显式指定：

```bash
PPT_MASTER_DIR=/absolute/path/to/ppt-master ./scripts/install_openclaw_agent.sh
```

如果你明确知道自己要绕过 companion preflight，可显式执行：

```bash
./scripts/install_openclaw_agent.sh --skip-companion-check my-ppt-agent
```

注意：`--skip-companion-check` 只应用于明确受控的例外场景，不应作为默认安装路径。

当前脚本内部会依次完成：

1. 调用 `./scripts/validate_workspace.sh`
2. 校验 `ppt-master` companion repo 的路径、origin 和 `requirements.txt`
3. 检查 `Node.js 22+`
4. 如缺失则执行 `npm install -g openclaw@latest`
5. 检查 agent 是否已经注册
6. 注册当前仓库为 OpenClaw workspace

AI 不需要重复实现这些逻辑，但必须知道脚本**不会**自动 clone `ppt-master`，也**不会**自动安装其 Python 依赖。脚本现在只负责在 companion repo 缺失或配置错误时尽早失败。

### 第 6 步：安装后验证

注册后，必须执行以下命令验证最终结果：

```bash
openclaw agents list
```

推荐继续执行：

```bash
openclaw onboard --install-daemon
```

如果用户希望长期运行该 agent，这一步通常值得保留在建议动作中。

### 第 7 步：初始化输出目录（推荐）

安装成功后，AI 可以初始化标准输出目录：

```bash
mkdir -p \
  "$WORKSPACE_DIR/outputs/decks" \
  "$WORKSPACE_DIR/outputs/reviews" \
  "$WORKSPACE_DIR/outputs/speaker-notes" \
  "$WORKSPACE_DIR/outputs/assets" \
  "$WORKSPACE_DIR/outputs/tmp"
```

说明：

- 这一步是推荐动作，不是安装成功的硬条件
- 如果用户指定了其他输出路径，应优先遵循用户要求
- 如果当前任务只是安装，不需要立即生成任何 deck 产物，也可以只记录目录规范而不创建目录

## 当前仓库文件职责

### 根目录 prompt 文件

- `AGENTS.md`
  - 主规则文件
  - 定义默认语言、输出契约、审稿标准、技能选择规则、heartbeat 行为与 progress reporting 规则

- `SOUL.md`
  - 定义 agent 的人格与表达风格

- `TOOLS.md`
  - 定义工具使用规则、验证边界和 heartbeat 安全约束

- `USER.md`
  - 定义用户偏好，例如默认中文、先摘要后细节

- `IDENTITY.md`
  - 定义 agent 名称、角色、领域定位和工作原则

- `HEARTBEAT.md`
  - 定义主动提醒的最小触发条件
  - 在无需提醒时必须返回 `HEARTBEAT_OK`

### 技能文件

- `skills/presentation-workflow/SKILL.md`
  - 负责创建、审稿、改写、转换等演示工作流入口

- `skills/ppt-generation/SKILL.md`
  - 负责从原始资料生成 message-first deck blueprint

- `skills/ppt-review/SKILL.md`
  - 负责结构化审稿与问题优先级排序

- `skills/speaker-notes/SKILL.md`
  - 负责讲稿、过渡语、强调点和可能问答

- `skills/deck-polish/SKILL.md`
  - 负责表达收紧、标题强化与高管化润色

### 运维脚本

- `scripts/install_openclaw_agent.sh`
  - 校验 workspace
  - 校验 `ppt-master` companion repo
  - 检查 `Node.js 22+`
  - 按需安装 `openclaw`
  - 注册当前仓库为 agent workspace

- `scripts/validate_workspace.sh`
  - 检查必需文件是否存在
  - 检查 `HEARTBEAT.md`、progress reporting 等关键约束是否被写入

- `tests/test_workspace_structure.sh`
  - 做一次轻量结构回归检查

## HEARTBEAT 与 Progress Reporting 说明

### HEARTBEAT

`HEARTBEAT.md` 的目标不是增加打扰频率，而是约束主动行为的边界：

- 没有明确 follow-up 需求时，返回 `HEARTBEAT_OK`
- 只有临近交付、用户要求提醒、或缺少关键输入时才允许主动提醒
- 主动提醒必须短、明确、低噪音

### Progress Reporting

当前 workspace 明确要求：

- 对多步骤 PPT 任务进行阶段性 progress 汇报
- 汇报内容至少包含：已完成阶段、当前阶段、下一阶段、阻塞项（如有）
- 这项约束同样适用于 AI 在较长安装或配置任务中的进度汇报

## AI 完成判定

只有同时满足以下条件，AI 才能宣称安装完成：

- `ppt-master` 已存在于目标路径，且来源正确
- `python3 -m pip install -r requirements.txt` 已成功执行
- `./scripts/validate_workspace.sh` 已通过
- `./tests/test_workspace_structure.sh` 已通过
- `openclaw agents list` 能看到目标 agent，或安装脚本明确报告已存在同名 agent

如果缺少其中任意一项，AI 只能报告“已完成部分步骤”，不能报告“安装完成”。

## 常见问题与处理原则

### 1. `ppt-master` 目录已存在，但远程地址不一致

处理原则：停止并汇报，不覆盖，不删除，不强行改 remote。

### 2. `python3 -m pip install -r requirements.txt` 失败

处理原则：保留完整错误输出，停止继续安装当前 workspace。
原因可能包括：

- 网络不可达
- Python 版本不兼容
- 本地编译依赖缺失
- pip 配置异常

### 3. `Node.js` 版本低于 `22`

处理原则：停止执行 `./scripts/install_openclaw_agent.sh`，先升级 Node.js。

### 4. `npm install -g openclaw@latest` 失败

处理原则：保留完整错误输出，停止注册流程。

### 5. 结构校验失败

优先检查：

- `AGENTS.md`
- `HEARTBEAT.md`
- `skills/presentation-workflow/SKILL.md`
- `skills/ppt-generation/SKILL.md`
- `skills/ppt-review/SKILL.md`
- `docs/openclaw-install.md`
- `scripts/install_openclaw_agent.sh`

## 推荐汇报模板

当 AI 按本文档执行安装时，推荐输出如下结构：

1. 已确认环境与路径
2. `ppt-master` 安装状态
3. 当前 workspace 校验状态
4. OpenClaw agent 注册状态
5. 剩余风险或阻塞

## 结论

对 AI 来说，正确顺序不是“直接运行 `./scripts/install_openclaw_agent.sh`”，而是：

1. 先确认环境
2. 先安装 `ppt-master`
3. 再校验当前 workspace
4. 最后注册 OpenClaw agent

如果 AI 跳过第 2 步，那么当前安装流程就是不完整的。
