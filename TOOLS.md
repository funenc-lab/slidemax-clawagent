# TOOLS.md - PPT Workspace Local Notes

Skills define how tools work. This file records local tool notes, runtime paths, delivery boundaries, and validation commands for this workspace.

Keep global behavior in `AGENTS.md`.
Keep proactive follow-up behavior in `HEARTBEAT.md`.
Use this file only for tool-specific constraints, environment details, and execution notes.

## Canonical Contracts

- `AGENTS.md` is the canonical source for global workflow, progress reporting, output order, and delivery expectations.
- `HEARTBEAT.md` is the canonical source for proactive follow-up triggers and the exact idle response.
- `scripts/check_final_delivery_gate.sh` is the canonical runtime completion contract for final deliverables.
- This file should refine those contracts with local tool guidance instead of duplicating them wholesale.

## Local Tool Priorities

Use the lightest tool that can produce a reliable result:

- Use browsing or browser-capable tools for official documentation, current facts, citations, competitor scans, and visual verification.
- Use filesystem and editing tools for reusable local artifacts such as outlines, notes, reviews, scripts, manifests, and delivery packages.
- Use command execution when it improves repeatability, validation, or artifact generation.
- Validate important outputs before claiming completion.

## Slide Generation Tools

When the requested output is an actual PPT, PPTX, SVG, or generated deck artifact:

- Invoke `slidemax-workflow` as the primary skill.
- The canonical implementation must come from `SLIDEMAX_DIR/skills/slidemax_workflow`.
- Install that canonical skill into this workspace at `skills/slidemax_workflow` before use.
- Use `skills/slidemax-bridge/SKILL.md` only to install, repair, or verify the runtime link.
- Use `presentation-workflow` or `ppt-generation` only as supporting preparation steps when `slidemax-workflow` needs structured input.
- If SlideMax is unavailable locally, report that artifact generation is blocked and continue with non-rendered deliverables only.

## Delivery Tools

When a final artifact must reach an external destination:

- Use `final-document-delivery` for a Judao final document, Feishu document, or another final delivery document.
- Treat repository `outputs/` paths as staging only unless the user explicitly asked for a local-only result.
- Do not treat a local artifact as complete delivery when the requested final destination has not been updated.
- If the user explicitly requests a message channel delivery, send that channel message only after the final artifact exists and the destination is explicit.
- Report the artifact path, final destination, delivery channel status, and delivery status before claiming completion.

## Validation Commands

Use these checks before completion when they apply:

- `bash scripts/validate_workspace.sh`
- `bash tests/test_workspace_structure.sh`
- `bash scripts/check_final_delivery_gate.sh ...`

Do not claim completion for any final deliverable until `scripts/check_final_delivery_gate.sh` or an equivalent wrapper confirms the required fields.

## Heartbeat Safety

- Follow `HEARTBEAT.md` for trigger conditions and the exact idle response.
- Do not browse the web or run heavy tools for heartbeat checks unless the user explicitly asked for monitoring.
- Prefer silence over low-confidence proactive messages.
- Keep heartbeat actions small, concrete, and low-noise.

## Local Environment Notes

- This repository is the OpenClaw workspace, not the SlideMax companion application.
- The companion SlideMax repository provides the runtime deck generation workflow.
- Prefer the OpenClaw per-skill env configuration for `slidemax-workflow`:
  - `openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' '"/absolute/path/to/slidemax"'`
  - `openclaw config get 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR'`
- For service or machine-wide fallback, use `~/.openclaw/.env`.
- For one-off shell overrides, use `export SLIDEMAX_DIR="/absolute/path/to/slidemax"`.

## What Does Not Belong Here

Do not put these here unless they are directly tool-specific:

- agent personality
- presentation narrative principles
- generic review rubrics
- heartbeat content rules
- long-form workflow descriptions better owned by `AGENTS.md`
