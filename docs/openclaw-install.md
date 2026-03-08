# OpenClaw PPT Agent AI Installation Runbook

## Executive Summary

This document is a full installation runbook for an AI executor, not a short end-user note.
The goal is to ensure the AI completes the installation in the correct order:

1. Install the SlideMax companion repository used for actual PPT generation
2. Register this repository as an OpenClaw agent workspace

Key facts:

- The canonical repository address for SlideMax is `https://github.com/funenc-lab/slidemax`
- Only the canonical `funenc-lab/slidemax` remote is supported by this installation flow
- The agent uses the installed SlideMax repository as the workflow skill backend for actual PPT generation
- The workspace exposes `skills/slidemax-workflow/SKILL.md` as the local skill entrypoint for that generation flow
- This repository contains the OpenClaw workspace, not the SlideMax companion application itself
- `scripts/install_openclaw_agent.sh` does not clone SlideMax
- `scripts/install_openclaw_agent.sh` does not install the Python dependencies for SlideMax

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

- The workspace install script validates the workspace first
- The workspace install script validates the companion repository path, origin, and `requirements.txt`
- The workspace install script requires `Node.js 22+`
- The workspace install script installs `openclaw` only when it is missing
- The companion repository requires at least `Python 3.8+`
- The companion repository installs dependencies with `pip install -r requirements.txt`
- The canonical GitHub repository for the companion project is `funenc-lab/slidemax`
- The companion repository contains the workflow and commands used by the agent to generate PPT artifacts

### Assumptions

This runbook assumes:

- `git`, `python3`, `pip`, `node`, and `npm` are available
- this workspace repository already exists locally
- the current working directory is the root of this workspace
- network access to GitHub and npm is available
- if the user does not provide a custom companion path, the companion repository will live next to this workspace

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
- `./scripts/validate_workspace.sh` succeeds
- `./tests/test_workspace_structure.sh` succeeds
- `openclaw agents list` shows the agent, or the install script confirms that it is already registered

## Output Directory Convention

Unless the user explicitly requests another location, generated reusable artifacts should be written under the repository-root `outputs/` directory.

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
- do not write generated deliverables to the repository root unless the user explicitly asks for that
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

### Step 0: Resolve Paths

First compute the local paths:

```bash
WORKSPACE_DIR=$(pwd)
PARENT_DIR=$(dirname "$WORKSPACE_DIR")
SLIDEMAX_DIR="${PARENT_DIR}/slidemax"
```

Then report:

- the current workspace path
- the chosen SlideMax companion repository path

If the user explicitly provided a custom companion path, use that path instead.

Supported override names:

- use `SLIDEMAX_DIR` as the supported environment variable
- use `--slidemax-dir` as the supported CLI override
- do not invent alternate environment variable names for the companion path

### Step 1: Check Required Tools

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
- the workspace installer requires `Node.js 22+`

If `Node.js` is below `22`, do not run the workspace install script.
If `Python` is below `3.8`, do not proceed with the companion repository installation.

### Step 2: Install or Reuse SlideMax

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
- if the path exists and is a Git repository, reuse it only when the remote is `https://github.com/funenc-lab/slidemax.git`
- if the path exists but is not a Git repository, stop and report the conflict
- if the existing remote is anything else, stop and report the conflict

Do not delete, overwrite, or force-reset an unexpected directory or repository.

### Step 3: Install SlideMax Dependencies

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

### Step 4: Return to the Workspace and Validate It

After the SlideMax repository is ready, return to this workspace:

```bash
cd "$WORKSPACE_DIR"
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
```

If either command fails, do not continue to agent registration.

### Step 5: Install and Register the OpenClaw Workspace

Run the default install command:

```bash
./scripts/install_openclaw_agent.sh
```

Agent handling rule:

- if the target OpenClaw agent does not exist yet, create it
- if the target OpenClaw agent already exists, reuse it and do not create a duplicate

If the user provided a custom agent name:

```bash
./scripts/install_openclaw_agent.sh my-ppt-agent
```

If the SlideMax repository is not located at the default sibling path:

```bash
SLIDEMAX_DIR=/absolute/path/to/slidemax ./scripts/install_openclaw_agent.sh
```

Supported CLI override:

```bash
./scripts/install_openclaw_agent.sh --slidemax-dir /absolute/path/to/slidemax
```

If you intentionally need to bypass companion preflight validation in a controlled exception case:

```bash
./scripts/install_openclaw_agent.sh --skip-companion-check my-ppt-agent
```

`--skip-companion-check` should not be used as the default path.

The script currently performs these actions internally:

It resolves the companion repository path in this order:

1. `SLIDEMAX_DIR`
2. `../slidemax`

The script then:

1. run `./scripts/validate_workspace.sh`
2. validate the SlideMax companion repository path, origin, and `requirements.txt`
3. verify `Node.js 22+`
4. install `openclaw` if it is missing
5. check whether the agent is already registered
6. register this workspace with OpenClaw only when the target agent does not already exist

If the target agent is already registered, the script reports that state and skips duplicate registration.

The AI does not need to reimplement these steps, but it must remember that the script does not clone SlideMax and does not install the Python dependencies for SlideMax.
The script only fails early when the companion repository is missing or incorrectly configured.

### Step 6: Post-Install Verification

After registration, verify the final state with:

```bash
openclaw agents list
```

Recommended follow-up:

```bash
openclaw onboard --install-daemon
```

If the user wants this agent to run more reliably over time, this is a reasonable next step.

### Step 7: Initialize Output Directories (Recommended)

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

- `skills/presentation-workflow/SKILL.md`
  - the workflow entry point for creation, review, rewrite, and conversion tasks
  - prepares narrative inputs before handing actual deck generation to SlideMax when needed

- `skills/ppt-generation/SKILL.md`
  - generates message-first deck blueprints from raw inputs
  - feeds SlideMax when the deliverable must become an actual PPT artifact

- `skills/ppt-review/SKILL.md`
  - reviews presentation material and prioritizes issues

- `skills/speaker-notes/SKILL.md`
  - produces talk tracks, transitions, emphasis cues, and likely Q&A

- `skills/deck-polish/SKILL.md`
  - tightens wording, sharpens titles, and improves executive readability

- `skills/slidemax-workflow/SKILL.md`
  - routes actual PPT, PPTX, SVG, and rendered deck generation to the installed SlideMax companion workflow
  - blocks generation cleanly when SlideMax is not installed locally

### Operational Scripts

- `scripts/install_openclaw_agent.sh`
  - validates the workspace
  - validates the companion repository
  - checks `Node.js 22+`
  - installs `openclaw` if needed
  - registers the workspace as an agent

- `scripts/validate_workspace.sh`
  - checks required files and critical prompt constraints

- `tests/test_workspace_structure.sh`
  - runs a lightweight structure regression check

- `tests/test_install_openclaw_agent.sh`
  - runs a behavior-level smoke test for companion preflight and agent registration logic

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

Do not run `./scripts/install_openclaw_agent.sh` until Node.js is upgraded.

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
- `scripts/install_openclaw_agent.sh`

## Recommended Reporting Shape

When an AI follows this runbook, a useful status report looks like this:

1. environment and paths confirmed
2. SlideMax companion repository status
3. workspace validation status
4. OpenClaw agent registration status, including whether the agent was created or reused
5. remaining risks or blockers

## Conclusion

For an AI executor, the correct order is not “run `./scripts/install_openclaw_agent.sh` immediately”.
The correct order is:

1. confirm the environment
2. install or validate SlideMax
3. validate this workspace
4. register the OpenClaw agent

If step 2 is skipped, the installation is incomplete.
