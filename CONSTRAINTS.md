---
name: constraints
description: Seam 0 and Seam 2 forensic audit and mechanical quality floor contract for lam-stack v0.2.1.
version: 0.2.1
---

# CONSTRAINTS: Mechanical Quality Floor & Forensic Baseline (v0.2.1)

## 1. Seam 0 Forensic Audit (v0.1.0 Defect Ledger)

Prior to executing the v0.2.1 upgrade, a forensic inspection of `lam-stack` v0.1.0 identified five structural and mechanical defects that violated $M = R$ (Model State equals Reality):

1. **Defect A (Phantom Agent Reference)**: `SKILL.md` and `skills/lam-ship/SKILL.md` delegated verification work to `test-engineer`, yet `agents/test-engineer.md` did not exist on disk and was absent from `plugin.json`, `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, and `.codex-plugin/plugin.json`.
2. **Defect B (Root/Skill DRY Violation)**: Root `SKILL.md` and `skills/lam-mode/SKILL.md` were duplicated word-for-word, creating drift risk and wasting context tokens instead of using an ultra-compact (<90 lines) Two-Load entry router at `SKILL.md`.
3. **Defect C (Unenforced Hook Gates)**: `hooks/hooks.json` lacked `PreToolUse` (blocking `git commit` and `gh pr create` when floor violations exist) and `Stop` enforcement gates.
4. **Defect D (Incomplete Floor Guard Regexes)**: `scripts/floor-guard.sh` failed to trap focused tests (`.only`), runtime debug noise (`console.log`, `debugger`, `[DEBUG-xxxx]`), type-system escapes (`as any`, `as unknown as`), silent error swallowing (`catch {}`, `except: pass`), and leaked credential patterns.
5. **Defect E (Missing Tier-2 & Tier-3 Validator Coverage)**: `scripts/validate-lam.py` lacked Tier-2 manifest-to-disk bidirectional path verification, markdown reference existence checks, YAML trigger-phrase collision detection, and Tier-3 behavioral execution traces.

## 2. Seam 2 Mechanical Verification Commands (`how` + `why`)

Every slice in `lam-stack` v0.2.1 is governed by three deterministic verification gates:

### `check:fast`
```bash
python3 scripts/validate-lam.py
```
- **Why**: Enforces 3-Tier structural, manifest parity, routing collision, and behavioral trace invariants in under 2 seconds.

### `check:task`
```bash
python3 scripts/validate-lam.py && bash scripts/floor-guard.sh
```
- **Why**: Verifies both structural/manifest integrity and zero suppression, stub, debug, or secret violations across tracked repository files after every vertical slice.

### `check:full`
```bash
python3 scripts/validate-lam.py && bash scripts/floor-guard.sh --self-test && bash scripts/seam-gate.sh --self-test && bash scripts/floor-guard.sh
```
- **Why**: Executes the seeded-violation self-test suite (proving each regex trap and seam gate exits non-zero when a defect is injected) followed by the clean control scan against the live repository.

## 3. Hard Non-Negotiable Invariants

- **File Length Ceiling**: Every `SKILL.md`, `agents/*.md`, `references/*.md`, and `.claude/commands/*.md` file MUST be `<= 500` lines.
- **Zero Typographic Slop**: Zero em-dashes or en-dashes across all markdown artifacts; use standard ASCII hyphens (`-` or `--`) or colons.
- **Manifest Parity**: `plugin.json`, `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, and `.codex-plugin/plugin.json` MUST remain 100% synchronized at version `0.2.1`.
- **Zero Unverified Commits**: `hooks/pre-commit-guard.sh` blocks `git commit` and `gh pr create` unless `bash scripts/floor-guard.sh` exits `0`.
