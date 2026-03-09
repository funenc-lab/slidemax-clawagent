#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

required_files=(
  "AGENTS.md"
  "SOUL.md"
  "TOOLS.md"
  "USER.md"
  "IDENTITY.md"
  "HEARTBEAT.md"
  "README.md"
  "scripts/validate_workspace.sh"
  "skills/presentation-workflow/SKILL.md"
  "skills/ppt-generation/SKILL.md"
  "skills/ppt-review/SKILL.md"
  "skills/speaker-notes/SKILL.md"
  "skills/deck-polish/SKILL.md"
  "skills/slidemax-bridge/SKILL.md"
  "skills/final-document-delivery/SKILL.md"
  "docs/openclaw-install.md"
)

for relative_path in "${required_files[@]}"; do
  if [[ ! -f "$ROOT_DIR/$relative_path" ]]; then
    echo "Missing required file: $relative_path" >&2
    exit 1
  fi
done

if [[ -f "$ROOT_DIR/scripts/install_openclaw_agent.sh" ]]; then
  echo 'Install helper script should not exist anymore.' >&2
  exit 1
fi

if [[ -f "$ROOT_DIR/tests/test_install_openclaw_agent.sh" ]]; then
  echo 'Install helper smoke test should not exist anymore.' >&2
  exit 1
fi

if grep -Eq '^HEARTBEAT\.md$' "$ROOT_DIR/.gitignore"; then
  echo 'HEARTBEAT.md should be committed to the workspace repository.' >&2
  exit 1
fi

if ! grep -Fq 'skills/slidemax_workflow' "$ROOT_DIR/.gitignore"; then
  echo 'The runtime companion skill link should be ignored.' >&2
  exit 1
fi

heartbeat_size=$(wc -c < "$ROOT_DIR/HEARTBEAT.md" | tr -d ' ')
if [[ "$heartbeat_size" -gt 800 ]]; then
  echo 'HEARTBEAT.md should stay tiny to avoid prompt bloat.' >&2
  exit 1
fi

for skill_name in 'presentation-workflow' 'ppt-generation' 'ppt-review' 'speaker-notes' 'deck-polish' 'slidemax-workflow' 'slidemax-bridge' 'final-document-delivery'; do
  if ! grep -Fq "$skill_name" "$ROOT_DIR/AGENTS.md"; then
    echo "AGENTS.md must reference skill: $skill_name" >&2
    exit 1
  fi
done

for required_text in \
  'Select `slidemax-workflow` as the primary skill' \
  'SLIDEMAX_DIR/skills/slidemax_workflow' \
  'skills/slidemax-bridge/SKILL.md' \
  'Judao final document' \
  'Delivery status'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/TOOLS.md"; then
    echo "AGENTS.md or TOOLS.md missing required text: $required_text" >&2
    exit 1
  fi
done

for required_text in \
  'skills/slidemax-bridge/SKILL.md' \
  'skills/slidemax_workflow/SKILL.md' \
  'skills/final-document-delivery/SKILL.md' \
  'SLIDEMAX_DIR/skills/slidemax_workflow' \
  'ln -s "$SLIDEMAX_DIR/skills/slidemax_workflow" "$WORKSPACE_DIR/skills/slidemax_workflow"' \
  'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' \
  'Judao final document' \
  'Feishu document' \
  'Delivery status'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/README.md" "$ROOT_DIR/docs/openclaw-install.md"; then
    echo "README or install docs missing required text: $required_text" >&2
    exit 1
  fi
done

for forbidden_text in \
  'ppt-master' \
  'skills/slidemax-workflow/SKILL.md'; do
  if grep -Fqi "$forbidden_text" "$ROOT_DIR/README.md" "$ROOT_DIR/docs/openclaw-install.md"; then
    echo "README or install docs should not mention: $forbidden_text" >&2
    exit 1
  fi
done

for required_text in \
  'name: slidemax-bridge' \
  'SLIDEMAX_DIR/skills/slidemax_workflow' \
  'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/skills/slidemax-bridge/SKILL.md"; then
    echo "slidemax-bridge skill missing required text: $required_text" >&2
    exit 1
  fi
done


if ! grep -Fq 'final delivery destination' "$ROOT_DIR/skills/presentation-workflow/SKILL.md"; then
  echo 'presentation-workflow must capture the final delivery destination.' >&2
  exit 1
fi

if ! grep -Fq 'delivery target and handoff status' "$ROOT_DIR/skills/ppt-generation/SKILL.md"; then
  echo 'ppt-generation must report delivery target and handoff status.' >&2
  exit 1
fi

if ! grep -Fq 'delivery status' "$ROOT_DIR/USER.md"; then
  echo 'USER.md must require delivery status in final responses.' >&2
  exit 1
fi

echo 'Workspace structure test passed.'
