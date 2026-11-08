---
name: lam-architect
description: 5-phase interface design and module deepening workflow combining Lauren Tan's /architect and /arena with Matt Pocock's codebase-design (Design-It-Twice, Deletion Test) and Addy Osmani's api-and-interface-design.
---

# L.A.M. Architect (`architect` + `codebase-design` + `api-and-interface-design`)

## Overview
Designs **deep modules** (maximum hidden implementation behind a minimal public interface at a clean seam) by running a parallel "Design It Twice" `arena` bakeoff, writing caller usage first, and enforcing a hard **Scrap Trigger** if implementation hits repeated friction.

## When to Use
- Any change that crosses a function/module boundary, introduces a new public interface or REST/GraphQL endpoint, or reshapes stateful domain logic.

## The Workflow
1. **Phase A - Ground**: Run `lam-investigate` (`how` + `why`) over touched subsystems. Read `GLOSSARY.md` and `docs/adr/`.
2. **Phase B - Sketch (`Design It Twice` via `arena`)**:
   - Spawn 2-3 parallel fresh-context subagents to design radically distinct interface shapes.
   - **Caller Usage First**: Each sketch writes caller and test invocation at the seam first, then types (`kind` discriminated unions, branded IDs, `{ error: { code, message, details? } }`), boundary validation, and module signatures with `not implemented` bodies.
   - **Evaluate & Graft**: Score sketches on **Depth** (small interface hiding rich logic), **The Deletion Test**, **30-Second Reader Load**, **Boundary Discipline**, **Hyrum's Law**, and **Atomic Idempotency** (for state-changing APIs: single `INSERT` unique constraint + `422` on payload hash mismatch). Pick the cleanest base and graft the best idea from the runner-up.
3. **Phase C - Agree**: Present the winning sketch (pausing for human approval only if requested with checkpoint).
4. **Phase D - Implement Against Contract**: Treat the sketch as a contract; surface any unanticipated parameter or seam leak immediately.
5. **Phase E - Scrap Trigger (`pstack/architect`)**: If implementation exhibits repeated friction (same workaround across files, `any`/casts required to compile, callers needing internal ordering knowledge, or >=2 independent deviations from the sketch), **scrap the sketch** and return to Phase B.

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"The first interface shape I thought of is fine; no need to sketch a second."* | Single-sketch designs anchor on shallow pass-throughs (`DESIGN-IT-TWICE.md`). Comparing 2 radical sketches exposes leaky parameters immediately. |
| *"Implementation hit 3 awkward type casts, so I'll just add optional flags to the interface."* | Repeated workarounds are Phase E tells (`architect`). Scrap the sketch and redesign the data shape from first principles. |

## Red Flags
- Exposing internal database models or third-party SDK types directly across a module's public seam.
- Implementing `SELECT` then `INSERT` for idempotency keys (TOCTOU race condition).

## Verification
- [ ] At least 2 distinct interface shapes were compared on Depth, Locality, and Seam placement.
- [ ] Caller usage and seam test signatures were written before implementation bodies.
- [ ] Module passes the Deletion Test and keeps validation strictly at system boundaries.
