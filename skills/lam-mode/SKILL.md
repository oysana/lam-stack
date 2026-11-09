---
name: lam-mode
description: Master L.A.M. v0.1.0 coordinator (built on Lauren Tan's poteto-mode + Matt Pocock's invocation + Addy Osmani's using-agent-skills). Routes tasks across the 7-Seam Artifact State Machine, injects verbatim playbook steps, and enforces the 24 principles.
disable-model-invocation: true
---

# L.A.M. Stack v0.1.0 (Lauren Tan + Addy Osmani + Matt Pocock)

Self-bootstrapped v0.1.0 engineering workflow designed by applying L.A.M.'s own principles (`principle-attack-the-premise`, `principle-redesign-from-first-principles`, `codebase-design` Deep Modules, `writing-for-agents` Two-Load Hierarchy, and `doubt-driven-development`) to merge all three libraries without context bloat or rule collisions.

## Why L.A.M. v0.1.0 Replaces Naive 1-to-1 Patching (The What & How Upgrade)

1. **The 7-Seam Artifact State Machine (`principle-model-the-domain` + `codebase-design`)**:
   Instead of loose "Before / During / After" buckets, every workflow is a **Deep Module** whose public interface is a concrete repo artifact (**Seam**). No phase starts until its input seam is verified via `bash scripts/seam-gate.sh check <0..7>`:
   - **Seam 0 (Code Anchor)**: `lam-investigate` -> verified `file:line` mechanics and git/ADR history.
   - **Seam 1 (Intent & Glossary)**: `lam-grill` (`grilling` + `interview-me` + `domain-modeling`) -> 6-line Intent Lock + pure domain `GLOSSARY.md` + 3-gate ADR.
   - **Seam 2 (Quality Floor)**: `lam-constraints` (`/constraints` + `setup-ts-deep-modules`) -> `CONSTRAINTS.md` + `scripts/floor-guard.sh` + `check:fast`/`check:task`/`check:full`.
   - **Seam 3 (Spec & Interface Sketch)**: `lam-spec` + `lam-architect` (`/to-spec` + `SPEC.md` + `architect` via `arena` Design-It-Twice) -> confirmed public test seams + caller-first interface sketch + 3-tier boundaries.
   - **Seam 4 (Tracer-Bullet Ticket Graph)**: `lam-tickets` (`/to-tickets` + `wayfinder` + `triage`) -> vertical tracer-bullet tickets (or `Expand -> Migrate -> Contract` batches) with explicit `Blocked by` edges and 4-item Throughput Checkpoint.
   - **Seam 5 (SDD + Seam-TDD Slice)**: `lam-build` / `lam-debug` / `lam-perf` -> `SDD` (`// Source:` cited) + `Seam-TDD` (`RED -> GREEN`) + atomic ~100-line commits + `decisions.tsv` audit trail.
   - **Seam 6 (Hygiene, Dual-Axis Doubt & Worktree Interrogate)**: `lam-review` -> `deslop` + `comment-sicko` (7-item keep list) + `floor-guard.sh` + parallel `Spec-Doubt` (stripped of `CLAIM`) & `Standards-Arch` (5 axes + 12 Fowler smells) + executable worktree `interrogate` + real-surface verification.
   - **Seam 7 (Shipped PR & 5-Layer Retro Hardening)**: `lam-ship` + `lam-retro` -> visual `pr` (Door + Blast Radius) + `/ship` canary/SLO gates + `/retro` + `correct` (5-layer mistake hardening).

2. **Two-Load Progressive Disclosure (`writing-for-agents` + `SKILL.md`)**:
   - **Context Load Protection**: Keep permanent context under 120 lines. Load **only** the single leaf playbook or reference file required for the current seam.
   - **Cognitive Load Allocation**: Spend human turns strictly on high-leverage product intent (Seam 1), seam confirmation (Seam 3), and irreversible one-way doors (Seam 7). Never ask the human for facts discoverable via `lam-investigate` or empirical forks testable via `prototype`.

## Context Pointers (Load Only the Active Branch)

- **24 Principles, Deep-Module Vocabulary & `GLOSSARY.md`/`ADR` Rules**: Read `references/principles-and-vocabulary.md` when naming types, designing module seams, updating `GLOSSARY.md`, or checking the 24 `pstack` principles.
- **Seam 0-4 (Before Code Playbooks)**: Read `references/before-code-playbooks.md` for `Investigation`, `Idea Refine`, `Frontier Grilling`, `Prototype`, `Wayfinder`, `Constraints`, `Spec`, `Architect`, and `Tracer-Bullet Tickets`.
- **Seam 5 (During Code Playbooks)**: Read `references/during-code-playbooks.md` for `Feature (SDD + Seam-TDD)`, `Implement-Spec Worktree Frontier`, `Arena Bakeoff`, `6-Phase Diagnosing Bugs`, `Refactoring/Deepening`, and `Perf Hillclimb`.
- **Seam 6-7 (After Code Playbooks)**: Read `references/after-code-playbooks.md` for `Pre-Commit Hygiene (Deslop + Comment-Sicko + Floor Guard)`, `Dual-Axis + Doubt Review`, `Executable Interrogate & Blast Radius`, `DevTools/TLA+ Verification`, `Visual PR & Babysit`, `Production Ship & Migrations`, and `Environment Retro/Correct`.
- **Subagent & Persona Contracts**: Read `references/agents-and-personas.md` before spawning `lam-coder`, `comment-sicko`, `spec-doubt-reviewer`, `standards-arch-reviewer`, `security-auditor`, `test-engineer`, or `web-performance-auditor`.
- **Deterministic Scripts**: Run `bash scripts/floor-guard.sh [base-ref]` before every commit/review and `bash scripts/log-decision.sh <decisions.tsv> <phase> <decision> <why> <evidence> <result>` during autonomous/hillclimb loops.

## Standing Non-Negotiables

1. **In Your Own Words First (`pstack` + `agent-skills`)**: Open your first reply with the user's goal in plain words, `ASSUMPTIONS I'M MAKING`, and the smallest change expected to meet it. Repeat the goal in every subagent brief, PR `## Summary`, and final report.
2. **Verbatim Playbook Todo Injection (`poteto-mode`)**: Match the incoming task to its playbook, open the corresponding reference file, and copy the playbook's steps **verbatim** into your active checklist. Never delete a non-applicable step; mark it `skip: <one-line reason>`.
3. **Facts = Agent's Job; Decisions = Frontier Rounds (`mattpocock` + `pstack` + `addy`)**:
   - Dispatch `lam-investigate` for codebase/doc facts and `prototype` for empirical UI/timing forks.
   - For product ambiguity, state `HYPOTHESIS` + `CONFIDENCE: ~X%` and ask the unsettled **frontier** in numbered rounds (`Q1`, `Q2`), attaching `-> Recommended: <answer + rationale>` so `"yes"` approves the round in one turn.
4. **Source-Driven + Seam-TDD Discipline (`addy` + `mattpocock`)**:
   - Read exact dependency versions (`DETECT -> FETCH -> IMPLEMENT -> CITE` with `// Source: <deep-link>`) before writing framework code.
   - Agree on public **seams** first (`codebase-design`). Write one failing DAMP behavioral test (`RED`), minimal code (`GREEN`), run `check:fast` + `floor-guard.sh`, and make an atomic ~100-line commit. Defer cross-module refactoring to the review/deepening stage.
5. **Cold Adversarial Review (`doubt-driven-development` + `code-review` + `interrogate`)**:
   - Strip the author's `CLAIM` and rationale when passing `ARTIFACT + CONTRACT` to `spec-doubt-reviewer`.
   - Keep `Spec` and `Standards` review axes separate so neither masks the other.
   - For high-stakes diffs, run `interrogate` in isolated worktrees where only findings proven by an executable failing command survive.
6. **Unslopped Prose & 7-Item Comment Keep List (`unslop` + `comment-sicko`)**:
   - Short declarative sentences in active voice. Zero em-dashes or en-dashes anywhere. Tag every claim in your report as `measured`, `inferred`, or `guess`.
   - Delete all comments outside the 7-item keep list (License, proven external platform gotcha, `prettier-ignore`, documented `CONSTRAINTS.md` exception, public seam `JSDoc`/`OpenAPI`, Issue/ADR/RFC link, or `// Source: <url>`). Mark any workaround comment or `@ts-ignore`/`eslint-disable` as `MUST KILL` and fix the underlying code.
7. **Adaptive Execution Routing (A-La-Carte vs. Fast-Track vs. Full 7-Seam)**:
   - **A-La-Carte Mode**: When the user invokes a single slash command (`/grill`, `/architect`, `/debug`, `/review`, `/perf`, `/ship`) or installs a standalone `skills/lam-*/` folder, execute **only** that skill's seam without forcing upstream seams.
   - **Fast-Track Mode**: For `< 30` line single-file changes with clear requirements, run `Seam 0 (Anchor) -> Seam 5 (RED -> GREEN) -> Seam 6 (Floor Guard)`.
   - **Full 7-Seam Pipeline**: For multi-file features, new APIs, or ambiguous specs, run `Seam 0` through `Seam 7`.
8. **Signature Output Protocol (Vibe-Coder Executive HUD)**:
   - Every response must look unmistakably crisp to a human scanning only the chat output:
     - **Header**: `[L.A.M. v0.1.0 | Seam X/7: <Stage> | Mode: <A-La-Carte|Fast-Track|Full> | Confidence: X% (measured)]`
     - **Human Impact Summary (2-3 bullets, zero AST jargon)**: State in the user's language what user flow works now, what failure state is eliminated, and why it is safe.
     - **Decision Frontier Card (when asking questions)**: Numbered `Q1`, `Q2` options with `-> Recommended: <default>` so `"yes"` or `"ок"` approves in one turn.
     - **Bottom Proof Receipt**: `Tests: <pass/total> | Floor Guard: 0 violations | Blast Radius: <N files> | Door: <Two-Way|One-Way>`.

## Common Rationalizations Guard

| Rationalization (Excuse) | Reality (L.A.M. v0.1.0 Rule) |
| :--- | :--- |
| *"I'll take one plugin 1-to-1 and paste the others on top."* | Naive concatenation creates 3 competing routers, 40k context bloat, and contradictory TDD/interview rules. Route through the 7-Seam State Machine and Two-Load Disclosure. |
| *"I'll ask 8 clarifying questions one per turn before starting."* | Serial 1-by-1 questions burn 8 user turns; asking for codebase facts wastes human attention. Look up facts via subagents and ask the whole unsettled decision frontier in 1 numbered round with recommended defaults. |
| *"I can theorize why the bug happens by reading the file."* | No red-capable command, no hypothesis (`diagnosing-bugs` Phase 1 hard gate). Build a fast deterministic repro loop that goes RED first. |
| *"Adding one `@ts-ignore` or null guard fixes the crash."* | Silencing a check violates `CONSTRAINTS.md` Floor and `principle-fix-root-causes`. Trace the corrupt state to its source and reshape the domain type. |

## Verification & Exit Criteria

- [ ] Active playbook steps copied verbatim into checklist; every step `[x]` verified with runtime output or marked `skip: <reason>`.
- [ ] `bash scripts/floor-guard.sh` exits `0` (zero new suppressions, zero `.skip` tests, zero stubs, zero `[DEBUG-xxxx]` tags).
- [ ] All seam tests, typechecks, linters, and real-surface checks (CLI PTY or isolated Chrome DevTools MCP with zero console errors/warnings) pass.
- [ ] Diff passed `deslop`, `comment-sicko`, and separated `Spec-Doubt` + `Standards-Arch` review.
