---
name: interrogate
description: Spin up an isolated Interrogate Worktree to stress-test, mutate, and adversarially audit a candidate slice.
command: /interrogate
version: 0.2.1
---

# Command: `/interrogate` (Seam 6 Interrogate Worktree Audit)

1. Activate `skills/lam-review/SKILL.md`, `agents/reviewer.md`, and `agents/test-engineer.md` in the `judge` and `peer` roles.
2. Create a clean, isolated `Interrogate Worktree`:
   ```bash
   bash scripts/seam-gate.sh worktree interrogate <slice-slug>
   ```
3. Perform condition-inversion mutation checks and verify all 5 scenario categories (`Happy`, `Empty`, `Boundary`, `Error`, `Concurrency`).
4. Run `bash scripts/floor-guard.sh --self-test && bash scripts/floor-guard.sh` and record the verdict via `bash scripts/log-decision.sh`.
