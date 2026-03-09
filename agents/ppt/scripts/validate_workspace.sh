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
  echo "Runtime companion skill link should be ignored via .gitignore." >&2
  missing=1
fi

heartbeat_size=$(wc -c < "$ROOT_DIR/HEARTBEAT.md" | tr -d ' ')
if [[ "$heartbeat_size" -gt 800 ]]; then
  echo "HEARTBEAT.md is too large and should remain tiny." >&2
  missing=1
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

for required_text in \
  'slidemax-workflow' \
  'final-document-delivery' \
  'message-channel-delivery' \
  'SLIDEMAX_DIR/skills/slidemax_workflow' \
  'Select `slidemax-workflow` as the primary skill' \
  'Judao final document' \
  'Delivery status' \
  'scripts/check_final_delivery_gate.sh' \
  'canonical runtime completion contract'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/AGENTS.md"; then
    echo "AGENTS.md missing required text: $required_text" >&2
    missing=1
  fi
done

for required_text in \
  'AGENTS.md' \
  'HEARTBEAT.md' \
  'slidemax-workflow' \
  'SLIDEMAX_DIR/skills/slidemax_workflow' \
  'final delivery document' \
  'scripts/check_final_delivery_gate.sh' \
  'canonical runtime completion contract'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/TOOLS.md"; then
    echo "TOOLS.md missing required text: $required_text" >&2
    missing=1
  fi
done

for required_text in \
  'Primary Deck Generation Skill: slidemax-workflow' \
  'SlideMax'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/IDENTITY.md"; then
    echo "IDENTITY.md missing required text: $required_text" >&2
    missing=1
  fi
done

for required_text in \
  'https://github.com/funenc-lab/slidemax' \
  'https://github.com/funenc-lab/slidemax-clawagent' \
  'SLIDEMAX_DIR/skills/slidemax_workflow' \
  'skills/slidemax_workflow/SKILL.md' \
  'skills/final-document-delivery/SKILL.md' \
  'skills/message-channel-delivery/SKILL.md' \
  'ln -s "$SLIDEMAX_DIR/skills/slidemax_workflow" "$WORKSPACE_DIR/skills/slidemax_workflow"' \
  'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' \
  'openclaw agents list --json' \
  'openclaw agents add ppt-agent --workspace' \
  'openclaw agents delete ppt-agent' \
  'already points to `WORKSPACE_DIR`' \
  'points to a different workspace' \
  'Only determine the local OpenClaw agent status when Step 6 or Step 7 is actually reached' \
  'If the installation stops before the OpenClaw registration or verification step' \
  'the agent should decide the next action based on the actual local OpenClaw state' \
  'actual PPT generation'; do
  if ! grep -Fq "$required_text" "$REPO_DIR/docs/openclaw-install.md"; then
    echo "Install docs missing required text: $required_text" >&2
    missing=1
  fi
done

for forbidden_text in \
  'scripts/install_openclaw_agent.sh' \
  'tests/test_install_openclaw_agent.sh' \
  'ppt-master' \
  'PPT_MASTER_DIR' \
  'skills/slidemax-workflow/SKILL.md'; do
  if grep -Fqi "$forbidden_text" "$REPO_DIR/docs/openclaw-install.md"; then
    echo "Install docs must not mention: $forbidden_text" >&2
    missing=1
  fi
done

for required_text in \
  'AI Install Prompt' \
  'raw.githubusercontent.com/funenc-lab/slidemax-clawagent/main/docs/openclaw-install.md' \
  'agents/ppt' \
  'slidemax-clawagent repository root' \
  'clone it first' \
  'skills/slidemax_workflow/SKILL.md' \
  'skills/final-document-delivery/SKILL.md' \
  'skills/message-channel-delivery/SKILL.md' \
  'SLIDEMAX_DIR/skills/slidemax_workflow' \
  'ln -s "$SLIDEMAX_DIR/skills/slidemax_workflow" "$WORKSPACE_DIR/skills/slidemax_workflow"' \
  'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' \
  '~/.openclaw/.env' \
  'Judao final document' \
  'Feishu document' \
  'Delivery status' \
  'scripts/check_final_delivery_gate.sh' \
  'canonical runtime completion contract'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/README.md"; then
    echo "README.md missing required text: $required_text" >&2
    missing=1
  fi
done

for forbidden_text in \
  'scripts/install_openclaw_agent.sh' \
  'tests/test_install_openclaw_agent.sh' \
  'ppt-master' \
  'skills/slidemax-workflow/SKILL.md'; do
  if grep -Fqi "$forbidden_text" "$ROOT_DIR/README.md"; then
    echo "README.md must not mention: $forbidden_text" >&2
    missing=1
  fi
done

if ! grep -Fq 'final delivery destination' "$ROOT_DIR/skills/presentation-workflow/SKILL.md"; then
  echo "presentation-workflow must capture the final delivery destination." >&2
  missing=1
fi

if ! grep -Fq 'message-channel-delivery' "$ROOT_DIR/skills/presentation-workflow/SKILL.md"; then
  echo "presentation-workflow must route channel handoff to message-channel-delivery." >&2
  missing=1
fi

if ! grep -Fq 'delivery target and handoff status' "$ROOT_DIR/skills/ppt-generation/SKILL.md"; then
  echo "ppt-generation must report delivery target and handoff status." >&2
  missing=1
fi

if ! grep -Fq 'delivery status' "$ROOT_DIR/USER.md"; then
  echo "USER.md must require delivery status in final responses." >&2
  missing=1
fi

if ! grep -Fq 'scripts/check_final_delivery_gate.sh' "$ROOT_DIR/skills/final-document-delivery/SKILL.md"; then
  echo "final-document-delivery must require the runtime completion gate." >&2
  missing=1
fi

for required_text in \
  'Feishu' \
  'file artifact' \
  'channel handoff status'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/skills/message-channel-delivery/SKILL.md"; then
    echo "message-channel-delivery skill missing required text: $required_text" >&2
    missing=1
  fi
done

for required_text in \
  '--verification-evidence' \
  '--local-only-approval-evidence' \
  '--attempted-delivery'; do
  if ! grep -Fq -- "$required_text" "$ROOT_DIR/scripts/check_final_delivery_gate.sh" "$ROOT_DIR/README.md"; then
    echo "Completion gate contract missing required text: $required_text" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

echo "Workspace validation passed."
