#!/usr/bin/env python3
"""
L.A.M. Stack v0.2.0 - 3-Tier Architecture & Invariant Validator
Enforces:
  - Tier 1 (Structural & Unslop Invariants): Every SKILL.md, skills/*/SKILL.md,
            agents/*.md, references/*.md, and .claude/commands/*.md must be <=500 lines
            (and root SKILL.md <90 lines), contain zero em-dashes or en-dashes,
            include valid YAML frontmatter, and include ## Verification and
            ## Common Rationalizations in every skill.
  - Tier 2 (Manifest & Reference Integrity + Routing Collision Check): Verify every
            path in all 4 plugin.json manifests exists on disk and vice versa; verify
            every markdown file path referenced inside SKILL.md and skills/*/SKILL.md
            exists; verify no two skills have identical trigger phrases in their
            YAML description.
  - Tier 3 (Behavioral Execution Trace): Run bash scripts/floor-guard.sh --self-test,
            bash scripts/seam-gate.sh --self-test, and bash scripts/log-decision.sh
            on a temp TSV to verify formula-injection sanitization and TSV schema
            integrity.
"""

from __future__ import annotations

import glob
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

MANIFEST_PATHS = [
    "plugin.json",
    ".claude-plugin/plugin.json",
    ".cursor-plugin/plugin.json",
    ".codex-plugin/plugin.json",
]

MD_PATH_REGEX = re.compile(
    r"(?:`|\b)((?:skills/[a-zA-Z0-9_-]+/SKILL\.md|agents/[a-zA-Z0-9_-]+\.md|"
    r"references/[a-zA-Z0-9_-]+\.md|\.claude/commands/[a-zA-Z0-9_-]+\.md|"
    r"scripts/[a-zA-Z0-9_-]+\.(?:sh|py)|hooks/[a-zA-Z0-9_-]+\.(?:sh|json)|"
    r"CONSTRAINTS\.md|GLOSSARY\.md|SPEC\.md|SKILL\.md))(?:`|\b)"
)

SEMVER_REGEX = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$")


def strip_root_prefix(entry: str) -> str:
    return entry[2:] if entry.startswith("./") else entry


def manifest_paths(value: object) -> list[str]:
    if isinstance(value, str):
        return [value]
    if isinstance(value, dict):
        return [
            v["source"]
            for v in value.values()
            if isinstance(v, dict) and isinstance(v.get("source"), str)
        ]
    return [e for e in (value or []) if isinstance(e, str)]


def parse_frontmatter(text: str) -> dict[str, str] | None:
    if not text.startswith("---\n"):
        return None
    end_idx = text.find("\n---\n", 4)
    if end_idx == -1:
        return None
    block = text[4:end_idx]
    data: dict[str, str] = {}
    current_key: str | None = None
    for raw_line in block.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" in raw_line and not raw_line.startswith((" ", "\t")):
            key, val = raw_line.split(":", 1)
            current_key = key.strip()
            data[current_key] = val.strip().strip('"').strip("'")
        elif current_key:
            data[current_key] = (data[current_key] + " " + line).strip()
    return data


