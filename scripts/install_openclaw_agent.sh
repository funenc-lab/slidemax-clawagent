#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
AGENT_NAME=${1:-ppt-agents}

agent_exists() {
  openclaw agents list --json | node -e '
    const fs = require("fs");
    const raw = fs.readFileSync(0, "utf8").trim();
    const agents = raw ? JSON.parse(raw) : [];
    const targetId = process.argv[1];
    process.exit(agents.some((agent) => agent.id === targetId) ? 0 : 1);
  ' "$AGENT_NAME"
}

require_command() {
  local command_name=$1
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 1
  fi
}

ensure_node_version() {
  require_command node
  local node_major_version
  node_major_version=$(node -p 'process.versions.node.split(".")[0]')
  if [[ "$node_major_version" -lt 22 ]]; then
    echo "OpenClaw requires Node.js 22 or newer. Current major version: $node_major_version" >&2
    exit 1
  fi
}

ensure_openclaw() {
  if command -v openclaw >/dev/null 2>&1; then
    return 0
  fi

  require_command npm
  echo "Installing OpenClaw CLI globally..."
  npm install -g openclaw@latest
  hash -r

  if ! command -v openclaw >/dev/null 2>&1; then
    echo "OpenClaw CLI is still unavailable after installation." >&2
    exit 1
  fi
}

register_agent() {
  if agent_exists; then
    echo "OpenClaw agent already registered: $AGENT_NAME"
    return 0
  fi

  echo "Registering workspace with OpenClaw..."
  openclaw agents add "$AGENT_NAME" --workspace "$WORKSPACE_DIR" --non-interactive
}

main() {
  "$SCRIPT_DIR/validate_workspace.sh"
  ensure_node_version
  ensure_openclaw
  register_agent

  echo
  echo "OpenClaw agent installed successfully."
  echo "Agent name: $AGENT_NAME"
  echo "Workspace: $WORKSPACE_DIR"
  echo
  echo "Recommended next steps:"
  echo "  openclaw agents list"
  echo "  openclaw onboard --install-daemon"
}

main "$@"
