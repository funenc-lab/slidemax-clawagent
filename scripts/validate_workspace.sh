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
  "scripts/install_openclaw_agent.sh"
  "docs/openclaw-install.md"
  "tests/test_install_openclaw_agent.sh"
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

if ! grep -q 'https://github.com/funenc-lab/slidemax' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must reference the canonical funenc-lab/slidemax repository URL." >&2
  missing=1
fi

if ! grep -q -- '--skip-companion-check' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must explain the --skip-companion-check override." >&2
  missing=1
fi

if ! grep -q 'SLIDEMAX_DIR' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must explain the SLIDEMAX_DIR override." >&2
  missing=1
fi

if grep -q 'PPT_MASTER_DIR' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must not mention the deprecated PPT_MASTER_DIR override." >&2
  missing=1
fi

if ! grep -qi 'AI' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must explicitly target AI-guided installation." >&2
  missing=1
fi

if ! grep -q 'does not exist yet, create it' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must explain that a missing agent should be created." >&2
  missing=1
fi

if ! grep -q 'already exists, reuse it and do not create a duplicate' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must explain that an existing agent should be reused." >&2
  missing=1
fi

if ! grep -q 'AI Install Prompt' "$ROOT_DIR/README.md"; then
  echo "README.md must include a copy-ready AI install prompt." >&2
  missing=1
fi

if ! grep -q 'slidemax-workflow' "$ROOT_DIR/AGENTS.md"; then
  echo "AGENTS.md must describe the SlideMax workflow integration." >&2
  missing=1
fi

if ! grep -q 'SlideMax' "$ROOT_DIR/IDENTITY.md"; then
  echo "IDENTITY.md must declare SlideMax as the PPT generation backend." >&2
  missing=1
fi

if ! grep -q 'skills/slidemax-workflow/SKILL.md' "$ROOT_DIR/README.md"; then
  echo "README.md must list the SlideMax workflow skill entrypoint." >&2
  missing=1
fi

if ! grep -q 'actual PPT generation' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo "Install docs must explain that SlideMax is used for actual PPT generation." >&2
  missing=1
fi

if ! grep -q 'raw.githubusercontent.com/funenc-lab/slidemax-clawagent/main/docs/openclaw-install.md' "$ROOT_DIR/README.md"; then
  echo "README.md must direct AI installers to the GitHub file URL for the install runbook." >&2
  missing=1
fi

if grep -q 'PPT_MASTER_DIR' "$ROOT_DIR/scripts/install_openclaw_agent.sh"; then
  echo "Install script must not support the deprecated PPT_MASTER_DIR override." >&2
  missing=1
fi

if grep -q -- '--ppt-master-dir' "$ROOT_DIR/scripts/install_openclaw_agent.sh"; then
  echo "Install script must not support the deprecated --ppt-master-dir option." >&2
  missing=1
fi

if grep -qi 'ppt-master' "$ROOT_DIR/README.md"; then
  echo "README.md must not mention deprecated ppt-master compatibility in install guidance." >&2
  missing=1
fi

if ! grep -q 'execution prompt file' "$ROOT_DIR/README.md"; then
  echo "README.md must tell AI installers to follow the install prompt file exactly." >&2
  missing=1
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo "Workspace validation passed."
