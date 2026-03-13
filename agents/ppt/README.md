# PPT OpenClaw Agent Workspace

This directory is the installed OpenClaw workspace for the PPT agent.
It is not the SlideMax companion application.

## Runtime Layout

- workspace root: this directory
- runtime scripts: `scripts/`
- runtime tests: `tests/`
- runtime skills: `skills/`

## External Dependencies

- The actual deck generation backend lives in the external SlideMax repository.
- The final `slidemax_workflow` skill must be installed at `skills/slidemax_workflow`.
- If `slidemax_workflow` or `SLIDEMAX_DIR` is missing, actual PPT, PPTX, SVG, and rendered deck generation is blocked.

## Runtime Rules

- Treat this workspace as the runtime execution home for PPT tasks.
- Use `AGENTS.md` as the primary workspace contract.
- Use `TOOLS.md` for runtime-specific tool and delivery notes.
- Use `scripts/check_final_delivery_gate.sh` before claiming final delivery completion.
