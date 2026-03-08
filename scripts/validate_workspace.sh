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
  "skills/slidemax-workflow/SKILL.md"
  "scripts/validate_workspace.sh"
  "docs/openclaw-install.md"
  "tests/test_workspace_structure.sh"
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

if ! grep -qi 'progress' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md must define progress reporting behavior." >&2
  missing=1
fi

for skill_file in \
  "$ROOT_DIR/skills/presentation-workflow/SKILL.md" \
  "$ROOT_DIR/skills/ppt-generation/SKILL.md" \
  "$ROOT_DIR/skills/ppt-review/SKILL.md"; do
  if ! grep -qi 'progress' "$skill_file"; then
    echo "Skill missing progress reporting guidance: $skill_file" >&2
    missing=1
  fi
done

if ! grep -q 'AGENTS.md' "$ROOT_DIR/TOOLS.md"; then
  echo "TOOLS.md should reference AGENTS.md as the canonical workspace contract." >&2
  missing=1
fi

if ! grep -q 'HEARTBEAT.md' "$ROOT_DIR/TOOLS.md"; then
  echo "TOOLS.md should reference HEARTBEAT.md for heartbeat behavior." >&2
  missing=1
fi

if grep -qi 'ppt-master' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must not mention deprecated ppt-master compatibility." >&2
  missing=1
fi

for required_text in \
  'https://github.com/funenc-lab/slidemax' \
  'https://github.com/funenc-lab/slidemax-clawagent' \
  'repository root' \
  'test -f ./scripts/validate_workspace.sh' \
  'test -f ./tests/test_workspace_structure.sh' \
  'SLIDEMAX_DIR' \
  'openclaw agents list --json' \
  'openclaw agents add ppt-agent --workspace' \
  'openclaw agents delete ppt-agent' \
  'already points to `WORKSPACE_DIR`' \
  'points to a different workspace' \
  'Only determine the local OpenClaw agent status when Step 6 or Step 7 is actually reached' \
  'If the installation stops before the OpenClaw registration or verification step' \
  'the agent should decide the next action based on the actual local OpenClaw state' \
  'actual PPT generation'; do
  if ! grep -q "$required_text" "$ROOT_DIR/docs/openclaw-install.md"; then
    echo "Install docs missing required text: $required_text" >&2
    missing=1
  fi
done

for forbidden_text in \
  'scripts/install_openclaw_agent.sh' \
  'tests/test_install_openclaw_agent.sh' \
  'PPT_MASTER_DIR'; do
  if grep -q "$forbidden_text" "$ROOT_DIR/docs/openclaw-install.md"; then
    echo "Install docs must not mention: $forbidden_text" >&2
    missing=1
  fi
done

if ! grep -qi 'AI' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must explicitly target AI-guided installation." >&2
  missing=1
fi

for required_text in \
  'AI Install Prompt' \
  'raw.githubusercontent.com/funenc-lab/slidemax-clawagent/main/docs/openclaw-install.md' \
  'slidemax-clawagent repository root' \
  'clone it first' \
  'Inspect the local OpenClaw installation and agent state yourself' \
  'update the workspace files and reuse the existing registration' \
  'delete it and add it again with the current workspace' \
  'only when the local OpenClaw agent state is made explicit by the runbook steps' \
  'There is no separate per-skill installation command for this agent' \
  'workspace-specific skills that become available to the agent through the registered workspace' \
  'loaded on demand rather than copied into the agent as a separate install artifact' \
  'skills/slidemax-workflow/SKILL.md'; do
  if ! grep -q "$required_text" "$ROOT_DIR/README.md"; then
    echo "README.md missing required text: $required_text" >&2
    missing=1
  fi
done

for forbidden_text in \
  'scripts/install_openclaw_agent.sh' \
  'tests/test_install_openclaw_agent.sh' \
  'ppt-master'; do
  if grep -qi "$forbidden_text" "$ROOT_DIR/README.md"; then
    echo "README.md must not mention: $forbidden_text" >&2
    missing=1
  fi
done

if ! grep -q 'slidemax-workflow' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md must describe the SlideMax workflow integration." >&2
  missing=1
fi

if ! grep -q 'SlideMax' "$ROOT_DIR/IDENTITY.md"; then
  echo "IDENTITY.md must declare SlideMax as the PPT generation backend." >&2
  missing=1
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo "Workspace validation passed."
