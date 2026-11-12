#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
: "${CAPTURE_URL:?Set CAPTURE_URL to the exact preview URL}"
: "${CAPTURE_DIR:?Set CAPTURE_DIR for screenshot output}"
: "${RUNTIME_DIR:?RUNTIME_DIR must be set by the runtime}"

export CAPTURE_STRICT=1
export CAPTURE_READY_SELECTOR='#game'

set +e
/usr/bin/time -p node "$RUNTIME_DIR/scripts/default-capture.mjs"
status=$?
set -e
exit "$status"
