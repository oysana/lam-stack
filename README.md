# L.A.M. Stack v0.2.1

> **The Unified Principal-Engineer Plugin for AI Coding Agents**
> A compressed synthesis of **`pstack`** (`chhoumann/t3-pstack`), **Matt Pocock's `skills`** (`mattpocock/skills`), and **Addy Osmani's `agent-skills`** (`addyosmani/agent-skills`) into one zero-conflict plugin with a mechanical quality floor.

**Measured startup surface** (YAML frontmatter bytes that harnesses preload as skill metadata, counted 2026-11-08 on v0.2.1): L.A.M. carries `~4.3 KB` across 13 skills + router, vs `~36 KB` for all three source packs combined (66 + 39 + 25 skills). That is roughly `1.1k` vs `9k` tokens at 4 bytes/token, and smaller than any single source pack (pstack `~17.8 KB`, mattpocock `~8.0 KB`, addyosmani `~10.3 KB`). Method and raw counts are in `evals/startup-surface.md`.

**Head-to-head status (honest):** in a blinded 4-arm duel on real tasks (same model, task, seed, starting commit; 24 runs), L.A.M. **tied** pstack and finished marginally behind the Pocock and Osmani packs on a saturated strong-model lane — details and raw grader JSON in `evals/duel-2026-11-08.md`. A discriminating free-model lane is instrumented; claims here stay exact about which packs, if any, were beaten.

---

## Navigation

