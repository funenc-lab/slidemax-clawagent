---
name: slidemax-bridge
description: Use when installing, repairing, or verifying the SlideMax companion workflow skill for this workspace. This local bridge skill does not replace the canonical slidemax-workflow skill from the SlideMax repository.
---

# SlideMax Bridge

Use this skill when you need to install, refresh, or verify the canonical `slidemax-workflow` skill from the SlideMax companion repository.

## Purpose

This workspace does not own the canonical implementation of `slidemax-workflow`.
The canonical skill must come from the installed SlideMax companion repository at `SLIDEMAX_DIR/skills/slidemax_workflow`.
This bridge skill exists only to help the agent install that companion skill into the workspace and verify that the runtime path is correct.

## When To Use

Use this skill when:

- the local SlideMax companion repository was just cloned or updated
- `slidemax-workflow` is missing from the active skill set
- the workspace link to `skills/slidemax_workflow` must be created or repaired
- `SLIDEMAX_DIR` must be configured for the companion workflow
- a PPT generation request is blocked because the companion skill is unavailable

Do not use this skill as the final deck generation skill.
When the companion skill is installed and available, use the canonical `slidemax-workflow` skill from the SlideMax repository for actual PPT generation.

## Workflow

### 1. Resolve the companion repository path

Use `SLIDEMAX_DIR` if it is already provided.
Otherwise use the default sibling path `<workspace-parent>/slidemax`.

### 2. Verify the canonical companion skill exists

The required file is:

```bash
test -f "$SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md"
```

If this file is missing, stop and report that the SlideMax companion skill is not installed yet.

### 3. Install the companion skill into this workspace

Create the runtime workspace link only after the companion skill path is confirmed:

```bash
if [ -L "$WORKSPACE_DIR/skills/slidemax_workflow" ]; then
  rm "$WORKSPACE_DIR/skills/slidemax_workflow"
elif [ -e "$WORKSPACE_DIR/skills/slidemax_workflow" ]; then
  echo "Target workspace skill path already exists and is not a symlink: $WORKSPACE_DIR/skills/slidemax_workflow" >&2
  exit 1
fi

ln -s "$SLIDEMAX_DIR/skills/slidemax_workflow" "$WORKSPACE_DIR/skills/slidemax_workflow"
test -f "$WORKSPACE_DIR/skills/slidemax_workflow/SKILL.md"
```

### 4. Configure the companion path for the canonical skill

Prefer the OpenClaw per-skill env configuration for the canonical `slidemax-workflow` skill:

```bash
openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' '"/absolute/path/to/slidemax"'
openclaw config get 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR'
```

If persistent service-level fallback is needed, use `~/.openclaw/.env`.
For a one-off shell override, use `export SLIDEMAX_DIR="/absolute/path/to/slidemax"`.

### 5. Hand control back to the canonical workflow skill

After the companion skill is linked into `skills/slidemax_workflow`, start a new agent session if needed and use `slidemax-workflow` for actual PPT, PPTX, SVG, or deck generation.

## Report

Report:

- the workspace path used
- the SlideMax companion path used
- whether `skills/slidemax_workflow` now points to the companion repo skill
- whether `skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR` is configured
- any blocker, warning, or failure output
