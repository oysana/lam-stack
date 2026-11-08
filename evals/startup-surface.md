# Startup surface measurement

What a harness reads before the first user message is the `name` and `description` frontmatter of every installed skill. We measure that surface as the byte count of each `SKILL.md` frontmatter block, counted 2026-11-08.

## Method

```bash
python3 - <<'EOF'
import re, glob, os

def desc_bytes(patterns):
    total, files, seen = 0, 0, set()
    for pat in patterns:
        for f in glob.glob(pat, recursive=True):
            f = os.path.realpath(f)
            if f in seen:
                continue
            seen.add(f)
            t = open(f, encoding="utf-8").read()
            files += 1
            m = re.match(r"^---\n(.*?)\n---\n", t, re.S)
            total += len((m.group(1) if m else t).encode("utf-8"))
    return files, total
EOF
```

## Raw counts

| Pack | Skill files | Frontmatter bytes | ~Tokens (4 B/tok) |
| --- | --- | --- | --- |
| L.A.M. Stack v0.2.1 | 14 (13 skills + root router) | 4,302 | ~1,075 |
| pstack (chhoumann/t3-pstack 2.2.8) | 66 | 17,849 | ~4,462 |
| mattpocock/skills | 39 | 7,952 | ~1,988 |
| addyosmani/agent-skills | 25 | 10,318 | ~2,579 |
| All three source packs combined | 130 | 36,119 | ~9,030 |

## What this does not measure

- Skill bodies load on demand, not at startup, so full-file size is excluded by design.
- Harness-specific overhead (agent definitions, hook injections, system prompts) is not counted.
- Token estimates use 4 bytes/token, a rough convention, not a tokenizer.
