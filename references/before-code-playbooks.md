---
name: before-code-playbooks
description: Seam 0 through Seam 4 pre-code playbooks including 4 Model Roles routing, CLAIM->EXTRACT->DOUBT->RECONCILE->STOP loop, Frontier Rounds, Spec lock, and Tracer-Bullet slicing.
version: 0.1.0
---

# L.A.M. Stack: Before-Code Playbooks (До кода)

This file governs all pre-code discovery, codebase investigation, requirement interrogation, specification, mechanical quality gating, interface architecture, and vertical-slice task breakdown.

---

## Playbook 1: Codebase Investigation (`how` + `why` + `teach` + `research`)
*Origin: Lauren Tan's `how`, `why`, `teach` + Matt Pocock's `research`*

**When to run**: Read-only questions (*"how does X work?"*, *"why was Y built this way?"*, *"are we sure about Z?"*), or before designing any non-trivial change or redefining ownership.

### Steps (Copy Verbatim into Checklist)
1. **Restate Goal (`in-your-own-words`)**: State the exact question and scope in one sentence. Record `throughput checkpoint: n/a, read-only investigation`.
2. **Map Mechanics (`how`)**:
   - For a single module, trace the call path directly.
   - For a complex subsystem, fan out 2-4 parallel `readonly` explorer subagents across distinct subsystem slices, then synthesize into five sections: `Overview`, `Key Concepts`, `How It Works` (with `file:line` pointers), `Where Things Live`, and `Gotchas`.
3. **Trace Rationale & History (`why`)**:
   - Build a code anchor inline (`git blame -L`, `git log --follow -p`, `gh pr view --json`, `docs/adr/`).
   - Fan out parallel investigators across available sources (git history, issues/tickets, ADRs/docs, observability/error logs).
   - Synthesize under strict epistemics into: `The Question`, `The Code in Question`, `What We Found` (measured facts), `What We Can Reasonably Infer`, `Competing Hypotheses`, `What We Don't Know`, and a `Preserve / Change / Avoid / Risk` constraint table.
4. **External Primary-Source Research (`research`, if needed)**:
   - When the question depends on external library/protocol specs, dispatch a fresh-context subagent to read primary official docs/source and write a cited summary file.
5. **Mental Model Synthesis (`teach`, if requested)**:
   - Weave `how` + `why` into a progressive plain-English explanation with Mermaid sequence or state diagrams.

---

## Playbook 2: Idea Refinement (`idea-refine`)
*Origin: Addy Osmani's `idea-refine` + Lauren Tan's `sharpen` & `principle-exhaust-the-design-space`*

**When to run**: Raw, open-ended product or architecture ideas where options should be expanded and stress-tested before converging on a spec.

### Steps (Copy Verbatim into Checklist)
1. **Sharpen the Problem (`sharpen` + `How Might We`)**: Restate the ask as a crisp *"How Might We"* problem statement and identify what a top domain expert would inspect first in the codebase.
2. **Divergent Exploration (5-8 Variations across 7 Lenses)**: Generate 5-8 concrete variations grounded in the repo using the 7 lenses: *Inversion*, *Constraint Removal*, *Audience Shift*, *Combination*, *Simplification*, *10x Version*, and *Expert Lens*.
3. **Converge & Stress-Test (2-3 Directions)**: Cluster into 2-3 distinct directions and evaluate against **User Value** (painkiller vs. vitamin), **Feasibility**, and **Differentiation**. Surface hidden assumptions (*what we are betting is true* and *what could kill it*).
4. **One-Pager Output**: Produce a concise decision brief containing: `Problem Statement`, `Recommended Direction`, `Key Assumptions to Validate`, `MVP Scope`, `Not Doing (and Why)`, and `Open Questions`.

---

## Playbook 3: L.A.M. Frontier Grilling & Domain Modeling (`/grill-with-docs` + `interview-me`)
*Origin: Matt Pocock's `grilling` + `domain-modeling` merged with Addy Osmani's `interview-me` confidence scoring & Lauren Tan's empirical prototype rule*

