# PPT OpenClaw Agent Workspace

This repository is a production-ready OpenClaw agent workspace for presentation strategy, deck writing, slide review, speaker notes, and delivery execution.

It follows the OpenClaw workspace model: the workspace is the agent's home, prompt layer, local memory surface, and task operating context. This repository is the workspace. It is not the SlideMax companion application and it is not the OpenClaw runtime itself.

## Executive Summary

This workspace provides:

- a prompt layer that defines identity, workflow, safety boundaries, tool usage, and heartbeat behavior
- PPT-specific skills for generation, review, polishing, speaker support, and final delivery
- a bridge path to the canonical SlideMax workflow used for actual PPT generation
- validation scripts and smoke tests for repeatable workspace verification
- a final delivery contract that requires artifact generation, destination delivery, and `Delivery status`

Canonical repositories:

- SlideMax companion repository: `https://github.com/funenc-lab/slidemax`
- OpenClaw workspace repository: `https://github.com/funenc-lab/slidemax-clawagent`

For the full AI-oriented installation runbook, see `docs/openclaw-install.md`.

## How This Maps to OpenClaw

According to the OpenClaw workspace model, a workspace should contain the durable operating instructions that shape how the agent behaves in repeated sessions.

In this repository:

- `AGENTS.md` defines the global operating contract, startup order, progress rules, delivery flow, and heartbeat behavior
- `TOOLS.md` defines local tool notes, runtime paths, validation commands, and delivery tooling boundaries
- `SOUL.md`, `USER.md`, and `IDENTITY.md` define persona, user preferences, and domain identity
- `HEARTBEAT.md` keeps the proactive follow-up contract tiny and low-noise
- `skills/` contains workspace-specific skills and the runtime link target for deck generation

The canonical runtime generation skill is not authored here. It comes from the installed SlideMax companion repository and is linked into this workspace at `skills/slidemax_workflow/SKILL.md`.

## Companion Requirement

Before registering this workspace with OpenClaw, install the SlideMax companion project from the canonical repository `funenc-lab/slidemax`.

Required companion facts:

- the canonical runtime workflow is sourced from `SLIDEMAX_DIR/skills/slidemax_workflow`
- the runtime skill must appear in this workspace at `skills/slidemax_workflow/SKILL.md`
- the local file `skills/slidemax-bridge/SKILL.md` is only a bridge skill for install, repair, and verification
- the local file `skills/final-document-delivery/SKILL.md` handles final delivery after artifacts exist
- this workspace is usable for outlines, reviews, and notes even when SlideMax is missing, but actual PPT generation remains blocked

According to the companion repository, the minimum setup includes:

- `Python 3.8+`
- `pip install -r requirements.txt`

## Workspace Layout

### Prompt Layer

- `AGENTS.md`
- `TOOLS.md`
- `SOUL.md`
- `USER.md`
- `IDENTITY.md`
- `HEARTBEAT.md`

### Skill Layer

- `skills/presentation-workflow/SKILL.md`
- `skills/ppt-generation/SKILL.md`
- `skills/ppt-review/SKILL.md`
- `skills/speaker-notes/SKILL.md`
- `skills/deck-polish/SKILL.md`
- `skills/slidemax-bridge/SKILL.md`
- `skills/slidemax_workflow/SKILL.md`
- `skills/final-document-delivery/SKILL.md`

### Operational Layer

- `scripts/validate_workspace.sh`
- `tests/test_workspace_structure.sh`
- `scripts/check_final_delivery_gate.sh`
- `tests/test_final_delivery_gate.sh`
- `docs/openclaw-install.md`

## Operating Model

This workspace is designed for the full PPT lifecycle, not only for draft generation.

The standard flow is:

1. capture audience, objective, decision, timing, and final delivery destination
2. gather evidence and existing materials
3. design the narrative spine
4. draft slide-by-slide structure and notes
5. review and polish the content
6. generate the artifact with SlideMax when an actual PPT, PPTX, or SVG is required
7. deliver the result to the requested final document destination
8. if explicitly requested, send the completion message to the target message channel
9. run the delivery gate and report `Delivery status`

