---
name: slidemax-workflow
description: Primary skill for actual PPT, PPTX, SVG, or rendered deck artifact generation when the local SlideMax companion repository is available.
---

# SlideMax Workflow

Use this skill when the user needs an actual slide artifact instead of only an outline, rewrite, review, or speaker notes. Select this skill first for actual deck generation requests.

## Goals

Turn a validated deck blueprint into a generated PPT artifact through the installed SlideMax companion repository.

## When To Use

Use this skill when:

- the deliverable must become a real PPT, PPTX, SVG, or rendered deck artifact
- the narrative, slide plan, or deck blueprint is already available
- the local SlideMax companion repository is installed and ready

Do not use this skill when the task only needs:

- a slide outline
- rewritten slide copy
- speaker notes
- a review report
- a recommendation memo

## Progress Reporting

For multi-step deck generation, provide short progress updates with:

- completed stage
- current stage
- next stage
- blocker, if any

Suggested milestones:

- deck blueprint confirmed
- SlideMax input prepared
- generation command completed
- artifact verification completed

## Workflow

### 1. Confirm SlideMax availability

Verify that the local SlideMax companion repository is installed.
If it is missing, stop the generation flow and report that actual PPT generation is blocked.

For a custom companion path, prefer the OpenClaw per-skill env configuration:

```bash
openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' '"/absolute/path/to/slidemax"'
```

If persistent service-level fallback is needed, use `~/.openclaw/.env`. For a one-off shell override, use `export SLIDEMAX_DIR="/absolute/path/to/slidemax"`.

### 2. Confirm structured inputs

Before generation, make sure you already have:

- audience and objective
- slide-by-slide blueprint or deck-ready content
- required visuals, notes, or export constraints
- output directory or filename expectation

If those inputs are incomplete, gather them through `presentation-workflow` or `ppt-generation`, then resume this skill as the task owner for final generation.

### 3. Use SlideMax as the execution layer

Treat SlideMax as the rendering and export backend.
This workspace should prepare the narrative and deck structure first, then hand the generation step to the installed SlideMax companion workflow.

Resolve the companion path in this order:

1. `SLIDEMAX_DIR` already present in the process environment
2. OpenClaw per-skill env injection such as `skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR`
3. OpenClaw-loaded `.env` values such as `~/.openclaw/.env`
4. the default sibling path `<workspace-parent>/slidemax`

### 4. Place outputs predictably

Unless the user requests another location, write generated deck artifacts under `outputs/decks/` using English-only names.
Keep related exported files together in the same task folder.

### 5. Report result clearly

Report:

- the workspace path used
- the SlideMax companion path used
- the output artifact path
- validation or generation results
- any blocker, warning, or missing dependency
