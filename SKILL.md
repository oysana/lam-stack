---
name: lam-stack
description: Ultra-compact Two-Load entry router for L.A.M. Stack v0.2.0. Delegates orchestration to skills/lam-mode/SKILL.md across the 7-Seam Artifact State Machine.
version: 0.2.0
---

# L.A.M. Stack v0.2.0: Root Two-Load Entry Router

This file is the `< 90` line Load-1 router for `lam-stack` v0.2.0. To eliminate the v0.1.0 DRY duplication defect between root `SKILL.md` and `skills/lam-mode/SKILL.md`, full orchestration rules live exclusively in `skills/lam-mode/SKILL.md`.

## 1. Two-Load Progressive Disclosure Router

Load `skills/lam-mode/SKILL.md` first, then load **only** the active Seam skill, reference playbook, and subagent persona:

| Seam | Canonical Stage | Target Skill | Reference Playbook | Active Agent Persona(s) |
| :--- | :--- | :--- | :--- | :--- |
| **All** | Full 7-Seam Coordinator | `skills/lam-mode/SKILL.md` | `references/principles-and-vocabulary.md` | `agents/lam-coder.md` |
| **Seam 0** | Code Anchor (`how` + `why`) | `skills/lam-investigate/SKILL.md` | `references/before-code-playbooks.md` | `agents/lam-coder.md` |
| **Seam 1** | Intent & Glossary (`GLOSSARY.md`) | `skills/lam-grill/SKILL.md` | `references/before-code-playbooks.md` | `agents/standards-arch-reviewer.md` |
| **Seam 2** | Quality Floor (`CONSTRAINTS.md`) | `skills/lam-constraints/SKILL.md` | `references/before-code-playbooks.md` | `agents/comment-sicko.md` |
| **Seam 3** | Spec & Interface (`SPEC.md`) | `skills/lam-spec/SKILL.md`, `skills/lam-architect/SKILL.md` | `references/before-code-playbooks.md` | `agents/spec-doubt-reviewer.md` |
| **Seam 4** | Tracer-Bullet Ticket Graph | `skills/lam-tickets/SKILL.md` | `references/before-code-playbooks.md` | `agents/lam-coder.md` |
| **Seam 5** | SDD + Seam-TDD Slice | `skills/lam-build/SKILL.md`, `skills/lam-debug/SKILL.md`, `skills/lam-perf/SKILL.md` | `references/during-code-playbooks.md` | `agents/lam-coder.md`, `agents/test-engineer.md`, `agents/web-performance-auditor.md` |
| **Seam 6** | Hygiene, Doubt & Interrogate | `skills/lam-review/SKILL.md` | `references/after-code-playbooks.md` | `agents/spec-doubt-reviewer.md`, `agents/standards-arch-reviewer.md`, `agents/test-engineer.md` |
| **Seam 7** | Shipped PR & 5-Layer Retro | `skills/lam-ship/SKILL.md`, `skills/lam-retro/SKILL.md` | `references/after-code-playbooks.md` | `agents/security-auditor.md`, `agents/test-engineer.md` |

## 2. Adaptive Execution Modes & Standalone Skill Portability

`lam-stack` does **not** force all 7 seams on every prompt. Select the execution tier that matches the user's invocation:
- **A-La-Carte Mode (Single Slash Command or Standalone Skill)**: Invoking `/grill`, `/architect`, `/debug`, `/review`, `/perf`, or installing a single `skills/lam-*/` folder executes **only** that skill's seam. If `scripts/` or root contracts are absent in a standalone install, run the project's native test/lint commands.
- **Fast-Track Mode (`< 30` lines, 1 file, clear intent)**: Route `Seam 0 (Anchor) -> Seam 5 (RED -> GREEN) -> Seam 6 (Floor Guard)`.
- **Full 7-Seam Pipeline (`/lam` on multi-file features)**: Route sequentially across `Seam 0..7` gated by `bash scripts/seam-gate.sh check <0..7>`.

## 3. Signature Output Style (Vibe-Coder Executive HUD)

Users judge agent quality by the clarity of your chat output, not just raw diffs. Format every reply with these 3 visual blocks:
1. **Top HUD Bar**: `[L.A.M. v0.2.0 | Seam X/7: <Stage> | Mode: <A-La-Carte|Fast-Track|Full> | Confidence: X% (measured)]`
2. **Real-World Impact (Zero Jargon)**: 2-3 plain-language bullets in the user's language stating what user behavior now works, what failure state is now impossible, and what changed.
3. **Bottom Proof Receipt**: Compact verification line (`Tests: PASS | Floor Guard: 0 violations | Blast Radius: N files | Door: Two-Way`).

## 4. Mechanical Enforcement Scripts & Contracts

- Root Contracts: `CONSTRAINTS.md`, `GLOSSARY.md`, `SPEC.md`
- Persona Registry: `references/agents-and-personas.md`
- Mechanical Gates: `scripts/validate-lam.py`, `scripts/floor-guard.sh`, `scripts/seam-gate.sh`, `scripts/log-decision.sh`
- Hook Enforcement: `hooks/hooks.json`, `hooks/pre-commit-guard.sh`, `hooks/session-start.sh`

## Common Rationalizations

| Rationalization | Reality (L.A.M. v0.2.0 Rule) |
| :--- | :--- |
| *"I will duplicate the entire orchestrator into root `SKILL.md`."* | Word-for-word duplication between `SKILL.md` and `skills/lam-mode/SKILL.md` violates DRY structure. Keep `SKILL.md` under 90 lines and delegate to `skills/lam-mode/SKILL.md`. |
| *"I can skip `seam-gate.sh` and start coding before `SPEC.md` is locked."* | Every Full-Pipeline Seam transition is mechanically gated by `bash scripts/seam-gate.sh check <0..7>`. |

## Verification

- [ ] `python3 scripts/validate-lam.py` passes Tier 1, Tier 2, and Tier 3 checks with 0 errors.
- [ ] `bash scripts/floor-guard.sh --self-test && bash scripts/floor-guard.sh` exits `0`.
- [ ] `bash scripts/seam-gate.sh check 7` verifies all 7 Seam artifacts on disk.
