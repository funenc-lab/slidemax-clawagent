# PPT OpenClaw Agent Workspace

This repository is a production-ready OpenClaw agent workspace for presentation and slide-oriented tasks.

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
- Chinese installation guide: `docs/openclaw-install.md`

## Workspace focus

This agent is designed for:

- executive updates
- project reviews
- technical presentations
- proposal and pitch decks
- speaker notes and delivery coaching
- presentation content review and rewrite

## Install

```bash
./scripts/install_openclaw_agent.sh
```

You can also specify a custom agent name:

```bash
./scripts/install_openclaw_agent.sh my-ppt-agent
```

## Validate

```bash
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
```
