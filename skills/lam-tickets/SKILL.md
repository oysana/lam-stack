---
name: lam-tickets
description: Breaks a Spec or plan into tracer-bullet vertical-slice tickets (or expand-contract refactor batches) with explicit blocking edges and a Throughput Checkpoint. Combines Matt Pocock's /to-tickets, /wayfinder, and /triage with Addy Osmani's planning-and-task-breakdown.
disable-model-invocation: true
---

# L.A.M. Tickets (`/tickets` + `/to-tickets` + `planning-and-task-breakdown`)

## Overview
Slices an approved Spec into a dependency graph of self-contained, end-to-end verifiable **tracer-bullet tickets** (or **expand-contract batches** for wide refactors) sized to fit in a single fresh context window (XS-M, <=5 files).

## When to Use
- After `SPEC.md` is approved, or when decomposing any multi-step feature or migration.

## The Workflow
1. **Read-Only Pre-Flight & Prefactor Check**:
   - Check if `tasks/todo.md` or `.scratch/<feature>/issues/` already has unfinished tickets (ask before overwriting).
   - Identify any **prefactoring** (`principle-subtract-before-you-add`: *"Make the change easy, then make the easy change"*) to place as Ticket `01`.
2. **Draft Vertical Tracer-Bullet Slices (or Expand-Contract Batches)**:
   - **Standard Features**: Each ticket cuts a narrow, complete vertical path through all layers (schema + domain + API + UI + seam test) that is demoable/verifiable on its own and touches <=5 files (XS/S/M). Break down any L/XL ticket or any ticket with `"and"` in the title.
   - **Wide Mechanical Refactors (Expand-Contract Exception)**:
     1. *Expand*: Add new form alongside old so CI stays green.
     2. *Migrate Batches*: Migrate callers in blast-radius batches (blocked by Expand).
     3. *Contract*: Delete old form once zero callers remain (blocked by all Migrate batches).
3. **Attach Blocking Edges & 4-Item Throughput Checkpoint**:
   - Every ticket states: `What to build` (user-observable behavior, zero brittle line numbers), `Acceptance criteria` (at confirmed seam), `Verification command`, and `Blocked by`.
   - Record Lauren Tan's **Throughput Checkpoint**: (1) Data shape named, (2) Parallelizable worktree frontier identified, (3) Deterministic script/lever opportunities noted (`principle-build-the-lever`), (4) Live surface check command specified.
4. **Quiz & Publish**: Show the numbered ticket list (`Title | Blocked by | What it delivers`), confirm granularity and edges with the user, and publish to GitHub Issues (`--parent`, `--blocked-by`, `ready-for-agent`), `.scratch/<feature>/issues/<NN>-<slug>.md`, or `tasks/todo.md`.

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"I'll create Ticket 1 for DB schema, Ticket 2 for Backend, Ticket 3 for UI."* | Horizontal layer slicing hides integration bugs until the final ticket. Slice vertically so Ticket 1 proves one complete end-to-end path. |

## Red Flags
- Any ticket touching >5 files or lacking an explicit `Blocked by` declaration and verification command.

## Verification
- [ ] Every ticket is a vertical tracer bullet (or explicit Expand-Contract batch) touching <=5 files.
- [ ] Blocking edges form an acyclic graph with a clear initial ready frontier (`Blocked by: None`).
- [ ] 4-item Throughput Checkpoint is recorded.
