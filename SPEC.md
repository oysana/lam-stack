---
name: spec
description: 7-Seam Artifact State Machine and 4 Model Roles contract for lam-stack v0.2.0.
version: 0.2.0
---

# SPEC: 7-Seam Artifact State Machine & Model Role Contract (v0.2.0)

## 1. Core Axiom: $M = R$ (Model State Equals Reality)

Illegal plugin and application states MUST be unrepresentable at compile time and runtime:
1. Every manifest entry in `plugin.json`, `.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, and `.codex-plugin/plugin.json` MUST map 1:1 to a verified file on disk.
2. Every transition across the 7 Seams is mechanically gated by `bash scripts/seam-gate.sh check <0..7>`.
3. Every commit or PR creation tool call is mechanically gated by `hooks/pre-commit-guard.sh` invoking `bash scripts/floor-guard.sh`.

## 2. The 7-Seam Artifact State Machine

```
[Seam 0: Code Anchor]
        |
        v
[Seam 1: Intent & Glossary]
        |
        v
[Seam 2: Quality Floor]
        |
        v
[Seam 3: Spec & Interface Sketch]
        |
        v
[Seam 4: Tracer-Bullet Ticket Graph]
        |
        v
[Seam 5: SDD + Seam-TDD Slice]
        |
        v
[Seam 6: Hygiene, Dual-Axis Doubt & Worktree Interrogate]
        |
        v
[Seam 7: Shipped PR & 5-Layer Retro Hardening]
```

| Seam | Canonical Name | Required Artifacts on Disk | Gate Verification Command | Primary Role |
| :--- | :--- | :--- | :--- | :--- |
| **Seam 0** | `Seam 0: Code Anchor` | `plugin.json`, `SKILL.md`, `scripts/validate-lam.py` | `bash scripts/seam-gate.sh check 0` | `worker` |
| **Seam 1** | `Seam 1: Intent & Glossary` | `GLOSSARY.md` | `bash scripts/seam-gate.sh check 1` | `builder` |
| **Seam 2** | `Seam 2: Quality Floor` | `CONSTRAINTS.md`, `scripts/floor-guard.sh`, `hooks/hooks.json`, `hooks/pre-commit-guard.sh` | `bash scripts/seam-gate.sh check 2` | `builder` |
| **Seam 3** | `Seam 3: Spec & Interface Sketch` | `SPEC.md`, `references/principles-and-vocabulary.md`, `references/before-code-playbooks.md` | `bash scripts/seam-gate.sh check 3` | `builder` + `judge` |
| **Seam 4** | `Seam 4: Tracer-Bullet Ticket Graph` | `skills/lam-architect/SKILL.md`, `scripts/seam-gate.sh`, `scripts/log-decision.sh` | `bash scripts/seam-gate.sh check 4` | `builder` |
| **Seam 5** | `Seam 5: SDD + Seam-TDD Slice` | `agents/test-engineer.md`, `skills/lam-build/SKILL.md`, `references/during-code-playbooks.md` | `bash scripts/seam-gate.sh check 5` | `builder` |
| **Seam 6** | `Seam 6: Hygiene, Dual-Axis Doubt & Worktree Interrogate` | `skills/lam-review/SKILL.md`, `agents/reviewer.md`, `.claude/commands/interrogate.md` | `bash scripts/seam-gate.sh check 6` | `judge` + `peer` |
| **Seam 7** | `Seam 7: Shipped PR & 5-Layer Retro Hardening` | `skills/lam-ship/SKILL.md`, `references/after-code-playbooks.md`, `decisions.tsv` | `bash scripts/seam-gate.sh check 7` | `judge` |

## 3. The 4 Model Roles (`worker`, `builder`, `judge`, `peer`)

| Role | Cognitive Posture | Permitted Operations | Forbidden Operations | Primary Seams |
| :--- | :--- | :--- | :--- | :--- |
| **`worker`** | Fast, deterministic mechanical execution, file inventory, and command running. | Codebase indexing, path checks, running `validate-lam.py`, `floor-guard.sh`, and `log-decision.sh`. | Inventing domain abstractions or relaxing `CONSTRAINTS.md` rules. | Seam 0, Seam 2 |
| **`builder`** | Deep-module synthesis, $M=R$ schema design, and Tracer-Bullet vertical implementation. | Authoring specs, interfaces, seam tests, and production slices that pass `check:task`. | Self-approving Seam 6 reviews or bypassing `floor-guard.sh`. | Seam 1, 3, 4, 5 |
| **`judge`** | Cold, adversarial verification with zero attachment to the author's chain-of-thought. | Executing `CLAIM -> EXTRACT -> DOUBT -> RECONCILE -> STOP`, Cold Spec-Doubt, and 5-Layer Retro checks. | Quietly patching broken code without logging a finding first. | Seam 3, 6, 7 |
| **`peer`** | Parallel alternative explorer operating in an isolated `arena` or `interrogate` worktree. | Competing in `/arena` worktrees, stress-testing edge cases in `/interrogate`, and challenging trade-offs. | Mutating the primary branch directly without winning selection. | Seam 3, 5, 6 |

## 4. Pre-Code `CLAIM -> EXTRACT -> DOUBT -> RECONCILE -> STOP` Contract

Before writing production code at Seam 3 or Seam 5, the active agent MUST execute:
1. **CLAIM**: State the exact behavioral invariant or architectural hypothesis to be implemented.
2. **EXTRACT**: Pull the concrete types, seam signatures, and file paths from the live repository anchor.
3. **DOUBT**: Run a cold adversarial check (`judge` posture) asking how the claim fails under empty, boundary, error, or concurrent inputs.
4. **RECONCILE**: Tighten the $M = R$ data shape and interface signature so the doubted failure mode becomes unrepresentable or explicitly typed.
5. **STOP**: Lock the contract in `SPEC.md` and `decisions.tsv` before writing implementation lines.
