# SEO & Launch Playbook — L.A.M. Stack

## GitHub About description (158 chars, exact)

```
Deterministic control runtime for AI coding agents — 7 gated seams, a mechanical quality floor, ~4.3KB skill metadata, evals published raw JSONL. MIT, v0.1.0.
```

(158 characters incl. spaces — verified.)

## GitHub topics (20, high-intent)

```
claude-code claude-skills agent-skills ai-agents ai-coding-agent
plugin llm context-engineering prompt-engineering developer-tools
agentic-ai opencode codex cli deterministic-workflow quality-gates
test-driven-development software-engineering agents markdown
```

## Search keyword matrix

| Intent | Keywords | Where they must appear |
|---|---|---|
| Install a pack | claude code plugin, claude skills, agent skills | README line 1 + About + topics |
| Reduce context | context engineering, token overhead, skill metadata | "Measured startup surface" section + About |
| Enforce quality | quality gates, deterministic workflow, pre-commit guard | comparison matrix + topics |
| Methodology | TDD, spec-driven development, state machine | ASCII seam diagram + SPEC references |
| Evaluate | benchmark, evals, skills comparison | `evals/` links + About |

Rule: first 120 characters of README carry install + category keywords —
that span is what GitHub search and Google snippets index.

## Show HN template

```
Show HN: L.A.M. — a deterministic control runtime for AI coding agents
(published evals, including where we tied)

Most agent skill packs are prose the model may or may not honor. L.A.M.
puts the discipline in scripts instead: every phase transition crosses a
mechanical gate (seam-gate.sh), every claim requires a checkable artifact
(SPEC.md's M=R axiom), and the pre-commit guard blocks floor violations
before they exist.

It's the three biggest packs (pstack, mattpocock, addyosmani — ~130 skills)
distilled into 13 phase skills at ~4.3KB of startup metadata, ~8x lighter.

The part I haven't seen elsewhere: a reproducible blinded duel harness.
24 runs, same model/task/seed/commit — we tied pstack and trailed the
others by 0.17. The raw grader JSON is in the repo: evals/duel-2026-11-08.md.

Install: /plugin marketplace add oysana/lam-stack
```

## X/Twitter thread template

```
1/ Your agent's skill pack is a suggestion. Mine is a gate.
   L.A.M. Stack: deterministic control runtime for coding agents. 🧵

2/ Every work phase crosses a mechanical check.
   `seam-gate.sh check <N>` — a failed gate stops the transition.
   Not a warning. A non-zero exit.

3/ Every claim requires an artifact. SPEC.md's axiom: M = R —
   model state equals reality. "Tests pass" without a test-run
   artifact is a violation, not a status update.

4/ The three biggest packs compressed to 13 skills.
   ~4.3KB startup surface vs ~36KB combined. ~1.1k vs ~9k tokens.

5/ And the receipts: a blinded 4-arm duel, 24 runs, raw grader
   JSON in the repo — including where we tied.
   evals/duel-2026-11-08.md

6/ /plugin marketplace add oysana/lam-stack — MIT, v0.1.0.
   If your agent skips steps, this is for you.
```

## Reddit template (r/ClaudeAI, r/LocalLLaMA, r/programming)

```
Title: I built a skill pack that enforces agent discipline with
scripts instead of prompts — and published the benchmark where
we *didn't* win

Body: The pitch is boring on purpose: quality rules that live in
floor-guard.sh and seam-gate.sh rather than in prose. M=R invariant
from SPEC.md — every agent claim needs a machine-checkable artifact.
~4.3KB startup surface vs ~9k tokens for the big packs combined.
I ran a blinded 4-arm duel vs pstack/mattpocock/addyosmani — tied
one, trailed two. Raw JSON is in evals/. AMA about the harness.
```

## Launch order

1. Set GitHub About + 20 topics + social preview (the ASCII seam diagram
   renders well as a preview image).
2. README is already positioned (done 2026-11-09).
3. Submit to awesome lists: hesreallyhim/awesome-claude-code,
   VoltAgent/awesome-agent-skills, travisvn/awesome-claude-skills,
   ComposioHQ/awesome-claude-skills.
4. Show HN Tuesday–Thursday 14:00–16:00 UTC.
5. Reddit same week, X thread day-of.
```
