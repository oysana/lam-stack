---
name: lam-spec
description: Synthesizes an agreed conversation or wayfinder map into a durable SPEC.md or tracker Spec issue with confirmed public test seams and 3-tier boundaries. Combines Matt Pocock's /to-spec and Addy Osmani's spec-driven-development.
disable-model-invocation: true
---

# L.A.M. Spec (`/spec` + `/to-spec` + `spec-driven-development`)

## Overview
Turns settled product intent into a durable specification (`SPEC.md` or GitHub Spec issue) without re-interviewing, locking in public test **seams** and 3-tier boundaries before task breakdown.

## When to Use
- After `lam-grill` or `/wayfinder` reaches shared understanding, or when starting a multi-slice feature.

## The Workflow
1. **Phase 0 - Capability Map (Multi-Module Initiatives Only)**: If the ask bundles multiple independent modules, propose an acyclic Capability Map table (`Module ID | Responsibility | Depends On | Build Order`) and get confirmation first.
2. **Sketch & Confirm Public Test Seams (`mattpocock/to-spec`)**:
   - Identify the highest public **seams** where the feature will be tested (prefer existing seams; ideal count is 1 per module).
   - State a 1-line note per seam on what it catches and what it misses, and confirm with the user.
3. **Draft the Unified Spec (`SPEC.md` or Tracker Issue)**:
   - Use `GLOSSARY.md` domain language throughout and respect `docs/adr/`.
   - Include all 6 mandatory sections:
     1. `Problem Statement & Solution` (user + maintainer perspective).
     2. `User Stories & Measurable Success Criteria` (`As an <actor>, I want <feature>, so that <benefit>` + quantitative targets).
     3. `Implementation Decisions & Module Interfaces` (modules modified, public interface contracts, schema changes, state machine/type shapes from any prototype - **omit brittle file paths and line numbers**).
     4. `Testing Decisions & Confirmed Seams` (agreed seams, behavioral test cases, prior art, and exact repo commands for `build`, `test`, `lint`).
     5. `Three-Tier Boundaries` (**Always do** / **Ask first** / **Never do**).
     6. `Out of Scope & Open Questions`.
4. **Approval Checkpoint**: Save `SPEC.md` (or publish with `ready-for-agent`), summarize key decisions, and pause for human approval before running `/tickets` or `/build` (unless in autonomous mode).

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"I'll list exact line numbers and 20 file paths in SPEC.md."* | Line numbers and internal file paths go stale after the first commit (`/to-spec`). Specify module interfaces, domain contracts, and seams instead. |

## Red Flags
- Writing tests or implementation code in the same turn before `SPEC.md` and its test seams are confirmed.

## Verification
- [ ] Public test seams are explicitly named with 1-line catch/miss notes.
- [ ] All 6 sections (`Problem/Solution`, `User Stories/Metrics`, `Interface Decisions`, `Testing Seams/Commands`, `3-Tier Boundaries`, `Out of Scope`) are present.
- [ ] Domain terms match `GLOSSARY.md`.
