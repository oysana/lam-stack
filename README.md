# L.A.M. Stack Plugin (Lauren Tan `pstack` + Addy Osmani `agent-skills` + Matt Pocock `skills`)

A unified, zero-conflict engineering plugin for **Claude Code**, **Cursor**, **OpenAI Codex**, **Gemini CLI**, and **OpenCode**.

## Install & Usage Across Harnesses

- **Claude Code**: Copy or clone this directory and run `/plugin add ./lam-stack-plugin`, or copy `.claude/commands/`, `skills/`, `agents/`, and `hooks/` into your project. Invoke `/lam`, `/grill`, `/spec`, `/constraints`, `/architect`, `/tickets`, `/build`, `/debug`, `/perf`, `/review`, `/ship`, or `/retro`.
- **Cursor**: Copy `skills/` to `.cursor/skills/` and `.cursor/rules/lam-mode.mdc` to `.cursor/rules/`.
- **OpenAI Codex**: Copy `.codex-plugin/` and `skills/` into `.agents/skills/`.
- **Gemini CLI**: Copy `.gemini/commands/*.toml` and `skills/` into `.gemini/`.
- **Validate Structure**: Run `python3 scripts/validate-lam.py` and `bash scripts/floor-guard.sh`.
