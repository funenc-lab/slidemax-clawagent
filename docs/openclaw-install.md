# OpenClaw PPT Agent AI Installation Runbook

## Executive Summary

This document is a full installation runbook for an AI executor, not a short end-user note.
The goal is to ensure the AI completes the installation in the correct order:

1. Install the SlideMax companion repository used for actual PPT generation
2. Register this repository as an OpenClaw agent workspace

Key facts:

- The canonical repository address for SlideMax is `https://github.com/funenc-lab/slidemax`
- The canonical workspace repository address is `https://github.com/funenc-lab/slidemax-clawagent`
- Only the canonical `funenc-lab/slidemax` remote is supported by this installation flow
- The agent uses the installed SlideMax repository as the canonical workflow skill backend for actual PPT generation
- The canonical workflow skill file is `SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md`
- During installation, that companion skill must be installed into this workspace at `WORKSPACE_DIR/skills/slidemax_workflow`
- This repository contains the OpenClaw workspace, not the SlideMax companion application itself
- This runbook does not rely on an install helper script
- The AI should determine the local OpenClaw action directly from the observed local state

## Document Role

When an AI follows this document, it should behave like a controlled installer rather than an improvisational assistant.

That means:

- execute the steps in order
- stop immediately on failure
- separate confirmed facts from local recommendations
- record the final absolute paths being used
- verify the result with commands before claiming completion

## Facts, Assumptions, and Recommendations

### Confirmed Facts

The following facts are confirmed from the current repository and the companion repository instructions:

- The workspace must be validated before registration
- The companion repository path, origin, and `requirements.txt` must be checked before registration
- OpenClaw requires `Node.js 22+`
- `openclaw` may need to be installed before agent registration
- The companion repository requires at least `Python 3.8+`
- The companion repository installs dependencies with `pip install -r requirements.txt`
- The canonical GitHub repository for the companion project is `funenc-lab/slidemax`
- The companion repository contains the workflow and commands used by the agent to generate PPT artifacts
- The companion repository must contain `skills/slidemax_workflow/SKILL.md` before installation can continue

### Assumptions

This runbook assumes:

- `git`, `python3`, `pip`, `node`, and `npm` are available
- network access to GitHub and npm is available
- if the user does not provide a custom companion path, the companion repository will live next to this workspace
- the AI is allowed to clone the workspace repository when it is missing locally

### Local Recommendations

The following recommendations improve safety, but are not hard requirements from the companion repository itself:

- use the local companion directory name `slidemax` for all new installs
- reuse an existing local clone when its remote is valid
- stop and report if the existing remote is not the canonical `funenc-lab/slidemax` remote

## How the Agent Uses SlideMax

SlideMax is not only an installation dependency. It is the companion workflow used by this agent when the deliverable must become an actual PPT, PPTX, SVG, or rendered deck artifact.

Recommended division of responsibility:

- use this workspace to build the narrative, slide structure, notes, review findings, and content decisions
- use the installed SlideMax workflow as the generation layer for actual deck artifacts
- if SlideMax is missing, the agent may still produce outlines, copy, notes, and reviews, but should state that actual PPT generation is blocked

## Installation Success Criteria

The installation is considered complete only when all of the following are true:

- this workspace remains at its intended local path
- the SlideMax companion repository exists at the chosen path
- the companion repository remote is canonical `funenc-lab/slidemax`
- the companion repository dependency installation command succeeds
- `SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md` exists
- `WORKSPACE_DIR/skills/slidemax_workflow/SKILL.md` exists and resolves to the companion skill
- `./scripts/validate_workspace.sh` succeeds
- `./tests/test_workspace_structure.sh` succeeds
- `openclaw agents list` shows the agent after the chosen install or update path

## Output Directory Convention

Unless the user explicitly requests another location, generated reusable artifacts should be written under the workspace-root `outputs/` directory.

Recommended structure:

- `outputs/decks/`
  - slide blueprints, rewritten deck copy, deck-ready outlines
- `outputs/reviews/`
  - review reports, scored rubrics, issue lists, improvement recommendations
- `outputs/speaker-notes/`
  - talk tracks, transitions, emphasis cues, Q&A preparation
