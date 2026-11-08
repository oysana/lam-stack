#!/usr/bin/env bash
set -euo pipefail

# L.A.M. Stack v0.2.0 - Mechanical Floor Guard
# Blocks compiler/lint/coverage/mutation suppressions, focused/skipped tests,
# unimplemented stubs, silent error swallowing, debug leftovers, type escapes,
# and leaked credentials across code diffs while ignoring markdown prose (*.md).

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

declare -a RULE_NAMES=(
  "SUPPRESSION_DIRECTIVE"
  "TYPE_ESCAPE"
  "FOCUSED_OR_SKIPPED_TEST"
  "UNIMPLEMENTED_STUB"
  "SILENT_ERROR_SWALLOW"
  "DEBUG_LEFTOVER"
  "LEAKED_CREDENTIAL"
)

declare -a RULE_PATTERNS=(
  "(@ts-ignore|@ts-expect-error|eslint-disable|biome-ignore|# noqa|# type: ignore|istanbul ignore|Stryker disable|nosemgrep|gitleaks:allow)"
  "(as[[:space:]]+any([^a-zA-Z0-9_]|$)|as[[:space:]]+unknown[[:space:]]+as)"
  "(\.(skip|only|todo)[[:space:]]*\(|\b(xit|fdescribe)[[:space:]]*\(|@pytest\.mark\.skip)"
  "(throw[[:space:]]+new[[:space:]]+Error\(['\"]not implemented['\"]\)|NotImplementedError|todo!\(\)|unimplemented!\(\))"
  "(catch[[:space:]]*(\([^)]*\))?[[:space:]]*\{[[:space:]]*\}|except[^:]*:[[:space:]]*pass)"
  "(\[DEBUG-[0-9a-zA-Z_-]+\]|\bdebugger[[:space:]]*;?|console\.log[[:space:]]*\()"
  "(AKIA[0-9A-Z]{16}|ghp_[0-9a-zA-Z]{36}|BEGIN (RSA|OPENSSH|EC|PGP) PRIVATE KEY|(api_key|secret_key|access_token)[[:space:]]*[:=][[:space:]]*['\"][A-Za-z0-9_\-]{20,}['\"])"
)

scan_file() {
  local file="$1"
  # Never false-positive on Markdown prose documentation
  if [[ "$file" == *.md ]]; then
    return 0
  fi
  local violations=0
  local i
  for i in "${!RULE_NAMES[@]}"; do
    local name="${RULE_NAMES[$i]}"
    local pattern="${RULE_PATTERNS[$i]}"
    if grep -nE "$pattern" "$file" >/dev/null 2>&1; then
      echo "[FLOOR-GUARD FAIL] ${name} in ${file}:" >&2
      grep -nE "$pattern" "$file" >&2 || true
      violations=$((violations + 1))
    fi
  done
  return "$violations"
}

scan_diff_stream() {
  local diff_text="$1"
  if [[ -z "$diff_text" ]]; then
    return 0
  fi
  local violations=0
  local i
  for i in "${!RULE_NAMES[@]}"; do
    local name="${RULE_NAMES[$i]}"
    local pattern="${RULE_PATTERNS[$i]}"
    local matches
    matches="$(printf '%s\n' "$diff_text" | grep -E "$pattern" || true)"
    if [[ -n "$matches" ]]; then
      echo "[FLOOR-GUARD FAIL] ${name} in git diff:" >&2
      printf '%s\n' "$matches" | head -n 10 >&2
      violations=$((violations + 1))
    fi
  done
  return "$violations"
}

