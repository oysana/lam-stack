# L.A.M. Stack: Principles, Deep-Module Vocabulary & Domain Modeling

This reference combines 1-to-1:
1. **Lauren Tan's 24 Engineering Principles (`pstack`)** - with exact triggers and rules.
2. **Matt Pocock's Deep-Module Vocabulary (`codebase-design`) & Domain Modeling (`GLOSSARY.md` + 3-Gate `ADR-FORMAT.md`)**.
3. **Addy Osmani's Foundational Laws (`agent-skills`)** - Hyrum's Law, Beyoncé Rule, 80/15/5 Test Pyramid, DAMP over DRY, Chesterton's Fence, and Definition of Done.

---

## Part 1: Lauren Tan's 24 Engineering Principles (`pstack` 1-to-1)

Cite each principle that shaped a decision in your reply and state the specific choice it changed.

### 1.1 Core Principles (10)

1. **`principle-laziness-protocol` (Laziness Protocol)**
   - **When it applies**: Refactoring, sizing a diff, or tempted to add abstractions, layers, or signal threading.
   - **Rule**: Consolidate decisions behind one source of truth and pass the result as a simple flag. Minimize the diff: make the smallest change that solves the problem. Fewer lines beat "elegant" boilerplate.
2. **`principle-foundational-thinking` (Foundational Thinking)**
   - **When it applies**: Before writing logic - settling core types, data structures, scaffold-vs-feature sequencing, and shared state.
   - **Rule**: Structural decisions protect option value; code-level decisions protect simplicity. Get the data shape right before writing logic. Define core types early, trace every access pattern, and choose structures that match dominant paths. At code level, DRY the structure, not every line (three similar statements still beat a premature abstraction). Before sharing state between concurrent actors, ask *"what happens if another actor modifies this concurrently?"* If not *"nothing"*, isolate. Sequence: **Subtraction -> Scaffolding -> Features**.
3. **`principle-redesign-from-first-principles` (Redesign from First Principles)**
   - **When it applies**: Integrating a new requirement into an existing design.
   - **Rule**: Do not bolt a new requirement onto an existing design with special-case flags. Read all affected files and ask: *"If we were writing this from scratch with this new requirement as a day-one foundational assumption, what would we build?"* Propagate the change through types, docs, examples, and tests, then deliver incrementally.
4. **`principle-attack-the-premise` (Attack the Premise)**
   - **When it applies**: Two or more fixes that share one premise have failed the same gate.
   - **Rule**: Suspect the premise, not the fixes. (1) Write down the one-sentence premise that every failed fix assumed. (2) Test the premise directly with a rerunnable observation before writing a third fix. (3) Follow the evidence: if contradicted, the root cause is elsewhere; if confirmed, ask the next "why". (4) Remove the underlying condition rather than compensating for it.
5. **`principle-subtract-before-you-add` (Subtract Before You Add)**
   - **When it applies**: Sequencing an addition, refactor, or rewrite.
   - **Rule**: Remove dead weight, unused parameters, redundant validators, and stub references first, then build on the simpler base. Design for observed usage, not speculative edge cases. Leave the design slightly simpler behind the same or smaller surface than you found it.
6. **`principle-minimize-reader-load` (Minimize Reader Load)**
   - **When it applies**: Reviewing or shaping code that is hard to trace.
   - **Rule**: Track two axes: **layers to trace** (indirections between question and answer) and **state to hold** (hidden or mutable context the reader must keep in mind). Collapse wrappers with one caller and adapters with no second implementation. Prefer pure functions (returns over mutations), locals over fields, fields over module state, and module state over globals. Derive instead of sync. **The 30-Second Test**: Can a new reader answer *"where does X come from?"* and *"what can change X?"* in under 30 seconds? If not, cut layers or cut state.
7. **`principle-outcome-oriented-execution` (Outcome-Oriented Execution)**
   - **When it applies**: Planned rewrites and migrations with explicit phase boundaries.
   - **Rule**: Optimize for the intended, verifiable end state rather than preserving throwaway compatibility shims for intermediate states. Declare where temporary breakage is acceptable across planned phases, keep high-signal checks on touched areas, and require full static and runtime verification at completion.
8. **`principle-experience-first` (Experience First)**
   - **When it applies**: Product, UX, API ergonomics, or feature-scope trade-offs.
   - **Rule**: When implementation convenience conflicts with user delight, choose delight. Ship fewer, deeply polished features over more rough ones. Prototype in throwaway HTML/CLI before committing. Remember the three consumers: the **end user** (for UI), the **importing colleague** (for an API/module), and the **next maintaining engineer**.
