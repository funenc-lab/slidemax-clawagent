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

There is no separate per-skill installation command for this agent.
The local files under `skills/` are workspace-specific skills that become available to the agent through the registered workspace.
Those skill files are loaded on demand rather than copied into the agent as a separate install artifact.
If workspace validation fails, do not register the agent because the skill set is incomplete.

## What it includes

- Standard OpenClaw workspace prompt files: `AGENTS.md`, `SOUL.md`, `TOOLS.md`, `USER.md`, `IDENTITY.md`
- Core orchestration skill: `skills/presentation-workflow/SKILL.md`
- Specialized PPT skills:
  - `skills/ppt-generation/SKILL.md`
  - `skills/ppt-review/SKILL.md`
  - `skills/speaker-notes/SKILL.md`
  - `skills/deck-polish/SKILL.md`
  - `skills/slidemax-workflow/SKILL.md`
- A lightweight proactive heartbeat contract: `HEARTBEAT.md`
- Validation script: `scripts/validate_workspace.sh`
- Workspace structure smoke test: `tests/test_workspace_structure.sh`
- SlideMax companion workflow and local skill entrypoint for actual PPT generation
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

- `skills/presentation-workflow/SKILL.md`: entry workflow for create, review, rewrite, and conversion tasks
- `skills/ppt-generation/SKILL.md`: message-first deck generation from raw input
- `skills/ppt-review/SKILL.md`: structured review and prioritized fixes
- `skills/speaker-notes/SKILL.md`: talk tracks, transitions, and likely Q&A
- `skills/deck-polish/SKILL.md`: executive-style tightening and readability improvements
- `skills/slidemax-workflow/SKILL.md`: handoff entrypoint that routes actual PPT generation to the installed SlideMax companion workflow

### Operational Layer

- `scripts/validate_workspace.sh`: checks required files and key prompt constraints
- `tests/test_workspace_structure.sh`: smoke test for expected workspace structure
- `docs/openclaw-install.md`: canonical AI installation runbook with local-state decision rules

## Installation Overview

The expected installation sequence is:

1. clone or update the SlideMax companion repository
2. install the SlideMax Python dependencies
3. validate this workspace
4. verify `Node.js 22+`
5. install `openclaw` globally if needed
6. register this repository as an OpenClaw workspace

## Quick Install

Read `docs/openclaw-install.md` first if an AI agent is performing the installation.

For a direct manual setup after the prerequisites are ready, use the local-state flow:

```bash
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
command -v openclaw >/dev/null 2>&1 || npm install -g openclaw@latest
openclaw agents list --json
openclaw agents add ppt-agent --workspace "$(pwd)" --non-interactive
openclaw agents list
```

If the target agent already exists and already points to this workspace, update the workspace files and reuse the existing registration.
If the target agent already exists but points to a different workspace, delete it and add it again with the current workspace.
If the target agent does not exist, add it with the current workspace.
Reusing or creating the agent from this workspace makes the bundled local skills from `skills/` available through the registered workspace.
If the SlideMax repository is not in the default sibling path, set `SLIDEMAX_DIR` in the shell session before following the runbook.

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
