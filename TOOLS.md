# Tool Usage Guide

## General Rules

- Use browsing or browser-capable tools for current facts, citations, competitor scans, and visual verification.
- Use filesystem and editing tools to create reusable artifacts such as outlines, notes, checklists, tables, scripts, and templates.
- Use code execution only when it clearly improves accuracy, repeatability, or validation.
- Validate important outputs before completion.

## Canonical Contracts

- `AGENTS.md` is the canonical source for global output order, progress reporting, and reusable artifact placement.
- `HEARTBEAT.md` is the canonical source for proactive follow-up triggers and the exact no-op reply.
- This file should only add tool-specific constraints that refine those contracts.

## Presentation Workflow

When building or reviewing presentation material:

1. Identify the audience, objective, time limit, and expected decision.
2. Build the narrative spine before drafting slide-level content.
3. Keep evidence traceable to a source or mark it as an assumption.
4. Produce speaker notes when delivery or persuasion matters.
5. End with concrete decisions, asks, owners, or next actions.

## Tool-Specific Progress Guidance

- Follow the progress structure defined in `AGENTS.md`.
- Use tool calls only when they materially advance the current stage.
- Keep progress updates short and high-signal rather than narrating every command.

## Review Rubric

For reviews and rewrites, assess:

- message clarity
- audience relevance
- evidence sufficiency
- slide density
- recommendation strength
- delivery readiness

## Heartbeat Safety

- Follow `HEARTBEAT.md` for trigger conditions and the exact idle response.
- Do not browse the web or run heavy tools for heartbeat checks unless the user explicitly asked for monitoring.
- Prefer silence over low-confidence proactive messages.

## Output Preferences

- Follow the default output order defined in `AGENTS.md` unless the user asks otherwise.
- Use tables when comparing options, risks, or slide plans.
- Make implicit assumptions explicit.
- Call out missing inputs before overcommitting to specifics.
## SlideMax Usage

- When the requested output is an actual PPT, PPTX, SVG, or generated slide artifact, invoke `skills/slidemax-workflow/SKILL.md` as the local entrypoint to the installed SlideMax companion workflow.
- Use this workspace for narrative planning, review, notes, and presentation logic first, then hand off deck generation to SlideMax.
- If SlideMax is unavailable locally, report that PPT artifact generation is blocked and continue with non-rendered deliverables only.

