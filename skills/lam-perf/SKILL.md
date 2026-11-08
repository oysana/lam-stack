---
name: lam-perf
description: Scientific performance optimization and metric hillclimbing combining Lauren Tan's perf-issue, hillclimb, and 7-point benchmark-checklist with Addy Osmani's performance-optimization (/webperf) and web-performance-auditor.
---

# L.A.M. Performance & Hillclimb (`perf-issue` + `hillclimb` + `benchmark-checklist` + `/webperf`)

## Overview
Eliminates placebo optimizations by vetting every measurement against Lauren Tan's 7-point `benchmark-checklist`, walking the 7 performance mantras in order, enforcing Addy Osmani's strict **Keep or Revert** rule, and logging every experiment in `decisions.tsv` / `PERF.md`.

## When to Use
- Slow endpoints/queries, Core Web Vitals regressions (`LCP <= 2.5s`, `INP <= 200ms`, `CLS <= 0.1`), memory/CPU bottlenecks, or sustained metric hillclimbing.

## The Workflow
1. **Measure Baseline & Vet with the 7-Point Benchmark Checklist (`principle-explain-the-number`)**:
   - Capture baseline (DevTools Perfetto trace / Lighthouse / CrUX for frontend; `EXPLAIN ANALYZE` for DB; CPU/heap profile for backend).
   - Answer all 7 questions before trusting any number: (1) What physical/resource limiter stops it from being 2x faster? (2) Is the baseline tuned? (3) Distance to hardware/network limit? (4) Zero silent errors/skipped work? (5) Reproducible across >=5 interleaved runs (median + spread)? (6) Reflects end-to-end user wall time? (7) Only target work inside timed region?
2. **Apply the 7 Performance Mantras in Order (`pstack`)**:
   1. *Don't do it* -> 2. *Don't do it again* (`loadOnce` coalescing, tenant-safe cache keys) -> 3. *Do it less* (eliminate N+1s, paginate, composite/partial indexes proven via `EXPLAIN ANALYZE`) -> 4. *Do it later* (code-split, lazy load, `fetchpriority="high"` on LCP) -> 5. *Do it when not looking* (`scheduler.yield()` on >50ms tasks, background queues) -> 6. *Do it concurrently* -> 7. *Do it cheaper*.
3. **One-Variable Loop & Strict Keep/Revert Rule (`hillclimb` + `PERF.md`)**:
   - Test one change at a time under identical conditions.
   - **Keep**: Commit atomically only if the gain exceeds run-to-run variance and all tests pass.
   - **Revert**: Immediately revert if within noise (neutral), worse, or if a new DB index fails to improve `EXPLAIN ANALYZE`.
   - Record every kept and reverted attempt via `bash scripts/log-decision.sh` into `decisions.tsv` (and `PERF.md`).

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"This memoization / DB index didn't hurt, so I'll keep it even though timings didn't move."* | Neutral changes within noise add maintenance and write-overhead debt (`performance-optimization`). Revert neutral changes and log them in `PERF.md`. |

## Red Flags
- Reporting a single-run timing without run count, spread/variance, or limiter explanation.
- Inventing synthetic metrics in static analysis mode (violates `Metric-Honesty Rule`).

## Verification
- [ ] Baseline and post-fix numbers pass all 7 `benchmark-checklist` gates across >=5 interleaved runs.
- [ ] Neutral/failed experiments were reverted and logged in `decisions.tsv` / `PERF.md`.
