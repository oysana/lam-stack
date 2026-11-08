---
name: lam-review
description: Tiered 3-gate post-code verification and review pipeline combining Lauren Tan's deslop, no-comments (comment-sicko), interrogate, and blast-radius with Matt Pocock's 2-axis code-review (Spec + Standards) and Addy Osmani's doubt-driven-development and 5-axis code-review-and-quality.
---

# L.A.M. Review (`deslop` + `comment-sicko` + `Dual-Axis Doubt/Standards Review` + `interrogate`)

## Overview
Runs a zero-conflict, 3-gate review pipeline that strips AI slop and workaround comments first, then dispatches two separated fresh-context review subagents (**Axis 1: Cold Spec & Doubt** and **Axis 2: Standards, Deep Modules & 5 Dimensions**), and escalates high-stakes diffs to executable multi-model worktree interrogation (`interrogate`).

## When to Use
- After completing any ticket, slice, or integration branch, or when asked to review a branch/PR diff (`/review`).

## The Workflow
1. **Gate 1 - Pre-Review Hygiene (`deslop` + `comment-sicko` + `floor-guard`)**:
   - Strip AI code slop from `git diff <base>...HEAD`: redundant internal `try/catch` guards, `as any` casts, and single-caller pass-throughs (`deslop`).
   - Spawn `comment-sicko` (`agents/comment-sicko.md`): delete all comments outside the **7-item L.A.M. Keep List** (License, proven external platform gotcha, `prettier-ignore`, documented `CONSTRAINTS.md` exception, public seam `JSDoc`/`OpenAPI`, Issue/ADR/RFC link, or `// Source: <url>`). Reshape any symbol flagged `MUST KILL`.
   - Run `bash scripts/floor-guard.sh <base>`.
2. **Gate 2 - Parallel Dual-Axis Fresh-Context Review (`Spec-Doubt` + `Standards-Arch`)**:
   - Spawn two fresh-context subagents in parallel and report their outputs side-by-side without merging or re-ranking across axes:
     - **Subagent A (`spec-doubt-reviewer`)**: Receives **only** `ARTIFACT` (`git diff`) + `CONTRACT` (`SPEC.md`/ticket + `CONSTRAINTS.md` + `GLOSSARY.md`) with the author's `CLAIM` and rationale stripped (`doubt-driven-development`). Audits missing/partial requirements, scope creep, and broken edge cases.
     - **Subagent B (`standards-arch-reviewer`)**: Audits (1) Seam tests first + experimental condition-inversion mutation check, (2) Deep-module Deletion Test + <30s reader load, (3) `CODING_STANDARDS.md` + 12 Fowler code smells baseline, (4) Boundary security, and (5) N+1/observability checks.
   - Validate all candidate findings against real callers and type guards (`RECONCILE`), classify as `Critical`, `Required`, `Optional`, or `Nit`, and fix all `Critical` and `Required` findings (capping Doubt loops at <=3 cycles).
3. **Gate 3 - High-Stakes Executable Interrogation & Blast Radius (`interrogate` + `blast-radius`)**:
   - When changes touch auth, billing, concurrency, wire formats, or contested architecture, copy the diff into isolated worktrees for adversarial reviewers (`interrogate`) and offer read-only cross-model CLI review (`codex` / `gemini`).
   - **Survival Rule**: Keep only findings proven by an executable command/test output that breaks the intent; trace 3-hop consumers (`blast-radius`).

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"I'll review the diff myself in this session."* | Self-review in the author's context window rationalizes bugs. Fresh-context subagents with the `CLAIM` stripped catch what the author cannot see. |

## Red Flags
- Merging `Spec` and `Standards` findings into one list (allowing clean formatting to mask a missed spec requirement).
- Keeping a workaround comment instead of fixing the `MUST KILL` symbol.

## Verification
- [ ] `bash scripts/floor-guard.sh` and `comment-sicko` audit passed with zero unresolved `MUST KILL` flags.
- [ ] Both `## Axis 1: Spec & Contract` and `## Axis 2: Standards & Architecture` reports were generated in fresh context and all `Critical`/`Required` items are fixed.
