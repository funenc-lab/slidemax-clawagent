#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

bash "$ROOT_DIR/scripts/validate_workspace.sh"

echo 'Workspace structure test passed.'