- `outputs/assets/`
  - exported images, charts, PDFs, and presentation attachments
- `outputs/tmp/`
  - disposable intermediate files that can be regenerated

Naming rules:

- use English-only file and directory names
- prefer lowercase kebab-case names
- keep each task in its own `YYYY-MM-DD-topic-slug` directory
- do not write generated deliverables to the workspace root unless the user explicitly asks for that
- do not write generated deliverables into `docs/`, `scripts/`, or `skills/` unless the task itself is a documentation or code change

Version-control rules:

- `outputs/` is treated as generated content rather than stable source
- creating the output directories is recommended, but not a hard requirement for installation success

Example:

```text
outputs/
  decks/
    2026-03-08-quarterly-business-review/
  reviews/
    2026-03-08-board-deck-review/
  speaker-notes/
    2026-03-08-launch-talk-track/
  assets/
    2026-03-08-launch-figures/
  tmp/
    2026-03-08-import-scratch/
```

## AI Execution Order

### Step 0: Acquire and Verify the Repository Root and Workspace Root

Treat the exact repository path as the absolute path of the local `slidemax-clawagent` repository root.
Treat the exact workspace path as the absolute path of the local `slidemax-clawagent` repository root plus `/agents/ppt`.
Do not treat an arbitrary current directory as the workspace path.

If the workspace repository is missing locally, clone it first and then enter the workspace root before doing anything else:

```bash
REPO_PARENT=$(pwd)
REPO_DIR="${REPO_PARENT}/slidemax-clawagent"
WORKSPACE_DIR="${REPO_DIR}/agents/ppt"

if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" remote get-url origin
elif [ -e "$REPO_DIR" ]; then
  echo "Target repository path exists but is not a Git repository: $REPO_DIR" >&2
  exit 1
else
  git clone https://github.com/funenc-lab/slidemax-clawagent.git "$REPO_DIR"
fi

cd "$WORKSPACE_DIR"
test -f ./scripts/validate_workspace.sh
test -f ./tests/test_workspace_structure.sh
```

Rules:

- if the workspace repository does not exist locally, clone `https://github.com/funenc-lab/slidemax-clawagent.git`
- if the target repository path exists but is not a Git repository, stop and report the conflict
- if `./scripts/validate_workspace.sh` is missing, stop immediately
- if `./tests/test_workspace_structure.sh` is missing, stop immediately

Then report:

- the exact repository path
- the exact workspace path
- that the current shell is now inside the workspace root

### Step 1: Resolve Paths

After entering the workspace root, compute the local paths:

```bash
WORKSPACE_DIR=$(pwd)
REPO_DIR=$(cd "$WORKSPACE_DIR/../.." && pwd)
PARENT_DIR=$(dirname "$REPO_DIR")
SLIDEMAX_DIR="${PARENT_DIR}/slidemax"
WORKSPACE_SLIDEMAX_SKILL_DIR="$WORKSPACE_DIR/skills/slidemax_workflow"
SLIDEMAX_WORKFLOW_SOURCE_DIR="$SLIDEMAX_DIR/skills/slidemax_workflow"
```

Then report:

- the exact repository path
- the exact workspace path
- the chosen SlideMax companion repository path

If the user explicitly provided a custom companion path, use that path instead.

Supported override names:

- use `SLIDEMAX_DIR` as the supported environment variable
- do not invent alternate environment variable names for the companion path
- treat `SLIDEMAX_DIR/skills/slidemax_workflow` as the canonical source path for the runtime `slidemax-workflow` skill

When the SlideMax companion path is not the default sibling path, prefer OpenClaw's per-skill env injection for the `slidemax-workflow` skill:

```bash
openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' '"/absolute/path/to/slidemax"'
openclaw config get 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR'
```

This is the preferred persistent configuration because OpenClaw applies `skills.entries.<skill>.env` to the host process for the agent run.

If OpenClaw runs as a background service and the companion path should be available outside the current shell, use the global OpenClaw env file:

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

OpenClaw env precedence is:

1. process environment
2. `.env` in the current working directory
3. `~/.openclaw/.env`
4. config `env`
5. optional shell import