def run_tier_1(errors: list[str]) -> int:
    checked = 0
    skill_files = ["SKILL.md"] + sorted(
        str(Path(p).relative_to(ROOT))
        for p in glob.glob(str(ROOT / "skills" / "*" / "SKILL.md"))
    )
    agent_files = sorted(
        str(Path(p).relative_to(ROOT))
        for p in glob.glob(str(ROOT / "agents" / "*.md"))
    )
    ref_files = sorted(
        str(Path(p).relative_to(ROOT))
        for p in glob.glob(str(ROOT / "references" / "*.md"))
    )
    cmd_files = sorted(
        str(Path(p).relative_to(ROOT))
        for p in glob.glob(str(ROOT / ".claude" / "commands" / "*.md"))
    )
    contract_files = ["CONSTRAINTS.md", "GLOSSARY.md", "SPEC.md"]

    all_md = skill_files + agent_files + ref_files + cmd_files + contract_files
    for rel in all_md:
        fpath = ROOT / rel
        if not fpath.is_file():
            errors.append(f"[Tier 1] Missing required markdown file: {rel}")
            continue
        checked += 1
        content = fpath.read_text(encoding="utf-8")
        lines = content.splitlines()
        line_count = len(lines)
        if line_count > 500:
            errors.append(
                f"[Tier 1] {rel} exceeds 500-line ceiling ({line_count} lines)"
            )
        if rel == "SKILL.md" and line_count >= 90:
            errors.append(
                f"[Tier 1] Root SKILL.md must be <90 lines Two-Load router ({line_count} lines)"
            )
        if "\u2014" in content or "\u2013" in content:
            errors.append(
                f"[Tier 1] {rel} contains forbidden em-dash or en-dash characters"
            )
        fm = parse_frontmatter(content)
        if not fm or not fm.get("description"):
            errors.append(
                f"[Tier 1] {rel} is missing valid YAML frontmatter with description"
            )
        if rel in skill_files or rel in agent_files:
            if not fm or not fm.get("name"):
                errors.append(
                    f"[Tier 1] {rel} is missing 'name' in YAML frontmatter"
                )
        if rel in skill_files:
            if "## Verification" not in content:
                errors.append(
                    f"[Tier 1] Skill {rel} is missing required '## Verification' section"
                )
            if "## Common Rationalizations" not in content:
                errors.append(
                    f"[Tier 1] Skill {rel} is missing required '## Common Rationalizations' section"
                )

    return checked


