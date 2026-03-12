# slidemax-clawagent

This repository hosts OpenClaw agent workspaces under `agents/`.

## Source Workspace

- `agents/ppt/`: source PPT workspace for narrative design, deck generation, review, speaker notes, and delivery workflows

## Repository Role

This repository is the primary human and AI entry point.
It is the repository root for checkout, installation guidance, validation entry, and source workspace updates.

This repository is not the SlideMax companion application and it is not the OpenClaw runtime.

Canonical repositories:

- SlideMax companion repository: `https://github.com/funenc-lab/slidemax`
- OpenClaw workspace repository: `https://github.com/funenc-lab/slidemax-clawagent`

## Primary Entry

- Repository root: the local `slidemax-clawagent` checkout
- Source workspace root: `agents/ppt`
- AI install prompt entry file: `docs/openclaw-install.md`
- Fresh install runbook: `docs/openclaw-install-fresh.md`
- Update runbook: `docs/openclaw-update.md`
- Workspace validation: `scripts/validate_workspace.sh`
- Workspace structure test: `tests/test_workspace_structure.sh`

The entry file `docs/openclaw-install.md` is the only external prompt target.
It detects local state first, then routes to the fresh-install or update runbook.

## Installation Contract

- Treat the repository root as `REPO_DIR`.
- Treat the source PPT workspace root as `SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"`.
- Treat the default installed OpenClaw workspace root as `INSTALL_WORKSPACE_DIR="$HOME/.openclaw/workspace-ppt"`.
- Treat the default installed OpenClaw agent data root as `INSTALL_AGENT_DIR="$HOME/.openclaw/agents/ppt/agent"`.
- Use `REPO_DIR/docs/openclaw-install.md` as the project installation and update prompt file.
- Treat `SOURCE_WORKSPACE_DIR` as repository source only, not as the final OpenClaw runtime workspace.
- Do not register `agents/ppt` directly as the final OpenClaw runtime workspace.
- Install or update the runtime workspace from this source workspace according to `docs/openclaw-install.md`.
- Install the SlideMax companion repository before registering the workspace with OpenClaw.
- The runtime companion workflow is sourced from `SLIDEMAX_DIR/skills/slidemax_workflow`.
- The runtime skill must be copied into the installed workspace at `skills/slidemax_workflow/SKILL.md`.
- Final delivery helpers live at `skills/final-document-delivery/SKILL.md` and `skills/message-channel-delivery/SKILL.md`.
- Use `~/.openclaw/.env` only as a machine-wide fallback when per-skill env injection is not sufficient.

## Human Quick Start

```bash
bash scripts/validate_workspace.sh
bash tests/test_workspace_structure.sh
```

Use the root `README.md` as the main repository entry.
Use `docs/openclaw-install.md` as the installation and update prompt file for human or AI-driven setup.

## AI Install Prompt

Use this single prompt with your AI coding agent:

```text
Use https://raw.githubusercontent.com/funenc-lab/slidemax-clawagent/main/docs/openclaw-install.md to install or update this agent. Use the local checkout as repo root, use `agents/ppt` only as the source workspace, follow the file exactly, and report the installed workspace path, installed agentDir path, SlideMax path, validation results, registration status, and any blocker.
```

## Validation and Delivery Contract

- Run `bash scripts/validate_workspace.sh` and `bash tests/test_workspace_structure.sh` after installation or workspace changes.
- Use `agents/ppt/scripts/check_final_delivery_gate.sh` as the canonical runtime completion contract for final deliverables.
- Prefer a final delivery destination such as a Judao final document or a Feishu document.
- If the final delivery ecosystem is Feishu, the final destination must be a Feishu document.
- Do not treat a Feishu chat or group as the final PPT delivery destination.
- If a Feishu message handoff is requested, the final handoff should be a Feishu online document link message after the Feishu document is ready.
- Completion messages must include `Delivery status`.

## Repository Maintenance

- When new source workspaces are added under `agents/`, extend this root `README.md` as the primary repository index and installation entry.
- Keep installation guidance in `docs/` and keep source workspace files under `agents/<workspace>/`.
