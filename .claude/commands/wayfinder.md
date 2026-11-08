---
name: wayfinder
description: Run structured Frontier Rounds at Seam 0 and Seam 1 to burn down ambiguity and lock GLOSSARY.md.
command: /wayfinder
version: 0.2.0
---

# Command: `/wayfinder` (Seam 0 & Seam 1 Frontier Round Discovery)

1. Reference `references/before-code-playbooks.md` and `agents/architect.md`.
2. Run `worker` reconnaissance on the live repository (`Seam 0: Code Anchor`).
3. Conduct structured `Frontier Rounds` across four orthogonal axes:
   - Axis A: Domain Scope & Ubiquitous Language (`GLOSSARY.md`).
   - Axis B: Polyglot $M = R$ Data Shapes (`references/principles-and-vocabulary.md`).
   - Axis C: Failure Modes (`Empty`, `Boundary`, `Error`, `Concurrency`).
   - Axis D: Mechanical Quality Floor (`CONSTRAINTS.md`).
4. Verify `bash scripts/seam-gate.sh check 2` and log the baseline in `decisions.tsv`.