def run_tier_2(errors: list[str]) -> int:
    checks = 0
    loaded_manifests: dict[str, dict] = {}
    for m_rel in MANIFEST_PATHS:
        m_path = ROOT / m_rel
        checks += 1
        if not m_path.is_file():
            errors.append(f"[Tier 2] Missing manifest file: {m_rel}")
            continue
        try:
            data = json.loads(m_path.read_text(encoding="utf-8"))
            loaded_manifests[m_rel] = data
        except Exception as exc:
            errors.append(f"[Tier 2] Invalid JSON in {m_rel}: {exc}")

    if "plugin.json" in loaded_manifests:
        canonical = loaded_manifests["plugin.json"]
        version = canonical.get("version")
        checks += 1
        if not isinstance(version, str) or not SEMVER_REGEX.match(version):
            errors.append(
                f"[Tier 2] plugin.json version must be semver, got {version!r}"
            )
        for ver_rel in ("SKILL.md", "AGENTS.md"):
            checks += 1
            ver_fm = parse_frontmatter((ROOT / ver_rel).read_text(encoding="utf-8"))
            fm_version = ver_fm.get("version") if ver_fm else None
            if fm_version != version:
                errors.append(
                    f"[Tier 2] {ver_rel} frontmatter version {fm_version!r} does not match plugin.json {version!r}"
                )
        for m_rel, data in loaded_manifests.items():
            checks += 1
            if data != canonical:
                errors.append(
                    f"[Tier 2] Manifest parity drift: {m_rel} does not match root plugin.json"
                )

        # 1. Verify skills in manifest <-> disk
        manifest_skills = {
            strip_root_prefix(e) for e in manifest_paths(canonical.get("skills"))
        }
        for s_entry in manifest_skills:
            checks += 1
            s_dir = ROOT / s_entry
            s_md = s_dir / "SKILL.md" if s_dir.is_dir() else ROOT / s_entry
            if not s_md.is_file():
                errors.append(
                    f"[Tier 2] Manifest skill '{s_entry}' missing on disk"
                )

        for disk_skill_md in sorted(glob.glob(str(ROOT / "skills" / "*" / "SKILL.md"))):
            checks += 1
            skill_dir_rel = str(Path(disk_skill_md).parent.relative_to(ROOT))
            skill_md_rel = str(Path(disk_skill_md).relative_to(ROOT))
            if skill_dir_rel not in manifest_skills and skill_md_rel not in manifest_skills:
                errors.append(
                    f"[Tier 2] Disk skill '{skill_dir_rel}' is not registered in plugin.json"
                )
            openai_yaml = Path(disk_skill_md).parent / "agents" / "openai.yaml"
            checks += 1
            if not openai_yaml.is_file():
                errors.append(
                    f"[Tier 2] Missing Codex/OpenCode agent binding '{openai_yaml.relative_to(ROOT)}'"
                )

        cursor_mdc = ROOT / ".cursor" / "rules" / "lam-mode.mdc"
        checks += 1
        if not cursor_mdc.is_file():
            errors.append(
                "[Tier 2] Missing Cursor rule file '.cursor/rules/lam-mode.mdc'"
            )

        # 2. Verify agents in manifest <-> disk
        manifest_agents = {
            strip_root_prefix(e) for e in manifest_paths(canonical.get("agents"))
        }
        for a_entry in manifest_agents:
            checks += 1
            if not (ROOT / a_entry).is_file():
                errors.append(
                    f"[Tier 2] Manifest agent '{a_entry}' missing on disk"
                )

        for disk_agent in sorted(glob.glob(str(ROOT / "agents" / "*.md"))):
            checks += 1
            a_rel = str(Path(disk_agent).relative_to(ROOT))
            if a_rel not in manifest_agents:
                errors.append(
                    f"[Tier 2] Disk agent '{a_rel}' is not registered in plugin.json"
                )

        # 3. Verify commands in manifest <-> disk (.claude/commands/*.md and .gemini/commands/*.toml)
        manifest_cmd_files: set[str] = set()
        manifest_cmd_dirs: list[str] = []
        for c_entry in (
            strip_root_prefix(e) for e in manifest_paths(canonical.get("commands"))
        ):
            checks += 1
            c_path = ROOT / c_entry
            if c_path.is_dir():
                manifest_cmd_dirs.append(c_entry.rstrip("/"))
                continue
            if not c_path.is_file():
                errors.append(
                    f"[Tier 2] Manifest command '{c_entry}' missing on disk"
                )
                continue
            manifest_cmd_files.add(c_entry)

        for disk_cmd in sorted(glob.glob(str(ROOT / ".claude" / "commands" / "*.md"))):
            checks += 1
            c_rel = str(Path(disk_cmd).relative_to(ROOT))
            if c_rel not in manifest_cmd_files and not any(
                c_rel.startswith(d + "/") for d in manifest_cmd_dirs
            ):
                errors.append(
                    f"[Tier 2] Disk command '{c_rel}' is not registered in plugin.json"
                )
            stem = Path(c_rel).stem
            gemini_toml = ROOT / ".gemini" / "commands" / f"{stem}.toml"
            checks += 1
            if not gemini_toml.is_file():
                errors.append(
                    f"[Tier 2] Missing Gemini CLI parity command '.gemini/commands/{stem}.toml'"
                )

    # Verify markdown references inside SKILL.md and skills/*/SKILL.md exist on disk
    skill_paths = ["SKILL.md"] + sorted(
        str(Path(p).relative_to(ROOT))
        for p in glob.glob(str(ROOT / "skills" / "*" / "SKILL.md"))
    )
    seen_descriptions: dict[str, str] = {}
    seen_triggers: dict[str, str] = {}

    for s_rel in skill_paths:
        s_file = ROOT / s_rel
        if not s_file.is_file():
            continue
        text = s_file.read_text(encoding="utf-8")
        for match in MD_PATH_REGEX.finditer(text):
            ref_target = match.group(1)
            checks += 1
            if not (ROOT / ref_target).exists():
                errors.append(
                    f"[Tier 2] {s_rel} references non-existent path '{ref_target}'"
                )

        fm = parse_frontmatter(text)
        if fm and fm.get("description"):
            desc = fm["description"].strip().lower()
            checks += 1
            if desc in seen_descriptions:
                errors.append(
                    f"[Tier 2] Routing collision: {s_rel} and {seen_descriptions[desc]} share identical description"
                )
            else:
                seen_descriptions[desc] = s_rel

            for phrase in re.findall(r"'([^']+)'|\"([^\"]+)\"", desc):
                trig = (phrase[0] or phrase[1]).strip()
                if len(trig) >= 3:
                    checks += 1
                    if trig in seen_triggers and seen_triggers[trig] != s_rel:
                        errors.append(
                            f"[Tier 2] Trigger collision on '{trig}' between {s_rel} and {seen_triggers[trig]}"
                        )
                    else:
                        seen_triggers[trig] = s_rel

    return checks


