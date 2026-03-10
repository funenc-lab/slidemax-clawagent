# TOOLS.md - Local Tool Notes

This file is for local environment notes, runtime paths, delivery-specific execution details, and validation commands.

Keep global behavior in `AGENTS.md`.
Keep proactive follow-up behavior in `HEARTBEAT.md`.
Keep personality in `SOUL.md`.
Keep user profile data in `USER.md`.

## What Belongs Here

Use this file for:

- local runtime paths
- workspace-specific tool constraints
- environment-specific delivery notes
- validation commands that operators should actually run here

Do not turn this into a second `AGENTS.md`.

## Canonical Contracts

- `AGENTS.md` is the canonical source for global workflow, progress reporting, output order, and delivery expectations.
- `HEARTBEAT.md` is the canonical source for proactive follow-up triggers and the exact idle response.
- `scripts/check_final_delivery_gate.sh` is the canonical runtime completion contract for final deliverables.

## Reading Notes

- Prefer targeted discovery first with file search, headings, or narrow section reads.
- Prefer `rg` plus a focused `sed -n` range over dumping an entire long file.
- Read additional sections only when the current excerpt does not answer the task.
- Do not load every skill or reference file in advance; follow links only when they are needed.

## Local Runtime Notes

- This repository contains the source OpenClaw workspace, not the SlideMax companion application.
- The companion SlideMax repository provides the runtime deck generation workflow.
- The canonical generation skill must come from `SLIDEMAX_DIR/skills/slidemax_workflow`.
- Copy-install that canonical skill into the final OpenClaw workspace at `skills/slidemax_workflow`.
- Install the canonical skill during the installation flow instead of routing through a local bridge skill.

## Slide Generation Notes

When the requested output is an actual PPT, PPTX, SVG, or generated deck artifact:

- Treat SlideMax and `slidemax-workflow` as prerequisites, not optional helpers.
- Use `slidemax-workflow` as the primary skill.
- Use `presentation-workflow` or `ppt-generation` only as supporting preparation steps when `slidemax-workflow` needs structured input.
- If SlideMax is unavailable locally, report that artifact generation is blocked and continue with non-rendered deliverables only.

## Delivery Notes

When a final artifact must reach an external destination:

- Use `final-document-delivery` for a Judao final document, Feishu document, or another final delivery document.
- Use `message-channel-delivery` when the user also requests a chat, group, or channel handoff after final delivery.
- Treat workspace-root `outputs/` paths as staging only unless the user explicitly asked for a local-only result.
- Do not treat a local artifact as complete delivery when the requested final destination has not been updated.
- If the final delivery ecosystem is Feishu, the final destination must be a Feishu document rather than a Feishu chat or group.
- If the user explicitly requests a message channel delivery, perform that handoff only after the final artifact exists and the destination is explicit.
- If the requested channel is Feishu, complete the Feishu document upload first and then send a Feishu online document link message as the secondary handoff.
- Report the artifact path, final destination, delivery channel status, and delivery status before claiming completion.

## Validation Commands

Use these checks before completion when they apply:

- `bash scripts/validate_workspace.sh`
- `bash tests/test_workspace_structure.sh`
- `bash scripts/check_final_delivery_gate.sh ...`

Do not claim completion for any final deliverable until `scripts/check_final_delivery_gate.sh` or an equivalent wrapper confirms the required fields.

## Environment Configuration

Prefer the OpenClaw per-skill env configuration for `slidemax-workflow`:

- `openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' '"/absolute/path/to/slidemax"'`
- `openclaw config get 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR'`

For service or machine-wide fallback, use `~/.openclaw/.env`.
For one-off shell overrides, use `export SLIDEMAX_DIR="/absolute/path/to/slidemax"`.

## Heartbeat Safety

- Follow `HEARTBEAT.md` for trigger conditions and the exact idle response.
- Do not browse the web or run heavy tools for heartbeat checks unless the user explicitly asked for monitoring.
- Prefer silence over low-confidence proactive messages.
