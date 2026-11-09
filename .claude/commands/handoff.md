---
name: handoff
description: Package deterministic Seam state, verification proof, and Decision Trail entries for clean role or session handoff.
command: /handoff
version: 0.1.0
---

# Command: `/handoff` (Deterministic Seam & Role Handoff)

1. Reference `references/after-code-playbooks.md`.
2. Execute the mechanical verification suite to ensure the working tree is clean:
   ```bash
   python3 scripts/validate-lam.py && bash scripts/floor-guard.sh
   ```
3. Verify the highest completed Seam (`0..7`):
   ```bash
   bash scripts/seam-gate.sh check 7
   ```
4. Record a `HANDOFF` entry in `decisions.tsv` via `bash scripts/log-decision.sh` detailing the active Seam, completed Tracer-Bullet slices, and next verification target.
