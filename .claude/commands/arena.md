---
name: arena
description: Spawn isolated arena git worktrees for parallel peer model evaluation against a shared seam contract.
command: /arena
version: 0.2.0
---

# Command: `/arena` (Parallel Peer Worktree Arena)

1. Reference `references/before-code-playbooks.md` and assign competing `peer` model roles.
2. Create an isolated arena worktree that auto-prunes on exit:
   ```bash
   bash scripts/seam-gate.sh worktree arena <candidate-slug>
   ```
3. Evaluate competing Deep Module implementations using the `judge` role (`agents/reviewer.md` and `agents/test-engineer.md`) against identical DAMP public-seam tests.
4. Log the winning architecture in `decisions.tsv` via `bash scripts/log-decision.sh`.
