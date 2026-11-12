#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
BUILD_DIR="$PROJECT_DIR/dist"
: "${OPENCODE_WEB_DIR:?OPENCODE_WEB_DIR must be set by the runtime}"
PORT="${PORT:-3000}"
export PORT

run_timed() {
  /usr/bin/time -p "$@"
}

cd "$PROJECT_DIR"
run_timed npm install --no-audit --no-fund

needs_build=false
if [[ ! -f "$BUILD_DIR/index.html" || ! -f "$BUILD_DIR/server.js" || "$PROJECT_DIR/index.html" -nt "$BUILD_DIR/index.html" || "$PROJECT_DIR/server.js" -nt "$BUILD_DIR/server.js" ]]; then
  needs_build=true
fi
if [[ "$needs_build" == true ]]; then
  run_timed mkdir -p "$BUILD_DIR"
  run_timed cp "$PROJECT_DIR/index.html" "$PROJECT_DIR/server.js" "$BUILD_DIR/"
fi

run_timed mkdir -p "$OPENCODE_WEB_DIR"
run_timed node -e 'const fs = require("fs"); const path = require("path"); const [project, directory, output] = process.argv.slice(1); fs.writeFileSync(output, JSON.stringify({ project: path.resolve(project), directory: path.resolve(directory) }, null, 2) + "\n");' "$PROJECT_DIR" "$BUILD_DIR" "$OPENCODE_WEB_DIR/deployment-output.json"

exec /usr/bin/time -p node "$BUILD_DIR/server.js"