**When to run**: Whenever requirements, edge cases, or domain terms are underspecified before writing a spec or code.
*(Why this merge works: Addy's `interview-me` provides explicit hypothesis/confidence tracking and anti-buzzword probing, while Matt's `grilling` replaces slow 1-by-1 serial questioning with parallel **frontier rounds** where every question carries a recommended answer so the user can approve a whole round in one turn, while updating `GLOSSARY.md` inline.)*

### Steps (Copy Verbatim into Checklist)
1. **Initial Hypothesis & Confidence Score (`interview-me`)**:
   - State `HYPOTHESIS: <one-sentence statement of what the user actually wants and why now>`
   - State `CONFIDENCE: ~X% - missing: <key unresolved branches if <95%>`
2. **Separate Facts from Decisions (`grilling` + `pstack` Autonomy)**:
   - Never ask the user for a fact discoverable in the repo, environment, or docs - dispatch a fresh-context subagent to look it up immediately.
   - If a question is an empirical fork (layout, timing, state feel) that a quick sketch can settle, route that branch to **Playbook 4 (Prototype)** instead of guessing on paper.
3. **Ask the Unsettled Frontier in Numbered Rounds (`grilling`)**:
   - Map the remaining product/design decisions as a tree. The **frontier** is every decision whose prerequisites are settled.
   - Present the current frontier in one numbered round, wording each question so `"yes"` accepts your recommendation:
     ```markdown
     ❓ **Q1** - **<Question Title>**: <Focused question + concrete trade-off options>
     ➡️ **Recommended**: <Your recommended answer + 1-line rationale/guess>

     ❓ **Q2** - **<Question Title>**: <Focused question + concrete trade-off options>
     ➡️ **Recommended**: <Your recommended answer + 1-line rationale/guess>
     ```
   - **Want vs. Should Want Probe (`interview-me`)**: If the user answers with convention-signaling buzzwords (*"make it scalable/enterprise/clean"*), probe once: *"If you didn't have to justify this to anyone, what behavior would you actually want today?"*
4. **Inline Ubiquitous Language & ADR Capture (`domain-modeling`)**:
   - Cross-reference user statements against `GLOSSARY.md` and current code; immediately call out contradictions or overloaded words.
   - Update `GLOSSARY.md` inline as terms resolve (pure domain language, zero implementation details).
   - If a settled decision passes all 3 gates (*Hard to reverse + Surprising without context + Real trade-off*), record `docs/adr/NNNN-slug.md`.
5. **95% Confidence 6-Line Intent Lock (`interview-me` + `grilling` Exit Gate)**:
   - When the frontier is empty and confidence reaches >=95%, output the 6-line Statement of Intent:
     - `Outcome`: <1 sentence>
     - `User / Consumer`: <who benefits and what changes for them>
     - `Why now`: <trigger/constraint>
     - `Success criteria`: <measurable, testable outcomes>
     - `Constraints`: <technical/time/compatibility bounds>
     - `Out of scope`: <explicit non-goals>
   - Wait for explicit confirmation before starting implementation (unless operating under an explicit autonomous grant).

---

## Playbook 4: Throwaway Prototype (`prototype`)
*Origin: Lauren Tan's `playbooks/prototype.md` + Matt Pocock's `prototype` (`LOGIC.md` & `UI.md`)*

**When to run**: To settle an empirical fork, state-machine feel, or UI layout comparison by observing working code in an isolated scratch directory or `prototype/<name>` branch instead of debating in prose.

### Steps (Copy Verbatim into Checklist)
1. **Frame the Single Question**: Name the exact design or empirical question the prototype will answer.
2. **Invert the Laziness Protocol (`principle-exhaust-the-design-space`)**:
   - **For Logic / State Machines (`LOGIC.md`)**: Build a self-contained runnable artifact (e.g., single HTML file or CLI script) with a live state inspector panel, free-play action buttons, and guided scenario tabs.
   - **For UI / Interaction (`UI.md`)**: Build 2-3 radically distinct variants behind an on-screen switcher on a single route.
3. **Observe & Extract the Decision**: Run the prototype, capture screenshots or timings, fold the winning state/type shape into the spec or `architect` sketch, and leave `main` untouched.

