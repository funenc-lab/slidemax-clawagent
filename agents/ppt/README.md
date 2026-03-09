# PPT OpenClaw Agent Workspace Source

This directory is the source workspace for the PPT OpenClaw agent.

It is part of the Git repository source tree.
It is not the final OpenClaw runtime workspace directory and it is not the SlideMax companion application.

## Source vs Runtime

Source paths in this repository:

- repository root: `REPO_DIR`
- source workspace root: `SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"`

Default runtime installation paths:

- installed workspace root: `INSTALL_WORKSPACE_DIR="$HOME/.openclaw/workspace-ppt"`
- installed agent data root: `INSTALL_AGENT_DIR="$HOME/.openclaw/agents/ppt/agent"`

The final `slidemax_workflow` skill must be copy-installed into:

- `INSTALL_WORKSPACE_DIR/skills/slidemax_workflow`

Do not treat this source directory as the final installed runtime workspace.
Use `../../docs/openclaw-install.md` for installation and update flows.
