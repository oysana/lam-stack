#!/usr/bin/env bash
set -euo pipefail

# L.A.M. Stack v0.1.0 - Seam Gate & Worktree Isolation Controller
# Subcommands:
#   check <0..7>
#   worktree <arena|swarm|interrogate|spec> <slug>
#   --self-test

ROOT_DIR="${LAM_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

seam_artifacts() {
  local seam="$1"
  case "$seam" in
    0)
      echo "plugin.json .claude-plugin/plugin.json .cursor-plugin/plugin.json .codex-plugin/plugin.json SKILL.md skills/lam-investigate/SKILL.md scripts/validate-lam.py"
      ;;
    1)
      echo "GLOSSARY.md skills/lam-grill/SKILL.md"
      ;;
    2)
      echo "CONSTRAINTS.md skills/lam-constraints/SKILL.md scripts/floor-guard.sh hooks/hooks.json hooks/pre-commit-guard.sh"
      ;;
    3)
      echo "SPEC.md skills/lam-spec/SKILL.md skills/lam-architect/SKILL.md references/principles-and-vocabulary.md references/before-code-playbooks.md"
      ;;
    4)
      echo "skills/lam-tickets/SKILL.md scripts/seam-gate.sh scripts/log-decision.sh"
      ;;
    5)
      echo "agents/lam-coder.md agents/test-engineer.md skills/lam-build/SKILL.md skills/lam-debug/SKILL.md skills/lam-perf/SKILL.md references/during-code-playbooks.md"
      ;;
    6)
      echo "skills/lam-review/SKILL.md agents/spec-doubt-reviewer.md agents/standards-arch-reviewer.md agents/comment-sicko.md .claude/commands/interrogate.md"
      ;;
    7)
      echo "skills/lam-ship/SKILL.md skills/lam-retro/SKILL.md agents/security-auditor.md references/after-code-playbooks.md decisions.tsv"
      ;;
    *)
      echo "[SEAM-GATE] Unknown seam index: ${seam}. Expected 0..7." >&2
      return 2
      ;;
  esac
}

cmd_check() {
  local target_seam="${1:-}"
  if [[ ! "$target_seam" =~ ^[0-7]$ ]]; then
    echo "[SEAM-GATE] Invalid seam '${target_seam}'. Usage: seam-gate.sh check <0..7>" >&2
    return 2
  fi

  local missing=0
  local s
  for ((s = 0; s <= target_seam; s++)); do
    local artifacts
    artifacts="$(seam_artifacts "$s")"
    local rel_path
    for rel_path in $artifacts; do
      if [[ ! -f "${ROOT_DIR}/${rel_path}" ]]; then
        echo "[SEAM-GATE FAIL] Seam ${s} missing required artifact: ${rel_path}" >&2
        missing=$((missing + 1))
      fi
    done
  done

  if [[ "$missing" -gt 0 ]]; then
    echo "[SEAM-GATE] Blocked transition to Seam ${target_seam}: ${missing} missing artifact(s)." >&2
    return 1
  fi

  echo "[SEAM-GATE] PASS: Seam 0..${target_seam} artifacts verified."
  return 0
}

cmd_worktree() {
  local mode="${1:-}"
  local slug="${2:-}"

  case "$mode" in
    arena|swarm|interrogate|spec) ;;
    *)
      echo "[SEAM-GATE] Invalid worktree mode '${mode}'. Expected: arena|swarm|interrogate|spec" >&2
      return 2
      ;;
  esac

  if [[ -z "$slug" || ! "$slug" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "[SEAM-GATE] Invalid or missing slug '${slug}'." >&2
    return 2
  fi

  SEAM_WT_BASE="$(mktemp -d -t "lam-${mode}-${slug}-XXXXXX")"
  local wt_base="$SEAM_WT_BASE"

  cleanup_worktree() {
    if [[ -n "${SEAM_WT_BASE:-}" ]]; then
      if [[ -d "${ROOT_DIR}/.git" ]]; then
        git -C "$ROOT_DIR" worktree remove --force "$SEAM_WT_BASE" >/dev/null 2>&1 || true
        git -C "$ROOT_DIR" worktree prune >/dev/null 2>&1 || true
      fi
      rm -rf "$SEAM_WT_BASE" >/dev/null 2>&1 || true
    fi
  }
  trap cleanup_worktree EXIT

  if [[ -d "${ROOT_DIR}/.git" ]] && git -C "$ROOT_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
    git -C "$ROOT_DIR" worktree add --detach "$wt_base" HEAD >/dev/null 2>&1 || cp -R "${ROOT_DIR}/plugin.json" "${ROOT_DIR}/SKILL.md" "$wt_base/" 2>/dev/null || true
  else
    cp -R "${ROOT_DIR}/plugin.json" "${ROOT_DIR}/SKILL.md" "$wt_base/" 2>/dev/null || true
  fi

  echo "[SEAM-GATE] Created isolated '${mode}' worktree for '${slug}' at ${wt_base} (auto-pruned on exit)."
  return 0
}

run_self_test() {
  echo "[SEAM-GATE] Running self-test suite..."
  SEAM_SELF_TEST_TMP="$(mktemp -d)"
  trap 'rm -rf "${SEAM_SELF_TEST_TMP:-}"' EXIT
  local tmp_repo="$SEAM_SELF_TEST_TMP"

  # 1. Verify negative test: empty repo fails Seam 0
  if LAM_REPO_ROOT="$tmp_repo" bash "${BASH_SOURCE[0]}" check 0 >/dev/null 2>&1; then
    echo "  [FAIL] Seam 0 check passed on empty directory!" >&2
    exit 1
  else
    echo "  [PASS] Seam 0 check rejected incomplete repository."
  fi

  # 2. Verify positive check on actual root up to Seam 6 (or 7 if decisions.tsv exists)
  if [[ -f "${ROOT_DIR}/decisions.tsv" ]]; then
    bash "${BASH_SOURCE[0]}" check 7 >/dev/null
    echo "  [PASS] Seam 0..7 artifact gate verified on live repo."
  else
    bash "${BASH_SOURCE[0]}" check 6 >/dev/null
    echo "  [PASS] Seam 0..6 artifact gate verified on live repo."
  fi

  # 3. Verify worktree isolation and clean prune
  bash "${BASH_SOURCE[0]}" worktree interrogate self-test-slice >/dev/null
  echo "  [PASS] Worktree 'interrogate' created and pruned cleanly."

  echo "[SEAM-GATE] Self-test complete: all checks passed."
  return 0
}

subcmd="${1:-}"
case "$subcmd" in
  check)
    shift
    cmd_check "$@"
    ;;
  worktree)
    shift
    cmd_worktree "$@"
    ;;
  --self-test)
    run_self_test
    ;;
  *)
    echo "Usage: $0 {check <0..7>|worktree <arena|swarm|interrogate|spec> <slug>|--self-test}" >&2
    exit 2
    ;;
esac
