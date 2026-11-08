---
name: lam-architect
description: 5-phase interface design and module deepening workflow combining Lauren Tan's /architect and /arena with Matt Pocock's codebase-design (Design-It-Twice, Deletion Test) and Addy Osmani's api-and-interface-design and doubt-driven-development.
---

# L.A.M. Architect (`architect` + `codebase-design` + `api-and-interface-design`)

## Overview

Designs **deep modules** (maximum hidden implementation behind a minimal public interface at a clean seam) by routing across the 4 Model Roles (`worker`, `builder`, `judge`, `peer`), executing the Pre-Code `CLAIM -> EXTRACT -> DOUBT -> RECONCILE -> STOP` loop, running a parallel "Design It Twice" `arena` bakeoff, and enforcing a hard **Scrap Trigger** if implementation hits repeated friction.

## When to Use

- Any change that crosses a function/module boundary, introduces a new public interface or REST/GraphQL endpoint, or reshapes stateful domain logic (`M = R`).

## 1. The 4 Model Roles Routing Table (`pstack`)

| Role | Cognitive Posture | Architectural Duty | Active Seams |
| :--- | :--- | :--- | :--- |
| **`worker`** | Fast mechanical reconnaissance | Run `how`/`why` indexing, extract live signatures, run `scripts/validate-lam.py` and `scripts/floor-guard.sh`. | Seam 0, Seam 2 |
| **`builder`** | Deep-module & $M = R$ author | Author `GLOSSARY.md`, `SPEC.md`, boundary parsers, and vertical Tracer-Bullet slices. | Seam 1, 3, 4, 5 |
| **`judge`** | Cold adversarial Spec-Doubt auditor | Execute the `DOUBT` step, score `arena` candidates, verify the 80/15/5 Test Pyramid (`agents/test-engineer.md`). | Seam 3, 6, 7 |
| **`peer`** | Isolated worktree challenger | Sketch competing designs in `bash scripts/seam-gate.sh worktree arena <slug>` or probe in `interrogate`. | Seam 3, 5, 6 |

## 2. Pre-Code `CLAIM -> EXTRACT -> DOUBT -> RECONCILE -> STOP` Loop (`doubt-driven-development`)

Before locking any interface sketch in `SPEC.md`, execute all 5 steps in order:

1. **`CLAIM`**: State the proposed module boundary, type invariant, or state transition as a falsifiable engineering claim.
2. **`EXTRACT`**: Pull the exact existing types, callers, and constraints from the live repository anchor (`Seam 0`). Never design from memory.
3. **`DOUBT`**: Switch to the cold `judge` posture (`agents/spec-doubt-reviewer.md`) and attack the claim across `Empty`, `Boundary`, `Error`, and `Concurrency` inputs. Identify any gap where $|M| > |R|$ allows an illegal state to be represented.
4. **`RECONCILE`**: Reshape the data model using the Polyglot $M = R$ Data-Shape Matrix in `references/principles-and-vocabulary.md` (discriminated unions, branded IDs, `Pydantic` frozen models, Go opaque structs, Rust algebraic enums, or SQL `INSERT ... ON CONFLICT`).
5. **`STOP`**: Lock the reconciled contract in `SPEC.md`, log the decision via `bash scripts/log-decision.sh`, and verify `bash scripts/seam-gate.sh check 3` before implementation.

## 3. The 5-Phase Interface Workflow

1. **Phase A - Ground (`worker`)**: Run `skills/lam-investigate/SKILL.md` (`how` + `why`) over touched subsystems. Read `GLOSSARY.md` and `CONSTRAINTS.md`.
2. **Phase B - Sketch (`Design It Twice` via `arena` with `peer` models)**:
   - Spawn 2-3 parallel fresh-context subagents in isolated worktrees (`bash scripts/seam-gate.sh worktree arena <slug>`) to design radically distinct interface shapes.
   - **Caller Usage First**: Each sketch writes caller and test invocation at the seam first, then $M = R$ types (`kind` discriminated unions, branded IDs, `{ error: { code, message, details? } }`), and boundary validation.
   - **Evaluate & Graft (`judge`)**: Score sketches on **Depth** (small interface hiding rich logic), **The Deletion Test**, **30-Second Reader Load**, **Boundary Discipline**, **Hyrum's Law**, and **Atomic Idempotency** (single `INSERT ... ON CONFLICT` + `422` on payload hash mismatch). Pick the cleanest base and graft the best idea from the runner-up.
3. **Phase C - Agree**: Present the winning sketch and lock it in `SPEC.md`.
4. **Phase D - Implement Against Contract (`builder`)**: Treat the sketch as a hard contract; surface any unanticipated parameter or seam leak immediately.
5. **Phase E - Scrap Trigger (`pstack/architect`)**: If implementation exhibits repeated friction (same workaround across files, casts required to compile, callers needing internal ordering knowledge, or >=2 independent deviations from the sketch), **scrap the sketch** and return to Phase B.

## Common Rationalizations

| Rationalization | Reality |
| :--- | :--- |
| *"The first interface shape I thought of is fine; no need to sketch a second or run the DOUBT loop."* | Single-sketch designs anchor on shallow pass-throughs. Comparing 2 radical sketches and running `CLAIM -> EXTRACT -> DOUBT -> RECONCILE -> STOP` exposes leaky parameters immediately. |
| *"Implementation hit 3 awkward type casts, so I will just add optional flags to the interface."* | Optional flag bags create $2^N$ state combinations where $|M| > |R|$. Scrap the sketch and redesign the data shape from first principles. |

## Red Flags

- Exposing internal database models or third-party SDK types directly across a module's public seam.
- Implementing `SELECT` then `INSERT` for idempotency keys (TOCTOU race condition).

## Verification

- [ ] Pre-Code `CLAIM -> EXTRACT -> DOUBT -> RECONCILE -> STOP` loop executed and recorded in `SPEC.md`.
- [ ] At least 2 distinct interface shapes were compared on Depth, Locality, and Seam placement via `4 Model Roles` (`peer` + `judge`).
- [ ] Module passes the Deletion Test and keeps parsing strictly at system boundaries (`M = R`).
