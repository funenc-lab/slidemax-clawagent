# workspace-ppt

This directory is the complete OpenClaw PPT workspace.

Workspace role:

- prompt layer for PPT planning, review, generation, delivery, and heartbeat behavior
- local skill surface for presentation workflows and delivery workflows
- local validation and completion-gate scripts for workspace quality checks

Path contract:

- repository root: `REPO_DIR`
- workspace root: `WORKSPACE_DIR="$REPO_DIR/workspace-ppt"`
- agent directory: `AGENT_DIR="$REPO_DIR/agents/ppt"`
- repository install runbook: `REPO_DIR/docs/openclaw-install.md`

Use this directory as the `--workspace` target when registering the OpenClaw agent.

Quick validation:

```bash
bash scripts/validate_workspace.sh
bash tests/test_workspace_structure.sh
```
