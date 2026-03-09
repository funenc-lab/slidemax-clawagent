#!/usr/bin/env bash
set -euo pipefail

ARTIFACT_PATH=""
DELIVERY_STATUS=""
DESTINATION_TYPE=""
DESTINATION_REF=""
BLOCKER=""
NEXT_MANUAL_STEP=""
VERIFICATION_EVIDENCE=""
LOCAL_ONLY_APPROVAL_EVIDENCE=""
ATTEMPTED_DELIVERY=0

usage() {
  cat <<'EOF_USAGE'
Usage: check_final_delivery_gate.sh --artifact-path PATH --delivery-status STATUS [options]

The CLI arguments of this script are the canonical runtime completion contract.

Options:
  --artifact-path PATH               Local file or directory that represents the final artifact.
  --delivery-status STATUS           One of: delivered, blocked, local-only-draft.
  --destination-type TYPE            Final destination type such as feishu-document.
  --destination-ref REF              Final destination link, identifier, or path.
  --verification-evidence TEXT       Explicit evidence that delivery succeeded or that a blocker was verified.
  --attempted-delivery               Required for blocked delivery states after a real publish or send attempt.
  --blocker TEXT                     Verified delivery blocker.
  --next-manual-step TEXT            Exact next manual step when delivery is blocked.
  --local-only-approval-evidence TEXT
                                     Evidence that the user explicitly requested a local-only result.
  -h, --help                         Show this help message.
EOF_USAGE
}

require_value() {
  local option_name=$1
  local option_value=$2

  if [[ -z "$option_value" ]]; then
    echo "Missing required option: $option_name" >&2
    exit 1
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --artifact-path)
        [[ $# -ge 2 ]] || { echo "Missing value for --artifact-path." >&2; exit 1; }
        ARTIFACT_PATH=$2
        shift
        ;;
      --delivery-status)
        [[ $# -ge 2 ]] || { echo "Missing value for --delivery-status." >&2; exit 1; }
        DELIVERY_STATUS=$2
        shift
        ;;
      --destination-type)
        [[ $# -ge 2 ]] || { echo "Missing value for --destination-type." >&2; exit 1; }
        DESTINATION_TYPE=$2
        shift
        ;;
      --destination-ref)
        [[ $# -ge 2 ]] || { echo "Missing value for --destination-ref." >&2; exit 1; }
        DESTINATION_REF=$2
        shift
        ;;
      --verification-evidence)
        [[ $# -ge 2 ]] || { echo "Missing value for --verification-evidence." >&2; exit 1; }
        VERIFICATION_EVIDENCE=$2
        shift
        ;;
      --attempted-delivery)
        ATTEMPTED_DELIVERY=1
        ;;
      --blocker)
        [[ $# -ge 2 ]] || { echo "Missing value for --blocker." >&2; exit 1; }
        BLOCKER=$2
        shift
        ;;
      --next-manual-step)
        [[ $# -ge 2 ]] || { echo "Missing value for --next-manual-step." >&2; exit 1; }
        NEXT_MANUAL_STEP=$2
        shift
        ;;
      --local-only-approval-evidence)
        [[ $# -ge 2 ]] || { echo "Missing value for --local-only-approval-evidence." >&2; exit 1; }
        LOCAL_ONLY_APPROVAL_EVIDENCE=$2
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
    shift
  done
}

validate_common_requirements() {
  require_value --artifact-path "$ARTIFACT_PATH"
  require_value --delivery-status "$DELIVERY_STATUS"

  if [[ ! -e "$ARTIFACT_PATH" ]]; then
    echo "Final artifact path does not exist: $ARTIFACT_PATH" >&2
    exit 1
  fi
}

validate_delivery_status() {
  case "$DELIVERY_STATUS" in
    delivered)
      require_value --destination-type "$DESTINATION_TYPE"
      require_value --destination-ref "$DESTINATION_REF"
      require_value --verification-evidence "$VERIFICATION_EVIDENCE"
      ;;
    blocked)
      require_value --destination-type "$DESTINATION_TYPE"
      require_value --destination-ref "$DESTINATION_REF"
      require_value --verification-evidence "$VERIFICATION_EVIDENCE"
      require_value --blocker "$BLOCKER"
      require_value --next-manual-step "$NEXT_MANUAL_STEP"

      if [[ "$ATTEMPTED_DELIVERY" -ne 1 ]]; then
        echo "Blocked delivery requires --attempted-delivery after a real publish or send attempt." >&2
        exit 1
      fi
      ;;
    local-only-draft)
      require_value --local-only-approval-evidence "$LOCAL_ONLY_APPROVAL_EVIDENCE"
      ;;
    *)
      echo "Unsupported delivery status: $DELIVERY_STATUS" >&2
      exit 1
      ;;
  esac

  case "$DESTINATION_TYPE" in
    feishu-chat|feishu-group|feishu-channel)
      echo "Final delivery destination for Feishu must be feishu-document, not $DESTINATION_TYPE." >&2
      exit 1
      ;;
  esac
}

main() {
  parse_args "$@"
  validate_common_requirements
  validate_delivery_status

  echo "Final delivery gate passed for status: $DELIVERY_STATUS"
  echo "Artifact path: $ARTIFACT_PATH"

  if [[ -n "$DESTINATION_TYPE" ]]; then
    echo "Destination type: $DESTINATION_TYPE"
  fi

  if [[ -n "$DESTINATION_REF" ]]; then
    echo "Destination ref: $DESTINATION_REF"
  fi
}

main "$@"
