#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
REPO_DIR=$(cd "$ROOT_DIR/../.." && pwd)

required_files=(
  "README.md"
  "AGENTS.md"
  "SOUL.md"
  "TOOLS.md"
  "USER.md"
  "IDENTITY.md"
  "HEARTBEAT.md"
  "skills/presentation-workflow/SKILL.md"
  "skills/ppt-generation/SKILL.md"
  "skills/ppt-review/SKILL.md"
  "skills/speaker-notes/SKILL.md"
  "skills/deck-polish/SKILL.md"
  "skills/final-document-delivery/SKILL.md"
  "skills/message-channel-delivery/SKILL.md"
  "scripts/check_final_delivery_gate.sh"
  "scripts/validate_workspace.sh"
  "tests/test_workspace_structure.sh"
  "tests/test_final_delivery_gate.sh"
)

missing=0

require_text() {
  local file_path=$1
  local expected_text=$2
  local label=$3
  if ! grep -Fq -- "$expected_text" "$file_path"; then
    echo "$label missing required text: $expected_text" >&2
    missing=1
  fi
}

forbid_text() {
  local file_path=$1
  local forbidden_text=$2
  local label=$3
  if grep -Fqi -- "$forbidden_text" "$file_path"; then
    echo "$label must not mention: $forbidden_text" >&2
    missing=1
  fi
}

if [[ "$(basename "$ROOT_DIR")" != "ppt" || "$(basename "$(dirname "$ROOT_DIR")")" != "agents" ]]; then
  echo "Workspace root must live under agents/ppt." >&2
  missing=1
fi

for relative_path in "${required_files[@]}"; do
  if [[ ! -f "$ROOT_DIR/$relative_path" ]]; then
    echo "Missing required file: $relative_path" >&2
    missing=1
  fi
done

if [[ -e "$ROOT_DIR/docs" ]]; then
  echo "Workspace root should not contain docs/; installation docs belong at the repository root." >&2
  missing=1
fi

for forbidden_repo_path in \
  ".openclaw" \
  "AGENTS.md" \
  "BOOTSTRAP.md" \
  "HEARTBEAT.md" \
  "IDENTITY.md" \
  "SOUL.md" \
  "TOOLS.md" \
  "USER.md" \
  "scripts" \
  "skills" \
  "tests"; do
  if [[ -e "$REPO_DIR/$forbidden_repo_path" ]]; then
    echo "Repository root should not contain workspace path: $forbidden_repo_path" >&2
    missing=1
  fi
done

for required_repo_path in "README.md" ".gitignore" "docs/openclaw-install.md"; do
  if [[ ! -e "$REPO_DIR/$required_repo_path" ]]; then
    echo "Repository root missing required file: $required_repo_path" >&2
    missing=1
  fi
done

if [[ -e "$ROOT_DIR/skills/slidemax-bridge" ]]; then
  echo "skills/slidemax-bridge should not exist; SlideMax must be acquired during installation." >&2
  missing=1
fi

if grep -Eq '^HEARTBEAT\.md$' "$ROOT_DIR/.gitignore"; then
  echo "HEARTBEAT.md must be committed to the repository." >&2
  missing=1
fi

if ! grep -Fq 'skills/slidemax_workflow' "$ROOT_DIR/.gitignore"; then
  echo "The runtime companion skill directory should be ignored via .gitignore." >&2
  missing=1
fi

heartbeat_size=$(wc -c < "$ROOT_DIR/HEARTBEAT.md" | tr -d ' ')
if [[ "$heartbeat_size" -gt 800 ]]; then
  echo "HEARTBEAT.md is too large and should remain tiny." >&2
  missing=1
fi

require_text "$ROOT_DIR/AGENTS.md" 'Select `slidemax-workflow` as the primary skill' 'AGENTS.md'
require_text "$ROOT_DIR/AGENTS.md" 'SLIDEMAX_DIR/skills/slidemax_workflow' 'AGENTS.md'
require_text "$ROOT_DIR/AGENTS.md" 'Delivery status' 'AGENTS.md'
require_text "$ROOT_DIR/AGENTS.md" 'scripts/check_final_delivery_gate.sh' 'AGENTS.md'

require_text "$ROOT_DIR/TOOLS.md" 'source OpenClaw workspace' 'TOOLS.md'
require_text "$ROOT_DIR/TOOLS.md" 'Copy-install that canonical skill into the final OpenClaw workspace at `skills/slidemax_workflow`.' 'TOOLS.md'
require_text "$ROOT_DIR/TOOLS.md" 'scripts/check_final_delivery_gate.sh' 'TOOLS.md'

require_text "$ROOT_DIR/IDENTITY.md" 'Primary Deck Generation Skill: slidemax-workflow' 'IDENTITY.md'
require_text "$ROOT_DIR/IDENTITY.md" 'SlideMax' 'IDENTITY.md'

for required_text in \
  'https://github.com/funenc-lab/slidemax' \
  'https://github.com/funenc-lab/slidemax-clawagent' \
  'SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"' \
  'INSTALL_WORKSPACE_DIR="$HOME/.openclaw/workspace-ppt"' \
  'INSTALL_AGENT_DIR="$HOME/.openclaw/agents/ppt/agent"' \
  'Do not register `agents/ppt` directly as the final OpenClaw runtime workspace.' \
  'The runtime skill must be copied into the installed workspace at `skills/slidemax_workflow/SKILL.md`.' \
  'installed workspace path' \
  'installed agentDir path' \
  'scripts/check_final_delivery_gate.sh' \
  'canonical runtime completion contract'; do
  require_text "$REPO_DIR/README.md" "$required_text" 'README.md'
