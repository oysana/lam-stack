#!/usr/bin/env bash
set -euo pipefail

# L.A.M. Stack v0.2.0 - PreToolUse Guard for git commit and gh pr create
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL_INPUT="${1:-${CLAUDE_TOOL_INPUT:-}}"

# If invoked with tool input, check whether it matches git commit or gh pr create;
# if invoked directly with no arguments, always run the floor guard.
if [[ -n "$TOOL_INPUT" ]]; then
  if [[ ! "$TOOL_INPUT" =~ (git[[:space:]]+commit|gh[[:space:]]+pr[[:space:]]+create) ]]; then
    exit 0
  fi
fi

echo "[PRE-COMMIT-GUARD] Enforcing mechanical quality floor before commit/PR..."
bash "${ROOT_DIR}/scripts/floor-guard.sh"
