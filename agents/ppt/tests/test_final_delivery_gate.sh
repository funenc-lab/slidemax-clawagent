#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GATE_SCRIPT="$ROOT_DIR/scripts/check_final_delivery_gate.sh"

fail() {
  echo "TEST FAILED: $*" >&2
  exit 1
}

run_expect_success() {
  if ! "$@" >/dev/null 2>&1; then
    fail "expected success: $*"
  fi
}

run_expect_failure() {
  if "$@" >/dev/null 2>&1; then
    fail "expected failure: $*"
  fi
}

main() {
  local temp_dir
  temp_dir=$(mktemp -d)
  trap "rm -rf '$temp_dir'" EXIT

  local artifact_file=$temp_dir/final-deck.pptx
  touch "$artifact_file"

  run_expect_success \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status delivered \
    --destination-type feishu-document \
    --destination-ref https://example.com/doc/123 \
    --verification-evidence "Feishu API returned success status 200"

  run_expect_success \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status blocked \
    --destination-type judao-final-document \
    --destination-ref JD-123 \
    --attempted-delivery \
    --verification-evidence "Browser returned 401 after upload attempt" \
    --blocker "Missing browser authentication" \
    --next-manual-step "Sign in and rerun delivery"

  run_expect_success \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status local-only-draft \
    --local-only-approval-evidence "User explicitly asked for a local-only draft in the thread"

  run_expect_success \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status delivered \
    --destination-type feishu-document \
    --destination-ref https://example.com/doc/123 \
    --verification-evidence "Feishu API returned success status 200" \
    --channel-type feishu-chat \
    --channel-ref feishu://chat/456 \
    --channel-status sent \
    --channel-evidence "Feishu chat message sent with verified online document link"

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --delivery-status delivered

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename 最终成稿.pptx \
    --delivery-status delivered \
    --destination-type feishu-document \
    --destination-ref https://example.com/doc/123 \
    --verification-evidence "Feishu API returned success status 200"

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename wrong-name.pptx \
    --delivery-status delivered \
    --destination-type feishu-document \
    --destination-ref https://example.com/doc/123 \
    --verification-evidence "Feishu API returned success status 200"

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status delivered \
    --destination-type feishu-document \
    --destination-ref https://example.com/doc/123 \
    --verification-evidence "Feishu API returned success status 200" \
    --channel-type feishu-chat \
    --channel-ref feishu://chat/456 \
    --channel-status sent

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status delivered \
    --destination-type feishu-document \
    --destination-ref https://example.com/doc/123 \
    --verification-evidence "Feishu API returned success status 200" \
    --channel-type feishu-chat \
    --channel-ref feishu://chat/456 \
    --channel-status blocked \
    --channel-evidence "Chat message failed"

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status delivered \
    --destination-type judao-final-document \
    --destination-ref JD-123 \
    --verification-evidence "Judao upload returned success" \
    --channel-type feishu-chat \
    --channel-ref feishu://chat/456 \
    --channel-status sent \
    --channel-evidence "Feishu chat message sent with verified online document link"

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status delivered \
    --destination-type feishu-chat \
    --destination-ref https://example.com/chat/123 \
    --verification-evidence "Chat upload succeeded"

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status blocked \
    --destination-type feishu-group \
    --destination-ref https://example.com/group/123 \
    --attempted-delivery \
    --verification-evidence "Group upload failed with 401" \
    --blocker "Missing browser authentication" \
    --next-manual-step "Sign in and rerun delivery"

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status delivered \
    --destination-type feishu-document \
    --destination-ref https://example.com/doc/123

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status blocked \
    --destination-type feishu-document \
    --destination-ref https://example.com/doc/123

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status blocked \
    --destination-type feishu-document \
    --destination-ref https://example.com/doc/123 \
    --verification-evidence "Browser returned 401 after upload attempt" \
    --blocker "Missing browser authentication" \
    --next-manual-step "Sign in and rerun delivery"

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$artifact_file" \
    --artifact-filename final-deck.pptx \
    --delivery-status local-only-draft

  run_expect_failure \
    "$GATE_SCRIPT" \
    --artifact-path "$temp_dir/missing-file.pptx" \
    --artifact-filename missing-file.pptx \
    --delivery-status local-only-draft

  echo "Final delivery gate test passed."
}

main "$@"
