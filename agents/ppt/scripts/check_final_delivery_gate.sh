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
REQUIRE_CHANNEL_HANDOFF=0
MANIFEST_PATH=""

usage() {
  cat <<'EOF_USAGE'
Usage: check_final_delivery_gate.sh --artifact-path PATH --artifact-filename NAME --delivery-status STATUS [options]
       check_final_delivery_gate.sh --manifest PATH [options]

The CLI arguments of this script are the canonical runtime completion contract.

Options:
  --manifest PATH                    Read the delivery contract from a JSON manifest file.
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
  --require-channel-handoff          Require message channel metadata for this completion claim.
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
      --manifest)
        [[ $# -ge 2 ]] || { echo "Missing value for --manifest." >&2; exit 1; }
        MANIFEST_PATH=$2
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
      --require-channel-handoff)
        REQUIRE_CHANNEL_HANDOFF=1
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

load_manifest_defaults() {
  if [[ -z "$MANIFEST_PATH" ]]; then
    return
  fi

  if [[ ! -f "$MANIFEST_PATH" ]]; then
    echo "Delivery manifest does not exist: $MANIFEST_PATH" >&2
    exit 1
  fi

  eval "$(
    python3 - "$MANIFEST_PATH" <<'PY'
import json
import shlex
import sys

manifest_path = sys.argv[1]
with open(manifest_path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

field_map = {
    "artifactPath": "MANIFEST_ARTIFACT_PATH",
    "artifactFilename": "MANIFEST_ARTIFACT_FILENAME",
    "deliveryStatus": "MANIFEST_DELIVERY_STATUS",
    "destinationType": "MANIFEST_DESTINATION_TYPE",
    "destinationRef": "MANIFEST_DESTINATION_REF",
    "blocker": "MANIFEST_BLOCKER",
    "nextManualStep": "MANIFEST_NEXT_MANUAL_STEP",
    "verificationEvidence": "MANIFEST_VERIFICATION_EVIDENCE",
    "localOnlyApprovalEvidence": "MANIFEST_LOCAL_ONLY_APPROVAL_EVIDENCE",
    "channelType": "MANIFEST_CHANNEL_TYPE",
    "channelRef": "MANIFEST_CHANNEL_REF",
    "channelStatus": "MANIFEST_CHANNEL_STATUS",
    "channelEvidence": "MANIFEST_CHANNEL_EVIDENCE",
    "channelBlocker": "MANIFEST_CHANNEL_BLOCKER",
    "channelNextManualStep": "MANIFEST_CHANNEL_NEXT_MANUAL_STEP",
}

for manifest_key, shell_name in field_map.items():
    value = data.get(manifest_key, "")
    if value is None:
        value = ""
    print(f"{shell_name}={shlex.quote(str(value))}")

attempted = "1" if data.get("attemptedDelivery") else "0"
require_channel = "1" if data.get("requireChannelHandoff") else "0"
print(f"MANIFEST_ATTEMPTED_DELIVERY={attempted}")
print(f"MANIFEST_REQUIRE_CHANNEL_HANDOFF={require_channel}")
PY
  )"

  [[ -n "$ARTIFACT_PATH" ]] || ARTIFACT_PATH=$MANIFEST_ARTIFACT_PATH
  [[ -n "$ARTIFACT_FILENAME" ]] || ARTIFACT_FILENAME=$MANIFEST_ARTIFACT_FILENAME
  [[ -n "$DELIVERY_STATUS" ]] || DELIVERY_STATUS=$MANIFEST_DELIVERY_STATUS
  [[ -n "$DESTINATION_TYPE" ]] || DESTINATION_TYPE=$MANIFEST_DESTINATION_TYPE
  [[ -n "$DESTINATION_REF" ]] || DESTINATION_REF=$MANIFEST_DESTINATION_REF
  [[ -n "$BLOCKER" ]] || BLOCKER=$MANIFEST_BLOCKER
  [[ -n "$NEXT_MANUAL_STEP" ]] || NEXT_MANUAL_STEP=$MANIFEST_NEXT_MANUAL_STEP
  [[ -n "$VERIFICATION_EVIDENCE" ]] || VERIFICATION_EVIDENCE=$MANIFEST_VERIFICATION_EVIDENCE
  [[ -n "$LOCAL_ONLY_APPROVAL_EVIDENCE" ]] || LOCAL_ONLY_APPROVAL_EVIDENCE=$MANIFEST_LOCAL_ONLY_APPROVAL_EVIDENCE
  [[ -n "$CHANNEL_TYPE" ]] || CHANNEL_TYPE=$MANIFEST_CHANNEL_TYPE
  [[ -n "$CHANNEL_REF" ]] || CHANNEL_REF=$MANIFEST_CHANNEL_REF
  [[ -n "$CHANNEL_STATUS" ]] || CHANNEL_STATUS=$MANIFEST_CHANNEL_STATUS
  [[ -n "$CHANNEL_EVIDENCE" ]] || CHANNEL_EVIDENCE=$MANIFEST_CHANNEL_EVIDENCE
  [[ -n "$CHANNEL_BLOCKER" ]] || CHANNEL_BLOCKER=$MANIFEST_CHANNEL_BLOCKER
  [[ -n "$CHANNEL_NEXT_MANUAL_STEP" ]] || CHANNEL_NEXT_MANUAL_STEP=$MANIFEST_CHANNEL_NEXT_MANUAL_STEP

  if [[ "$ATTEMPTED_DELIVERY" -eq 0 && "$MANIFEST_ATTEMPTED_DELIVERY" -eq 1 ]]; then
    ATTEMPTED_DELIVERY=1
  fi

  if [[ "$REQUIRE_CHANNEL_HANDOFF" -eq 0 && "$MANIFEST_REQUIRE_CHANNEL_HANDOFF" -eq 1 ]]; then
    REQUIRE_CHANNEL_HANDOFF=1
  fi
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
  if [[ "$REQUIRE_CHANNEL_HANDOFF" -eq 1 && "$DELIVERY_STATUS" == "local-only-draft" ]]; then
    echo "Local-only draft cannot require message channel handoff." >&2
    exit 1
  fi

  if [[ "$REQUIRE_CHANNEL_HANDOFF" -eq 1 ]]; then
    require_value --channel-type "$CHANNEL_TYPE"
    require_value --channel-ref "$CHANNEL_REF"
    require_value --channel-status "$CHANNEL_STATUS"
  fi

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
  load_manifest_defaults
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

  if [[ "$REQUIRE_CHANNEL_HANDOFF" -eq 1 ]]; then
    echo "Channel handoff required: yes"
  fi

  if [[ -n "$MANIFEST_PATH" ]]; then
    echo "Manifest path: $MANIFEST_PATH"
  fi
}

main "$@"