---

## Playbook 5: Multi-Session Wayfinder (`/wayfinder`)
*Origin: Matt Pocock's `wayfinder` + Lauren Tan's `figure-it-out`*

**When to run**: Huge, foggy greenfield initiatives or cross-cutting rewrites too large to specify in a single session.

### Steps (Copy Verbatim into Checklist)
1. **Name the Destination**: Run `grilling` + `domain-modeling` to lock the 1-2 line `Destination` and initial `Out of scope` boundaries.
2. **Chart the `wayfinder:map`**: Create the map artifact (GitHub issue labelled `wayfinder:map` or `.scratch/<slug>/wayfinder-map.md`) with four sections: `## Destination`, `## Notes`, `## Decisions so far` (index of links + 1-line gists), `## Not yet specified` (fog of war), and `## Out of scope`.
3. **Create & Wire Decision Tickets**: Create child decision tickets for sharp questions only, tagged with `wayfinder:research` (AFK subagent), `wayfinder:prototype` (HITL), `wayfinder:grilling` (HITL), or `wayfinder:task` (unblocking setup), wired with blocking edges.
4. **Resolve Frontier One Ticket at a Time**: Claim and resolve one frontier decision ticket per session (firing `research` tickets in parallel background subagents), graduating newly cleared fog into tickets until the route to `/to-spec` is clear.

---

## Playbook 6: Mechanical Quality Bar (`CONSTRAINTS.md` / `/constraints`)
*Origin: Addy Osmani's `constraint-driven-development` + Lauren Tan's `principle-encode-lessons-in-structure` + Matt Pocock's `setup-ts-deep-modules`*

**When to run**: Setting up a repo's quality gates, or whenever no `CONSTRAINTS.md` exists.

### Steps (Copy Verbatim into Checklist)
1. **Detect Stack & Existing Runners**: Inspect `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, linter/type configs, test runners, and CI workflows.
2. **Establish the Non-Negotiable Floor (`CONSTRAINTS.md`)**:
   - Zero new lint/type/coverage/mutation suppressions (`@ts-ignore`, `@ts-expect-error`, `eslint-disable`, `# noqa`, `# type: ignore`, `istanbul ignore`, `nosemgrep`, `gitleaks:allow`).
   - Zero unimplemented stubs (`throw new Error("not implemented")`, `TODO` in new code) or empty `catch {}` blocks.
   - Zero skipped (`.skip`, `xit`, `@pytest.mark.skip`) or deleted tests without replacement.
   - Zero secrets in source or git history (`gitleaks dir . --redact --no-banner`).
   - Deep-module boundary enforcement where applicable (e.g., `dependency-cruiser` blocking deep subfolder imports past module entry points).
3. **Wire Three Stage Budgets**:
   - `check:fast` (<5s: scoped typecheck + lint on touched files, run during `/build`).
   - `check:task` (<90s: affected unit/integration tests + `scripts/floor-guard.sh`, run at slice completion).
   - `check:full` (full test suite, build, security/dependency audit, E2E/CWV budgets, run before PR/ship).
4. **Verify the Guard**: Confirm each gate fails on a deliberate violation and passes on a clean control.

---

## Playbook 7: Specification & Capability Mapping (`/to-spec` + `spec-driven-development`)
*Origin: Matt Pocock's `/to-spec` merged with Addy Osmani's `spec-driven-development` (`SPEC.md`)*

**When to run**: Turning a settled grilling session, cleared wayfinder map, or multi-module initiative into a durable specification before slicing tickets or writing code.

