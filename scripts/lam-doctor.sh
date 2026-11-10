#!/usr/bin/env bash
# lam-doctor — standalone floor audit for ANY repo. No install needed:
#   bash lam-doctor.sh [repo-path]
# Scans tracked source files for the 7 floor-violation classes.
# Exit 0 = clean floor, exit 1 = violations found.
set -u
REPO="${1:-.}"
cd "$REPO" 2>/dev/null || { echo "lam-doctor: no such repo $REPO"; exit 2; }

RULE_NAMES=(SUPPRESSION_DIRECTIVE TYPE_ESCAPE FOCUSED_OR_SKIPPED_TEST UNIMPLEMENTED_STUB SILENT_ERROR_SWALLOW DEBUG_LEFTOVER LEAKED_CREDENTIAL)
RULE_PATTERNS=(
  "(@ts-ignore|@ts-expect-error|eslint-disable|biome-ignore|# noqa|# type: ignore|istanbul ignore|Stryker disable|nosemgrep|gitleaks:allow)"
  "(as[[:space:]]+any([^a-zA-Z0-9_]|$)|as[[:space:]]+unknown[[:space:]]+as)"
  "(\.(skip|only|todo)[[:space:]]*\(|\b(xit|fdescribe)[[:space:]]*\(|@pytest\.mark\.skip)"
  "(throw[[:space:]]+new[[:space:]]+Error\(['\"]not implemented['\"]\)|NotImplementedError|todo!\(\)|unimplemented!\(\))"
  "(catch[[:space:]]*(\([^)]*\))?[[:space:]]*\{[[:space:]]*\}|except[^:]*:[[:space:]]*pass)"
  "(\[DEBUG-[0-9a-zA-Z_-]+\]|\bdebugger[[:space:]]*;?|console\.log[[:space:]]*\()"
  "(AKIA[0-9A-Z]{16}|ghp_[0-9a-zA-Z]{36}|BEGIN (RSA|OPENSSH|EC|PGP) PRIVATE KEY|(api_key|secret_key|access_token)[[:space:]]*[:=][[:space:]]*['\"][A-Za-z0-9_\-]{20,}['\"])"
)

violations=0
scanned=0
while IFS= read -r f; do
  case "$f" in
    *.md|*.txt|*.json|*.lock|*.svg|*.png|*.woff*|.git*) continue ;;
  esac
  [ -f "$f" ] || continue
  scanned=$((scanned+1))
  for i in "${!RULE_NAMES[@]}"; do
    if grep -nE "${RULE_PATTERNS[$i]}" "$f" >/dev/null 2>&1; then
      echo "[FLOOR VIOLATION] ${RULE_NAMES[$i]} in $f"
      grep -nE "${RULE_PATTERNS[$i]}" "$f" | head -3
      violations=$((violations+1))
    fi
  done
done < <(git ls-files)

echo "lam-doctor: scanned $scanned files, $violations violation(s)"
[ "$violations" -eq 0 ] && exit 0 || exit 1
