---
name: glossary
description: Canonical Ubiquitous Language and forbidden synonym ledger for lam-stack v0.2.1.
version: 0.2.1
---

# GLOSSARY: L.A.M. Ubiquitous Language (v0.2.1)

This glossary locks the canonical domain nouns for `lam-stack` v0.2.1. Every skill, agent, reference, hook, and command MUST use these exact terms and reject the forbidden synonyms listed under `_Avoid:_`.

## 1. Core Domain Nouns

### `Seam`
A verifiable architectural boundary between two stages of the SDLC or two modules where contracts, types, and behavioral invariants are enforced before execution crosses the boundary.
- _Avoid:_ `Phase Bucket`, `Step Folder`, `Loose Stage`, `Handoff Zone`, `Milestone Wrapper`.

### `Deep Module`
A software component (following Ousterhout's principle) that exposes a narrow, minimal, strongly-typed public interface (`M = R`) while encapsulating substantial internal implementation complexity behind that boundary.
- _Avoid:_ `Thin Wrapper`, `Pass-Through Service`, `Manager Class`, `Helper Utility`, `Shallow Adapter`.

### `Frontier Round`
A structured pre-code ambiguity-Burn iteration that resolves one orthogonal axis of uncertainty (Domain Scope, Data Shape, Failure Modes, or Operational Constraints) before locking `SPEC.md`.
- _Avoid:_ `Brainstorm Chat`, `Discovery Call`, `Vibe Check`, `Open-Ended Ideation`, `Freeform Q&A`.

### `Tracer Bullet`
A narrow, end-to-end vertical implementation slice that connects every architectural layer (boundary parser, domain logic, persistence/state, and seam test) and passes `check:task` immediately.
- _Avoid:_ `Horizontal Layer Batch`, `Mocked Skeleton`, `Big-Bang PR`, `Stubbed Prototype`, `UI-Only Shell`.

### `Floor Guard`
The deterministic mechanical script (`scripts/floor-guard.sh`) and pre-commit hook gate that scans source files and blocks suppressions, skipped/focused tests, unimplemented stubs, silent catches, debug artifacts, and leaked credentials.
- _Avoid:_ `Soft Linter`, `Advisory Style Check`, `Optional Formatting Pass`, `Best-Effort Scanner`.

### `Cold Spec-Doubt`
An adversarial verification pass executed by an independent `judge` model context (with zero access to the builder's chain-of-thought rationalizations) that audits implementation diffs strictly against `SPEC.md` and `CONSTRAINTS.md`.
- _Avoid:_ `Self-Approval`, `Rubber-Stamp Review`, `Warm Author Check`, `LGTM Scan`.

### `Interrogate Worktree`
An isolated git worktree (`scripts/seam-gate.sh worktree interrogate <slug>`) spun up to stress-test, mutate, or adversarially probe a candidate branch without polluting the primary working tree, then pruned cleanly on exit.
- _Avoid:_ `In-Place Dirty Branch`, `Stash Juggling`, `Main-Tree Sandbox`, `Unpruned Temp Folder`.

### `Decision Trail`
The append-only, formula-sanitized tabular ledger (`decisions.tsv`) written via `scripts/log-decision.sh` that records the timestamp, seam, slice, role, status, and rationale for every architectural commitment.
- _Avoid:_ `Ephemeral Chat Memory`, `Unstructured Notes`, `Ad-Hoc Commit Prose`, `Lost Context`.

## 2. Harmonized Cross-Library Attribution

To eliminate rule collisions across upstream inspirations:
- **Lauren Tan (`pstack`)**: Governs the 4 Model Roles (`worker`, `builder`, `judge`, `peer`), worktree isolation (`arena`, `swarm`, `interrogate`, `spec`), and the `decisions.tsv` Decision Trail.
- **Matt Pocock (`skills`)**: Governs $M = R$ type-driven boundary parsing, Deep Modules, Tracer-Bullet vertical slicing, and Seam-TDD.
- **Addy Osmani (`agent-skills`)**: Governs the Pre-Code `CLAIM -> EXTRACT -> DOUBT -> RECONCILE -> STOP` loop (`doubt-driven-development`), the 80/15/5 Test Pyramid, and the 5-Layer Retro Hardening gate.