def run_tier_3(errors: list[str]) -> int:
    traces = 0

    # 1. floor-guard.sh --self-test
    traces += 1
    fg_res = subprocess.run(
        ["bash", str(ROOT / "scripts" / "floor-guard.sh"), "--self-test"],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    if fg_res.returncode != 0:
        errors.append(
            f"[Tier 3] floor-guard.sh --self-test failed (exit {fg_res.returncode}): {fg_res.stderr.strip()}"
        )

    # 2. seam-gate.sh --self-test
    traces += 1
    sg_res = subprocess.run(
        ["bash", str(ROOT / "scripts" / "seam-gate.sh"), "--self-test"],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    if sg_res.returncode != 0:
        errors.append(
            f"[Tier 3] seam-gate.sh --self-test failed (exit {sg_res.returncode}): {sg_res.stderr.strip()}"
        )

    # 3. log-decision.sh formula-injection sanitization & TSV schema check
    traces += 1
    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_tsv = Path(tmp_dir) / "test_decisions.tsv"
        ld_res = subprocess.run(
            [
                "bash",
                str(ROOT / "scripts" / "log-decision.sh"),
                str(tmp_tsv),
                "Seam-3",
                "=CMD|' /C calc'!A0",
                "judge",
                "@SUM(1+1) neutralized evidence",
                "VERIFIED",
            ],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
        )
        if ld_res.returncode != 0 or not tmp_tsv.is_file():
            errors.append(
                f"[Tier 3] log-decision.sh execution failed: {ld_res.stderr.strip()}"
            )
        else:
            rows = tmp_tsv.read_text(encoding="utf-8").splitlines()
            if len(rows) != 2:
                errors.append(
                    f"[Tier 3] Expected 2 lines in temp TSV (header + 1 row), got {len(rows)}"
                )
            else:
                header_cols = rows[0].split("\t")
                row_cols = rows[1].split("\t")
                if header_cols != [
                    "ts",
                    "phase",
                    "decision",
                    "why",
                    "evidence",
                    "result",
                ]:
                    errors.append(
                        f"[Tier 3] Invalid TSV header schema: {header_cols}"
                    )
                if len(row_cols) != 6:
                    errors.append(
                        f"[Tier 3] Invalid TSV row column count: {len(row_cols)}"
                    )
                elif not row_cols[2].startswith("'=") or not row_cols[4].startswith("'@"):
                    errors.append(
                        f"[Tier 3] Formula-injection payload was not neutralized: {row_cols}"
                    )

    return traces


def main() -> int:
    errors: list[str] = []
    t1_count = run_tier_1(errors)
    t2_count = run_tier_2(errors)
    t3_count = run_tier_3(errors)

    try:
        banner_version = json.loads((ROOT / "plugin.json").read_text(encoding="utf-8")).get("version", "?")
    except Exception:
        banner_version = "?"
    print(f"=== L.A.M. Stack v{banner_version} | 3-Tier Validator Suite ===")
    print(f"  Tier 1 (Structural & Unslop Invariants): {t1_count} artifacts inspected")
    print(f"  Tier 2 (Manifest Parity & Collision Check): {t2_count} path/routing assertions")
    print(f"  Tier 3 (Behavioral Execution Traces): {t3_count} runtime suites executed")

    if errors:
        print(f"\n[VALIDATE-LAM FAIL] {len(errors)} error(s) detected:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print("[VALIDATE-LAM PASS] All 3 validation tiers passed with 0 errors.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
