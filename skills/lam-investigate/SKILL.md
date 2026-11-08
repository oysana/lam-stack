---
name: lam-investigate
description: Codebase and history investigation combining Lauren Tan's /how and /why with Matt Pocock's /research. Use when asked how a subsystem works, why code was written a certain way, or when grounding architecture before changes.
---

# L.A.M. Investigate (`how` + `why` + `research`)

## Overview
Answers read-only mechanics and historical rationale questions by combining parallel `readonly` code explorers (`how`), git/PR/ADR forensic investigators (`why`), and primary-source external documentation readers (`research`).

## When to Use
- "How does X work?", "Where does Y live?", "Why was Z designed this way?", or "Are we sure about W?"
- Phase A (`Ground`) of `lam-architect` before modifying any cross-module interface.

## The Workflow
1. **Restate Question (`in-your-own-words`)**: Name the exact target symbol/subsystem and record `throughput checkpoint: n/a, read-only investigation`.
2. **Trace Mechanics (`how`)**:
   - Single file/module: trace call graph and data flow directly.
   - Complex subsystem: fan out 2-4 fresh-context `readonly` explorer subagents across disjoint slices, then synthesize into `Overview`, `Key Concepts`, `How It Works` (with `file:line`), `Where Things Live`, and `Gotchas`.
3. **Trace Design Rationale & History (`why`)**:
   - Build git anchor inline (`git blame -L`, `git log --follow -p`, `gh pr view --json`, `docs/adr/`).
   - Fan out parallel investigators across git history, issue tracker, ADRs/docs, and error/observability logs.
   - Synthesize with strict epistemic labels (`measured`, `inferred`, `guess`) into: `The Question`, `The Code in Question`, `What We Found`, `What We Can Reasonably Infer`, `Competing Hypotheses`, `What We Don't Know`, and a `Preserve / Change / Avoid / Risk` constraint table.
4. **External Primary Docs (`research`)**: If the question involves an external library or spec, spawn a fresh-context subagent to read official docs/source and save a cited markdown brief.

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"I can infer why this legacy guard exists from its variable name."* | Variable names go stale. Run `git log -S` / `git blame` and check `docs/adr/` (`Chesterton's Fence`) before claiming rationale. |
| *"I'll read all 30 subsystem files in the main thread."* | Bulk reading floods the main context window (`principle-guard-the-context-window`). Fan out 2-4 `readonly` subagents and return file pointers. |

## Red Flags
- Reporting an inferred guess as a verified fact without `file:line` or commit SHA evidence.
- Asking the human how their own codebase works instead of reading it.

## Verification
- [ ] Every mechanical claim cites an exact `file:line` pointer.
- [ ] Every historical claim cites a commit SHA, PR/issue number, or ADR file (or is explicitly marked `inferred` / `unknown`).
- [ ] Output ends with a concrete `Preserve / Change / Avoid / Risk` constraint summary when feeding into design work.
