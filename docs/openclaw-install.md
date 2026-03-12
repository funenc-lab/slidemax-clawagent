# OpenClaw PPT Agent Install Entry

This file is the only install/update entry prompt.
It must decide the current scenario first, then route to exactly one runbook:

- fresh install: `docs/openclaw-install-fresh.md`
- update or repair: `docs/openclaw-update.md`

Canonical paths:

- `REPO_DIR`: local `slidemax-clawagent` checkout
- `SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"`
- `INSTALL_WORKSPACE_DIR="$HOME/.openclaw/workspace-ppt"`
- `INSTALL_AGENT_DIR="$HOME/.openclaw/agents/ppt/agent"`

Important rules:

- `SOURCE_WORKSPACE_DIR` is repository source only
- `INSTALL_WORKSPACE_DIR` is the final OpenClaw runtime workspace
- `INSTALL_AGENT_DIR` is the final OpenClaw runtime `agentDir`
- use `SOURCE_WORKSPACE_DIR` only as the source payload path
- never report `SOURCE_WORKSPACE_DIR` as the installed workspace path
- never validate the repository source tree as if it were the installed runtime workspace

Canonical repositories:

- `https://github.com/funenc-lab/slidemax`
- `https://github.com/funenc-lab/slidemax-clawagent`

## Step 0: Prepare the Repository Source

Use the local `slidemax-clawagent` checkout when available.
If it does not exist yet, clone the canonical repository first.

```bash
CURRENT_DIR=$(pwd)

if [ -d "$CURRENT_DIR/.git" ]; then
  REPO_DIR="$CURRENT_DIR"
elif [ -d "$CURRENT_DIR/slidemax-clawagent/.git" ]; then
  REPO_DIR="$CURRENT_DIR/slidemax-clawagent"
else
  REPO_DIR="$CURRENT_DIR/slidemax-clawagent"
  git clone https://github.com/funenc-lab/slidemax-clawagent.git "$REPO_DIR"
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

if ! git -C "$REPO_DIR" diff --quiet || ! git -C "$REPO_DIR" diff --cached --quiet; then
  echo "Repository checkout has local changes. Stop and report a repository source blocker." >&2
  exit 1
fi

git -C "$REPO_DIR" fetch --all --prune
git -C "$REPO_DIR" pull --ff-only

SOURCE_WORKSPACE_DIR="$REPO_DIR/agents/ppt"
test -d "$SOURCE_WORKSPACE_DIR"

bash "$REPO_DIR/scripts/validate_workspace.sh"
bash "$REPO_DIR/tests/test_workspace_structure.sh"
```

Then report:

- `REPO_DIR`
- `SOURCE_WORKSPACE_DIR`

## Step 1: Resolve Runtime Paths

```bash
SOURCE_WORKSPACE_DIR="${REPO_DIR}/agents/ppt"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
INSTALL_WORKSPACE_DIR="${INSTALL_WORKSPACE_DIR:-$OPENCLAW_HOME/workspace-ppt}"
INSTALL_AGENT_DIR="${INSTALL_AGENT_DIR:-$OPENCLAW_HOME/agents/ppt/agent}"
PARENT_DIR=$(dirname "$REPO_DIR")
SLIDEMAX_DIR="${SLIDEMAX_DIR:-${PARENT_DIR}/slidemax}"
AGENT_ID="${AGENT_ID:-ppt}"
```

Then report:

- `INSTALL_WORKSPACE_DIR`
- `INSTALL_AGENT_DIR`
- `SLIDEMAX_DIR`
- `AGENT_ID`

## Step 2: Detect the Scenario

Inspect the local runtime state first.

```bash
command -v openclaw || true
OPENCLAW_AGENTS_JSON=$(openclaw agents list --json 2>/dev/null || true)
printf '%s\n' "$OPENCLAW_AGENTS_JSON"

WORKSPACE_EXISTS=0
if [ -d "$INSTALL_WORKSPACE_DIR" ]; then
  WORKSPACE_EXISTS=1
fi

AGENT_EXISTS=0
case "$OPENCLAW_AGENTS_JSON" in
  *"\"name\":\"$AGENT_ID\""*)
    AGENT_EXISTS=1
    ;;
esac
```

Choose exactly one path:

- If `WORKSPACE_EXISTS=0` and `AGENT_EXISTS=0`, follow `docs/openclaw-install-fresh.md`
- If `WORKSPACE_EXISTS=1` or `AGENT_EXISTS=1`, follow `docs/openclaw-update.md`
- If the runtime exists but is obviously broken, still follow `docs/openclaw-update.md`

## Step 3: Route to One Runbook Only

Read and follow exactly one of these files:

- fresh install: `docs/openclaw-install-fresh.md`
- update or repair: `docs/openclaw-update.md`

Do not mix the two procedures in one run.

## Output Contract

At the end of the chosen runbook, report:

- `REPO_DIR`
- `SOURCE_WORKSPACE_DIR`
- `INSTALL_WORKSPACE_DIR`
- `INSTALL_AGENT_DIR`
- `SLIDEMAX_DIR`
- whether repository source validation passed
- whether runtime payload verification passed
- whether OpenClaw registration passed
- the final blocker, if one exists
