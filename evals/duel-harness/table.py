#!/usr/bin/env python3
"""Aggregate all *.grade.json under runs/ into a score table + per-arm means."""
import json, glob, statistics as st, sys

EVAL = "/tmp/opencode/lam-eval"
rows = []
for f in sorted(glob.glob(f"{EVAL}/runs/*.grade.json")):
    r = json.load(open(f))
    rows.append(r)

print(f"{'run':44} {'model':26} {'acc':>5} {'art':>4} {'pen':>4} {'comp':>6} {'oos':>3}")
for r in rows:
    print(f"{r['run_id']:44} {r['model']:26} {r['acceptance']['score']:>5} "
          f"{r['artifacts_score']:>4} {r['floor_penalty']:>4} {r['composite_pre_judge']:>6} "
          f"{len(r['out_of_scope']):>3}")

print("\narm means (composite_pre_judge):")
for arm in ["lam", "pstack", "pocock", "osmani"]:
    s = [r["composite_pre_judge"] for r in rows if r["arm"] == arm]
    if s:
        print(f"  {arm:8} n={len(s)} mean={st.mean(s):.3f}  runs={s}")
