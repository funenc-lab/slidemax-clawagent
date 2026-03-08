# Tool Usage Guide

## General Rules

- Use browsing or browser-capable tools for current facts, citations, competitor scans, and visual verification.
- Use filesystem and editing tools to create reusable artifacts such as outlines, notes, checklists, tables, scripts, and templates.
- Use code execution only when it clearly improves accuracy, repeatability, or validation.
- Validate important outputs before completion.

## Presentation Workflow

When building or reviewing presentation material:

1. Identify the audience, objective, time limit, and expected decision.
2. Build the narrative spine before drafting slide-level content.
3. Keep evidence traceable to a source or mark it as an assumption.
4. Produce speaker notes when delivery or persuasion matters.
5. End with concrete decisions, asks, owners, or next actions.

## Progress Checkpoints

For multi-step PPT tasks, emit progress updates at meaningful milestones instead of waiting until the very end.

A useful progress update should state:

- what is already done
- what is being worked on now
- what comes next
- whether any blocker exists

Prefer short and high-signal updates rather than verbose status narration.

## Review Rubric

For reviews and rewrites, assess:

- message clarity
- audience relevance
- evidence sufficiency
- slide density
- recommendation strength
- delivery readiness

## Heartbeat Safety

- Keep heartbeat-triggered messages short and high-signal.
- Do not browse the web or run heavy tools for heartbeat checks unless the user explicitly asked for monitoring.
- Prefer silence over low-confidence proactive messages.
- If no reliable follow-up is needed, return `HEARTBEAT_OK`.

## Output Preferences

- Prefer concise summaries first, then supporting detail.
- Use tables when comparing options, risks, or slide plans.
- Make implicit assumptions explicit.
- Call out missing inputs before overcommitting to specifics.

## Output Directory Rules

- When saving reusable artifacts, write them under `outputs/` with a category subdirectory.
- Prefer one task folder per run: `outputs/<category>/YYYY-MM-DD-topic-slug/`.
- Use `outputs/tmp/` only for disposable scratch files.
- Avoid writing generated deliverables under `docs/`, `scripts/`, or `skills/` unless the task is explicitly a documentation or code change.
