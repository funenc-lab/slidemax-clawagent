# OpenClaw PPT Agent AI Installation Runbook

## Executive Summary

This document is the canonical installation and update prompt for AI executors.

It intentionally separates the repository source layout from the final OpenClaw runtime layout.

The repository source workspace lives at:

- `SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"`

The default final OpenClaw runtime layout is:

- `INSTALL_WORKSPACE_DIR="$HOME/.openclaw/workspace-ppt"`
- `INSTALL_AGENT_DIR="$HOME/.openclaw/agents/ppt/agent"`

The installation goal is:

1. acquire or update the source repository
2. acquire or update the SlideMax companion repository
3. copy the source workspace into the final OpenClaw runtime workspace
4. copy-install the canonical `slidemax_workflow` skill into the final runtime workspace
5. register the final runtime workspace and the final `agentDir` with OpenClaw

Key facts:

- The canonical repository address for SlideMax is `https://github.com/funenc-lab/slidemax`
- The canonical workspace repository address is `https://github.com/funenc-lab/slidemax-clawagent`
- Only the canonical `funenc-lab/slidemax` remote is supported by this installation flow
- The canonical workflow skill file is `SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md`
- The final installed skill path must be `INSTALL_WORKSPACE_DIR/skills/slidemax_workflow/SKILL.md`
- The repository source tree is not the final OpenClaw runtime directory
- The runtime installation must use copied files, not a mount, not a symlink, and not a local bridge skill

## Document Role

When an AI follows this document, it should behave like a controlled installer.

That means:

- execute the steps in order
- stop immediately on failure
- separate confirmed facts from local recommendations
- record the final absolute paths being used
- verify the result with commands before claiming completion

## Source and Runtime Model

This project has two different directory layers:

### Repository Source Layer

- `REPO_DIR`
- `SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"`
- `REPO_DIR/docs/openclaw-install.md`

This layer is version-controlled source.

### OpenClaw Runtime Layer

Default runtime paths:

- `OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"`
- `INSTALL_WORKSPACE_DIR="${INSTALL_WORKSPACE_DIR:-$OPENCLAW_HOME/workspace-ppt}"`
- `INSTALL_AGENT_DIR="${INSTALL_AGENT_DIR:-$OPENCLAW_HOME/agents/ppt/agent}"`

This layer is the actual OpenClaw runtime target.

The repository source workspace must be copied into the runtime workspace.
The runtime `slidemax_workflow` skill must be copied into the runtime workspace `skills/` directory.

## Installation Success Criteria

The installation is complete only when all of the following are true:

- `SOURCE_WORKSPACE_DIR` exists
- `INSTALL_WORKSPACE_DIR` exists
- `INSTALL_AGENT_DIR` exists
- `SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md` exists
- `INSTALL_WORKSPACE_DIR/skills/slidemax_workflow/SKILL.md` exists
- the installed runtime workspace passed `bash scripts/validate_workspace.sh`
- the installed runtime workspace passed `bash tests/test_workspace_structure.sh`
- `openclaw agents list` shows the configured agent
- the registered OpenClaw agent points to `INSTALL_WORKSPACE_DIR`
- the registered OpenClaw agent uses `INSTALL_AGENT_DIR`

## Final Runtime Directory Example

By default, the installed runtime layout should look like this:

```text
$HOME/.openclaw/
  workspace-ppt/
    AGENTS.md
    TOOLS.md
    SOUL.md
    USER.md
    IDENTITY.md
    HEARTBEAT.md
    README.md
    scripts/
    skills/
      presentation-workflow/
      ppt-generation/
      ppt-review/
      speaker-notes/
      deck-polish/
      final-document-delivery/
      message-channel-delivery/
      slidemax_workflow/
    tests/
  agents/
    ppt/
      agent/
      sessions/
```

## AI Execution Order

### Step 0: Acquire and Verify the Repository Source

Treat the exact repository path as the absolute path of the local `slidemax-clawagent` repository root.
Treat the exact source workspace path as the absolute path of the local `slidemax-clawagent` repository root plus `/agents/ppt`.
Do not treat the source repository itself as the final OpenClaw runtime directory.

You may start from the repository root, the source workspace root, or a parent directory where the repository may need to be cloned.

