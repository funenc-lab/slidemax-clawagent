#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

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
  "scripts/install_openclaw_agent.sh"
  "docs/openclaw-install.md"
)

missing=0
for relative_path in "${required_files[@]}"; do
  if [[ ! -f "$ROOT_DIR/$relative_path" ]]; then
    echo "Missing required file: $relative_path" >&2
    missing=1
  fi
done

if grep -Eq '^HEARTBEAT\.md$' "$ROOT_DIR/.gitignore"; then
  echo "HEARTBEAT.md must be committed to the repository." >&2
  missing=1
fi

if [[ -f "$ROOT_DIR/HEARTBEAT.md" ]]; then
  heartbeat_size=$(wc -c < "$ROOT_DIR/HEARTBEAT.md" | tr -d ' ')
  if [[ "$heartbeat_size" -gt 800 ]]; then
    echo "HEARTBEAT.md is too large and should remain tiny." >&2
    missing=1
  fi
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo "Workspace validation passed."