9. **`principle-exhaust-the-design-space` (Exhaust the Design Space)**
   - **When it applies**: Facing a novel UI interaction or architectural decision with no precedent in the codebase.
   - **Rule**: Build 2-3 competing prototypes or interface sketches and compare them side-by-side before committing.
10. **`principle-build-the-lever` (Build the Lever)**
    - **When it applies**: Any non-trivial sweep, migration, analysis, or verification check.
    - **Rule**: Do the first unit by hand to learn the recipe, then build a deterministic tool (codemod, generator, SQLite query, verification script, or delegate skill) and prove it by diffing its output on unit 1 against your hand-done version. A deterministic script beats fanning out subagents to hand-edit files. Citing this principle requires committing or producing the script/tool artifact.

### 1.2 Architecture Principles (6)

11. **`principle-model-the-domain` (Model the Domain)**
    - **When it applies**: Writing stateful logic, branching heavily, or repeating a shape assumption across files.
    - **Rule**: Encode domain rules in a data structure instead of scattered conditionals:
      - A **state machine** instead of scattered booleans or phase flags.
      - A **typed model / discriminated union (`kind`)** instead of loose parameters.
      - A **map, registry, or lookup table** instead of repeated `switch`/`if-else` cascades across files.
      - A **reducer or command/event model** instead of ad-hoc mutations.
      - A module organized around **one body of domain knowledge** rather than execution order (`load -> validate -> transform -> save`).
12. **`principle-boundary-discipline` (Boundary Discipline)**
    - **When it applies**: Wiring validation, schema parsing, error handling, or framework adapters.
    - **Rule**: Place validation, type narrowing, and defensive error handling strictly at system boundaries (HTTP inputs, CLI args, config files, env vars, untrusted external APIs, LLM outputs). Inside the system, trust internal types unconditionally without redundant defensive re-validation, and keep core business logic in pure functions.
13. **`principle-type-system-discipline` (Type System Discipline)**
    - **When it applies**: Designing types or function signatures in any typed language.
    - **Rule**: Make illegal states unrepresentable. Brand semantic primitives (`UserId` vs. `OrderId`) via type guards or constructors so they cannot be swapped accidentally. Parse external data once at creation (`unknown` -> validated schema -> branded/narrowed type). Derive types from authoritative schemas (OpenAPI, Protobuf, DB migrations) rather than hand-rolling parallel types. Use exhaustive switches (`_exhaustive: never`).
14. **`principle-make-operations-idempotent` (Make Operations Idempotent)**
    - **When it applies**: State-mutating endpoints, migrations, CLI scripts, background jobs, and retry loops.
    - **Rule**: Every state-mutating operation must answer: *"What happens if this runs twice? What happens if the previous run crashed halfway?"* Derive each step by diffing current state against target state. Make locks, temp files, and claimed jobs recognizable as stale on restart. For HTTP mutations, claim idempotency keys atomically via a single DB `INSERT` with a unique constraint and reject payload mismatches with `422 IDEMPOTENCY_KEY_REUSED`.
15. **`principle-migrate-callers-then-delete-legacy-apis` (Migrate Callers Then Delete Legacy APIs)**
    - **When it applies**: Introducing a new internal API while old internal callers still exist.
    - **Rule**: When no external consumers require backward compatibility, migrate all internal callers and delete the legacy API in the same wave (or final expand-contract ticket) instead of leaving parallel compatibility layers behind.
16. **`principle-separate-before-serializing-shared-state` (Separate Before Serializing Shared State)**
    - **When it applies**: Concurrent actors (threads, background jobs, or parallel subagents) touching files, branches, keys, or objects.
    - **Rule**: Eliminate sharing first by giving each actor its own isolated git worktree, directory, key prefix, or state file, merging only at the read/reporting boundary. Treat *"we need a lock"* as a design smell; use structural serialization (lockfiles, unique DB constraints, sequential phases) only when a single writer is a true domain invariant.

### 1.3 Verification Principles (5)

17. **`principle-prove-it-works` (Prove It Works)**
    - **When it applies**: After every task, before declaring done.
    - **Rule**: Verify against the real artifact directly - run the feature, read the persisted DB/file state, inspect live DOM/console via DevTools MCP, or run the CLI inside a PTY. Never infer correctness from proxies, mocks, self-reports, or *"it compiles."* Script the check whenever possible.
