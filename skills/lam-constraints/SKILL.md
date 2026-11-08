---
name: lam-constraints
description: Establishes and enforces a repository's mechanical quality bar in CONSTRAINTS.md with diff-scoped floor guards. Combines Addy Osmani's constraint-driven-development, Matt Pocock's setup-ts-deep-modules, and Lauren Tan's principle-encode-lessons-in-structure.
disable-model-invocation: true
---

# L.A.M. Constraints (`/constraints` + `floor-guard`)

## Overview
Writes `CONSTRAINTS.md` at the repo root and wires fast, deterministic quality gates so agents can never quietly lower the bar via `@ts-ignore`, `eslint-disable`, `.skip` tests, or empty stubs.

## When to Use
- First-time repo setup, before starting `/build auto`, or when recurring agent mistakes need a mechanical gate.

## The Workflow
1. **Detect Stack First**: Inspect build manifests (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`), linter/type configs, test runners, and CI workflows. Report findings in 2 lines.
2. **Confirm 4 Intake Defaults**:
   - Dimensions beyond Floor: changed-line test coverage (>=80%) + zero critical/high security advisories.
   - Mid-task enforcement: hard block on the Floor, warn/ratchet on legacy metrics.
   - Legacy thresholds: measure today's baseline and hold (`0.5%` ratchet tolerance).
   - Stage budgets: `check:fast` (<5s on edit), `check:task` (<90s at slice end), `check:full` (CI / `/ship`).
3. **Write `CONSTRAINTS.md` & Link in `CLAUDE.md`/`AGENTS.md`**:
   - `## Floor`: Zero new compiler/linter/coverage/mutation suppressions (`@ts-ignore`, `eslint-disable`, `# noqa`, `# type: ignore`, `istanbul ignore`, `Stryker disable`, `nosemgrep`, `gitleaks:allow`), zero unimplemented stubs or empty `catch {}`, zero `.skip`/deleted tests, zero secrets (`gitleaks dir . --redact --no-banner`), and deep-module entry-point boundaries (`dependency-cruiser`).
   - `## Enforced with numbers`, `## Measured ratchets`, and `## Exceptions` (owner + expiry <=90 days).
4. **Verify Against Violation & Clean Control**: Run `bash scripts/floor-guard.sh` against a seeded violation (must fail) and clean working tree (must pass).

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"Writing rules in CLAUDE.md is enough; we don't need a script."* | Prose instructions drift under context pressure (`principle-encode-lessons-in-structure`). Mechanical checks in `floor-guard.sh` and `check:fast` never forget. |

## Red Flags
- Editing `CONSTRAINTS.md` thresholds downward to make a failing check pass.
- Running `gitleaks` without `--redact`.

## Verification
- [ ] `CONSTRAINTS.md` exists at repo root with exact runnable commands for `check:fast`, `check:task`, and `check:full`.
- [ ] `scripts/floor-guard.sh` fails on a seeded `@ts-ignore` or `it.skip` and passes on clean code.
