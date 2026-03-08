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
  "scripts/install_openclaw_agent.sh"
  "scripts/validate_workspace.sh"
  "skills/presentation-workflow/SKILL.md"
  "skills/ppt-generation/SKILL.md"
  "skills/ppt-review/SKILL.md"
  "skills/speaker-notes/SKILL.md"
  "skills/deck-polish/SKILL.md"
  "skills/slidemax-workflow/SKILL.md"
  "docs/openclaw-install.md"
  "tests/test_install_openclaw_agent.sh"
)

for relative_path in "${required_files[@]}"; do
  if [[ ! -f "$ROOT_DIR/$relative_path" ]]; then
    echo "Missing required file: $relative_path" >&2
    exit 1
  fi
done

if grep -Eq '^HEARTBEAT\.md$' "$ROOT_DIR/.gitignore"; then
  echo 'HEARTBEAT.md should be committed to the workspace repository.' >&2
  exit 1
fi

heartbeat_size=$(wc -c < "$ROOT_DIR/HEARTBEAT.md" | tr -d ' ')
if [[ "$heartbeat_size" -gt 800 ]]; then
  echo 'HEARTBEAT.md should stay tiny to avoid prompt bloat.' >&2
  exit 1
fi

if ! grep -q 'openclaw agents add' "$ROOT_DIR/scripts/install_openclaw_agent.sh"; then
  echo 'Install script must register the workspace with OpenClaw.' >&2
  exit 1
fi

if ! grep -q -- '--skip-companion-check' "$ROOT_DIR/scripts/install_openclaw_agent.sh"; then
  echo 'Install script must support the --skip-companion-check override.' >&2
  exit 1
fi

if ! grep -q 'SLIDEMAX_DIR' "$ROOT_DIR/scripts/install_openclaw_agent.sh"; then
  echo 'Install script must support the SLIDEMAX_DIR override.' >&2
  exit 1
fi

if ! grep -q -- '--slidemax-dir' "$ROOT_DIR/scripts/install_openclaw_agent.sh"; then
  echo 'Install script must support the --slidemax-dir option.' >&2
  exit 1
fi

if grep -q 'PPT_MASTER_DIR' "$ROOT_DIR/scripts/install_openclaw_agent.sh"; then
  echo 'Install script must not support the deprecated PPT_MASTER_DIR override.' >&2
  exit 1
fi

if grep -q -- '--ppt-master-dir' "$ROOT_DIR/scripts/install_openclaw_agent.sh"; then
  echo 'Install script must not support the deprecated --ppt-master-dir option.' >&2
  exit 1
fi

for skill_name in 'presentation-workflow' 'ppt-generation' 'ppt-review' 'speaker-notes' 'deck-polish'; do
  if ! grep -q "$skill_name" "$ROOT_DIR/AGENTS.md"; then
    echo "AGENTS.md must reference skill: $skill_name" >&2
    exit 1
  fi
done

if ! grep -q 'HEARTBEAT_OK' "$ROOT_DIR/AGENTS.md"; then
  echo 'AGENTS.md should define heartbeat reply behavior.' >&2
  exit 1
fi

if ! grep -qi 'progress' "$ROOT_DIR/AGENTS.md"; then
  echo 'AGENTS.md should define progress reporting behavior for PPT work.' >&2
  exit 1
fi

for skill_file in \
  "$ROOT_DIR/skills/presentation-workflow/SKILL.md" \
  "$ROOT_DIR/skills/ppt-generation/SKILL.md" \
  "$ROOT_DIR/skills/ppt-review/SKILL.md"; do
  if ! grep -qi 'progress' "$skill_file"; then
    echo "Skill missing progress-reporting guidance: $skill_file" >&2
    exit 1
  fi
done

if ! grep -q 'AGENTS.md' "$ROOT_DIR/TOOLS.md"; then
  echo 'TOOLS.md should reference AGENTS.md as the canonical contract.' >&2
  exit 1
fi

if ! grep -q 'HEARTBEAT.md' "$ROOT_DIR/TOOLS.md"; then
  echo 'TOOLS.md should reference HEARTBEAT.md for heartbeat behavior.' >&2
  exit 1
fi