- **[Part 1: For Humans & Vibe Coders](#part-1-for-humans--vibe-coders)**
  - [Why L.A.M. Stack Exists](#why-lam-stack-exists)
  - [3 Execution Modes (Autonomous, A-La-Carte, Fast-Track)](#3-execution-modes)
  - [Installation](#installation)
  - [What This Is (and Is Not)](#what-this-is-and-is-not)
  - [Slash Commands & Skills Matrix](#slash-commands--skills-matrix)
  - [What You See in Terminal (Vibe-Coder Executive HUD)](#what-you-see-in-terminal-vibe-coder-executive-hud)
- **[Part 2: For AI Coding Agents (Execution Contract)](#part-2-for-ai-coding-agents-execution-contract)**
  - [Agent Bootstrap & Two-Load Routing Protocol](#1-agent-bootstrap--two-load-routing-protocol)
  - [The 4 Built-In First-Principles Laws](#2-the-4-built-in-first-principles-laws)
  - [7-Seam Artifact State Machine & Exit Gates](#3-7-seam-artifact-state-machine--exit-gates)
  - [4 Model Roles & Fresh-Context Subagent Topology](#4-4-model-roles--fresh-context-subagent-topology)
  - [Signature Output Protocol (Mandatory HUD Format)](#5-signature-output-protocol-mandatory-hud-format)
  - [Mechanical Verification Suite](#6-mechanical-verification-suite)

---

# Part 1: For Humans & Vibe Coders

## Why L.A.M. Stack Exists

Installing `pstack`, `mattpocock/skills`, and `addyosmani/agent-skills` side-by-side causes three immediate failures:
1. **Token Bloat (~40,000 tokens)**: All three dump dozens of overlapping markdown instructions into the system prompt on every turn.
2. **Routing Collisions**: Competing TDD, planning, and code-review skills fight over the same triggers.
3. **Meta-Prompt Fatigue**: Without a unified discipline layer, you still have to paste 50-line "senior engineer" prompts (`prove facts with data`, `make modules deep`, `find implicit state machines`) on every turn.

**L.A.M. Stack v0.2.1** solves all three:
- **Two-Load Progressive Disclosure (`~1,500` tokens at start)**: Loads only a `< 90`-line router (`SKILL.md`) at session start and pulls leaf playbooks on demand.
- **Built-In Senior Engineering Physics**: Automatically enforces Data-First Probing, Ousterhout Deep Modules (Deletion Test + Interface Shrink), First-Principles State Machine Discovery ($M = R$), and 17 Mechanical Anti-Slop Traps (`scripts/floor-guard.sh`).
- **Executive Terminal Output**: Vibe coders do not want to read walls of AI prose. Every response prints a clean **Executive HUD**, a 3-bullet summary, a decision/diff table, and raw terminal proof.

---

## 3 Execution Modes

You never have to choose between Lauren Tan's autonomous orchestration and Matt Pocock's surgical single-skill workflow. L.A.M. Stack adapts automatically:

| Mode | How to Trigger | What Happens | Best For |
| :--- | :--- | :--- | :--- |
| **1. Full 7-Seam Autonomous** | `/lam <goal>` or complex multi-file feature request | Agent autonomously executes Intake -> Spec-Doubt -> $M=R$ Types -> Deep Module Plan -> Seam-TDD Slices -> Dual-Axis Review -> 17/17 Floor Guard. | New features, full-stack modules, complex refactors |
| **2. A-La-Carte (Single Skill)** | `/grill`, `/spec`, `/architect`, `/tickets`, `/build`, `/debug`, `/review`, `/ship`, `/arena`, `/interrogate`, `/prototype` | Runs **only** the requested skill and its own verification check, then stops immediately. No forced 7-Seam cycle. | Matt Pocock style surgical workflows |
| **3. Fast-Track (`< 30` lines)** | Any 1-file bugfix, UI tweak, or config edit | Skips `SPEC.md` and ADR paperwork; runs Data-First Probe + Deep Module edit + `scripts/floor-guard.sh` directly. | Quick fixes, rapid iteration |

---

## Installation

### Claude Code (validated: `claude plugin validate` passes on v0.2.1)

```text
/plugin install lam-stack --marketplace oysana/lam-stack
```

Or register the marketplace first, then install from the `/plugin` UI:

```text
/plugin marketplace add oysana/lam-stack
/plugin install lam-stack@lam-stack
```

### OpenCode (validated: `opencode.json` skills key, OpenCode v2.2.x)

```bash
git clone https://github.com/oysana/lam-stack ~/.local/share/lam-stack
```

Add to your project `opencode.json`:

```json
{ "skills": ["~/.local/share/lam-stack/skills"] }
```

Or symlink the skill folders into `.claude/skills/` or `.agents/skills/`, which OpenCode auto-discovers.

### Other harnesses (shipped by convention, not yet validated end-to-end)

| Harness | Provided | Status |
| :--- | :--- | :--- |
| Cursor | `.cursor/rules/lam-mode.mdc` auto-attached rule + `skills/` | Untested on latest Cursor |
| OpenAI Codex CLI | `AGENTS.md` + `skills/*/agents/openai.yaml` + `.codex-plugin/plugin.json` | Untested |
| Gemini CLI | `.gemini/commands/*.toml` (18 mirrors) + `skills/` | Untested |
| Devin / Antigravity | `AGENTS.md` + `skills/` | Untested |

For these, copy `skills/`, `agents/`, `references/`, `scripts/`, and the root markdown contract files into your project, or point the harness's skill directory at them. File an issue if a mechanism needs adjusting.

### A-La-Carte Installation

Every skill in `skills/lam-*/SKILL.md` is self-contained. Copy only the folders you want:

```bash
mkdir -p .claude/skills .claude/commands
cp -r lam-stack/skills/lam-grill lam-stack/skills/lam-architect .claude/skills/
cp lam-stack/.claude/commands/grill.md lam-stack/.claude/commands/architect.md .claude/commands/
```

---

## What This Is (and Is Not)

L.A.M. is a compressed synthesis, not a superset. It keeps the overlapping core of the three source packs (routing, spec-doubt, TDD, review, ship discipline) and enforces it with deterministic scripts. It does not re-implement every upstream skill.

**Derived from** (all MIT, notices in `LICENSE`):

- `chhoumann/t3-pstack`: principles vocabulary, decision-trail logging, subagent topology, deslop and comment discipline.
- `addyosmani/agent-skills`: persona roster, doubt-driven development, eval methodology, floor-guard precedent.
- `mattpocock/skills`: grill/spec/tickets flow, invocation conventions, single-skill a-la-carte mode.

**Not covered** (use the source packs for these):

- From `pstack`: standalone `how`/`why`/`research`/`statechart`/`reflect`/`tdd` skills, orchestration and autopilot playbooks, formal verification, `benchmark-checklist`.
- From `mattpocock/skills`: the `writing-*` family, `improve-codebase-architecture`, `wizard`, `wait-what`, standalone `pr`.
- From `addyosmani/agent-skills`: `frontend-ui-engineering`, `browser-testing-with-devtools`, `ci-cd-and-automation`, `git-workflow-and-versioning`, `observability-and-instrumentation`, `deprecation-and-migration`, `context-engineering`, `interview-me`, `documentation-and-adrs`.

---

## Slash Commands & Skills Matrix

| Command | Skill Folder | Seam | Model Role | What It Does |
| :--- | :--- | :--- | :--- | :--- |
| `/lam` | `skills/lam-mode` | `Seam 0..7` | All 4 Roles | Master router: runs Adaptive Mode (Full 7-Seam, Fast-Track, or A-La-Carte) |
| `/investigate` | `skills/lam-investigate` | `Seam 0` | `worker` | Read-only repo reconnaissance, blast-radius map, and data-first fact probing |
| `/grill` | `skills/lam-grill` | `Seam 1` | `worker` + `peer` | Epistemic interrogation (`Hypothesis + Confidence %` + Decision-Tree Frontier) |
| `/constraints` | `skills/lam-constraints` | `Seam 1` | `worker` | Locks `CONSTRAINTS.md` stage budgets (`check:fast`, `check:task`, `check:full`) |
| `/spec` | `skills/lam-spec` | `Seam 1` | `builder` + `judge` | Locks `SPEC.md` and runs pre-code Spec-Doubt (`CLAIM -> DOUBT -> RECONCILE`) |
| `/architect` | `skills/lam-architect` | `Seam 2 & 3` | `builder` | Enforces $M = R$ types, `GLOSSARY.md` nouns, Ousterhout Deep Modules, and ADRs |
| `/tickets` | `skills/lam-tickets` | `Seam 4` | `builder` | Decomposes architecture into vertical `Seam-TDD` slices with Dependency DAG |
| `/build` | `skills/lam-build` | `Seam 5` | `builder` | Source-Driven (`DETECT->FETCH->CITE`) vertical `RED -> GREEN -> REFACTOR` execution |
| `/debug` | `skills/lam-debug` | `Seam 5` | `worker` + `builder` | 6-phase root-cause debugger with mandatory Phase 1 red-capable reproducer command |
| `/perf` | `skills/lam-perf` | `Seam 5 & 6` | `builder` | Core Web Vitals (`LCP`, `INP`, `CLS`), bundle budget, and query hot-path profiler |
| `/review` | `skills/lam-review` | `Seam 6` | `judge` + `peer` | Fresh-context Dual-Axis review (`spec-doubt-reviewer` + `comment-sicko` + `floor-guard.sh`) |
| `/ship` | `skills/lam-ship` | `Seam 6` | `judge` | 6-Gate production launch audit (STRIDE/OWASP/LLM01-10) + PR Blast-Radius report |
| `/retro` | `skills/lam-retro` | `Seam 7` | `worker` + `builder` | 7-category retrospective + 5-layer mistake hardening (`correct`) into `decisions.tsv` |
| `/arena` | `skills/lam-architect` | `Seam 3` | `builder` + `judge` | Design-It-Twice parallel worktree bakeoff between competing module architectures |
| `/interrogate` | `skills/lam-review` | `Seam 6` | `peer` + `judge` | Cross-model adversarial examination where only executable code-backed findings survive |
| `/prototype` | `skills/lam-grill` | `Seam 1 & 3` | `builder` | Disposable empirical spike (`< 15 min`) to resolve uncertain technical forks |
| `/wayfinder` | `skills/lam-investigate` | `Seam 0` | `worker` | Next-action recommender based on current git diff and Seam artifact state |
| `/handoff` | `skills/lam-retro` | `Seam 7` | `worker` | Context-compaction state serializer writing deterministic resume pointers |

---

## What You See in Terminal (Vibe-Coder Executive HUD)

Every L.A.M. Stack response follows a strict visual output contract so you can verify progress in 5 seconds without reading raw code:

```text
╭─ ⚡ L.A.M. STACK v0.2.1 ── [Seam 2: M=R & Deep Modules] ── [Role: Builder] ─╮
│ [✓ Intake] ──▶ [✓ Spec] ──▶ [● M=R] ──▶ [○ Plan] ──▶ [○ Slice] ──▶ [○ Ship] │
╰─────────────────────────────────────────────────────────────────────────────╯

### 🎯 Executive Summary
- **Goal**: Replace boolean billing flags with an exhaustive discriminated union (`InvoiceState`).
- **Architecture**: Pulled signature verification, retry backoff, and idempotency locking inside `StripeBillingEngine` (Ousterhout Deep Module).
- **Blast Radius**: 2 files updated (`src/domain/billing.ts`, `src/engine/billing.ts`), 0 public callers broken.

### 📐 Decision & Invariant Matrix
| Concept | Previous Shape (Illegal States Possible) | New $M = R$ Shape (0 Illegal States) |
| :--- | :--- | :--- |
| Invoice lifecycle | `{ isPaid: boolean; txId?: string }` | `{ status: 'draft' } \| { status: 'paid'; txId: TxId }` |
| Webhook boundary | Raw `req.body as any` | `parseWebhookEvent(raw: unknown): Result<VerifiedEvent, SigError>` |

### 🛡️ Proof Gate
- `npm test` -> `14/14 PASS (0.8s)`
- `bash scripts/floor-guard.sh` -> `0 violations (0 console.log, 0 as any, 0 mocks)`
```

---

# Part 2: For AI Coding Agents (Execution Contract)

> **AGENT DIRECTIVE**: If you are an AI coding agent (Claude Code, Cursor, OpenCode, Codex, Devin, Gemini CLI, or Antigravity) operating inside a repository containing L.A.M. Stack v0.2.1, this section is your deterministic execution specification.

## 1. Agent Bootstrap & Two-Load Routing Protocol

To preserve context window hygiene (`< 1,500` startup tokens), you MUST obey the **Two-Load Progressive Disclosure Law**:
1. **Load 1 (Router)**: Read `SKILL.md` (`< 90` lines) and `skills/lam-mode/SKILL.md`.
2. **Mode Classification**:
   - If the user invoked a specific slash command or single skill (`/grill`, `/architect`, `/debug`, `/review`, etc.), execute **A-La-Carte Mode**: load only that skill's `SKILL.md`, perform its task, run its verification command, and stop.
   - If the task is a localized edit (`< 30` lines, single file, no schema/boundary change), execute **Fast-Track Mode**: probe the target file, apply Deep Module + $M=R$ rules directly, and verify with `check:fast` + `bash scripts/floor-guard.sh`.
   - Otherwise, execute the **Full 7-Seam Artifact State Machine** (`Seam 0` -> `Seam 7`).
3. **Load 2 (On-Demand Leaf)**: Load **only** the active Seam's `skills/lam-*/SKILL.md` and its single paired reference file (`references/before-code-playbooks.md` for Seams 0-4, `references/during-code-playbooks.md` for Seam 5, `references/after-code-playbooks.md` for Seams 6-7). **Never** preload all reference files simultaneously.

---

## 2. The 4 Built-In First-Principles Laws

Every action you take in any mode MUST enforce these four foundational engineering laws without waiting for the user to prompt them:

1. **Empirical Data-First Household (`lam-investigate` / `lam-debug`)**:
   - Every architectural or debugging conclusion MUST be backed by proven data gathered via probing, reading files, git history, or running deterministic tools before stating a conclusion. Never guess when you can probe.
2. **First-Principles State Machine & Invariant Discovery ($M = R$, `lam-architect`)**:
   - Actively locate every implicit state machine and every invariant the application relies on but does not explicitly enforce.
   - Enforce the Cardinality Law ($|M| = |R|$): replace loose boolean flags, nullable optional bags, and stringly-typed statuses with exhaustive discriminated unions, opaque branded types, and parse-at-the-boundary constructors (`parse, don't validate`).
3. **Ousterhout Deep Modules & Interface Shrink (`lam-architect` / `lam-build`)**:
   - Make every module deep: a simple interface hiding substantial implementation complexity.
   - **Deletion Test**: If deleting a module would only push its complexity back onto its callers, it earns its place; if nothing is lost, merge it away into the owning module.
   - **Single Concept Ownership & Interface Shrink**: Put each concept in the single module that owns it. Pull special cases, ordering rules, retries, validation, and derived values inside so callers never have to know them. Drop any parameter, flag, or option the module can derive itself, that every caller passes the same way, or that nobody reads, migrate all callers to the new shape, and delete the old code path completely.
4. **Fresh-Context Dual-Axis Verification & Anti-Slop Floor (`lam-review` / `floor-guard.sh`)**:
   - Strip Builder `CLAIM` narratives before passing diffs to `agents/spec-doubt-reviewer.md`.
   - Enforce `agents/comment-sicko.md` (delete all `WHAT`/`HOW` restatement comments; keep only the 7 permitted categories such as `// Source:` citations and `// SAFETY:` invariants).
   - Never use em-dashes or en-dashes in plugin markdown artifacts.

---

## 3. 7-Seam Artifact State Machine & Exit Gates

| Seam | Stage Name | Active Skill(s) | Required Artifact / State | Mechanical Exit Gate |
| :--- | :--- | :--- | :--- | :--- |
| **Seam 0** | Triage & Recon | `skills/lam-investigate/SKILL.md` | Blast-radius map + verified repo facts | `bash scripts/seam-gate.sh 0` |
| **Seam 1** | Epistemic Spec & Doubt | `skills/lam-grill/SKILL.md`, `skills/lam-constraints/SKILL.md`, `skills/lam-spec/SKILL.md` | `CONSTRAINTS.md` + `SPEC.md` (`CLAIM->DOUBT->RECONCILE`) | `bash scripts/seam-gate.sh 1` |
| **Seam 2** | Ubiquitous Language & $M=R$ | `skills/lam-architect/SKILL.md` | `GLOSSARY.md` (`_Avoid:_` synonyms) + $M=R$ boundary types | `bash scripts/seam-gate.sh 2` |
| **Seam 3** | Deep Modules & ADRs | `skills/lam-architect/SKILL.md` | `docs/adr/NNNN-slug.md` (3-Gate ADR) + Deletion Test | `bash scripts/seam-gate.sh 3` |
| **Seam 4** | Vertical Slice Plan | `skills/lam-tickets/SKILL.md` | Dependency DAG of atomic vertical `RED->GREEN` slices | `bash scripts/seam-gate.sh 4` |
| **Seam 5** | Execution & Diagnosis | `skills/lam-build/SKILL.md`, `skills/lam-debug/SKILL.md`, `skills/lam-perf/SKILL.md` | Source-cited implementation + passing vertical tests | `bash scripts/seam-gate.sh 5` |
| **Seam 6** | Dual-Axis Review & Ship | `skills/lam-review/SKILL.md`, `skills/lam-ship/SKILL.md` | Fresh-context audit + 6-Gate security/perf release check | `bash scripts/floor-guard.sh && bash scripts/seam-gate.sh 6` |
| **Seam 7** | Telemetry & Retro | `skills/lam-retro/SKILL.md` | Append verified row to `decisions.tsv` via `scripts/log-decision.sh` | `bash scripts/seam-gate.sh 7` |

---

## 4. 4 Model Roles & Fresh-Context Subagent Topology

Defined in `references/agents-and-personas.md`:
- **`worker`**: Fast read-only reconnaissance, file probing, symptom reproduction, and context handoffs (`lam-investigate`, `wayfinder`).
- **`builder`**: Deep module design, $M=R$ type construction, vertical `RED -> GREEN -> REFACTOR` slice implementation (`agents/lam-coder.md`, `agents/test-engineer.md`).
- **`judge`**: Fresh-context adversarial auditor (`agents/spec-doubt-reviewer.md`, `agents/standards-arch-reviewer.md`, `agents/comment-sicko.md`, `agents/security-auditor.md`, `agents/web-performance-auditor.md`). Never shares conversational rationalizations with `builder`.
- **`peer`**: Cross-model second opinion for high-blast-radius architecture forks (`arena`) and executable survival audits (`interrogate`).

---

## 5. Signature Output Protocol (Mandatory HUD Format)

Every turn MUST open with the **Vibe-Coder Executive HUD** box and close with a **Proof Gate**:

```text
╭─ ⚡ L.A.M. STACK v0.2.1 ── [Seam <N>: <Stage Name>] ── [Role: <Active Role>] ─╮
│ [✓ Intake] ──▶ [✓ Spec] ──▶ [● M=R] ──▶ [○ Plan] ──▶ [○ Slice] ──▶ [○ Ship]  │
╰──────────────────────────────────────────────────────────────────────────────╯
```
1. **🎯 Executive Summary** (max 3 bullets: `Goal`, `Architecture`, `Blast Radius`).
2. **📐 Decision / Diff Matrix** (markdown table of key invariants, deep module boundaries, or resolved forks).
3. **🛡️ Proof Gate** (exact commands executed and their pass/fail status).

---

## 6. Repository Structure & Mechanical Verification Suite

```text
lam-stack/
├── SKILL.md                          # <90-line Load-1 progressive disclosure router
├── AGENTS.md                         # Universal entry contract (OpenCode, Codex, Devin, Cursor)
├── CONSTRAINTS.md                    # Stage verification budgets (check:fast, check:task, check:full)
├── GLOSSARY.md                       # Ubiquitous domain nouns & forbidden synonyms (_Avoid:_)
├── SPEC.md                           # Active behavioral specification & Spec-Doubt log
├── decisions.tsv                     # Append-only architectural & retrospective audit log
├── plugin.json                       # Universal plugin manifest (canonical; harness copies are byte-parity checked)
├── opencode.json                     # OpenCode skill directory declaration
├── .claude-plugin/plugin.json + marketplace.json + icon.png   # Claude Code plugin + marketplace listing
├── .agents/plugins/marketplace.json  # Cross-agent marketplace entry
├── .cursor-plugin/plugin.json        # Cursor plugin manifest
├── .codex-plugin/plugin.json         # OpenAI Codex plugin manifest
├── .cursor/rules/lam-mode.mdc        # Cursor auto-attached rule
├── .claude/commands/*.md             # 18 Claude Code slash commands (/lam, /grill, /architect, ...)
├── .gemini/commands/*.toml           # 18 Gemini CLI slash commands
├── skills/lam-*/SKILL.md             # 13 modular Seam skills (+ agents/openai.yaml)
├── agents/*.md                       # 7 specialized fresh-context subagents
├── references/*.md                   # 5 deep reference playbooks (loaded on demand)
├── hooks/                            # SessionStart, PreToolUse, and Stop mechanical hooks
└── scripts/
    ├── validate-lam.py               # 3-Tier validator (47 artifacts, 272 assertions, 3 suites)
    ├── floor-guard.sh                # 17-trap anti-slop & security diff scanner (--self-test)
    ├── seam-gate.sh                  # Seam 0..7 artifact gate verifier (--self-test)
    └── log-decision.sh               # Formula-injection-safe TSV logger for decisions.tsv
```

### Run Full Self-Verification (`check:full`)

```bash
python3 scripts/validate-lam.py
bash scripts/floor-guard.sh --self-test
bash scripts/seam-gate.sh --self-test
bash scripts/floor-guard.sh
```

---

## License

MIT License. See [LICENSE](./LICENSE).