```bash
CURRENT_DIR=$(pwd)

if [ -d "$CURRENT_DIR/.git" ]; then
  REPO_DIR="$CURRENT_DIR"
elif [ "$(basename "$CURRENT_DIR")" = "ppt" ] && \
     [ "$(basename "$(dirname "$CURRENT_DIR")")" = "agents" ] && \
     [ -d "$CURRENT_DIR/../../.git" ]; then
  REPO_DIR=$(cd "$CURRENT_DIR/../.." && pwd)
else
  REPO_DIR="${CURRENT_DIR}/slidemax-clawagent"
  if [ -d "$REPO_DIR/.git" ]; then
    :
  elif [ -e "$REPO_DIR" ]; then
    echo "Target repository path exists but is not a Git repository: $REPO_DIR" >&2
    exit 1
  else
    git clone https://github.com/funenc-lab/slidemax-clawagent.git "$REPO_DIR"
  fi
fi

REPO_ORIGIN=$(git -C "$REPO_DIR" remote get-url origin)
printf '%s\n' "$REPO_ORIGIN"

case "$REPO_ORIGIN" in
  *funenc-lab/slidemax-clawagent.git|*funenc-lab/slidemax-clawagent)
    ;;
  *)
    echo "Repository remote is not the canonical slidemax-clawagent repository: $REPO_ORIGIN" >&2
    exit 1
    ;;
esac

SOURCE_WORKSPACE_DIR="${REPO_DIR}/agents/ppt"
test -d "$SOURCE_WORKSPACE_DIR"
test -f "$REPO_DIR/docs/openclaw-install.md"
test -f "$SOURCE_WORKSPACE_DIR/scripts/validate_workspace.sh"
test -f "$SOURCE_WORKSPACE_DIR/tests/test_workspace_structure.sh"
```

Then report:

- the exact repository path
- the exact source workspace path

### Step 1: Resolve the Final OpenClaw Runtime Paths

After the source repository is available, compute the final runtime paths:

```bash
SOURCE_WORKSPACE_DIR="${REPO_DIR}/agents/ppt"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
INSTALL_WORKSPACE_DIR="${INSTALL_WORKSPACE_DIR:-$OPENCLAW_HOME/workspace-ppt}"
INSTALL_AGENT_DIR="${INSTALL_AGENT_DIR:-$OPENCLAW_HOME/agents/ppt/agent}"
PARENT_DIR=$(dirname "$REPO_DIR")
SLIDEMAX_DIR="${SLIDEMAX_DIR:-${PARENT_DIR}/slidemax}"
```

Then report:

- the exact source workspace path
- the exact installed workspace path
- the exact installed `agentDir` path
- the chosen SlideMax companion repository path

Rules:

- use `SLIDEMAX_DIR` as the supported environment variable for a custom SlideMax path
- use `INSTALL_WORKSPACE_DIR` only for the final OpenClaw runtime workspace
- use `INSTALL_AGENT_DIR` only for the final OpenClaw runtime `agentDir`

Prefer the OpenClaw per-skill env configuration for `slidemax-workflow`:

```bash
openclaw config set 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR' "\"$SLIDEMAX_DIR\""
openclaw config get 'skills.entries["slidemax-workflow"].env.SLIDEMAX_DIR'
```

For a machine-wide fallback outside the current shell, use `~/.openclaw/.env`.

### Step 2: Check Required Tools

Verify the commands exist:

```bash
command -v git
command -v python3
command -v pip
command -v node
command -v npm
```

Then check versions:

```bash
python3 --version
node --version
npm --version
```

Rules:

- SlideMax requires `Python 3.8+`
- OpenClaw requires `Node.js 22+`

### Step 3: Install or Reuse SlideMax

```bash
if [ -d "$SLIDEMAX_DIR/.git" ]; then
  git -C "$SLIDEMAX_DIR" remote get-url origin
elif [ -e "$SLIDEMAX_DIR" ]; then
  echo "Target companion path exists but is not a Git repository: $SLIDEMAX_DIR" >&2
  exit 1
else
  git clone https://github.com/funenc-lab/slidemax.git "$SLIDEMAX_DIR"
fi
```

Rules:

- if the path does not exist, clone the canonical repository
- if the path exists and is a Git repository, reuse it only when the remote is the canonical `funenc-lab/slidemax` repository
- if the path exists but is not a Git repository, stop and report the conflict
- after clone or reuse, verify `test -f "$SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md"` before continuing

### Step 4: Install SlideMax Dependencies

```bash
cd "$SLIDEMAX_DIR"
python3 -m pip install -r requirements.txt
```

Stop immediately if the command fails.

### Step 5: Install or Update the Final Runtime Workspace

Create the final OpenClaw runtime directories first:

```bash
mkdir -p "$INSTALL_WORKSPACE_DIR" "$INSTALL_AGENT_DIR" "$INSTALL_WORKSPACE_DIR/skills"
```

Copy the managed source workspace files into the final runtime workspace:

```bash
cd "$REPO_DIR"

for managed_file in AGENTS.md BOOTSTRAP.md HEARTBEAT.md IDENTITY.md README.md SOUL.md TOOLS.md USER.md; do
  cp "$SOURCE_WORKSPACE_DIR/$managed_file" "$INSTALL_WORKSPACE_DIR/$managed_file"
done

rm -rf "$INSTALL_WORKSPACE_DIR/scripts" "$INSTALL_WORKSPACE_DIR/tests"
cp -R "$SOURCE_WORKSPACE_DIR/scripts" "$INSTALL_WORKSPACE_DIR/scripts"
cp -R "$SOURCE_WORKSPACE_DIR/tests" "$INSTALL_WORKSPACE_DIR/tests"

for managed_skill in presentation-workflow ppt-generation ppt-review speaker-notes deck-polish final-document-delivery message-channel-delivery; do
  rm -rf "$INSTALL_WORKSPACE_DIR/skills/$managed_skill"
  cp -R "$SOURCE_WORKSPACE_DIR/skills/$managed_skill" "$INSTALL_WORKSPACE_DIR/skills/$managed_skill"
done
```