done

for required_text in \
  'SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"' \
  'INSTALL_WORKSPACE_DIR="$HOME/.openclaw/workspace-ppt"' \
  'INSTALL_AGENT_DIR="$HOME/.openclaw/agents/ppt/agent"' \
  'INSTALL_WORKSPACE_DIR/skills/slidemax_workflow' \
  'Do not treat this source directory as the final installed runtime workspace.' \
  '../../docs/openclaw-install.md'; do
  require_text "$ROOT_DIR/README.md" "$required_text" 'Workspace README'
done

for required_text in \
  'https://github.com/funenc-lab/slidemax' \
  'https://github.com/funenc-lab/slidemax-clawagent' \
  'SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"' \
  'INSTALL_WORKSPACE_DIR="$HOME/.openclaw/workspace-ppt"' \
  'INSTALL_AGENT_DIR="$HOME/.openclaw/agents/ppt/agent"' \
  'The repository source tree is not the final OpenClaw runtime directory' \
  'copy the source workspace into the final OpenClaw runtime workspace' \
  'cp "$SOURCE_WORKSPACE_DIR/$managed_file" "$INSTALL_WORKSPACE_DIR/$managed_file"' \
  'cp -R "$SOURCE_WORKSPACE_DIR/scripts" "$INSTALL_WORKSPACE_DIR/scripts"' \
  'cp -R "$SOURCE_WORKSPACE_DIR/tests" "$INSTALL_WORKSPACE_DIR/tests"' \
  'cp -R "$SLIDEMAX_DIR/skills/slidemax_workflow" "$INSTALL_WORKSPACE_DIR/skills/slidemax_workflow"' \
  'INSTALL_WORKSPACE_DIR/skills/slidemax_workflow/SKILL.md' \
  'do not mount or symlink `INSTALL_WORKSPACE_DIR/skills/slidemax_workflow`' \
  'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' \
  '~/.openclaw/.env' \
  'openclaw agents add "$AGENT_ID" --workspace "$INSTALL_WORKSPACE_DIR" --agent-dir "$INSTALL_AGENT_DIR" --non-interactive' \
  'openclaw agents delete "$AGENT_ID"' \
  'openclaw agents list --json' \
  'bash scripts/validate_workspace.sh' \
  'bash tests/test_workspace_structure.sh' \
  'only copying managed source files' \
  'actual OpenClaw runtime target'; do
  require_text "$REPO_DIR/docs/openclaw-install.md" "$required_text" 'Install docs'
done

for forbidden_text in \
  'Register the PPT workspace at `agents/ppt` as an OpenClaw agent workspace' \
  'The repository root is `REPO_DIR`, and the OpenClaw workspace root is `WORKSPACE_DIR="$REPO_DIR/agents/ppt"`' \
  'ln -s "$SLIDEMAX_DIR/skills/slidemax_workflow" "$WORKSPACE_DIR/skills/slidemax_workflow"' \
  'workspace runtime link' \
  'already exists and is not a symlink'; do
  forbid_text "$REPO_DIR/docs/openclaw-install.md" "$forbidden_text" 'Install docs'
done

for forbidden_text in \
  'Register `agents/ppt`, not the repository root, as the OpenClaw workspace.' \
  'The runtime skill must appear in the workspace at `skills/slidemax_workflow/SKILL.md`.'; do
  forbid_text "$REPO_DIR/README.md" "$forbidden_text" 'README.md'
done

require_text "$ROOT_DIR/skills/presentation-workflow/SKILL.md" 'final delivery destination' 'presentation-workflow'
require_text "$ROOT_DIR/skills/presentation-workflow/SKILL.md" 'message-channel-delivery' 'presentation-workflow'
require_text "$ROOT_DIR/skills/ppt-generation/SKILL.md" 'delivery target and handoff status' 'ppt-generation'
require_text "$ROOT_DIR/USER.md" 'delivery status' 'USER.md'
require_text "$ROOT_DIR/skills/final-document-delivery/SKILL.md" 'scripts/check_final_delivery_gate.sh' 'final-document-delivery'
require_text "$ROOT_DIR/skills/message-channel-delivery/SKILL.md" 'Feishu' 'message-channel-delivery'
require_text "$ROOT_DIR/skills/message-channel-delivery/SKILL.md" 'file artifact' 'message-channel-delivery'
require_text "$ROOT_DIR/skills/message-channel-delivery/SKILL.md" 'channel handoff status' 'message-channel-delivery'
require_text "$ROOT_DIR/scripts/check_final_delivery_gate.sh" '--verification-evidence' 'check_final_delivery_gate.sh'
require_text "$ROOT_DIR/scripts/check_final_delivery_gate.sh" '--local-only-approval-evidence' 'check_final_delivery_gate.sh'
require_text "$ROOT_DIR/scripts/check_final_delivery_gate.sh" '--attempted-delivery' 'check_final_delivery_gate.sh'

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo 'Workspace validation passed.'
