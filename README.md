# PPT OpenClaw Agent Workspace

This repository is a production-ready OpenClaw agent workspace for presentation and slide-oriented tasks.

## Executive Summary

This workspace packages a PPT-focused OpenClaw agent with:

- prompt-layer files that define role, tone, tools, and operating rules
- specialized presentation skills for generation, review, polishing, and speaker support
- a tiny heartbeat contract for low-noise follow-up behavior
- validation tooling for repeatable workspace checks
- smoke tests for workspace structure and install guidance

This workspace is intended to be installed together with the SlideMax companion repository used by the agent for actual PPT generation. The canonical repository address is:

- `https://github.com/funenc-lab/slidemax`

For the full AI-oriented installation runbook, see `docs/openclaw-install.md`.

## Companion Requirement

Before registering this workspace with OpenClaw, install the SlideMax companion project from the canonical repository `funenc-lab/slidemax`.

According to the official SlideMax repository, the minimum setup includes:

- `Python 3.8+`
- `pip install -r requirements.txt`

This repository does not auto-clone or auto-install SlideMax; that dependency and its workflow role are documented in `docs/openclaw-install.md`.

This repository does not bundle the canonical `slidemax-workflow` implementation.
The local `skills/slidemax-bridge/SKILL.md` file is only a bridge skill for installation and repair.
During installation, the AI must install the canonical companion skill from `SLIDEMAX_DIR/skills/slidemax_workflow` into `skills/slidemax_workflow` inside this workspace before the agent can use it for actual PPT generation.
The remaining local files under `skills/` are workspace-specific skills that become available to the agent through the registered workspace.
If workspace validation fails, do not register the agent because the local skill set is incomplete or the companion workflow was not installed correctly.

## What it includes

- Standard OpenClaw workspace prompt files: `AGENTS.md`, `SOUL.md`, `TOOLS.md`, `USER.md`, `IDENTITY.md`
- Core orchestration skill: `skills/presentation-workflow/SKILL.md`
- Local bridge skill: `skills/slidemax-bridge/SKILL.md`
- Canonical runtime generation skill installed from the SlideMax companion repo: `skills/slidemax_workflow/SKILL.md`
- Final delivery skill: `skills/final-document-delivery/SKILL.md`
- Specialized PPT skills:
  - `skills/ppt-generation/SKILL.md`
  - `skills/ppt-review/SKILL.md`
  - `skills/speaker-notes/SKILL.md`
  - `skills/deck-polish/SKILL.md`
- A lightweight proactive heartbeat contract: `HEARTBEAT.md`
- Validation script: `scripts/validate_workspace.sh`
- Workspace structure smoke test: `tests/test_workspace_structure.sh`
- SlideMax companion workflow bridge plus runtime-installed canonical skill for actual PPT generation
- English AI installation guide: `docs/openclaw-install.md`

## Workspace Layout

### Prompt Layer

- `AGENTS.md`: top-level operating contract, output format, progress reporting, heartbeat rules, and skill routing
- `SOUL.md`: persona, tone, and behavioral traits
- `TOOLS.md`: tool boundaries, validation guidance, and presentation workflow rules
- `USER.md`: user-facing response preferences
- `IDENTITY.md`: agent identity and domain positioning
- `HEARTBEAT.md`: minimal proactive follow-up conditions and exact no-op reply

### Skill Layer

- `skills/slidemax-bridge/SKILL.md`: local bridge skill that installs or repairs the canonical SlideMax workflow skill in this workspace
- `skills/slidemax_workflow/SKILL.md`: canonical runtime skill sourced from the installed SlideMax companion repository for actual PPT generation
- `skills/final-document-delivery/SKILL.md`: final delivery skill that sends finished artifacts to a Judao final document, Feishu document, or another final destination
- `skills/presentation-workflow/SKILL.md`: entry workflow for create, review, rewrite, and conversion tasks, and supporting narrative preparation for SlideMax
- `skills/ppt-generation/SKILL.md`: message-first deck generation from raw input when SlideMax needs structured content
- `skills/ppt-review/SKILL.md`: structured review and prioritized fixes
- `skills/speaker-notes/SKILL.md`: talk tracks, transitions, and likely Q&A
- `skills/deck-polish/SKILL.md`: executive-style tightening and readability improvements

### Operational Layer

- `scripts/validate_workspace.sh`: checks required files and key prompt constraints
- `tests/test_workspace_structure.sh`: smoke test for expected workspace structure
- `docs/openclaw-install.md`: canonical AI installation runbook with local-state decision rules

The final delivery chain for generated work is:

1. build or review the content in this workspace
2. generate the final artifact with the canonical SlideMax workflow when needed
3. send or publish the finished result to the requested final document destination through `final-document-delivery`

## Installation Overview

The expected installation sequence is:

1. clone or update the SlideMax companion repository
2. install the SlideMax Python dependencies
3. install the canonical `slidemax_workflow` skill from the companion repo into this workspace
4. validate this workspace
5. verify `Node.js 22+`
6. install `openclaw` globally if needed
7. register this repository as an OpenClaw workspace

## Quick Install

Read `docs/openclaw-install.md` first if an AI agent is performing the installation.

For a direct manual setup after the prerequisites are ready, use the local-state flow:

