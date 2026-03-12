# OpenClaw PPT Agent Fresh Install Runbook

Use this file only when the runtime does not exist yet or when a fresh install was explicitly requested.

This runbook assumes the entry flow in `docs/openclaw-install.md` already completed:

- repository source checkout is ready
- repository source validation passed
- runtime paths are resolved
- `SLIDEMAX_DIR` and `AGENT_ID` are known

## Managed Runtime Payload

```bash
managed_runtime_root_files=(
  AGENTS.md
  BOOTSTRAP.md
  HEARTBEAT.md
  IDENTITY.md
  README.md
  SOUL.md
  TOOLS.md
  USER.md
)

managed_runtime_scripts=(
  check_final_delivery_gate.sh
)

managed_runtime_tests=(
  test_final_delivery_gate.sh
)

managed_runtime_skills=(
  presentation-workflow
  ppt-generation
  ppt-review
  speaker-notes
  deck-polish
  final-document-delivery
  message-channel-delivery
)

source_only_repo_paths=(
  AGENTS.md
  docs/openclaw-install.md
  docs/openclaw-install-fresh.md
  docs/openclaw-update.md
  scripts/validate_workspace.sh
  tests/test_workspace_structure.sh
)
```

Rules:

- overwrite only the managed runtime payload
- never copy any path listed in `source_only_repo_paths` into `INSTALL_WORKSPACE_DIR`
- always copy-install `slidemax_workflow` from `SLIDEMAX_DIR/skills/slidemax_workflow`

## Step 1: Check Required Tools and SlideMax

```bash
command -v git
command -v python3
command -v pip
command -v node
command -v npm

python3 --version
node --version
npm --version
```

```bash
if [ -d "$SLIDEMAX_DIR/.git" ]; then
  SLIDEMAX_ORIGIN=$(git -C "$SLIDEMAX_DIR" remote get-url origin)
  printf '%s\n' "$SLIDEMAX_ORIGIN"
  case "$SLIDEMAX_ORIGIN" in
    *funenc-lab/slidemax.git|*funenc-lab/slidemax)
      ;;
    *)
      echo "SlideMax remote is not canonical: $SLIDEMAX_ORIGIN" >&2
      exit 1
      ;;
  esac
  if ! git -C "$SLIDEMAX_DIR" diff --quiet || ! git -C "$SLIDEMAX_DIR" diff --cached --quiet; then
    echo "SlideMax checkout has local changes. Stop and report a dependency blocker." >&2
    exit 1
  fi
  git -C "$SLIDEMAX_DIR" fetch --all --prune
  git -C "$SLIDEMAX_DIR" pull --ff-only
elif [ -e "$SLIDEMAX_DIR" ]; then
  echo "Target companion path exists but is not a Git repository: $SLIDEMAX_DIR" >&2
  exit 1
else
  git clone https://github.com/funenc-lab/slidemax.git "$SLIDEMAX_DIR"
fi

test -f "$SLIDEMAX_DIR/skills/slidemax_workflow/SKILL.md"
cd "$SLIDEMAX_DIR"
python3 -m pip install -r requirements.txt
```

## Step 2: Prepare the Runtime Directories

```bash
mkdir -p \
  "$INSTALL_WORKSPACE_DIR" \
  "$INSTALL_AGENT_DIR" \
  "$INSTALL_WORKSPACE_DIR/scripts" \
  "$INSTALL_WORKSPACE_DIR/tests" \
  "$INSTALL_WORKSPACE_DIR/skills"
```

## Step 3: Copy the Managed Runtime Payload

```bash
cd "$REPO_DIR"

for runtime_file in "${managed_runtime_root_files[@]}"; do
  cp "$SOURCE_WORKSPACE_DIR/$runtime_file" "$INSTALL_WORKSPACE_DIR/$runtime_file"
done

for runtime_script in "${managed_runtime_scripts[@]}"; do
  cp "$SOURCE_WORKSPACE_DIR/scripts/$runtime_script" "$INSTALL_WORKSPACE_DIR/scripts/$runtime_script"
done

for runtime_test in "${managed_runtime_tests[@]}"; do
  cp "$SOURCE_WORKSPACE_DIR/tests/$runtime_test" "$INSTALL_WORKSPACE_DIR/tests/$runtime_test"
done

for runtime_skill in "${managed_runtime_skills[@]}"; do
  rm -rf "$INSTALL_WORKSPACE_DIR/skills/$runtime_skill"
  cp -R "$SOURCE_WORKSPACE_DIR/skills/$runtime_skill" "$INSTALL_WORKSPACE_DIR/skills/$runtime_skill"
done

rm -rf "$INSTALL_WORKSPACE_DIR/skills/slidemax_workflow"
cp -R "$SLIDEMAX_DIR/skills/slidemax_workflow" "$INSTALL_WORKSPACE_DIR/skills/slidemax_workflow"
```

## Step 4: Register the OpenClaw Agent

```bash
if ! command -v openclaw >/dev/null 2>&1; then
  npm install -g openclaw@latest
  hash -r
fi

openclaw agents list --json 2>/dev/null || true
openclaw agents add "$AGENT_ID" --workspace "$INSTALL_WORKSPACE_DIR" --agent-dir "$INSTALL_AGENT_DIR" --non-interactive
```

## Step 5: Verify the Installed Runtime

```bash
for runtime_file in "${managed_runtime_root_files[@]}"; do
  test -f "$INSTALL_WORKSPACE_DIR/$runtime_file"
done

for runtime_script in "${managed_runtime_scripts[@]}"; do
  test -f "$INSTALL_WORKSPACE_DIR/scripts/$runtime_script"
done

for runtime_test in "${managed_runtime_tests[@]}"; do
  test -f "$INSTALL_WORKSPACE_DIR/tests/$runtime_test"
done

for runtime_skill in "${managed_runtime_skills[@]}"; do
  test -f "$INSTALL_WORKSPACE_DIR/skills/$runtime_skill/SKILL.md"
done

test -f "$INSTALL_WORKSPACE_DIR/skills/slidemax_workflow/SKILL.md"

openclaw agents list --json
```

Confirm:

- the installed workspace path is `INSTALL_WORKSPACE_DIR`
- the installed `agentDir` path is `INSTALL_AGENT_DIR`
- the managed runtime payload exists
- `slidemax_workflow` was copied from the SlideMax companion repository

## Final Report

Report:

- `REPO_DIR`
- `SOURCE_WORKSPACE_DIR`
- `INSTALL_WORKSPACE_DIR`
- `INSTALL_AGENT_DIR`
- `SLIDEMAX_DIR`
- whether repository source validation passed
- whether runtime payload verification passed
- whether OpenClaw registration passed
- the final blocker, if one exists
