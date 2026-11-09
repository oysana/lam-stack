---
name: lam-agents-root
description: Universal AGENTS.md entry contract for OpenCode, Codex, Devin, Antigravity, Cursor, and Claude Code running L.A.M. Stack v0.1.0.
version: 0.1.0
---

# AGENTS.md - L.A.M. Stack v0.1.0

Before starting any engineering task, read `SKILL.md` (`< 90` lines) -> `skills/lam-mode/SKILL.md` and route execution through the 7-Seam Artifact State Machine (`Seam 0` through `Seam 7`).

1. Load only the active Seam skill and reference playbook for the current stage.
2. Enforce `CONSTRAINTS.md`, `GLOSSARY.md`, and `SPEC.md`.
3. Verify `python3 scripts/validate-lam.py` and `bash scripts/floor-guard.sh` before declaring any task done.
