---
name: prototype
description: Execute a time-boxed feasibility spike in an isolated spec worktree to extract verified seam signatures.
command: /prototype
version: 0.2.0
---

# Command: `/prototype` (Seam 3 Isolated Spec Worktree Spike)

1. Reference `references/before-code-playbooks.md` and `skills/lam-architect/SKILL.md`.
2. Spin up an isolated `spec` worktree:
   ```bash
   bash scripts/seam-gate.sh worktree spec <spike-slug>
   ```
3. Probe external library behavior or data-shape feasibility, extract the verified $M = R$ interface into `SPEC.md`, discard throwaway spike code when the worktree prunes, and log the finding via `bash scripts/log-decision.sh`.
