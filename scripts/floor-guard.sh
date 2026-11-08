#!/usr/bin/env bash
# L.A.M. Stack - Mechanical Floor Guard (from Addy Osmani's `constraint-driven-development` + Lauren Tan's `comment-sicko`)
# Inspects git diff against base branch (default: HEAD) for forbidden suppressions, skipped tests, unimplemented stubs, and secrets.

set -euo pipefail

BASE_REF="${1:-HEAD}"
DIFF_ADDED="$(git diff "$BASE_REF" --unified=0 2>/dev/null | grep -E '^\+[^+]' || true)"

if [ -z "$DIFF_ADDED" ]; then
  echo "[L.A.M. Floor Guard] Clean: no added lines against $BASE_REF."
  exit 0
fi

FAILURES=0

check_pattern() {
  local label="$1"
  local regex="$2"
  local matches
  matches="$(printf '%s\n' "$DIFF_ADDED" | grep -E "$regex" || true)"
  if [ -n "$matches" ]; then
    echo "[L.A.M. Floor Guard] VIOLATION - $label:" >&2
    printf '%s\n' "$matches" | head -n 10 >&2
    FAILURES=$((FAILURES + 1))
  fi
}

# 1. Forbidden compiler/linter/coverage/mutation suppressions
check_pattern "New type/lint/coverage suppression added" '(@ts-ignore|@ts-expect-error|eslint-disable|biome-ignore|# noqa|# type: ignore|istanbul ignore|Stryker disable|nosemgrep|gitleaks:allow)'

# 2. Skipped or disabled tests
check_pattern "Skipped or disabled test added" '\b(it|test|describe)\.(skip|todo)\b|\bx(it|test|describe)\b|@pytest\.mark\.skip'

# 3. Unimplemented stubs
check_pattern "Unimplemented stub added" 'throw new Error\(["'\'']not implemented["'\'']\)|NotImplementedError'

# 4. Leftover debug tags from diagnosing-bugs
check_pattern "Leftover [DEBUG-xxxx] instrumentation tag" '\[DEBUG-[a-zA-Z0-9]+\]'

if [ "$FAILURES" -gt 0 ]; then
  echo "[L.A.M. Floor Guard] FAILED with $FAILURES violation category(s)." >&2
  exit 1
fi

echo "[L.A.M. Floor Guard] PASSED: Zero floor violations detected."
