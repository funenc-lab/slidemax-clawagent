# slidemax-clawagent

This repository hosts the PPT OpenClaw workspace at `workspace-ppt/` and the matching agent data directory at `agents/ppt/`.

## Primary Workspace

- `workspace-ppt/`: complete PPT-focused OpenClaw workspace for narrative design, deck generation, review, speaker notes, and delivery workflows
- `agents/ppt/`: agent-side data directory for PPT runtime state and future agent-local data

## Repository Role

This repository is the primary human and AI entry point.
It is the repository root for checkout, installation guidance, validation entry, and OpenClaw workspace registration.

This repository is not the SlideMax companion application and it is not the OpenClaw runtime.

## Primary Entry

- Repository root: the local `slidemax-clawagent` checkout
- OpenClaw workspace root: `workspace-ppt`
- Agent data root: `agents/ppt`
- AI install prompt file: `docs/openclaw-install.md`
- Workspace validation: `workspace-ppt/scripts/validate_workspace.sh`
- Workspace structure test: `workspace-ppt/tests/test_workspace_structure.sh`

## Installation Contract

- Treat the repository root as `REPO_DIR`.
- Treat the PPT workspace root as `WORKSPACE_DIR="$REPO_DIR/workspace-ppt"`.
- Treat the PPT agent data root as `AGENT_DIR="$REPO_DIR/agents/ppt"`, which is the OpenClaw `agentDir` for this agent.
- Use `REPO_DIR/docs/openclaw-install.md` as the project installation and update prompt file.
- Register `workspace-ppt` as the OpenClaw workspace and `agents/ppt` as the OpenClaw `agentDir`.
- Install the SlideMax companion repository before registering the workspace with OpenClaw.
- The runtime companion workflow is sourced from `SLIDEMAX_DIR/skills/slidemax_workflow`.
- The runtime skill must be copied and installed into the workspace at `skills/slidemax_workflow/SKILL.md`.
- Final delivery helpers live at `skills/final-document-delivery/SKILL.md` and `skills/message-channel-delivery/SKILL.md`.
- Use `~/.openclaw/.env` only as a machine-wide fallback when per-skill env injection is not sufficient.

## Human Quick Start

```bash
cd workspace-ppt
bash scripts/validate_workspace.sh
bash tests/test_workspace_structure.sh
```

Use the root `README.md` as the main repository entry.
Use `docs/openclaw-install.md` as the installation and update prompt file for human or AI-driven setup.

## AI Install Prompt

Use one of the following single-line prompts with your AI coding agent.

Local prompt:

```text
Please use <repo_root>/docs/openclaw-install.md to install or update this agent. That file is the project's installation and update prompt file. Treat <repo_root> as the repository root, treat <repo_root>/workspace-ppt as the workspace root, treat <repo_root>/agents/ppt as the agent data root, follow the file exactly, and report the workspace path, agent data path, SlideMax path, validation results, agent registration status, and any blocker.
```

Remote prompt:

```text
Please use https://raw.githubusercontent.com/funenc-lab/slidemax-clawagent/main/docs/openclaw-install.md to install or update this agent. That URL is the project's installation and update prompt file. Use the local repository checkout as the repository root, use its `workspace-ppt` directory as the workspace root, use its `agents/ppt` directory as the agent data root, follow the file exactly, and report the workspace path, agent data path, SlideMax path, validation results, agent registration status, and any blocker.
```

## Validation and Delivery Contract

- Run `workspace-ppt/scripts/validate_workspace.sh` and `workspace-ppt/tests/test_workspace_structure.sh` after installation or workspace changes.
- Use `workspace-ppt/scripts/check_final_delivery_gate.sh` as the canonical runtime completion contract for final deliverables.
- Prefer a final delivery destination such as a Judao final document or a Feishu document.
- Completion messages must include `Delivery status`.

## Repository Maintenance

- When new OpenClaw workspaces or agent data directories are added, extend this root `README.md` as the primary repository index and installation entry.
- Keep installation guidance in `docs/`, keep workspace prompt layers in dedicated workspace directories such as `workspace-ppt/`, and keep agent-local runtime data under `agents/<agent>/`.
