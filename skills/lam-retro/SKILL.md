---
name: lam-retro
description: Closes the engineering loop by auditing session transcripts across 7 environment categories, encoding recurring mistakes into 5-layer structural checks, and managing context handoffs (/retro + correct + reflect + /handoff + /wait-what).
disable-model-invocation: true
---

# L.A.M. Retro & Environment Hardening (`/retro` + `correct` + `reflect` + `/handoff`)

## Overview
Upgrades the **agent's environment** (not just the code) after a build or debugging session by combining Matt Pocock's 7-category `/retro` and `writing-for-agents` pruning rules with Lauren Tan's 5-layer mistake hardener (`correct`) and 3-lens session reviewer (`reflect`).

## When to Use
- At the end of a build/debug session (`/retro`), when a mistake class repeats (`correct`), when switching sessions/harnesses (`/handoff`), or when an explanation failed to land (`/wait-what`).

## The Workflow
1. **Audit the Session Across 7 Environment Categories (`mattpocock/retro` + `pstack/reflect`)**:
   - Inspect the session transcript through 3 lenses (*Judgment*, *Tooling*, *Divergent*) across 7 categories:
     1. *Navigation*: Add missing context pointers in `CLAUDE.md`/`AGENTS.md` if file discovery was slow.
     2. *Automated Checks*: Wire existing linters/tests or build a new deterministic check for any mechanical error made during the session.
     3. *Coding Standards*: Reserve `CODING_STANDARDS.md` strictly for reviewer judgement calls that no deterministic linter/type rule can check.
     4. *Global Steering Pruning (`writing-for-agents`)*: Delete environment caches (facts discoverable from `package.json`) and sentence-level no-ops from `CLAUDE.md`/`AGENTS.md`.
     5. *Tool Economy (`principle-build-the-lever`)*: Replace expensive multi-turn tool loops with a reusable script.
     6. *Positive Leading Words*: Rewrite weak negations (*"don't write messy tests"*) into positive leading-word targets (*"write DAMP tests at confirmed public seams"*).
     7. *Information Access*: Tee dev-server logs or configure read-only MCP connectors where the agent lacked visibility.
2. **5-Layer Mistake Hardening (`pstack/correct`)**:
   - For any mistake class occurring >=2 times across commits/sessions, encode the fix at the **highest possible layer**:
     `Layer 1: Architecture / Data Shape -> Layer 2: Type System -> Layer 3: Custom Lint / CONSTRAINTS.md Floor Script -> Layer 4: Seam Tests -> Layer 5: Skill / Doc Pointer`.
   - Prove the new check fails against the historical mistake before committing.
3. **Context Handoff & Plain Restatement (`/handoff` & `/wait-what`)**:
   - On `/handoff`: Write `/tmp/handoff-<slug>.md` using file/URL pointers (zero duplicated bodies), redacted secrets, and `Suggested Skills` for the next session.
   - On `/wait-what`: Re-pitch the last message in ASD-STE100 Simplified Technical English using exact `GLOSSARY.md` domain nouns.

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"I'll add a paragraph to CLAUDE.md telling the agent not to make that syntax mistake again."* | Mechanical mistakes belong in a linter or `floor-guard.sh`, never as prose sediment in `CLAUDE.md` (`/retro` + `principle-encode-lessons-in-structure`). |

## Red Flags
- Adding prose rules to `CLAUDE.md` without pruning stale lines or checking if a deterministic script can enforce the rule instead.

## Verification
- [ ] Every proposed environment improvement is classified into its highest enforcement layer (`Architecture > Types > Lint/Script > Test > Pointer`).
- [ ] Any new mechanical check was proven to fail on the past mistake and pass on clean code.