18. **`principle-fix-root-causes` (Fix Root Causes)**
    - **When it applies**: Debugging any failure or unexpected state.
    - **Rule**: Reproduce first. Trace the symptom back to the first place the system made a wrong decision. Ask whether the state that triggered the crash is legitimate: if legitimate, handle it there; if the state should never exist, adding a null guard where it crashed hides the bug - find and fix what produced the corrupt state. If a workaround requires a paragraph-long comment to justify, the code is wrong.
19. **`principle-sequence-verifiable-units` (Sequence Work into Verifiable Units)**
    - **When it applies**: Multi-step work, sweeps, migrations, and stacked commits/PRs.
    - **Rule**: Break work into small units (~100 lines / XS-M slices) that each end in a deterministic check. Verify each unit from a known-good baseline before starting the next. Order commits so the sequence proves itself (e.g., failing reproduction test first, minimal fix second, refactor third).
20. **`principle-test-behavior-not-implementation` (Test Behavior, Not Implementation)**
    - **When it applies**: Writing, modifying, or reviewing any test.
    - **Rule**: Assert only what callers or users observe through public **seams**. Judge every test against two imagined edits:
      1. *Break the behavior* (return wrong value, skip effect, double effect): if the test still passes, it is tautological or weak.
      2. *Change the internals* (restructure private helpers while keeping observable output identical): if the test fails, it is implementation-coupled and must be rewritten at the public seam.
21. **`principle-explain-the-number` (Explain the Number)**
    - **When it applies**: Before measuring, trusting, reporting, or acting on any performance, latency, throughput, bundle size, or eval metric.
    - **Rule**: Name the quantity, units, input scope, exclusions, run count, spread/variance, and the measured physical or resource limiter (*"why isn't it twice as fast?"*). Never fabricate metrics or report unmeasured static guesses as numbers.

### 1.4 Delegation & Meta Principles (3)

22. **`principle-guard-the-context-window` (Guard the Context Window)**
    - **When it applies**: Large outputs, long files, multi-file exploration, transcript mining, or trace parsing.
    - **Rule**: Keep focused source files in the main thread under 2,000 lines. Delegate bulk reading, log/trace SQLite queries, and parallel explorations to fresh-context subagents, passing file pointers rather than pasted blobs and returning compact structured summaries.
23. **`principle-never-block-on-the-human` (Never Block on the Human)**
    - **When it applies**: Reversible engineering steps during execution.
    - **Rule**: Never ask *"Should I do X?"* on reversible work. Execute the reversible step, verify it, present the result, and let the human course-correct if needed. Reserve blocking questions strictly for genuine product ambiguity (before code) or irreversible operations.
24. **`principle-encode-lessons-in-structure` (Encode Lessons in Structure)**
    - **When it applies**: Writing the same instruction, review comment, or correction a second time.
    - **Rule**: The second time a mistake or rule recurs, encode it as a custom lint rule (whose error message names the replacement), a type constraint, a `CONSTRAINTS.md` check, a pre-commit hook, or a test - never just another paragraph of prose in `AGENTS.md`.

---

## Part 2: Matt Pocock's Deep-Module Vocabulary (`codebase-design`)

Use these exact terms whenever designing or reviewing module boundaries:

- **Module**: Anything with an interface and an implementation (a function, class, package, or vertical slice). *Avoid: unit, component, service.*
- **Interface**: Everything a caller must know to use the module correctly - type signature, invariants, ordering constraints, error modes, required config, and performance characteristics. *Avoid: API, signature.*
- **Implementation**: The body of code hidden inside a module.
- **Depth**: Leverage at the interface - the amount of behavior a caller or test exercises per unit of interface they must learn.
  - **Deep Module**: Small interface + rich hidden implementation (Target).
  - **Shallow Module**: Large/complex interface + thin pass-through implementation (Avoid).
- **Seam** (Michael Feathers): The public location where a module's interface lives and where behavior can be altered or tested without editing inside the module. *Avoid: boundary (reserved for system edges / DDD bounded contexts).*
- **Adapter**: A concrete implementation that satisfies an interface at a seam (e.g., `PostgresOrderRepo` vs. `InMemoryOrderRepo`).
- **Leverage**: What callers gain from depth (more capability per unit of interface learned).
- **Locality**: What maintainers gain from depth (changes, bugs, and verification concentrate in one module rather than scattering across callers).

### Core Deep-Module Tests (`DEEPENING.md` & `DESIGN-IT-TWICE.md`)

