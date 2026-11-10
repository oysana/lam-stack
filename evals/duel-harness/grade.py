#!/usr/bin/env python3
"""Deterministic grader: grade.py <workdir> <taskdir> <meta.json> <out.json>

Scores the candidate's working tree against the frozen task spec:
- hidden acceptance tests (copied in post-run, run alone under node --test)
- the candidate's own spec-required test file (exists and passes)
- floor-guard rule classes scanned over added diff lines
- scope and diff-size budgets
Produces composite_pre_judge; the judge pass adds the rubric score later.
"""
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

FLOOR_RULES = [
    ("SUPPRESSION_DIRECTIVE", r"(@ts-ignore|@ts-expect-error|eslint-disable|biome-ignore|# noqa|# type: ignore|istanbul ignore|Stryker disable|nosemgrep|gitleaks:allow)"),
    ("TYPE_ESCAPE", r"(as\s+any([^a-zA-Z0-9_]|$)|as\s+unknown\s+as)"),
    ("FOCUSED_OR_SKIPPED_TEST", r"(\.(skip|only|todo)\s*\(|\b(xit|fdescribe)\s*\(|@pytest\.mark\.skip)"),
    ("UNIMPLEMENTED_STUB", r"(throw\s+new\s+Error\(['\"]not implemented['\"]\)|NotImplementedError|todo!\(\)|unimplemented!\(\))"),
    ("SILENT_ERROR_SWALLOW", r"(catch\s*(\([^)]*\))?\s*\{\s*\}|except[^:]*:\s*pass)"),
    ("DEBUG_LEFTOVER", r"(\[DEBUG-[0-9a-zA-Z_-]+\]|\bdebugger\s*;?|console\.log\s*\()"),
    ("LEAKED_CREDENTIAL", r"(AKIA[0-9A-Z]{16}|ghp_[0-9a-zA-Z]{36}|BEGIN (RSA|OPENSSH|EC|PGP) PRIVATE KEY|(api_key|secret_key|access_token)\s*[:=]\s*['\"][A-Za-z0-9_\-]{20,}['\"])"),
]

SCAFFOLD_PREFIXES = (".pack/", "opencode.json", ".opencode", ".xdg", ".devin/")


def git(wd: Path, *args: str) -> str:
    return subprocess.run(
        ["git", "-C", str(wd), *args], capture_output=True, text=True
    ).stdout


def run_tests(wd: Path, test_path: str) -> dict:
    p = subprocess.run(
        ["node", "--test", test_path],
        cwd=str(wd), capture_output=True, text=True, timeout=120,
    )
    text = p.stdout + p.stderr
    passed = sum(int(m.group(1)) for m in re.finditer(r"(?:#|ℹ)\s*pass\s+(\d+)", text))
    failed = sum(int(m.group(1)) for m in re.finditer(r"(?:#|ℹ)\s*fail\s+(\d+)", text))
    if passed == 0 and failed == 0:
        # no summary matched: count TAP result lines
        passed = len(re.findall(r"^(?:ok|✔) \d+", text, re.M)) or len(re.findall(r"^ok ", text, re.M))
        failed = len(re.findall(r"^not ok ", text, re.M))
    return {"pass": passed, "fail": failed, "rc": p.returncode}


def main() -> int:
    workdir, taskdir, meta_path, out_path = map(Path, sys.argv[1:5])
    meta = json.loads(meta_path.read_text())
    spec = json.loads((taskdir / "spec.json").read_text())
    fixture = meta["fixture"]
    allowed = spec["allowed_paths"]

    diff = git(workdir, "diff", fixture, "--", *allowed)
    full_diff_files = [
        l.split("\t")[2] if l.split("\t")[0].startswith("R") else l.split("\t")[1]
        for l in git(workdir, "diff", "--name-status", fixture).splitlines() if l.strip()
    ]
    out_of_scope = [f for f in full_diff_files if not any(f.startswith(a) for a in allowed)]

    untracked = [
        l[3:] for l in git(workdir, "status", "--porcelain").splitlines()
        if l.startswith("??")
    ]
    stray = [
        f for f in untracked
        if not f.startswith(SCAFFOLD_PREFIXES)
        and not any(f.startswith(a) for a in allowed)
    ]
    out_of_scope += stray

    # hidden acceptance suite
    acc_target = workdir / "extension" / f"__acc_{spec['id']}.test.mjs"
    shutil.copy(taskdir / "acceptance.test.mjs", acc_target)
    acc = run_tests(workdir, f"extension/__acc_{spec['id']}.test.mjs")
    acc_total = acc["pass"] + acc["fail"]
    acc_score = round(10.0 * acc["pass"] / acc_total, 3) if acc_total else 0.0

    # candidate's own required test file(s)
    own_points = 0
    own_details = []
    for art in spec["required_artifacts"]:
        ap = workdir / art["path"]
        ok = ap.is_file()
        detail = {"path": art["path"], "exists": ok}
        if ok and art["kind"] == "own_test":
            r = run_tests(workdir, art["path"])
            detail.update(r)
            if r["pass"] > 0 and r["fail"] == 0:
                own_points += art["points"]
        own_details.append(detail)

    # floor scan on added lines of code files in scope
    violations = []
    current_file = ""
    for line in diff.splitlines():
        if line.startswith("+++ b/"):
            current_file = line[6:]
            continue
        if not line.startswith("+") or line.startswith("+++"):
            continue
        if current_file.endswith(".md"):
            continue
        added = line[1:]
        for name, pat in FLOOR_RULES:
            if re.search(pat, added) and name not in violations:
                violations.append(name)

    ins = sum(1 for l in diff.splitlines() if l.startswith("+") and not l.startswith("+++"))
    dels = sum(1 for l in diff.splitlines() if l.startswith("-") and not l.startswith("---"))
    size_ok = (ins + dels) <= spec["diff_size_budget_lines"]
    in_scope = not out_of_scope

    artifacts_score = own_points + (1 if in_scope else 0) + (1 if size_ok else 0)
    penalty = min(6, 2 * len(violations))
    composite = acc_score + artifacts_score - penalty

    result = {
        "run_id": meta["run_id"], "arm": meta["arm"], "task": meta["task"],
        "model": meta["model"], "seed": meta["seed"],
        "duration_s": meta["duration_s"], "timed_out": meta["timed_out"],
        "run_rc": meta["run_rc"],
        "acceptance": {"pass": acc["pass"], "fail": acc["fail"], "score": acc_score},
        "own_artifacts": own_details,
        "artifacts_score": artifacts_score,
        "floor_violations": violations,
        "floor_penalty": penalty,
        "diffstat": {"ins": ins, "del": dels},
        "out_of_scope": out_of_scope,
        "composite_pre_judge": round(composite, 3),
    }
    out_path.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    sys.exit(main())
