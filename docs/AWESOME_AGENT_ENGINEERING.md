# Awesome Agent Engineering — canonical CS → LAM mapping

Every LAM mechanism descends from a named result in software engineering.
This file maps each root idea to the upstream source, the LAM surface that
implements it, and the concrete trap it closes.

## Lamport — state machines and the truth about state

- **Root:** Lamport, *Time, Clocks, and the Ordering of Events* (1978) —
  a distributed system is a state machine; correctness = every replica
  transitions through the same states.
- **LAM surface:** `SPEC.md` §1 — the 7-Seam Artifact State Machine. Work is
  a state; a transition exists only through `seam-gate.sh check <N>`.
- **Trap closed:** agent "state" drifting from repo state. M = R requires a
  machine-checkable artifact per claim, the same way Lamport requires the
  log — not the memory — to define truth.

## Ousterhout — deep modules

- **Root:** Ousterhout, *A Philosophy of Software Design* — a module is deep
  when its interface is much smaller than its implementation. Shallow modules
  leak complexity.
- **LAM surface:** 13 `lam-*` skills, ~600 lines of interface over 944 lines
  of procedure in `references/` + gated scripts. Two-load law: only the router
  preloads; bodies load at the seam.
- **Trap closed:** all-or-nothing packs that preload every procedure as
  metadata (~9k tokens) — shallow interfaces, deep context cost.

## Parnas — information hiding

- **Root:** Parnas, *On the Criteria for Decomposing Systems into Modules*
  (1972) — hide the decision most likely to change behind the interface.
- **LAM surface:** seam contracts (`SPEC.md` §2). What a seam *produces* is
  public; *how* the skill produces it is the hidden decision — skills can be
  rewritten without touching the gate contract.
- **Trap closed:** skills coupled to each other's internals — the zero-
  conflict merge problem LAM solves by routing through seams, not imports.

## King — parse, don't validate

- **Root:** Alexis King, *Parse, Don't Validate* (2019) — accept data at the
  boundary into a type that makes bad states unrepresentable, don't check a
  blob and proceed anyway.
- **LAM surface:** `scripts/validate-lam.py` parses every manifest into a
  checked structure (version format, `./` path normalization, command-dir
  expansion) — the pack cannot be *interpreted* incorrectly downstream.
- **Trap closed:** "the manifest looked fine" — official `claude plugin
  validate` accepted 0 errors post-fix; prior state was 21 silent failures.

## Beck — tidyings first

- **Root:** Kent Beck, *Tidy First?* — separate behavior changes from
  structure changes; never mix them in one step.
- **LAM surface:** floor-guard rules scan *added lines* of the diff only —
  a refactor diff and a behavior diff are distinguishable artifacts, and the
  decision log (`log-decision.sh`) is append-only so the two never blur.
- **Trap closed:** "while I was in there" scope creep — the duel grader
  penalizes out-of-`allowed_paths` writes mechanically.

## Leveson — guard at the boundary, not the blame

- **Root:** Nancy Leveson, *Engineering a Safer World* — safety is a control
  problem: put constraints in the system, not in the operator's attention.
- **LAM surface:** `hooks/pre-commit-guard.sh` — a commit that violates the
  floor exits non-zero before it exists, not a review comment after.
- **Trap closed:** relying on the agent to *remember* constraints. Attention
  is not a safety mechanism; a non-zero exit code is.

## Knuth — trust, but measure

- **Root:** the measurement culture — "premature optimization is the root
  of all evil" is a *measurement* claim, not a vibe.
- **LAM surface:** `evals/` — startup-surface byte counts, blinded 4-arm duel
  with frozen `eval.json`, raw grader JSON kept per run.
- **Trap closed:** marketing arithmetic. Every number in README.md carries
  its method file; the duel publishes losses on equal terms with wins.
