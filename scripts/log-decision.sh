#!/usr/bin/env bash
# L.A.M. Stack v0.2.0 - Atomic Decision Trail Logger (from Lauren Tan's pstack `show-me-your-work`)
# Supports both:
#   bash scripts/log-decision.sh <tsv-path> <phase> <decision> <why> <evidence> <result>
#   bash scripts/log-decision.sh <phase> <decision> <why> <evidence> <result> (uses ${DECISIONS_FILE:-decisions.tsv})
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$#" -ge 6 ]]; then
  TSV_PATH="$1"
  shift
elif [[ "$#" -eq 5 ]]; then
  TSV_PATH="${DECISIONS_FILE:-${ROOT_DIR}/decisions.tsv}"
else
  echo "Usage: $0 [<tsv-path>] <phase> <decision> <why> <evidence> <result>" >&2
  exit 1
fi

sanitize_field() {
  local val="$1"
  # Replace tabs and newlines with spaces
  val="$(printf '%s' "$val" | tr '\t\r\n' '   ')"
  # Trim leading whitespace
  val="${val#"${val%%[![:space:]]*}"}"
  # Neutralize spreadsheet formula-injection prefixes (=, +, -, @, ")
  case "$val" in
    [=+\-@\"]*) val="'$val" ;;
  esac
  printf '%s' "$val"
}

TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
PHASE="$(sanitize_field "$1")"
DECISION="$(sanitize_field "$2")"
WHY="$(sanitize_field "$3")"
EVIDENCE="$(sanitize_field "$4")"
RESULT="$(sanitize_field "$5")"

mkdir -p "$(dirname "$TSV_PATH")"
if [[ ! -f "$TSV_PATH" ]]; then
  printf "ts\tphase\tdecision\twhy\tevidence\tresult\n" > "$TSV_PATH"
fi

printf "%s\t%s\t%s\t%s\t%s\t%s\n" \
  "$TS" "$PHASE" "$DECISION" "$WHY" "$EVIDENCE" "$RESULT" >> "$TSV_PATH"

echo "[DECISION-LOG] Recorded ${PHASE} / ${DECISION} -> ${RESULT} in ${TSV_PATH}"
