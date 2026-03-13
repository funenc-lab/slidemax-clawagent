#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
WORKSPACE_DIR="$REPO_DIR/agents/ppt"

required_repo_files=(
  "AGENTS.md"
  "README.md"
  ".gitignore"
  "docs/openclaw-install.md"
  "docs/openclaw-install-fresh.md"
  "docs/openclaw-update.md"
  "scripts/validate_workspace.sh"
  "tests/test_workspace_structure.sh"
)

required_workspace_files=(
  ".gitignore"
  "README.md"
  "AGENTS.md"
  "BOOTSTRAP.md"
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

for relative_path in "${required_repo_files[@]}"; do
  if [[ ! -f "$REPO_DIR/$relative_path" ]]; then
    echo "Missing required repository file: $relative_path" >&2
    missing=1
  fi
done

if [[ ! -d "$WORKSPACE_DIR" ]]; then
  echo "Missing source workspace: agents/ppt" >&2
  missing=1
fi

for relative_path in "${required_workspace_files[@]}"; do
  if [[ ! -f "$WORKSPACE_DIR/$relative_path" ]]; then
    echo "Missing required workspace file: $relative_path" >&2
    missing=1
  fi
done

if [[ -e "$WORKSPACE_DIR/scripts/validate_workspace.sh" ]]; then
  echo "agents/ppt/scripts/validate_workspace.sh must not exist." >&2
  missing=1
fi

if [[ -e "$WORKSPACE_DIR/tests/test_workspace_structure.sh" ]]; then
  echo "agents/ppt/tests/test_workspace_structure.sh must not exist." >&2
  missing=1
fi

if [[ -e "$WORKSPACE_DIR/skills/slidemax-bridge" ]]; then
  echo "skills/slidemax-bridge should not exist; SlideMax must be acquired during installation." >&2
  missing=1
fi

if grep -Eq '^HEARTBEAT\.md$' "$WORKSPACE_DIR/.gitignore"; then
  echo "HEARTBEAT.md must be committed to the repository." >&2
  missing=1
fi

if ! grep -Fq 'skills/slidemax_workflow' "$WORKSPACE_DIR/.gitignore"; then
  echo "The runtime companion skill directory should be ignored via .gitignore." >&2
  missing=1
fi

heartbeat_size=$(wc -c < "$WORKSPACE_DIR/HEARTBEAT.md" | tr -d ' ')
if [[ "$heartbeat_size" -gt 800 ]]; then
  echo "HEARTBEAT.md is too large and should remain tiny." >&2
  missing=1
fi

require_text "$REPO_DIR/README.md" 'scripts/validate_workspace.sh' 'README.md'
require_text "$REPO_DIR/README.md" 'tests/test_workspace_structure.sh' 'README.md'
require_text "$REPO_DIR/README.md" 'docs/openclaw-install.md' 'README.md'
require_text "$REPO_DIR/README.md" 'docs/openclaw-install-fresh.md' 'README.md'
require_text "$REPO_DIR/README.md" 'docs/openclaw-update.md' 'README.md'

if grep -Fq 'Local prompt:' "$REPO_DIR/README.md"; then
  echo 'README.md should not contain a Local prompt block.' >&2
  missing=1
fi

require_text "$REPO_DIR/docs/openclaw-install.md" 'fresh install: `docs/openclaw-install-fresh.md`' 'Install entry'
require_text "$REPO_DIR/docs/openclaw-install.md" 'update or repair: `docs/openclaw-update.md`' 'Install entry'
require_text "$REPO_DIR/docs/openclaw-install.md" 'SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"' 'Install entry'
require_text "$REPO_DIR/docs/openclaw-install.md" 'INSTALL_WORKSPACE_DIR="${INSTALL_WORKSPACE_DIR:-$OPENCLAW_HOME/workspace-ppt}"' 'Install entry'
require_text "$REPO_DIR/docs/openclaw-install.md" 'INSTALL_AGENT_DIR="${INSTALL_AGENT_DIR:-$OPENCLAW_HOME/agents/ppt/agent}"' 'Install entry'
require_text "$REPO_DIR/docs/openclaw-install.md" 'bash "$REPO_DIR/scripts/validate_workspace.sh"' 'Install entry'
require_text "$REPO_DIR/docs/openclaw-install.md" 'bash "$REPO_DIR/tests/test_workspace_structure.sh"' 'Install entry'

require_text "$REPO_DIR/docs/openclaw-install-fresh.md" 'managed_runtime_root_files=(' 'Fresh install doc'
require_text "$REPO_DIR/docs/openclaw-install-fresh.md" 'managed_runtime_scripts=(' 'Fresh install doc'
require_text "$REPO_DIR/docs/openclaw-install-fresh.md" 'managed_runtime_tests=(' 'Fresh install doc'
require_text "$REPO_DIR/docs/openclaw-install-fresh.md" 'managed_runtime_skills=(' 'Fresh install doc'
require_text "$REPO_DIR/docs/openclaw-install-fresh.md" 'source_only_repo_paths=(' 'Fresh install doc'
require_text "$REPO_DIR/docs/openclaw-install-fresh.md" 'cp -R "$SLIDEMAX_DIR/skills/slidemax_workflow" "$INSTALL_WORKSPACE_DIR/skills/slidemax_workflow"' 'Fresh install doc'

require_text "$REPO_DIR/docs/openclaw-update.md" 'managed_runtime_root_files=(' 'Update doc'
require_text "$REPO_DIR/docs/openclaw-update.md" 'managed_runtime_scripts=(' 'Update doc'
require_text "$REPO_DIR/docs/openclaw-update.md" 'managed_runtime_tests=(' 'Update doc'
require_text "$REPO_DIR/docs/openclaw-update.md" 'managed_runtime_skills=(' 'Update doc'
require_text "$REPO_DIR/docs/openclaw-update.md" 'source_only_repo_paths=(' 'Update doc'
require_text "$REPO_DIR/docs/openclaw-update.md" 'preserved_runtime_paths=(' 'Update doc'
require_text "$REPO_DIR/docs/openclaw-update.md" 'openclaw agents add "$AGENT_ID" --workspace "$INSTALL_WORKSPACE_DIR" --agent-dir "$INSTALL_AGENT_DIR" --non-interactive' 'Update doc'

if grep -Fq '  BOOTSTRAP.md' "$REPO_DIR/docs/openclaw-update.md"; then
  echo "Update doc must not recreate BOOTSTRAP.md." >&2
  missing=1
fi

require_text "$WORKSPACE_DIR/AGENTS.md" 'Select `slidemax-workflow` as the primary skill' 'AGENTS.md'
require_text "$WORKSPACE_DIR/AGENTS.md" 'Delivery status' 'AGENTS.md'
require_text "$WORKSPACE_DIR/AGENTS.md" 'Read `IDENTITY.md`' 'AGENTS.md'
require_text "$WORKSPACE_DIR/TOOLS.md" 'scripts/check_final_delivery_gate.sh' 'TOOLS.md'
require_text "$WORKSPACE_DIR/TOOLS.md" 'bash tests/test_final_delivery_gate.sh' 'TOOLS.md'
require_text "$WORKSPACE_DIR/IDENTITY.md" 'Primary Deck Generation Skill: slidemax-workflow' 'IDENTITY.md'
require_text "$WORKSPACE_DIR/README.md" 'installed OpenClaw workspace' 'README.md'

if grep -Fq 'source workspace for the PPT OpenClaw agent' "$WORKSPACE_DIR/README.md"; then
  echo "Runtime README.md must not describe the installed workspace as source-only." >&2
  missing=1
fi

if grep -Fq 'bash scripts/validate_workspace.sh' "$WORKSPACE_DIR/TOOLS.md"; then
  echo "Runtime TOOLS.md must not reference repository-only validation commands." >&2
  missing=1
fi

if grep -Fq 'bash tests/test_workspace_structure.sh' "$WORKSPACE_DIR/TOOLS.md"; then
  echo "Runtime TOOLS.md must not reference repository-only structure tests." >&2
  missing=1
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo 'Repository source validation passed.'