1. **The Deletion Test**: Imagine deleting the module. If complexity vanishes, the module was shallow pass-through ceremony - inline and delete it. If complexity reappears across N callers, the module is earning its keep.
2. **The Interface is the Test Surface**: Callers and tests must cross the exact same public seam. If you feel forced to reach past the interface to test private helpers, the module's seam is in the wrong place.
3. **One Adapter = Hypothetical Seam; Two Adapters = Real Seam**: Do not extract an interface/adapter seam unless two concrete implementations exist (e.g., production adapter + fast local fake) or the dependency is a true external boundary.
4. **Four Dependency Categories (`DEEPENING.md`)**:
   - **In-process pure/domain code**: Never mock; test directly through the deepened module's seam.
   - **Local-substitutable infrastructure** (DB, filesystem, queue with in-memory or testcontainer equivalent): Prefer real local instance or high-fidelity in-memory fake at the adapter seam.
   - **Remote but owned services**: Test via contract schemas at the seam.
   - **True external third-party APIs** (Stripe, OAuth, external LLMs): Place a thin adapter at the system boundary and substitute a deterministic fake/stub at that seam.

---

## Part 3: Ubiquitous Language (`GLOSSARY.md`) & 3-Gate ADRs (`domain-modeling`)

### 3.1 `GLOSSARY.md` Rules
- **Single-Context Default**: Maintain `/GLOSSARY.md` and `/docs/adr/` at the repo root (or `/GLOSSARY-MAP.md` pointing to `src/<context>/GLOSSARY.md` in multi-context monorepos).
- **Zero Implementation Details**: `GLOSSARY.md` holds pure domain concepts, relationships, and disambiguated synonyms - never file paths, database column types, or framework names.
- **Inline Updates**: Create lazily and update `GLOSSARY.md` the moment a fuzzy or overloaded term (e.g., `"account"` meaning both `Customer` and `Workspace`) is resolved during conversation.

```markdown
# <Project Name>

<1-2 sentence overview of the domain.>

## Language

**<Term>**: <Clear domain definition.>
_Avoid: <synonym 1>, <synonym 2>_

## Relationships

- A <Term A> holds many <Term B>s
- A <Term B> carries one <Term C> at a time

## Flagged ambiguities

- "<overloaded term>" was previously used to mean both X and Y. Resolved: ...
```

### 3.2 The Three-Gate ADR Filter (`docs/adr/NNNN-slug.md`)
Offer and write an Architectural Decision Record (`docs/adr/0001-slug.md`, matching any existing repo numbering convention per Addy Osmani's `documentation-and-adrs`) **only when all three gates hold simultaneously**:
1. **Hard to reverse**: Changing your mind later carries meaningful migration cost.
2. **Surprising without context**: A future engineer or agent reading the code will wonder *"why on earth did they do it this way?"*
3. **Result of a real trade-off**: Genuine alternatives were evaluated and one was chosen for specific reasons.

**L.A.M. ADR Template** (combining Matt Pocock's ultra-lean clarity with Addy Osmani's lifecycle traceability):
```markdown
# NNNN: <Short Declarative Title of Decision>

- **Status**:ACCEPTED (or PROPOSED / SUPERSEDED BY NNNN)
- **Date**: YYYY-MM-DD

## Context & Trade-off
<1-3 sentences explaining the problem, why the choice is non-obvious, and what constraints forced the decision.>

## Decision
<1-2 sentences stating the exact decision in `GLOSSARY.md` domain language.>

## Rejected Alternatives
- **<Alternative A>**: <1 sentence on why it was rejected.>
- **<Alternative B>**: <1 sentence on why it was rejected.>

## Consequences
<1-2 sentences on what becomes easier, what becomes harder, and how this is enforced.>
```

---

## Part 4: Addy Osmani's Standing Engineering Bar (`definition-of-done.md`)

Every change across the L.A.M. Stack must satisfy both the task-specific **Acceptance Criteria** and the standing 5-gate **Definition of Done**:
1. **Correctness**: Matches spec/intent, handles empty/boundary/error/concurrent inputs, and breaks no existing callers.
2. **Quality**: Respects `CONSTRAINTS.md` Floor, ~100-300 line atomic diff sizing, DAMP behavioral tests at public seams, and zero new lint/type/console warnings.
3. **Integration**: Builds cleanly, migrations follow zero-downtime `Expand -> Migrate -> Contract`, and observability signals (`requestId`, structured logs, bounded metrics) are wired where applicable.
4. **Documentation**: `GLOSSARY.md`, `SPEC.md`, public JSDoc/OpenAPI contracts, and `docs/adr/` reflect any changed domain terms, interfaces, or hard-to-reverse decisions.
5. **Ship-Readiness**: Blast radius and door type (One-Way vs. Two-Way Door) are stated, feature flags or rollback paths are verified, and independent review gates have passed.