if ! grep -q 'HEARTBEAT.md' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should explain HEARTBEAT.md.' >&2
  exit 1
fi

if ! grep -q 'ppt-review' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should explain the advanced PPT skills.' >&2
  exit 1
fi

if ! grep -qi 'progress' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should explain the progress reporting behavior.' >&2
  exit 1
fi

if ! grep -q 'https://github.com/funenc-lab/slidemax' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should reference the canonical funenc-lab/slidemax repository URL.' >&2
  exit 1
fi

if ! grep -q 'https://github.com/funenc-lab/slidemax-clawagent' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should reference the canonical slidemax-clawagent workspace repository URL.' >&2
  exit 1
fi

if ! grep -q 'repository root' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should define the workspace repository root explicitly.' >&2
  exit 1
fi

if ! grep -q 'test -f ./scripts/install_openclaw_agent.sh' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should require verifying scripts/install_openclaw_agent.sh before continuing.' >&2
  exit 1
fi

if ! grep -q 'test -f ./tests/test_workspace_structure.sh' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should require verifying tests/test_workspace_structure.sh before continuing.' >&2
  exit 1
fi

if grep -qi 'ppt-master' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should not mention deprecated ppt-master compatibility.' >&2
  exit 1
fi

if ! grep -q -- '--skip-companion-check' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should explain the --skip-companion-check override.' >&2
  exit 1
fi

if ! grep -q 'SLIDEMAX_DIR' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should explain the SLIDEMAX_DIR override.' >&2
  exit 1
fi

if grep -q 'PPT_MASTER_DIR' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should not mention the deprecated PPT_MASTER_DIR override.' >&2
  exit 1
fi

if ! grep -qi 'AI' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should explicitly target AI-guided installation.' >&2
  exit 1
fi

if ! grep -q 'does not exist yet, create it' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should explain that a missing agent should be created.' >&2
  exit 1
fi

if ! grep -q 'already exists, reuse it and do not create a duplicate' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should explain that an existing agent should be reused.' >&2
  exit 1
fi

if ! grep -q 'AI Install Prompt' "$ROOT_DIR/README.md"; then
  echo 'README.md should include a copy-ready AI install prompt.' >&2
  exit 1
fi

if ! grep -q 'slidemax-workflow' "$ROOT_DIR/AGENTS.md"; then
  echo 'AGENTS.md should describe the SlideMax workflow integration.' >&2
  exit 1
fi

if ! grep -q 'SlideMax' "$ROOT_DIR/IDENTITY.md"; then
  echo 'IDENTITY.md should declare SlideMax as the PPT generation backend.' >&2
  exit 1
fi

if ! grep -q 'skills/slidemax-workflow/SKILL.md' "$ROOT_DIR/README.md"; then
  echo 'README.md should list the SlideMax workflow skill entrypoint.' >&2
  exit 1
fi

if ! grep -q 'actual PPT generation' "$ROOT_DIR/docs/openclaw-install.md"; then
  echo 'Install docs should explain that SlideMax is used for actual PPT generation.' >&2
  exit 1
fi

if ! grep -q 'raw.githubusercontent.com/funenc-lab/slidemax-clawagent/main/docs/openclaw-install.md' "$ROOT_DIR/README.md"; then
  echo 'README.md should point AI installers to the GitHub file URL for the install runbook.' >&2
  exit 1
fi

if ! grep -q 'slidemax-clawagent repository root' "$ROOT_DIR/README.md"; then
  echo 'README.md should define the exact workspace path as the slidemax-clawagent repository root.' >&2
  exit 1
fi

if ! grep -q 'clone it first' "$ROOT_DIR/README.md"; then
  echo 'README.md should tell AI installers to clone the workspace repo first when it is missing.' >&2
  exit 1
fi

if grep -qi 'ppt-master' "$ROOT_DIR/README.md"; then
  echo 'README.md should not mention deprecated ppt-master compatibility in install guidance.' >&2
  exit 1
fi

if ! grep -q 'execution prompt file' "$ROOT_DIR/README.md"; then
  echo 'README.md should tell AI installers to follow the install prompt file exactly.' >&2
  exit 1
fi

echo 'Workspace structure test passed.'