Because shell import only fills missing expected keys, do not rely on `OPENCLAW_LOAD_SHELL_ENV=1` as the primary way to supply `SLIDEMAX_DIR`.

### Step 2: Check Required Tools

Verify the commands exist:

```bash
command -v git
command -v python3
command -v pip
command -v node
command -v npm
```

Then check the key versions:

```bash
python3 --version
node --version
npm --version
```

Rules:

- SlideMax requires `Python 3.8+`
- OpenClaw requires `Node.js 22+`

If `Node.js` is below `22`, do not continue to the OpenClaw registration step.
If `Python` is below `3.8`, do not proceed with the companion repository installation.

### Step 3: Install or Reuse SlideMax

Check whether the target path already contains a Git repository:

```bash
if [ -d "$SLIDEMAX_DIR/.git" ]; then
  git -C "$SLIDEMAX_DIR" remote get-url origin
elif [ -e "$SLIDEMAX_DIR" ]; then
  echo "Target companion path exists but is not a Git repository: $SLIDEMAX_DIR" >&2
  exit 1
else
  git clone https://github.com/funenc-lab/slidemax.git "$SLIDEMAX_DIR"
fi
```

Rules:

- if the path does not exist, clone the canonical repository
- if the path exists and is a Git repository, reuse it only when the remote is the canonical `funenc-lab/slidemax` repository
- if the path exists but is not a Git repository, stop and report the conflict
- if the existing remote is anything else, stop and report the conflict
- after clone or reuse, verify `test -f "$SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md"` before continuing

Do not delete, overwrite, or force-reset an unexpected directory or repository.

### Step 4: Install SlideMax Dependencies

According to the companion repository instructions, the minimum dependency installation step is:

```bash
cd "$SLIDEMAX_DIR"
python3 -m pip install -r requirements.txt
```

Execution requirements:

- run the command from the companion repository root
- treat the process exit code as the decision point
- stop immediately if the command fails
- preserve the original error output in the report

`python3 -m pip` is used here to reduce interpreter ambiguity while remaining equivalent to the documented `pip install -r requirements.txt` workflow.

### Step 5: Install the Canonical Companion Skill and Validate the Workspace

After the SlideMax repository is ready, return to this workspace and install the canonical workflow skill from the companion repo:

```bash
cd "$WORKSPACE_DIR"
test -f "$SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md"

if [ -L "$WORKSPACE_DIR/skills/slidemax_workflow" ]; then
  rm "$WORKSPACE_DIR/skills/slidemax_workflow"
elif [ -e "$WORKSPACE_DIR/skills/slidemax_workflow" ]; then
  echo "Target workspace skill path already exists and is not a symlink: $WORKSPACE_DIR/skills/slidemax_workflow" >&2
  exit 1
fi

ln -s "$SLIDEMAX_DIR/skills/slidemax_workflow" "$WORKSPACE_DIR/skills/slidemax_workflow"
test -f "$WORKSPACE_DIR/skills/slidemax_workflow/SKILL.md"
openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' "\"$SLIDEMAX_DIR\""
openclaw config get 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR'
# start a new agent session after installation if an older session was already running
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
```

Rules:

- the runtime `slidemax-workflow` skill must come from `SLIDEMAX_DIR/skills/slidemax_workflow`, not from a hand-written local replacement
- install that canonical companion skill into `WORKSPACE_DIR/skills/slidemax_workflow` before agent registration
- if the workspace skill target exists and is not a symlink, stop and report the conflict
- if either validation command fails, do not continue to agent registration

These validation steps are also the guardrail for the dynamically installed companion workflow: if they fail, the agent must not be registered because the local skill surface is not trusted as complete.

### Step 6: Determine and Apply the Local OpenClaw Action

At this stage, the agent should decide the next action based on the actual local OpenClaw state.
Do not rely on an install helper script.

First inspect the local OpenClaw state:

```bash
command -v openclaw || true
openclaw agents list --json 2>/dev/null || true
```

If `openclaw` is missing, install it first:

```bash
npm install -g openclaw@latest
hash -r
```

Then inspect the local OpenClaw state again:

```bash
openclaw agents list --json
```

Decision rules:

- if the target OpenClaw agent does not exist yet, create it and register this workspace with OpenClaw
- if the target OpenClaw agent already exists, reuse it and do not create a duplicate
- if the target OpenClaw agent already exists and already points to `WORKSPACE_DIR`, update the workspace files and reuse the existing registration
- if the target OpenClaw agent already exists but points to a different workspace, delete it and add it again with `WORKSPACE_DIR`
- the agent should decide the next action based on the actual local OpenClaw state
- use direct OpenClaw commands instead of a helper script

Inspect the registered workspace path from the local OpenClaw state before deciding:

```bash
openclaw agents list --json
```

Direct add path when the agent does not exist:

```bash
openclaw agents add ppt-agent --workspace "$WORKSPACE_DIR" --non-interactive
```

Direct replace path when the agent exists but points to a different workspace:

```bash
openclaw agents delete ppt-agent
openclaw agents add ppt-agent --workspace "$WORKSPACE_DIR" --non-interactive
```

When this add or replace action succeeds, the workspace-local bridge files under `skills/` become available to the agent through the registered workspace.
The canonical `slidemax-workflow` skill should already have been installed during Step 5 at `skills/slidemax_workflow`, sourced from the SlideMax companion repository.
OpenClaw then loads that runtime skill from the workspace path on demand.

If the user provided a custom agent name, replace `ppt-agent` with that name in the inspection, delete, and add commands.

Only determine the local OpenClaw agent status when Step 6 or Step 7 is actually reached.
Do not infer or guess the agent status from earlier workspace, dependency, or validation steps.
If the installation stops before the OpenClaw registration or verification step, report the agent status as undetermined.
If the local OpenClaw state shows that the existing agent already points to this workspace, report the result as an update by workspace reuse rather than a new install.

### Step 7: Post-Install Verification

After the chosen Step 6 action completes, verify the final state with:

```bash
openclaw agents list
```

Recommended follow-up:

```bash
openclaw onboard --install-daemon
```

If the user wants this agent to run more reliably over time, this is a reasonable next step.

### Step 8: Initialize Output Directories (Recommended)

After installation, the AI may initialize the standard output directories:

```bash
mkdir -p \
  "$WORKSPACE_DIR/outputs/decks" \
  "$WORKSPACE_DIR/outputs/reviews" \
  "$WORKSPACE_DIR/outputs/speaker-notes" \
  "$WORKSPACE_DIR/outputs/assets" \
  "$WORKSPACE_DIR/outputs/tmp"
```

Notes:

- this is recommended, not required for installation success
- if the user specified a different output path, use the user preference
- if the task is only installation, creating the directories can be skipped as long as the convention is recorded

## Workspace File Responsibilities

### Root Prompt Files

- `AGENTS.md`
  - the top-level rules file
  - defines default language, output contract, review standards, skill routing, heartbeat behavior, and progress reporting

- `SOUL.md`
  - defines the agent persona and communication style

- `TOOLS.md`
  - defines tool usage constraints, validation boundaries, and heartbeat safety rules

- `USER.md`
  - defines user preferences such as default Chinese responses and summary-first delivery

- `IDENTITY.md`
  - defines the agent name, role, domain, SlideMax generation backend, and working principles

- `HEARTBEAT.md`
  - defines the minimum trigger conditions for proactive follow-up
  - requires `HEARTBEAT_OK` when no action is needed

### Skill Files

These files are workspace-specific skills made available to the agent by registering this workspace.
The canonical runtime `slidemax-workflow` skill is installed from the companion repository into `skills/slidemax_workflow` during Step 5.
The local `skills/final-document-delivery/SKILL.md` skill handles the final publish or send step after artifact generation.
The local `skills/message-channel-delivery/SKILL.md` skill handles the final channel handoff after final document delivery when chat or group delivery is requested.
If any required workspace skill file is missing, do not register or reuse the workspace until validation passes.

- `skills/presentation-workflow/SKILL.md`
  - the workflow entry point for creation, review, rewrite, and conversion tasks
  - prepares narrative inputs before handing actual deck generation to SlideMax when needed