The delivery chain is therefore:

1. content work in this workspace
2. artifact generation through the canonical SlideMax workflow when needed
3. publication to a final document destination such as a Judao final document or a Feishu document
4. optional message-channel handoff when explicitly requested

## Installation Overview

The expected installation sequence is:

1. clone or update the SlideMax companion repository
2. install the SlideMax Python dependencies
3. install the canonical `slidemax_workflow` skill from the companion repo into this workspace
4. validate this workspace
5. verify `Node.js 22+`
6. install `openclaw` globally if needed
7. register this repository as an OpenClaw workspace

Read `docs/openclaw-install.md` first if an AI agent is performing the installation.

## Quick Install

For a direct manual setup after the prerequisites are ready, use the local-state flow:

```bash
WORKSPACE_DIR="$(pwd)"
PARENT_DIR="$(dirname "$WORKSPACE_DIR")"
SLIDEMAX_DIR="${SLIDEMAX_DIR:-$PARENT_DIR/slidemax}"

command -v openclaw >/dev/null 2>&1 || npm install -g openclaw@latest
test -f "$SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md"

if [ -L "$WORKSPACE_DIR/skills/slidemax_workflow" ]; then
  rm "$WORKSPACE_DIR/skills/slidemax_workflow"
elif [ -e "$WORKSPACE_DIR/skills/slidemax_workflow" ]; then
  echo "Target workspace skill path already exists and is not a symlink: $WORKSPACE_DIR/skills/slidemax_workflow" >&2
  exit 1
fi

ln -s "$SLIDEMAX_DIR/skills/slidemax_workflow" "$WORKSPACE_DIR/skills/slidemax_workflow"
openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' "\"$SLIDEMAX_DIR\""
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
openclaw agents list --json
openclaw agents add ppt-agent --workspace "$WORKSPACE_DIR" --non-interactive
openclaw agents list
```

If the target agent already exists and already points to `WORKSPACE_DIR`, update the workspace files and reuse the existing registration.
If the target agent already exists but points to a different workspace, delete it and add it again with the current workspace.
If the target agent does not exist, add it with the current workspace.

## SlideMax Environment Configuration

If the SlideMax repository is not installed at the default sibling path, prefer configuring the companion path through OpenClaw's per-skill env injection for the canonical `slidemax-workflow` skill after `skills/slidemax_workflow` is installed into this workspace:

```bash
openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' '"/absolute/path/to/slidemax"'
openclaw config get 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR'
```

This is the preferred persistent setup for this workspace because OpenClaw applies `skills.entries.<skill>.env` to the host process for the agent run.

If you need a global fallback that also works when OpenClaw runs as a service, put the variable in `~/.openclaw/.env`.

For a one-off shell-only override, use:

```bash
export SLIDEMAX_DIR="/absolute/path/to/slidemax"
```

## AI Install Prompt

If you want an AI coding agent to perform the installation, copy the following Markdown prompt and give it to the agent directly:

```markdown
Treat the following file as the installation runbook (execution prompt file) and follow it exactly:
https://raw.githubusercontent.com/funenc-lab/slidemax-clawagent/main/docs/openclaw-install.md

Read it completely and execute the installation exactly as written in that file.
Do not skip steps and do not change the documented order.
Treat the exact workspace path as the absolute path of the local slidemax-clawagent repository root.
If the workspace repository is missing locally, clone it first and enter its root before following the runbook.
Inspect the local OpenClaw installation and agent state yourself, then choose the direct valid path.

After execution, report:
- the exact workspace path
- the exact companion path
- the validation results
- whether the agent was newly registered or already existed, only when the local OpenClaw agent state is made explicit by the runbook steps; otherwise report it as undetermined
- any blocker or failure output
```

