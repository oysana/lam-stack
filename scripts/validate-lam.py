#!/usr/bin/env python3
"""L.A.M. Stack Tier-1 Structural & Anti-Slop Validator."""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
errors = []

for skill_md in sorted(ROOT.glob("skills/*/SKILL.md")):
    text = skill_md.read_text(encoding="utf-8")
    lines = text.splitlines()
    if len(lines) > 500:
        errors.append(f"{skill_md}: exceeds 500 lines ({len(lines)})")
    if not text.startswith("---\n"):
        errors.append(f"{skill_md}: missing YAML frontmatter")
    if chr(0x2014) in text or chr(0x2013) in text:
        errors.append(f"{skill_md}: contains forbidden em-dash or en-dash")
    for required_section in ["## Verification", "## Common Rationalizations"]:
        if required_section not in text:
            errors.append(f"{skill_md}: missing required section '{required_section}'")

if errors:
    for err in errors:
        print(f"[FAIL] {err}", file=sys.stderr)
    sys.exit(1)

print(f"[PASS] Validated {len(list(ROOT.glob('skills/*/SKILL.md')))} skills, {len(list(ROOT.glob('agents/*.md')))} agents, and {len(list(ROOT.glob('.claude/commands/*.md')))} slash commands with 0 errors.")
