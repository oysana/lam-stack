#!/usr/bin/env bash
set -euo pipefail

# L.A.M. Stack v0.2.1 - PreToolUse Guard for git commit and gh pr create
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Claude Code delivers hook input as JSON on stdin. Extract tool_input.command
# and skip the floor guard unless the command is git commit or gh pr create.
# With no piped input (manual run, or an arg passed by another harness), fall
# back to $1; an empty command always runs the guard.
COMMAND=""
if [[ ! -t 0 ]]; then
  HOOK_INPUT="$(cat)"
  COMMAND="$(printf '%s' "$HOOK_INPUT" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("tool_input", {}).get("command", ""))
except Exception:
    pass' 2>/dev/null || true)"
fi
COMMAND="${COMMAND:-${CLAUDE_TOOL_INPUT:-${1:-}}}"

if [[ -n "$COMMAND" && ! "$COMMAND" =~ (git[[:space:]]+commit|gh[[:space:]]+pr[[:space:]]+create) ]]; then
  exit 0
fi

echo "[PRE-COMMIT-GUARD] Enforcing mechanical quality floor before commit/PR..."
bash "${ROOT_DIR}/scripts/floor-guard.sh"
