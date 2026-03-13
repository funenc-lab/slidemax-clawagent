#!/usr/bin/env bash
set -euo pipefail

ARTIFACT_PATH=""
ARTIFACT_FILENAME=""
DELIVERY_STATUS=""
DESTINATION_TYPE=""
DESTINATION_REF=""
BLOCKER=""
NEXT_MANUAL_STEP=""
VERIFICATION_EVIDENCE=""
LOCAL_ONLY_APPROVAL_EVIDENCE=""
CHANNEL_TYPE=""
CHANNEL_REF=""
CHANNEL_STATUS=""
CHANNEL_EVIDENCE=""
CHANNEL_BLOCKER=""
CHANNEL_NEXT_MANUAL_STEP=""
ATTEMPTED_DELIVERY=0

usage() {
  cat <<'EOF_USAGE'
Usage: check_final_delivery_gate.sh --artifact-path PATH --artifact-filename NAME --delivery-status STATUS [options]

The CLI arguments of this script are the canonical runtime completion contract.

Options:
  --artifact-path PATH               Local file or directory that represents the final artifact.
  --artifact-filename NAME          Expected final artifact file name. Must match the path basename and use English-only naming.
  --delivery-status STATUS           One of: delivered, blocked, local-only-draft.
  --destination-type TYPE            Final destination type such as feishu-document.
  --destination-ref REF              Final destination link, identifier, or path.
  --verification-evidence TEXT       Explicit evidence that delivery succeeded or that a blocker was verified.
  --attempted-delivery               Required for blocked delivery states after a real publish or send attempt.
  --blocker TEXT                     Verified delivery blocker.
  --next-manual-step TEXT            Exact next manual step when delivery is blocked.
  --local-only-approval-evidence TEXT
                                     Evidence that the user explicitly requested a local-only result.
  --channel-type TYPE                Optional message channel type such as feishu-chat.
  --channel-ref REF                  Optional message channel destination reference.
  --channel-status STATUS            Optional channel status: sent or blocked.
  --channel-evidence TEXT            Evidence that channel handoff succeeded or that a blocker was verified.
  --channel-blocker TEXT             Verified channel handoff blocker.
  --channel-next-manual-step TEXT    Exact next manual step when channel handoff is blocked.
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
      --artifact-filename)
        [[ $# -ge 2 ]] || { echo "Missing value for --artifact-filename." >&2; exit 1; }
        ARTIFACT_FILENAME=$2
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
      --channel-type)
        [[ $# -ge 2 ]] || { echo "Missing value for --channel-type." >&2; exit 1; }
        CHANNEL_TYPE=$2
        shift
        ;;
      --channel-ref)
        [[ $# -ge 2 ]] || { echo "Missing value for --channel-ref." >&2; exit 1; }
        CHANNEL_REF=$2
        shift
        ;;
      --channel-status)
        [[ $# -ge 2 ]] || { echo "Missing value for --channel-status." >&2; exit 1; }
        CHANNEL_STATUS=$2
        shift
        ;;
      --channel-evidence)
        [[ $# -ge 2 ]] || { echo "Missing value for --channel-evidence." >&2; exit 1; }
        CHANNEL_EVIDENCE=$2
        shift
        ;;
      --channel-blocker)
        [[ $# -ge 2 ]] || { echo "Missing value for --channel-blocker." >&2; exit 1; }
        CHANNEL_BLOCKER=$2
        shift
        ;;
      --channel-next-manual-step)
        [[ $# -ge 2 ]] || { echo "Missing value for --channel-next-manual-step." >&2; exit 1; }
        CHANNEL_NEXT_MANUAL_STEP=$2
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
  require_value --artifact-filename "$ARTIFACT_FILENAME"
  require_value --delivery-status "$DELIVERY_STATUS"

  if [[ ! -e "$ARTIFACT_PATH" ]]; then
    echo "Final artifact path does not exist: $ARTIFACT_PATH" >&2
    exit 1
  fi

  if [[ "$(basename "$ARTIFACT_PATH")" != "$ARTIFACT_FILENAME" ]]; then
    echo "Artifact filename does not match artifact path basename: $ARTIFACT_FILENAME" >&2
    exit 1
  fi

  if [[ ! "$ARTIFACT_FILENAME" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Artifact filename must use English-only deterministic naming: $ARTIFACT_FILENAME" >&2
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

validate_channel_requirements() {
  if [[ -z "$CHANNEL_TYPE$CHANNEL_REF$CHANNEL_STATUS$CHANNEL_EVIDENCE$CHANNEL_BLOCKER$CHANNEL_NEXT_MANUAL_STEP" ]]; then
    return
  fi

  if [[ "$DELIVERY_STATUS" == "local-only-draft" ]]; then
    echo "Local-only draft must not include message channel handoff metadata." >&2
    exit 1
  fi

  require_value --channel-type "$CHANNEL_TYPE"
  require_value --channel-ref "$CHANNEL_REF"
  require_value --channel-status "$CHANNEL_STATUS"

  case "$CHANNEL_STATUS" in
    sent)
      require_value --channel-evidence "$CHANNEL_EVIDENCE"
      ;;
    blocked)
      require_value --channel-evidence "$CHANNEL_EVIDENCE"
      require_value --channel-blocker "$CHANNEL_BLOCKER"
      require_value --channel-next-manual-step "$CHANNEL_NEXT_MANUAL_STEP"
      ;;
    *)
      echo "Unsupported channel status: $CHANNEL_STATUS" >&2
      exit 1
      ;;
  esac

  case "$CHANNEL_TYPE" in
    feishu-chat|feishu-group|feishu-channel)
      if [[ "$DESTINATION_TYPE" != "feishu-document" ]]; then
        echo "Feishu channel handoff requires a feishu-document final destination." >&2
        exit 1
      fi
      ;;
  esac
}

main() {
  parse_args "$@"
  validate_common_requirements
  validate_delivery_status
  validate_channel_requirements

  echo "Final delivery gate passed for status: $DELIVERY_STATUS"
  echo "Artifact path: $ARTIFACT_PATH"
  echo "Artifact filename: $ARTIFACT_FILENAME"

  if [[ -n "$DESTINATION_TYPE" ]]; then
    echo "Destination type: $DESTINATION_TYPE"
  fi

  if [[ -n "$DESTINATION_REF" ]]; then
    echo "Destination ref: $DESTINATION_REF"
  fi

  if [[ -n "$CHANNEL_STATUS" ]]; then
    echo "Channel status: $CHANNEL_STATUS"
  fi
}

main "$@"
