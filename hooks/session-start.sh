#!/usr/bin/env bash
# L.A.M. Stack SessionStart Hook (combines pstack-claude routing trigger + Addy Osmani JSON envelope)
set -euo pipefail

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "L.A.M. Stack is active. Whenever a task (1) touches >1 file or alters a module seam, (2) has underspecified requirements, or (3) debugs an unknown failure/perf bottleneck, load `skills/lam-mode/SKILL.md` and follow the 7-Seam Artifact State Machine."
  }
}
EOF
