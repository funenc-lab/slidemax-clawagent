---
name: slidemax-workflow
description: Use when the user needs an actual PPT, PPTX, SVG, or rendered deck artifact and the local SlideMax companion repository is available.
---

# SlideMax Workflow

Use this skill when the user needs an actual slide artifact instead of only an outline, rewrite, review, or speaker notes.

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

### 2. Confirm structured inputs

Before generation, make sure you already have:

- audience and objective
- slide-by-slide blueprint or deck-ready content
- required visuals, notes, or export constraints
- output directory or filename expectation

If those inputs are incomplete, return to `presentation-workflow` or `ppt-generation` first.

### 3. Use SlideMax as the execution layer

Treat SlideMax as the rendering and export backend.
This workspace should prepare the narrative and deck structure first, then hand the generation step to the installed SlideMax companion workflow.

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