### Steps (Copy Verbatim into Checklist)
1. **Phase 0 - Capability Map (Multi-Module Initiatives Only)**: If the ask spans multiple independently testable modules, propose an acyclic Capability Map table (`Module ID | Responsibility | Depends On | Build Order`) and confirm before writing specs.
2. **Confirm High-Level Test Seams First (`mattpocock/to-spec`)**: Identify the highest public **seams** where the feature will be tested (preferring existing seams; ideal count is 1 per module), state in one line what each seam catches and misses, and confirm with the user.
3. **Author the Unified L.A.M. Spec (`SPEC.md` or Tracker Issue)**:
   - Use `GLOSSARY.md` domain nouns throughout and respect `docs/adr/`.
   - Include:
     1. `Problem Statement & Solution` (from the user's perspective, consumer + maintainer impact).
     2. `User Stories & Reframed Measurable Success Criteria` (`As an <actor>, I want <feature>, so that <benefit>` + quantitative targets where applicable).
     3. `Implementation Decisions & Module Interfaces` (modules modified, public interface contracts, schema changes, state machine/type snippets from any prototype - **omit volatile file paths and line numbers** so the spec stays durable).
     4. `Testing Decisions & Confirmed Seams` (exact public seams, behavioral test expectations, prior art in repo, plus executable repo commands for build/test/lint).
     5. `Three-Tier Boundaries` (**Always do** / **Ask first** / **Never do**).
     6. `Out of Scope & Open Questions`.

---

## Playbook 8: Interface Architecture & Design-It-Twice (`architect` + `codebase-design` + `arena`)
*Origin: Lauren Tan's `architect` & `arena` merged with Matt Pocock's `codebase-design` (`DESIGN-IT-TWICE.md`) & Addy Osmani's `api-and-interface-design`*

**When to run**: Whenever code crosses a function/module boundary, introduces a new public interface or API endpoint, or reshapes stateful domain logic.

### Steps (Copy Verbatim into Checklist)
1. **Phase A - Ground**: Run `how` over touched subsystems (and `why` if changing ownership). Read `GLOSSARY.md` and `docs/adr/`.
2. **Phase B - Sketch (Design It Twice via `arena`)**:
   - Spawn 2-3 parallel fresh-context candidate subagents to sketch radically different interface shapes for the module.
   - **Write Caller Usage First**: Each sketch must start with how callers and tests invoke the interface at the seam, followed by types, discriminated unions, error shapes (`{ error: { code, message, details? } }`), and module boundaries with `not implemented` bodies.
   - **Judge & Graft**: Score sketches on **Depth** (maximum hidden complexity behind the smallest interface), **Locality**, **Reader Load (<30s trace)**, **Boundary Discipline**, and **Hyrum's Law / Idempotency**. Pick the strongest base and graft the best ideas from the runner-up.
3. **Phase C - Agree**: Present the winning interface contract (pausing for human sign-off if invoked with checkpoint, or proceeding under autonomous grant).
4. **Phase D - Implement against Contract**: Treat the sketch as a hard contract; surface any unanticipated parameter or seam leak immediately.
5. **Phase E - Scrap Trigger**: If implementation hits repeated friction (the same workaround recurring across files, types needing `any`/casts to compile, callers needing to know internal ordering rules, or >=2 independent deviations from the sketch), **scrap the sketch** and return to Phase B rather than forcing it through.

---

## Playbook 9: Tracer-Bullet Vertical Slicing (`/to-tickets` + `planning-and-task-breakdown`)
*Origin: Matt Pocock's `/to-tickets` merged with Addy Osmani's `planning-and-task-breakdown` & Lauren Tan's `Feature` Throughput Checkpoint*

**When to run**: Breaking a confirmed Spec or multi-step change into an ordered dependency graph of self-contained, verifiable units.

### Steps (Copy Verbatim into Checklist)
1. **Pre-Flight Check**: Check for any existing incomplete `tasks/todo.md` or `.scratch/<feature>/issues/` files before writing. Look for **prefactoring** opportunities (*"Make the change easy, then make the easy change"* / `principle-subtract-before-you-add`).
2. **Slice into Tracer-Bullet Vertical Tickets (or Expand-Contract Batches)**:
   - **Standard Features (Vertical Tracer Bullets)**: Each ticket cuts a narrow, end-to-end verifiable path through all layers (schema + domain logic + API + UI + seam test), sized to fit in a single fresh context window (**XS**: 1 file, **S**: 1-2 files, **M**: 3-5 files; never >5 files).
   - **Wide Mechanical Refactors (Expand-Contract Exception)**: When a change breaks many call sites across the repo, sequence as:
     1. *Ticket 1 - Expand*: Add new interface/column alongside old (dual-write if DB) while keeping CI green.
     2. *Tickets 2..N - Migrate Batches*: Migrate callers in blast-radius-sized batches, each blocked by Expand.
     3. *Final Ticket - Contract*: Delete the legacy API/column once zero callers remain (`principle-migrate-callers-then-delete-legacy-apis`), blocked by all Migrate tickets.
3. **Wire Explicit Blocking Edges & Throughput Checkpoint**:
   - Every ticket declares: `What to build` (user-observable behavior, no brittle file-line dumps), `Confirmed Seam & Acceptance Criteria`, `Verification Command`, and `Blocked by` (native tracker edges or ticket numbers).
   - Record the 4-item **Throughput Checkpoint (`pstack`)**: (1) Data shape named, (2) Independent slices identified for parallel worktree execution, (3)Deterministic lever/script opportunities noted (`principle-build-the-lever`), (4) Exact live surface verification command chosen.
4. **Quiz & Publish**: Present the numbered ticket graph (`Title | Blocked by | What it delivers`) for quick confirmation, then publish to the configured tracker (GitHub Issues with `--parent` and `--blocked-by`, `.scratch/<feature>/issues/<NN>-<slug>.md`, or `tasks/todo.md`).

---

## Playbook 10: The 4 Model Roles Routing Table & Pre-Code Doubt Loop (`pstack` + `doubt-driven-development`)

### 10.1 The 4 Model Roles Routing Table (`worker`, `builder`, `judge`, `peer`)

| Model Role | Cognitive Posture | Permitted Operations | Forbidden Operations | Primary Seams |
| :--- | :--- | :--- | :--- | :--- |
| **`worker`** | Fast, deterministic mechanical execution and reconnaissance. | Running `how`/`why` indexing, `validate-lam.py`, `floor-guard.sh`, `seam-gate.sh`, and `log-decision.sh`. | Inventing domain abstractions or relaxing `CONSTRAINTS.md` rules. | Seam 0, Seam 2 |
| **`builder`** | Deep-module synthesis, $M = R$ type modeling, and Tracer-Bullet slice authoring. | Authoring `GLOSSARY.md`, `SPEC.md`, boundary parsers, and vertical code slices passing `check:task`. | Self-approving Seam 6 reviews or bypassing `floor-guard.sh`. | Seam 1, 3, 4, 5 |
| **`judge`** | Cold Spec-Doubt verification with zero attachment to the builder's chain-of-thought. | Executing `CLAIM -> EXTRACT -> DOUBT -> RECONCILE -> STOP`, Cold Spec-Doubt, and 5-Layer Retro checks. | Quietly patching broken code without logging a finding first. | Seam 3, 6, 7 |
| **`peer`** | Parallel alternative explorer in an isolated git worktree (`arena` or `interrogate`). | Competing in `/arena` worktrees (`seam-gate.sh worktree arena <slug>`) and probing edge cases in `/interrogate`. | Mutating the primary branch directly without winning selection. | Seam 3, 5, 6 |

### 10.2 Pre-Code `CLAIM -> EXTRACT -> DOUBT -> RECONCILE -> STOP` Loop

Before locking `SPEC.md` at Seam 3 or writing production code at Seam 5, execute all 5 steps:
1. **`CLAIM`**: State the exact behavioral invariant, interface contract, or state transition as a falsifiable engineering claim.
2. **`EXTRACT`**: Pull the concrete existing types, callers, and file paths from the live repository anchor (`Seam 0`).
3. **`DOUBT`**: Switch to the cold `judge` posture and attack the claim across `Empty`, `Boundary`, `Error`, and `Concurrency` inputs or any $|M| > |R|$ state gap.
4. **`RECONCILE`**: Reshape the schema using the Polyglot $M = R$ Data-Shape Matrix in `references/principles-and-vocabulary.md` so the doubted failure state becomes unrepresentable.
5. **`STOP`**: Commit the contract to `SPEC.md`, log the commitment in `decisions.tsv` via `bash scripts/log-decision.sh`, and verify `bash scripts/seam-gate.sh check 4` before starting Seam 5.