- `skills/final-document-delivery/SKILL.md`
  - sends the finished artifact or document-ready package to a Judao final document, Feishu document, or another final destination
  - reports the final delivery status or a concrete delivery blocker

- `skills/ppt-generation/SKILL.md`
  - generates message-first deck blueprints from raw inputs
  - feeds SlideMax when the deliverable must become an actual PPT artifact

- `skills/ppt-review/SKILL.md`
  - reviews presentation material and prioritizes issues

- `skills/speaker-notes/SKILL.md`
  - produces talk tracks, transitions, emphasis cues, and likely Q&A

- `skills/deck-polish/SKILL.md`
  - tightens wording, sharpens titles, and improves executive readability

- `skills/message-channel-delivery/SKILL.md`
  - sends the final artifact or verified final link to a requested chat, group, or message channel after final document delivery
  - uploads the file artifact for Feishu channel delivery when file handoff is expected

- `skills/slidemax_workflow/SKILL.md`
  - runtime-installed canonical SlideMax workflow skill sourced from the companion repository
  - drives actual PPT, PPTX, SVG, and rendered deck generation after installation

### Operational Scripts

- `scripts/validate_workspace.sh`
  - checks required files and critical prompt constraints

- `tests/test_workspace_structure.sh`
  - runs a lightweight structure regression check

## HEARTBEAT and Progress Reporting

### HEARTBEAT

The goal of `HEARTBEAT.md` is not to increase interruption frequency.
It exists to constrain proactive behavior:

- when no reliable follow-up is needed, return `HEARTBEAT_OK`
- only send proactive follow-up when a delivery is close, the user explicitly requested follow-up, or a critical missing input blocks progress
- proactive messages must be short, concrete, and low-noise

### Progress Reporting

This workspace requires structured progress updates for multi-step PPT tasks and SlideMax-assisted generation flows.
Each update should include:

- completed stage
- current stage
- next stage
- blocker, if one exists

The same pattern is useful for longer installation or configuration flows handled by an AI executor.

## AI Completion Gate

The AI may only claim the installation is complete when all of the following are true:

- the SlideMax companion repository exists at the target path
- the companion repository remote is canonical `funenc-lab/slidemax`
- `python3 -m pip install -r requirements.txt` completed successfully
- `./scripts/validate_workspace.sh` passed
- `./tests/test_workspace_structure.sh` passed
- `openclaw agents list` shows the target agent, or the installer reported that it was already registered

If any of these are missing, the AI may only report partial progress, not full completion.
If the OpenClaw registration or verification step was not reached, the AI must not claim that the agent was newly registered or already existed.

## Common Failure Handling

### 1. The SlideMax Directory Exists but the Remote Does Not Match

If the remote is not `funenc-lab/slidemax`, stop and report the mismatch.
Do not overwrite, delete, rename, or force-change the repository.

### 2. `python3 -m pip install -r requirements.txt` Fails

Stop immediately and preserve the full error output.
Common causes include:

- network failure
- incompatible Python version
- missing native build dependencies
- broken pip configuration

### 3. `Node.js` Is Below `22`

Do not continue to the OpenClaw registration step until Node.js is upgraded.

### 4. `npm install -g openclaw@latest` Fails

Stop the registration flow and preserve the full error output.

### 5. Workspace Validation Fails

Check these files first:

- `AGENTS.md`
- `HEARTBEAT.md`
- `skills/presentation-workflow/SKILL.md`
- `skills/ppt-generation/SKILL.md`
- `skills/ppt-review/SKILL.md`
- `docs/openclaw-install.md`

## Recommended Reporting Shape

When an AI follows this runbook, a useful status report looks like this:

1. environment and paths confirmed
2. SlideMax companion repository status
3. workspace validation status
4. OpenClaw agent registration status, including whether the agent was created or reused
5. remaining risks or blockers

## Conclusion

For an AI executor, the correct order is not “jump to OpenClaw registration immediately”.
The correct order is:

1. confirm the environment
2. install or validate SlideMax
3. validate this workspace
4. register the OpenClaw agent

If step 2 is skipped, the installation is incomplete.
