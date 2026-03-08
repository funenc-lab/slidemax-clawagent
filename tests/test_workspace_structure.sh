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
  "skills/slidemax-workflow/SKILL.md"
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

heartbeat_size=$(wc -c < "$ROOT_DIR/HEARTBEAT.md" | tr -d ' ')
if [[ "$heartbeat_size" -gt 800 ]]; then
  echo 'HEARTBEAT.md should stay tiny to avoid prompt bloat.' >&2
  exit 1
fi

for skill_name in 'presentation-workflow' 'ppt-generation' 'ppt-review' 'speaker-notes' 'deck-polish' 'slidemax-workflow'; do
  if ! grep -q "$skill_name" "$ROOT_DIR/AGENTS.md"; then
    echo "AGENTS.md must reference skill: $skill_name" >&2
    exit 1
  fi
done

if ! grep -q 'Select `slidemax-workflow` as the primary skill' "$ROOT_DIR/AGENTS.md"; then
  echo 'AGENTS.md should define slidemax-workflow as the primary skill for actual PPT generation.' >&2
  exit 1
fi

if ! grep -q 'primary local entrypoint' "$ROOT_DIR/TOOLS.md"; then
  echo 'TOOLS.md should define slidemax-workflow as the primary local entrypoint for artifact generation.' >&2
  exit 1
fi

if ! grep -q 'Primary Deck Generation Skill: slidemax-workflow' "$ROOT_DIR/IDENTITY.md"; then
  echo 'IDENTITY.md should declare slidemax-workflow as the primary deck generation skill.' >&2
  exit 1
fi

if ! grep -q 'Select this skill first for actual deck generation requests' "$ROOT_DIR/skills/slidemax-workflow/SKILL.md"; then
  echo 'slidemax-workflow should be marked as the primary artifact generation skill.' >&2
  exit 1
fi

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

for required_text in \
  'HEARTBEAT.md' \
  'ppt-review' \
  'progress' \
  'https://github.com/funenc-lab/slidemax' \
  'https://github.com/funenc-lab/slidemax-clawagent' \
  'repository root' \
  'test -f ./scripts/validate_workspace.sh' \
  'test -f ./tests/test_workspace_structure.sh' \
  'SLIDEMAX_DIR' \
  'AI' \
  'does not exist yet, create it' \
  'already exists, reuse it and do not create a duplicate' \
  'Only determine the local OpenClaw agent status when Step 6 or Step 7 is actually reached' \
  'If the installation stops before the OpenClaw registration or verification step' \
  'the agent should decide the next action based on the actual local OpenClaw state' \
  'openclaw agents list --json' \
  'openclaw agents add ppt-agent --workspace' \
  'openclaw agents delete ppt-agent' \
  'already points to `WORKSPACE_DIR`' \
  'points to a different workspace' \
  'There is no separate skill installation command for this agent' \
  'workspace-specific skills' \
  'the local `skills/` directory available to the agent' \
  'workspace skill files under `skills/` are workspace-specific skills' \
  'loads their `SKILL.md` instructions on demand' \
  'No separate per-skill installation command is required' \
  'actual PPT generation'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/docs/openclaw-install.md"; then
    echo "Install docs missing required text: $required_text" >&2
    exit 1
  fi
done

for forbidden_text in \
  'scripts/install_openclaw_agent.sh' \
  'tests/test_install_openclaw_agent.sh' \
  'ppt-master' \
  'PPT_MASTER_DIR'; do
  if grep -qi "$forbidden_text" "$ROOT_DIR/docs/openclaw-install.md"; then
    echo "Install docs should not mention: $forbidden_text" >&2
    exit 1
  fi
done

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
  'skills/slidemax-workflow/SKILL.md' \
  'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' \
  '~/.openclaw/.env'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/README.md"; then
    echo "README.md missing required text: $required_text" >&2
    exit 1
  fi
done

for required_text in \
  'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' \
  '~/.openclaw/.env' \
  'process environment'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/docs/openclaw-install.md"; then
    echo "Install docs missing required text: $required_text" >&2
    exit 1
  fi
done

if ! grep -Fq 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' "$ROOT_DIR/skills/slidemax-workflow/SKILL.md"; then
  echo 'slidemax-workflow should document the OpenClaw per-skill SLIDEMAX_DIR configuration command.' >&2
  exit 1
fi

for forbidden_text in \
  'scripts/install_openclaw_agent.sh' \
  'tests/test_install_openclaw_agent.sh' \
  'ppt-master'; do
  if grep -qi "$forbidden_text" "$ROOT_DIR/README.md"; then
    echo "README.md should not mention: $forbidden_text" >&2
    exit 1
  fi
done

echo 'Workspace structure test passed.'
