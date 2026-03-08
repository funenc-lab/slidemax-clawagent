#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

fail() {
  echo "TEST FAILED: $*" >&2
  exit 1
}

make_mock_bin() {
  local mock_bin=$1

  mkdir -p "$mock_bin"

  cat >"$mock_bin/openclaw" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "agents" && "${2:-}" == "list" && "${3:-}" == "--json" ]]; then
  if [[ "${MOCK_OPENCLAW_STATE:-absent}" == "present" ]]; then
    printf '[{"id":"%s"}]\n' "${MOCK_AGENT_NAME:-ppt-agents}"
  else
    printf '[]\n'
  fi
  exit 0
fi

if [[ "${1:-}" == "agents" && "${2:-}" == "add" ]]; then
  printf '%s\n' "$*" >>"${MOCK_OPENCLAW_LOG:?}"
  exit 0
fi

echo "Unexpected openclaw invocation: $*" >&2
exit 1
EOF

  cat >"$mock_bin/npm" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "npm should not be called in install smoke tests" >&2
exit 99
EOF

  chmod +x "$mock_bin/openclaw" "$mock_bin/npm"
}

run_install() {
  local output_file=$1
  shift

  if "$ROOT_DIR/scripts/install_openclaw_agent.sh" "$@" >"$output_file" 2>&1; then
    return 0
  fi

  return 1
}

assert_contains() {
  local file_path=$1
  local expected_text=$2

  if ! grep -Fq -- "$expected_text" "$file_path"; then
    echo "Expected to find: $expected_text" >&2
    echo "--- file contents ---" >&2
    cat "$file_path" >&2
    fail "assert_contains failed"
  fi
}

main() {
  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" EXIT

  local mock_bin=$temp_dir/mock-bin
  local log_file=$temp_dir/openclaw.log
  local output_file=$temp_dir/install.out
  local bad_repo=$temp_dir/bad-slidemax
  local good_repo=$temp_dir/good-slidemax
  local deprecated_remote_repo=$temp_dir/deprecated-remote

  make_mock_bin "$mock_bin"
  export PATH="$mock_bin:$PATH"
  export MOCK_OPENCLAW_LOG="$log_file"

  : >"$log_file"
  export SLIDEMAX_DIR=$temp_dir/missing-slidemax
  export MOCK_OPENCLAW_STATE=absent
  if run_install "$output_file" test-agent; then
    fail "install should fail when the SlideMax companion repository is missing"
  fi
  assert_contains "$output_file" "SlideMax companion repository is missing"
  [[ ! -s "$log_file" ]] || fail "agent registration should not run when companion repo is missing"

  mkdir -p "$bad_repo"
  git -C "$bad_repo" init -q
  git -C "$bad_repo" remote add origin https://github.com/example/not-slidemax.git
  : >"$log_file"
  export SLIDEMAX_DIR=$bad_repo
  if run_install "$output_file" test-agent; then
    fail "install should fail when the SlideMax companion remote is unexpected"
  fi
  assert_contains "$output_file" "SlideMax companion repository origin does not match"
  [[ ! -s "$log_file" ]] || fail "agent registration should not run when companion remote is invalid"

  mkdir -p "$good_repo"
  git -C "$good_repo" init -q
  git -C "$good_repo" remote add origin https://github.com/funenc-lab/slidemax.git
  touch "$good_repo/requirements.txt"

  : >"$log_file"
  export SLIDEMAX_DIR=$good_repo
  export MOCK_OPENCLAW_STATE=absent
  if ! run_install "$output_file" test-agent; then
    cat "$output_file" >&2
    fail "install should succeed when companion repo uses the slidemax remote and agent is absent"
  fi
  assert_contains "$output_file" "Validated SlideMax companion repository: $good_repo"
  assert_contains "$log_file" "agents add test-agent --workspace $ROOT_DIR --non-interactive"

  mkdir -p "$deprecated_remote_repo"
  git -C "$deprecated_remote_repo" init -q
  git -C "$deprecated_remote_repo" remote add origin https://github.com/funenc-lab/ppt-master.git
  touch "$deprecated_remote_repo/requirements.txt"

  : >"$log_file"
  export SLIDEMAX_DIR=$deprecated_remote_repo
  export MOCK_OPENCLAW_STATE=absent
  if run_install "$output_file" deprecated-remote-agent; then
    fail "install should fail when the companion remote does not match funenc-lab/slidemax"
  fi
  assert_contains "$output_file" "SlideMax companion repository origin does not match funenc-lab/slidemax"
  [[ ! -s "$log_file" ]] || fail "agent registration should not run when companion remote is deprecated"

  : >"$log_file"
  export SLIDEMAX_DIR=$temp_dir/still-missing
  export MOCK_OPENCLAW_STATE=absent
  if ! run_install "$output_file" --skip-companion-check skip-agent; then
    cat "$output_file" >&2
    fail "install should allow skipping companion validation explicitly"
  fi
  assert_contains "$output_file" "Skipping SlideMax companion validation"
  assert_contains "$log_file" "agents add skip-agent --workspace $ROOT_DIR --non-interactive"

  : >"$log_file"
  export SLIDEMAX_DIR=$good_repo
  export MOCK_OPENCLAW_STATE=absent
  if ! run_install "$output_file" slidemax-env-agent; then
    cat "$output_file" >&2
    fail "install should accept the SLIDEMAX_DIR environment override"
  fi
  assert_contains "$log_file" "agents add slidemax-env-agent --workspace $ROOT_DIR --non-interactive"

  : >"$log_file"
  unset SLIDEMAX_DIR
  export MOCK_OPENCLAW_STATE=absent
  if ! run_install "$output_file" --slidemax-dir "$good_repo" slidemax-flag-agent; then
    cat "$output_file" >&2
    fail "install should accept the --slidemax-dir option"
  fi
  assert_contains "$log_file" "agents add slidemax-flag-agent --workspace $ROOT_DIR --non-interactive"

  : >"$log_file"
  export SLIDEMAX_DIR=$good_repo
  export MOCK_OPENCLAW_STATE=absent
  if run_install "$output_file" --ppt-master-dir "$good_repo" rejected-option-agent; then
    fail "install should reject the deprecated --ppt-master-dir option"
  fi
  assert_contains "$output_file" "Unknown option: --ppt-master-dir"
  [[ ! -s "$log_file" ]] || fail "agent registration should not run when the install command is invalid"

  : >"$log_file"
  export SLIDEMAX_DIR=$good_repo
  export MOCK_OPENCLAW_STATE=present
  export MOCK_AGENT_NAME=existing-agent
  if ! run_install "$output_file" existing-agent; then
    cat "$output_file" >&2
    fail "install should succeed when agent is already registered"
  fi
  assert_contains "$output_file" "OpenClaw agent already registered: existing-agent"
  [[ ! -s "$log_file" ]] || fail "install should not re-register an existing agent"

  echo "Install workflow smoke test passed."
}

main "$@"
