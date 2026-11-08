---
name: lam-grill
description: Frontier requirement grilling and inline domain modeling combining Matt Pocock's /grill-with-docs (grilling + domain-modeling) with Addy Osmani's interview-me confidence scoring and Lauren Tan's prototype fork rule. Use when requirements are underspecified or ambiguous.
---

# L.A.M. Frontier Grill & Domain Modeling (`grilling` + `interview-me` + `domain-modeling`)

## Overview
Extracts what the user actually wants with minimum turn overhead by combining Addy Osmani's upfront `HYPOTHESIS + CONFIDENCE %` and anti-buzzword probing with Matt Pocock's round-based **Decision Tree Frontier** and inline `GLOSSARY.md` + 3-Gate `ADR` updates.

## When to Use
- Underspecified feature requests ("build me X"), ambiguous edge cases, or fuzzy domain terminology.
- User says "grill me", "interview me", "stress-test my plan", or `/grill`.

## The Workflow
1. **State Initial Hypothesis & Confidence (`interview-me`)**:
   - Output `HYPOTHESIS: <1-sentence summary of underlying intent and why now>`
   - Output `CONFIDENCE: ~X% - missing: <unsettled branches if <95%>`
2. **Filter Out Facts & Empirical Forks (`pstack` + `grilling`)**:
   - Never ask the user a fact you can look up in the repo or docs; dispatch a fresh-context subagent immediately.
   - If a question is an empirical fork (UI layout feel, timing, state ergonomics), route that branch to `lam-prototype` instead of debating in prose.
3. **Ask the Unsettled Frontier in Numbered Rounds (`grilling`)**:
   - Map product/design decisions as a tree. The **frontier** is every question whose prerequisites are already settled.
   - Ask all current frontier questions in a single numbered round (`Q1`, `Q2`...), attaching a concrete recommended answer to each so `"yes"` approves the entire round:
     ```markdown
     Q1 - <Question Title>: <Focused question + concrete trade-offs>
     -> Recommended: <Recommended choice + 1-line rationale/guess>
     ```
   - **Want vs. Should Want Probe (`interview-me`)**: When the user replies with convention-signaling buzzwords ("make it enterprise/scalable/clean"), ask once: *"If you didn't have to justify this to anyone, what behavior would you actually want today?"*
4. **Update `GLOSSARY.md` & 3-Gate ADRs Inline (`domain-modeling`)**:
   - Challenge overloaded terms immediately against `GLOSSARY.md` and existing code.
   - Update `GLOSSARY.md` inline (pure domain terms, relationships, and `_Avoid:_` synonyms; zero implementation details).
   - Offer `docs/adr/NNNN-slug.md` **only** when all 3 gates hold: (1) Hard to reverse, (2) Surprising without context, (3) Result of a real trade-off.
5. **95% Confidence 6-Line Intent Lock**:
   - Once the frontier is empty (>=95% confidence), restate the 6-line contract: `Outcome | User | Why now | Success criteria | Constraints | Out of scope` and pause for explicit confirmation before coding.

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"I'll ask 10 questions one per message."* | Serial 1-by-1 questions waste 10 turns when 4 independent frontier branches can be answered in 1 round with recommended defaults. |
| *"I'll put database column types and file paths in GLOSSARY.md."* | `GLOSSARY.md` is strictly for domain language (`Customer`, `Subscription`, `Invoice`), never implementation details. |

## Red Flags
- Asking a question without a `-> Recommended:` default attached.
- Asking the user what framework or test runner the repo uses instead of checking `package.json`.

## Verification
- [ ] Turn 1 stated explicit `HYPOTHESIS` and `CONFIDENCE %`.
- [ ] Every question carried a concrete `-> Recommended:` answer.
- [ ] `GLOSSARY.md` (and `docs/adr/` if 3 gates passed) was updated inline.
- [ ] Confirmed 6-line Intent Lock (`Outcome / User / Why now / Success / Constraints / Out of scope`) before writing specs or code.
