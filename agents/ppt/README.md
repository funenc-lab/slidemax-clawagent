# agents/ppt

This directory is the PPT agent-side data area.

Reserved uses:

- agent-local `.openclaw` state kept outside the workspace prompt layer
- future agent-specific runtime data that should not live inside `workspace-ppt`

Path contract:

- repository root: `REPO_DIR`
- workspace root: `REPO_DIR/workspace-ppt`
- agent directory: `REPO_DIR/agents/ppt` as the OpenClaw `agentDir`

Do not register this directory itself as the OpenClaw workspace.
Register `REPO_DIR/workspace-ppt` as `--workspace` and this directory as `--agent-dir`.
