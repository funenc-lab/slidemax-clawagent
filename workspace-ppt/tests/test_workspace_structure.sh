#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
REPO_DIR=$(cd "$ROOT_DIR/.." && pwd)

required_files=(
  "README.md"
  "AGENTS.md"
  "SOUL.md"
  "TOOLS.md"
  "USER.md"
  "IDENTITY.md"
  "HEARTBEAT.md"
  "scripts/validate_workspace.sh"
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

for relative_path in "${required_files[@]}"; do
  if [[ ! -f "$ROOT_DIR/$relative_path" ]]; then
    echo "Missing required file: $relative_path" >&2
    exit 1
  fi
done

if [[ -e "$ROOT_DIR/docs" ]]; then
  echo 'Workspace root should not contain docs/; installation docs belong at the repository root.' >&2
  exit 1
fi

if [[ "$(basename "$ROOT_DIR")" != "workspace-ppt" ]]; then
  echo 'Workspace root must live at workspace-ppt.' >&2
  exit 1
fi

for forbidden_repo_path in \
  '.openclaw' \
  'AGENTS.md' \
  'BOOTSTRAP.md' \
  'HEARTBEAT.md' \
  'IDENTITY.md' \
  'SOUL.md' \
  'TOOLS.md' \
  'USER.md' \
  'scripts' \
  'skills' \
  'tests'; do
  if [[ -e "$REPO_DIR/$forbidden_repo_path" ]]; then
    echo "Repository root should not contain workspace path: $forbidden_repo_path" >&2
    exit 1
  fi
done

for required_repo_path in 'README.md' '.gitignore' 'docs/openclaw-install.md'; do
  if [[ ! -e "$REPO_DIR/$required_repo_path" ]]; then
    echo "Repository root missing required file: $required_repo_path" >&2
    exit 1
  fi
done

for required_agent_path in 'agents/ppt' 'agents/ppt/.openclaw' 'agents/ppt/README.md'; do
  if [[ ! -e "$REPO_DIR/$required_agent_path" ]]; then
    echo "Repository root missing required agent path: $required_agent_path" >&2
    exit 1
  fi
done

if [[ -e "$ROOT_DIR/skills/slidemax-bridge" ]]; then
  echo 'skills/slidemax-bridge should not exist; SlideMax must be acquired during installation.' >&2
  exit 1
fi

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
  echo 'The runtime installed companion skill directory should be ignored.' >&2
  exit 1
fi

heartbeat_size=$(wc -c < "$ROOT_DIR/HEARTBEAT.md" | tr -d ' ')
if [[ "$heartbeat_size" -gt 800 ]]; then
  echo 'HEARTBEAT.md should stay tiny to avoid prompt bloat.' >&2
  exit 1
fi

for skill_name in 'presentation-workflow' 'ppt-generation' 'ppt-review' 'speaker-notes' 'deck-polish' 'slidemax-workflow' 'final-document-delivery' 'message-channel-delivery'; do
  if ! grep -Fq "$skill_name" "$ROOT_DIR/AGENTS.md"; then
    echo "AGENTS.md must reference skill: $skill_name" >&2
    exit 1
  fi
done

for required_text in \
  'Select `slidemax-workflow` as the primary skill' \
  'SLIDEMAX_DIR/skills/slidemax_workflow' \
  'Judao final document' \
  'Delivery status' \
  'scripts/check_final_delivery_gate.sh' \
  'canonical runtime completion contract'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/TOOLS.md"; then
    echo "AGENTS.md or TOOLS.md missing required text: $required_text" >&2
    exit 1
  fi
done

for required_text in \
  'skills/slidemax_workflow/SKILL.md' \
  'skills/final-document-delivery/SKILL.md' \
  'skills/message-channel-delivery/SKILL.md' \
  'SLIDEMAX_DIR/skills/slidemax_workflow' \
  'You may start from the repository root, the workspace root, or a parent directory where the repository may need to be cloned.' \
  'CURRENT_DIR=$(pwd)' \
  'Repository remote is not the canonical slidemax-clawagent repository' \
  'The repository root is `REPO_DIR`, the OpenClaw workspace root is `WORKSPACE_DIR="$REPO_DIR/workspace-ppt"`, and the OpenClaw `agentDir` root is `AGENT_DIR="$REPO_DIR/agents/ppt"`' \
  'Unless explicitly noted otherwise, every path in this section is relative to `WORKSPACE_DIR`.' \
  'AGENT_DIR="$REPO_DIR/agents/ppt"' \
  'REPO_DIR/docs/openclaw-install.md' \
  'rm -rf "$WORKSPACE_DIR/skills/slidemax_workflow"' \
  'cp -R "$SLIDEMAX_DIR/skills/slidemax_workflow" "$WORKSPACE_DIR/skills/slidemax_workflow"' \
  'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' \
  'openclaw agents add ppt-agent --workspace "$WORKSPACE_DIR" --agent-dir "$AGENT_DIR" --non-interactive' \
  'workspace-ppt' \
  'agents/ppt' \
  'Judao final document' \
  'Feishu document' \
  'Delivery status' \
  'scripts/check_final_delivery_gate.sh' \
  'canonical runtime completion contract'; do
  if ! grep -Fq "$required_text" "$REPO_DIR/README.md" "$REPO_DIR/docs/openclaw-install.md"; then
    echo "README or install docs missing required text: $required_text" >&2
    exit 1
  fi
done

for forbidden_text in \
  'ppt-master' \
  'skills/slidemax-workflow/SKILL.md'; do
  if grep -Fqi "$forbidden_text" "$REPO_DIR/README.md" "$REPO_DIR/docs/openclaw-install.md"; then
    echo "README or install docs should not mention: $forbidden_text" >&2
    exit 1
  fi
done

if ! grep -Fq 'final delivery destination' "$ROOT_DIR/skills/presentation-workflow/SKILL.md"; then
  echo 'presentation-workflow must capture the final delivery destination.' >&2
  exit 1
fi

if ! grep -Fq 'message-channel-delivery' "$ROOT_DIR/skills/presentation-workflow/SKILL.md"; then
  echo 'presentation-workflow must route channel handoff to message-channel-delivery.' >&2
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

if ! grep -Fq 'scripts/check_final_delivery_gate.sh' "$ROOT_DIR/skills/final-document-delivery/SKILL.md"; then
  echo 'final-document-delivery must require the runtime completion gate.' >&2
  exit 1
fi

for required_text in \
  'Feishu' \
  'file artifact' \
  'channel handoff status'; do
  if ! grep -Fq "$required_text" "$ROOT_DIR/skills/message-channel-delivery/SKILL.md"; then
    echo "message-channel-delivery skill missing required text: $required_text" >&2
    exit 1
  fi
done

for required_text in \
  '--verification-evidence' \
  '--local-only-approval-evidence' \
  '--attempted-delivery'; do
  if ! grep -Fq -- "$required_text" "$ROOT_DIR/scripts/check_final_delivery_gate.sh" "$REPO_DIR/README.md"; then
    echo "Completion gate contract missing required text: $required_text" >&2
    exit 1
  fi
done

echo 'Workspace structure test passed.'