```bash
WORKSPACE_DIR="$(pwd)"
PARENT_DIR="$(dirname "$WORKSPACE_DIR")"
SLIDEMAX_DIR="${SLIDEMAX_DIR:-$PARENT_DIR/slidemax}"

command -v openclaw >/dev/null 2>&1 || npm install -g openclaw@latest
test -f "$SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md"

if [ -L "$WORKSPACE_DIR/skills/slidemax_workflow" ]; then
  rm "$WORKSPACE_DIR/skills/slidemax_workflow"
elif [ -e "$WORKSPACE_DIR/skills/slidemax_workflow" ]; then
  echo "Target workspace skill path already exists and is not a symlink: $WORKSPACE_DIR/skills/slidemax_workflow" >&2
  exit 1
fi

ln -s "$SLIDEMAX_DIR/skills/slidemax_workflow" "$WORKSPACE_DIR/skills/slidemax_workflow"
openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' "\"$SLIDEMAX_DIR\""
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
openclaw agents list --json
openclaw agents add ppt-agent --workspace "$WORKSPACE_DIR" --non-interactive
openclaw agents list
```

If the target agent already exists and already points to this workspace, update the workspace files and reuse the existing registration.
If the target agent already exists but points to a different workspace, delete it and add it again with the current workspace.
If the target agent does not exist, add it with the current workspace.
Reusing or creating the agent from this workspace makes the local bridge skills from `skills/` available through the registered workspace, and the installed `skills/slidemax_workflow` runtime skill provides the canonical SlideMax workflow.
If an older agent session was already open before the runtime skill was linked, start a new session before invoking `slidemax-workflow`.
If the SlideMax repository is not in the default sibling path, configure `SLIDEMAX_DIR` through the OpenClaw env system before following the runbook.

## SlideMax Environment Configuration

If the SlideMax repository is not installed at the default sibling path, prefer configuring the companion path through OpenClaw's per-skill env injection for the canonical `slidemax-workflow` skill after `skills/slidemax_workflow` is installed into this workspace:

```bash
openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' '"/absolute/path/to/slidemax"'
openclaw config get 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR'
```

This is the preferred persistent setup for this workspace because OpenClaw applies `skills.entries.<skill>.env` to the host process for the agent run.

If you need a global fallback that also works when OpenClaw runs as a service, put the variable in `~/.openclaw/.env`:

```bash
mkdir -p ~/.openclaw
python3 - <<'PY'
from pathlib import Path

env_path = Path.home() / '.openclaw' / '.env'
lines = []
if env_path.exists():
    lines = [line for line in env_path.read_text().splitlines() if not line.startswith('SLIDEMAX_DIR=')]
lines.append('SLIDEMAX_DIR=/absolute/path/to/slidemax')
env_path.write_text('\n'.join(lines) + '\n')
PY
```

For a one-off shell-only override, use:

```bash
export SLIDEMAX_DIR="/absolute/path/to/slidemax"
```

OpenClaw's official env precedence is: process environment, current-directory `.env`, `~/.openclaw/.env`, config `env`, then optional shell import.
For `SLIDEMAX_DIR`, prefer the explicit per-skill config or `~/.openclaw/.env` rather than relying on shell import.

## AI Install Prompt

If you want an AI coding agent to perform the installation, copy the following Markdown prompt and give it to the agent directly:

```markdown
Treat the following file as the installation runbook (execution prompt file) and follow it exactly:
https://raw.githubusercontent.com/funenc-lab/slidemax-clawagent/main/docs/openclaw-install.md

Read it completely and execute the installation exactly as written in that file.
Do not skip steps and do not change the documented order.
Treat the exact workspace path as the absolute path of the local slidemax-clawagent repository root.
If the workspace repository is missing locally, clone it first and enter its root before following the runbook.
Inspect the local OpenClaw installation and agent state yourself, then choose the direct valid path.

After execution, report:
- the exact workspace path
- the exact companion path
- the validation results
- whether the agent was newly registered or already existed, only when the local OpenClaw agent state is made explicit by the runbook steps; otherwise report it as undetermined
- any blocker or failure output
```

## Quick Validate

```bash
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
```

## Final Delivery Requirement

The repository-root `outputs/` directory is only a staging area for generated files.
Unless the user explicitly asks for a local-only draft, the agent is not done until the final artifact or document-ready package has been sent or published to the requested final delivery document.

Expected delivery behavior:

- Prefer the project final document destination such as a Judao final document or a Feishu document.
- Report the final artifact path, final destination, and `Delivery status` in the completion message.
- If the final document destination is missing, ask for it before claiming completion.
- If publishing is blocked by missing tools, authentication, or network access, still generate the final local artifact and report the exact blocker plus the next manual delivery step.

## Output Directories

Generated local artifacts should be written under the repository-root `outputs/` directory unless the user explicitly requests a different path.

Preferred layout:

- `outputs/decks/`: slide blueprints, rewritten deck copy, and deck-ready markdown
- `outputs/reviews/`: review reports, scored rubrics, and issue lists
- `outputs/speaker-notes/`: talk tracks, transitions, and Q&A packs
- `outputs/assets/`: exported images, charts, PDFs, and presentation attachments
- `outputs/tmp/`: disposable intermediate files that can be regenerated

Naming rules:

- use English-only file and directory names
- prefer `YYYY-MM-DD-topic-slug` task folders
- keep all files for one task in the same task folder
- avoid writing generated deliverables to the repository root

## Assumptions

- `Node.js 22+` is available on the target machine
- `git`, `python3`, `pip`, and `npm` are available
- the SlideMax companion repository can be cloned from GitHub
- this repository path is the intended OpenClaw workspace location
- the target agent should remain presentation-focused and low-noise in heartbeat mode

## Extension Points

- add richer companion health checks or upgrade guidance to the install runbook
- add richer `.pptx` handling or export workflows
- add more domain skills such as board updates, sales pitches, or technical design reviews
- add troubleshooting, upgrade, or uninstall guidance to `docs/openclaw-install.md`