run_self_test() {
  echo "[FLOOR-GUARD] Running seeded-violation self-test suite..."
  FLOOR_SELF_TEST_TMP="$(mktemp -d)"
  trap 'rm -rf "${FLOOR_SELF_TEST_TMP:-}"' EXIT
  local tmp_dir="$FLOOR_SELF_TEST_TMP"

  local -a seed_names=(
    "ts-ignore suppression"
    "eslint-disable suppression"
    "type-ignore python suppression"
    "Stryker mutation suppression"
    "as any type escape"
    "as unknown as double cast"
    ".only focused test"
    ".skip skipped test"
    "pytest skip decorator"
    "NotImplementedError stub"
    "Rust todo!() macro stub"
    "empty catch {} block"
    "Python except: pass block"
    "[DEBUG-xxxx] marker"
    "debugger statement"
    "console.log leftover"
    "AWS AKIA credential leak"
  )

  local -a seed_payloads=(
    "// @ts-ignore"
    "/* eslint-disable no-unused-vars */"
    "x = 1  # type: ignore"
    "// Stryker disable all"
    "const val = input as any;"
    "const coerced = input as unknown as TargetType;"
    "test.only('focused test', () => {});"
    "describe.skip('skipped suite', () => {});"
    "@pytest.mark.skip(reason='later')"
    "raise NotImplementedError('pending')"
    "fn calc() { todo!() }"
    "try { work(); } catch (err) {}"
    "try:\n    work()\nexcept: pass"
    "const tag = '[DEBUG-1042]';"
    "debugger;"
    "console.log('trace payload');"
    "const key = 'AKIAIOSFODNN7EXAMPLE';"
  )

  local passed=0
  local total="${#seed_names[@]}"
  local idx

  for idx in "${!seed_names[@]}"; do
    local label="${seed_names[$idx]}"
    local payload="${seed_payloads[$idx]}"
    local seed_file="${tmp_dir}/seed_${idx}.ts"
    printf "%b\n" "$payload" > "$seed_file"
    if bash "${BASH_SOURCE[0]}" --target "$seed_file" >/dev/null 2>&1; then
      echo "  [FAIL] Trap did NOT fire for seeded violation: ${label}" >&2
      exit 1
    else
      echo "  [PASS] Trap fired as expected for: ${label}"
      passed=$((passed + 1))
    fi
  done

  # Clean control code test
  local clean_file="${tmp_dir}/clean_control.ts"
  cat << 'EOF' > "$clean_file"
export interface ValidatedOrder {
  readonly id: string;
  readonly amountCents: number;
}

export function parseOrder(id: string, amountCents: number): ValidatedOrder {
  if (!id || amountCents < 0) {
    throw new Error("Invalid order parameters");
  }
  return { id, amountCents };
}
EOF

  if bash "${BASH_SOURCE[0]}" --target "$clean_file" >/dev/null 2>&1; then
    echo "  [PASS] Clean control code file exited 0 without false positives."
  else
    echo "  [FAIL] Clean control code file triggered a false positive!" >&2
    exit 1
  fi

  # Markdown prose immunity test (verifies console.log / as any in .md never false-positive)
  local md_file="${tmp_dir}/prose_doc.md"
  cat << 'EOF' > "$md_file"
# Documentation Example
Never use `console.log("debug")` or `value as any` or `@ts-ignore` in production seams.
EOF

  if bash "${BASH_SOURCE[0]}" --target "$md_file" >/dev/null 2>&1; then
    echo "  [PASS] Markdown prose file (.md) with console.log and as any exited 0 without false positives."
  else
    echo "  [FAIL] Markdown prose file (.md) triggered a false positive!" >&2
    exit 1
  fi

  echo "[FLOOR-GUARD] Self-test complete: ${passed}/${total} seeded violations trapped + 2/2 clean/markdown controls passed."
  return 0
}

if [[ "${1:-}" == "--self-test" ]]; then
  run_self_test
  exit 0
fi

if [[ "${1:-}" == "--target" ]]; then
  target_file="${2:-}"
  if [[ -z "$target_file" || ! -f "$target_file" ]]; then
    echo "[FLOOR-GUARD] Missing or invalid target file: ${target_file}" >&2
    exit 2
  fi
  if scan_file "$target_file"; then
    exit 0
  else
    exit 1
  fi
fi

# Default: inspect git diff of non-markdown code files against BASE_REF (default: HEAD)
BASE_REF="${1:-HEAD}"
if [[ -d "${ROOT_DIR}/.git" ]] && git -C "$ROOT_DIR" rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  DIFF_ADDED="$(git -C "$ROOT_DIR" diff "$BASE_REF" --unified=0 -- . ':!*.md' ':!scripts/floor-guard.sh' 2>/dev/null | grep -E '^\+[^+]' || true)"
  if ! scan_diff_stream "$DIFF_ADDED"; then
    echo "[FLOOR-GUARD] FAILED: Code diff against ${BASE_REF} violated mechanical quality floor." >&2
    exit 1
  fi
fi

echo "[FLOOR-GUARD] PASS: Zero floor violations across code diff."
exit 0