## Quick Validate

```bash
./scripts/validate_workspace.sh
./tests/test_workspace_structure.sh
```

## Final Delivery Requirement

The repository-root `outputs/` directory is only a staging area for generated files.
Unless the user explicitly asks for a local-only draft, the agent is not done until the final artifact or document-ready package has been sent or published to the requested final delivery document.

Expected delivery behavior:

- Prefer the project final document destination such as a Judao final document or a Feishu document.
- If the user explicitly requests a message channel, send that channel message only after the final destination is explicit and the artifact exists.
- Report the final artifact path, final destination, and `Delivery status` in the completion message.
- If the final document destination is missing, ask for it before claiming completion.
- If publishing is blocked by missing tools, authentication, or network access, still generate the final local artifact and report the exact blocker plus the next manual delivery step.
- Run `scripts/check_final_delivery_gate.sh` before claiming completion for any final deliverable.
- Treat the CLI of `scripts/check_final_delivery_gate.sh` as the canonical runtime completion contract.
- `local-only-draft` only passes with explicit local-only approval evidence from the user request.
- `blocked` only passes after a real delivery attempt and explicit verification evidence for the blocker.

## Output Directories

Generated local artifacts should be written under the repository-root `outputs/` directory unless the user explicitly requests a different path.

Preferred layout:

- `outputs/decks/`
- `outputs/reviews/`
- `outputs/speaker-notes/`
- `outputs/assets/`
- `outputs/tmp/`

Naming rules:

- use English-only file and directory names
- prefer `YYYY-MM-DD-topic-slug` task folders
- keep all files for one task in the same task folder
- avoid writing generated deliverables to the repository root

## Runtime Completion Gate

Use `scripts/check_final_delivery_gate.sh` to enforce the final delivery contract before claiming completion. The CLI of this script is the canonical runtime completion contract.

Examples:

```bash
./scripts/check_final_delivery_gate.sh \
  --artifact-path outputs/decks/2026-03-09-launch/final-deck.pptx \
  --delivery-status delivered \
  --destination-type feishu-document \
  --destination-ref https://example.com/doc/123 \
  --verification-evidence "Feishu API returned success status 200"
```

```bash
./scripts/check_final_delivery_gate.sh \
  --artifact-path outputs/decks/2026-03-09-launch/final-deck.pptx \
  --delivery-status blocked \
  --destination-type judao-final-document \
  --destination-ref JD-123 \
  --attempted-delivery \
  --verification-evidence "Browser returned 401 after upload attempt" \
  --blocker "Missing browser authentication" \
  --next-manual-step "Sign in and rerun delivery"
```

A local-only draft may pass the gate only when the user explicitly requested a local-only result:

```bash
./scripts/check_final_delivery_gate.sh \
  --artifact-path outputs/decks/2026-03-09-launch/draft.md \
  --delivery-status local-only-draft \
  --local-only-approval-evidence "User explicitly asked for a local-only draft in the thread"
```

## Security and Scope

This repository should contain workspace instructions, skills, validation scripts, and reusable generated outputs. It should not be treated as a credential store.

Recommended practice:

- keep the workspace repository private when it contains sensitive operating context
- avoid storing secrets in workspace files
- keep large generated assets in `outputs/` and promote only durable instructions into the prompt layer

## Assumptions

- `Node.js 22+` is available on the target machine
- `git`, `python3`, `pip`, and `npm` are available
- the SlideMax companion repository can be cloned from GitHub
- this repository path is the intended OpenClaw workspace location
- the target agent should remain presentation-focused and low-noise in heartbeat mode

## Extension Points

- add richer companion health checks or upgrade guidance to the install runbook
- add richer `.pptx` handling or export workflows
- add more domain skills such as board updates, sales pitches, or technical design reviews
- add message-channel specific delivery adapters or templates
- add troubleshooting, upgrade, or uninstall guidance to `docs/openclaw-install.md`