Then copy-install the canonical SlideMax workflow skill into the final runtime workspace:

```bash
test -f "$SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md"

rm -rf "$INSTALL_WORKSPACE_DIR/skills/slidemax_workflow"
cp -R "$SLIDEMAX_DIR/skills/slidemax_workflow" "$INSTALL_WORKSPACE_DIR/skills/slidemax_workflow"
test -f "$INSTALL_WORKSPACE_DIR/skills/slidemax_workflow/SKILL.md"
```

Then configure the runtime environment and validate the installed workspace:

```bash
cd "$INSTALL_WORKSPACE_DIR"
bash scripts/validate_workspace.sh
bash tests/test_workspace_structure.sh
```

Rules:

- the runtime `slidemax-workflow` skill must come from `SLIDEMAX_DIR/skills/slidemax_workflow`
- the final runtime skill location must be `INSTALL_WORKSPACE_DIR/skills/slidemax_workflow`
- do not mount or symlink `INSTALL_WORKSPACE_DIR/skills/slidemax_workflow`
- the installation contract requires a copied directory
- preserve local `memory/`, `MEMORY.md`, and `outputs/` content by only copying managed source files

### Step 6: Determine and Apply the Local OpenClaw Action

At this stage, determine the actual OpenClaw state.

```bash
command -v openclaw || true
openclaw agents list --json 2>/dev/null || true
```

If `openclaw` is missing:

```bash
npm install -g openclaw@latest
hash -r
openclaw agents list --json
```

Use `AGENT_ID="${AGENT_ID:-ppt}"` as the default agent id.

If the target agent does not exist:

```bash
AGENT_ID="${AGENT_ID:-ppt}"
openclaw agents add "$AGENT_ID" --workspace "$INSTALL_WORKSPACE_DIR" --agent-dir "$INSTALL_AGENT_DIR" --non-interactive
```

If the target agent already exists and already points to `INSTALL_WORKSPACE_DIR` and `INSTALL_AGENT_DIR`, reuse it.

If the target agent already exists but points somewhere else:

```bash
AGENT_ID="${AGENT_ID:-ppt}"
openclaw agents delete "$AGENT_ID"
openclaw agents add "$AGENT_ID" --workspace "$INSTALL_WORKSPACE_DIR" --agent-dir "$INSTALL_AGENT_DIR" --non-interactive
```

Rules:

- inspect `openclaw agents list --json` before deciding
- only determine the local OpenClaw agent status when Step 6 or Step 7 is actually reached
- if the installation stops before the OpenClaw registration or verification step, report the agent status as undetermined

### Step 7: Post-Install Verification

After the chosen Step 6 action completes, verify:

```bash
openclaw agents list
openclaw agents list --json
```

Confirm:

- the agent exists
- the workspace path is `INSTALL_WORKSPACE_DIR`
- the `agentDir` path is `INSTALL_AGENT_DIR`

## Workspace File Responsibilities

Unless explicitly noted otherwise, every path in this section is relative to `SOURCE_WORKSPACE_DIR` in the repository source tree and to `INSTALL_WORKSPACE_DIR` after installation.

### Root Prompt Files

- `AGENTS.md`
- `SOUL.md`
- `TOOLS.md`
- `USER.md`
- `IDENTITY.md`
- `HEARTBEAT.md`

### Skill Files

- `skills/presentation-workflow/SKILL.md`
- `skills/ppt-generation/SKILL.md`
- `skills/ppt-review/SKILL.md`
- `skills/speaker-notes/SKILL.md`
- `skills/deck-polish/SKILL.md`
- `skills/final-document-delivery/SKILL.md`
- `skills/message-channel-delivery/SKILL.md`
- `skills/slidemax_workflow/SKILL.md`

The canonical runtime `slidemax_workflow` skill is not authored in this repository.
It must be copied from `SLIDEMAX_DIR/skills/slidemax_workflow` into the final runtime workspace.

## AI Output Contract

At the end of the installation or update run, report:

- `REPO_DIR`
- `SOURCE_WORKSPACE_DIR`
- `INSTALL_WORKSPACE_DIR`
- `INSTALL_AGENT_DIR`
- `SLIDEMAX_DIR`
- whether the installed workspace validation passed
- whether the installed workspace structure test passed
- whether OpenClaw registration passed
- the final blocker, if one exists
