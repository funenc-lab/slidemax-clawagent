#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
DEFAULT_PPT_MASTER_DIR=$(cd "$WORKSPACE_DIR/.." && pwd)/ppt-master
DEFAULT_AGENT_NAME=ppt-agents
CANONICAL_PPT_MASTER_REPO=funenc-lab/slidemax
LEGACY_PPT_MASTER_REPO=funenc-lab/ppt-master

AGENT_NAME=$DEFAULT_AGENT_NAME
PPT_MASTER_DIR=${PPT_MASTER_DIR:-$DEFAULT_PPT_MASTER_DIR}
SKIP_COMPANION_CHECK=0

usage() {
  cat <<EOF_USAGE
Usage: $(basename "$0") [--skip-companion-check] [--ppt-master-dir PATH] [agent-name]

Options:
  --skip-companion-check  Skip ppt-master repository preflight validation.
  --ppt-master-dir PATH   Override the companion repository path.
  -h, --help              Show this help message.
EOF_USAGE
}

parse_args() {
  local positional_count=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-companion-check)
        SKIP_COMPANION_CHECK=1
        ;;
      --ppt-master-dir)
        if [[ $# -lt 2 ]]; then
          echo "Missing value for --ppt-master-dir." >&2
          exit 1
        fi
        PPT_MASTER_DIR=$2
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 1
        ;;
      *)
        if [[ "$positional_count" -gt 0 ]]; then
          echo "Only one agent name may be provided." >&2
          usage >&2
          exit 1
        fi
        AGENT_NAME=$1
        positional_count=1
        ;;
    esac
    shift
  done

  if [[ $# -gt 0 ]]; then
    echo "Unexpected extra argument: $1" >&2
    usage >&2
    exit 1
  fi
}

require_command() {
  local command_name=$1
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 1
  fi
}

normalize_github_remote() {
  local remote_url=$1

  remote_url=${remote_url#https://github.com/}
  remote_url=${remote_url#http://github.com/}
  remote_url=${remote_url#git@github.com:}
  remote_url=${remote_url#ssh://git@github.com/}

  printf '%s' "$remote_url"
}

is_expected_ppt_master_remote() {
  local normalized_remote
  normalized_remote=$(normalize_github_remote "$1")

  [[ "$normalized_remote" == "$CANONICAL_PPT_MASTER_REPO" ||
     "$normalized_remote" == "$CANONICAL_PPT_MASTER_REPO.git" ||
     "$normalized_remote" == "$LEGACY_PPT_MASTER_REPO" ||
     "$normalized_remote" == "$LEGACY_PPT_MASTER_REPO.git" ]]
}

ensure_companion_repository() {
  local origin_url

  if [[ "$SKIP_COMPANION_CHECK" -eq 1 ]]; then
    echo "Skipping ppt-master companion validation for: $PPT_MASTER_DIR"
    return 0
  fi

  if [[ ! -d "$PPT_MASTER_DIR/.git" ]]; then
    echo "ppt-master companion repository is missing: $PPT_MASTER_DIR" >&2
    echo "Clone https://github.com/funenc-lab/slidemax.git or pass --skip-companion-check to bypass this preflight intentionally." >&2
    exit 1
  fi

  require_command git

  if ! origin_url=$(git -C "$PPT_MASTER_DIR" remote get-url origin 2>/dev/null); then
    echo "ppt-master companion repository is missing an origin remote: $PPT_MASTER_DIR" >&2
    exit 1
  fi

  if ! is_expected_ppt_master_remote "$origin_url"; then
    echo "ppt-master companion repository origin does not match funenc-lab/slidemax or the legacy funenc-lab/ppt-master: $origin_url" >&2
    exit 1
  fi

  if [[ ! -f "$PPT_MASTER_DIR/requirements.txt" ]]; then
    echo "ppt-master companion repository is missing requirements.txt: $PPT_MASTER_DIR" >&2
    exit 1
  fi

  echo "Validated ppt-master companion repository: $PPT_MASTER_DIR"
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

agent_exists() {
  local raw_output status=0

  raw_output=$(openclaw agents list --json)
  AGENT_LIST_JSON="$raw_output" node -e '
    const raw = process.env.AGENT_LIST_JSON ?? "";
    const targetId = process.argv[1];

    try {
      const agents = raw.trim() ? JSON.parse(raw) : [];
      process.exit(agents.some((agent) => agent.id === targetId) ? 0 : 1);
    } catch (error) {
      console.error(`Unable to parse OpenClaw agent list JSON: ${error.message}`);
      process.exit(2);
    }
  ' "$AGENT_NAME" || status=$?

  if [[ "$status" -eq 2 ]]; then
    exit 1
  fi

  return "$status"
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
  parse_args "$@"
  "$SCRIPT_DIR/validate_workspace.sh"
  ensure_companion_repository
  ensure_node_version
  ensure_openclaw
  register_agent

  echo
  echo "OpenClaw agent installed successfully."
  echo "Agent name: $AGENT_NAME"
  echo "Workspace: $WORKSPACE_DIR"
  echo "Companion repository: $PPT_MASTER_DIR"
  echo
  echo "Recommended next steps:"
  echo "  openclaw agents list"
  echo "  openclaw onboard --install-daemon"
}

main "$@"
