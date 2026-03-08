# PPT OpenClaw Agent Workspace

This repository is a production-ready OpenClaw agent workspace for presentation and slide-oriented tasks.

## Executive Summary

This workspace packages a PPT-focused OpenClaw agent with:

- prompt-layer files that define role, tone, tools, and operating rules
- specialized presentation skills for generation, review, polishing, and speaker support
- a tiny heartbeat contract for low-noise follow-up behavior
- install and validation scripts for repeatable workspace registration
- smoke tests for the installation preflight and agent registration flow

This workspace is intended to be installed together with the companion repository `ppt-master`, whose canonical repository address is:

- `https://github.com/funenc-lab/slidemax`

For the full AI-oriented installation runbook, see `docs/openclaw-install.md`.

## Companion Requirement

Before registering this workspace with OpenClaw, install the companion project `ppt-master` from the canonical repository `funenc-lab/slidemax`.

According to the official `ppt-master` / `slidemax` repository, the minimum setup includes:

- `Python 3.8+`
- `pip install -r requirements.txt`

This repository does not auto-clone or auto-install `ppt-master`; that dependency is documented and guided in `docs/openclaw-install.md`.

## What it includes

- Standard OpenClaw workspace prompt files: `AGENTS.md`, `SOUL.md`, `TOOLS.md`, `USER.md`, `IDENTITY.md`
- Core orchestration skill: `skills/presentation-workflow/SKILL.md`
- Specialized PPT skills:
  - `skills/ppt-generation/SKILL.md`
  - `skills/ppt-review/SKILL.md`
  - `skills/speaker-notes/SKILL.md`
  - `skills/deck-polish/SKILL.md`
- A lightweight proactive heartbeat contract: `HEARTBEAT.md`
- Validation script: `scripts/validate_workspace.sh`
- Installation script: `scripts/install_openclaw_agent.sh`
- Install smoke test: `tests/test_install_openclaw_agent.sh`
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

### Operational Layer

- `scripts/install_openclaw_agent.sh`: validates the workspace, preflights the companion repository, ensures OpenClaw CLI exists, and registers the agent
- `scripts/validate_workspace.sh`: checks required files and key prompt constraints
- `tests/test_workspace_structure.sh`: smoke test for expected workspace structure
- `tests/test_install_openclaw_agent.sh`: behavior-level smoke test for install preflight and agent registration

## Installation Overview

The expected installation sequence is:

1. clone or update the companion repository `ppt-master`
2. install `ppt-master` Python dependencies
3. validate this workspace
4. verify `Node.js 22+`
5. install `openclaw` globally if needed
6. register this repository as an OpenClaw workspace

## Quick Install

Read `docs/openclaw-install.md` first if an AI agent is performing the installation.

Then run:

```bash
./scripts/install_openclaw_agent.sh
```

You can also specify a custom agent name:

```bash
./scripts/install_openclaw_agent.sh my-ppt-agent
```

To point at a non-default companion repository path:

```bash
PPT_MASTER_DIR=/absolute/path/to/ppt-master ./scripts/install_openclaw_agent.sh
```

To bypass the companion preflight intentionally:

```bash
./scripts/install_openclaw_agent.sh --skip-companion-check my-ppt-agent
```

## Quick Validate

```bash
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
./tests/test_install_openclaw_agent.sh
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
- the companion repository `ppt-master` can be cloned from the canonical `slidemax` repository on GitHub
- this repository path is the intended OpenClaw workspace location
- the target agent should remain presentation-focused and low-noise in heartbeat mode

## Extension Points

- remove the legacy `funenc-lab/ppt-master` fallback after the migration window closes
- add richer `.pptx` handling or export workflows
- add more domain skills such as board updates, sales pitches, or technical design reviews
- add troubleshooting, upgrade, or uninstall guidance to `docs/openclaw-install.md`
