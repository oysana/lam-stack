---
name: lam-ship
description: Shapes unslopped visual PR bodies, runs the 6-gate /ship production launch audit (Code, Security/STRIDE/OWASP/LLM, Perf, A11y, Infra/Observability, Docs), manages Expand-Migrate-Contract DB/API migrations, and drives PR stacks to merge. Combines Matt Pocock's pr, Lauren Tan's opening-a-pr/unslop/babysit/shipping, and Addy Osmani's /ship, security-and-hardening, and deprecation-and-migration.
disable-model-invocation: true
---

# L.A.M. Ship (`/ship` + `pr` + `unslop` + `security-and-hardening` + `babysit`)

## Overview
Prepares clean commit stacks and visual Pull Requests (`pr` + `unslop`), executes the parallel 3-persona production readiness audit (`/ship`), enforces zero-downtime `Expand -> Migrate -> Contract` migrations, and drives PRs through CI and review threads (`babysit`).

## When to Use
- Opening a PR, auditing security/launch readiness (`/ship`), planning a DB/API migration, or driving a PR stack to merge (`babysit`).

## The Workflow
1. **Order Commit Stack & Shape Visual PR Body (`make-pr-easy-to-review` + `pr` + `unslop`)**:
   - Order commits (`Prefactor -> Schema/Types -> Core Logic + Seam Tests -> Wiring/UI`) so each commit passes tests.
   - Format the PR body using `GLOSSARY.md` nouns and `unslop` prose (zero em-dashes):
     - `## Why & Consumer Impact`: 1-2 sentences on user goal, consumer impact, and maintainer inheritance.
     - `## Summary`: Smallest visual (shaped diff, call tree, component tree, shallow file tree, or Mermaid diagram).
     - `## Evidence`: Before/After screenshots, test execution output, or 7-point vetted metrics.
     - `## Merge Danger`: **Door** (`Two-Way Door` vs. `One-Way Door`), **Blast Radius** (`Low/Medium/High` + rollback command), and **Noticed But Not Touching**.
2. **Parallel 3-Persona Pre-Launch Audit (`/ship`)**:
   - Fan out `standards-arch-reviewer`, `security-auditor` (STRIDE, OWASP Top 10 + LLM01-LLM10, symlink-resolved `realpath()` path containment, lockfile install-script gates, GDPR/CCPA lifecycle), and `test-engineer` in parallel.
   - Merge into a Go/No-Go verdict across all **6 Gates**: Code Quality, Security, Performance, Accessibility, Infrastructure/Observability, and Documentation (`GLOSSARY.md`, `SPEC.md`, `docs/adr/`, `CHANGELOG.md`).
3. **Zero-Downtime Migrations (`deprecation-and-migration`)**:
   - Execute DB/API changes across 5 separate deploys: `1. Expand -> 2. Dual-Write -> 3. Throttled Backfill (CREATE INDEX CONCURRENTLY) -> 4. Switch Reads -> 5. Contract (after 0% usage verified, with tested down migration)`.
4. **Canary Rollout, SLO Error Budget & Rollback Thresholds**:
   - Verify SLO Error Budget (>20% normal; 0-20% slow canary; 0% freeze).
   - Roll out: `Staging -> Prod (Flag OFF) -> Team (24h) -> Canary 5% -> 25% -> 50% -> 100% -> Remove flag <=2 weeks`.
   - **Immediate Rollback**: Error rate `>2x baseline`, P95 latency `>50% above baseline`, JS errors `>0.1% sessions`, or business metric drop `>5%`.
5. **PR Babysitting (`babysit`)**: Work the merge frontier in strict order: **1. Conflicts -> 2. Review threads (triage bots skeptically) -> 3. CI checks (`fix-ci`)**.

## Common Rationalizations
| Rationalization | Reality |
| :--- | :--- |
| *"We can rename the database column in one PR since our deploy only takes 30 seconds."* | In-place column renames break in-flight requests and block rollbacks (`deprecation-and-migration`). Always use `Expand -> Migrate -> Contract`. |

## Red Flags
- Opening a PR without `Before / After` runtime evidence or `One-Way / Two-Way Door` classification.
- Approving `/ship` with unresolved `Critical` or `High` security findings.

## Verification
- [ ] PR body contains `Why`, visual `Summary`, `Before/After Evidence`, and `Merge Danger (Door + Blast Radius)`.
- [ ] All 6 `/ship` Pre-Launch Gates are green and rollback commands (`<1 min` flag / `<5 min` redeploy) are documented.
