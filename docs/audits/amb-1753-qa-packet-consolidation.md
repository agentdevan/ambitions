# AMB-1753 QA Packet Consolidation Ledger

Status: first QA packet consolidation batch complete
Issue: AMB-1753
Parent: AMB-1680 Source Atlas Scope Freeze
Baseline: `main` at `29d9aba2243ef28023caa857501f526a2d44df5d`
Date: 2026-07-03

## Scope

This ledger records the first bounded consolidation batch for
`docs/qa/source-atlas/**`.

The batch deletes tracked Source Atlas QA packets only when they meet all of the
following criteria:

1. The path is tracked by git under `docs/qa/source-atlas/**`.
2. No non-`docs/qa/source-atlas/**` tracked repo file contains the exact path.
3. The path uses old date, train, or closeout naming.
4. The path is not in a protected sibling scope reserved for AMB-1754 or
   AMB-1755.

This ledger does not promote old QA packets to current release proof.

## Authority Boundary

Source Atlas remains public/reference/freshness infrastructure only. R2 is not a
user-data backend and must not receive goals, captures, calendar data, schedule
assumptions, proof, receipts, closure history, personalization, behavior
patterns, inferred priorities, private user context, or the private life graph.

Current release truth still blocks Source Atlas production readiness, R2
production readiness, privacy/legal approval, device proof, TestFlight
readiness, App Store readiness, and Release Green unless separate current
evidence proves those claims.

## Classification Method

The keep/delete split used tracked repo evidence only:

```bash
git ls-files 'docs/qa/source-atlas/**'
rg --no-heading -o "docs/qa/source-atlas/[A-Za-z0-9._~/%:+@=-]+" -g '!docs/qa/source-atlas/**' .
```

Summary before deletion:

| Class | Count | Decision |
|---|---:|---|
| Tracked Source Atlas QA files | 799 | Review under AMB-1753 and sibling leaves. |
| Exact non-QA repo references | 167 | Retain. |
| No exact non-QA repo reference | 632 | Candidate pool. |
| Protected sibling-scope or current-marker paths | 436 | Retain or defer. |
| Deleted in this batch | 196 | Delete as unreferenced historical QA packets. |

## Retained Current Ledger Set

The following classes are retained in this batch:

| Class | Reason |
|---|---|
| Exact paths referenced by non-`docs/qa/source-atlas/**` tracked files | Current source, script, test, generated-proof, or control-plane dependency. |
| `docs/qa/source-atlas/SOURCE_ATLAS_COVERAGE_LEDGER.md` and `docs/qa/source-atlas/source-atlas-coverage-ledger.json` | Current coverage roll-up emitted by retained tooling. |
| `docs/qa/source-atlas/2026-06-26-m09-validation-command-matrix.json` | Current default matrix for retained M09 validation tooling. |
| `docs/qa/source-atlas/2026-06-26-m09-validation-repair-closeout-ledger.md` | Current default ledger for retained M09 validation tooling. |
| Paths containing `current`, `ledger`, `live`, or `stable` | Retained until a later pass chooses a replacement current ledger or proves them obsolete. |
| `docs/qa/source-atlas/native/**` | Native refresh/test artifact references; retained. |
| `docs/qa/source-atlas/legal/**` | Legal/terms artifact references; retained. |
| `docs/qa/source-atlas/r2/**` and root paths containing `r2`, `production`, `release-proof`, `proof-refresh`, `readiness`, `privacy`, or `app-store` | Deferred to AMB-1755 R2 proof retention. |
| Paths containing `launch-floor` or `lff-` | Deferred to AMB-1754 launch-floor retention. |
| Paths containing `completion-audit` | Deferred to AMB-1754 / AMB-1755-adjacent proof retention because AMB-1752 intentionally retained related completion-audit generated outputs. |

## Deleted Batch

Deleted 196 tracked QA files from historical, unreferenced date/train/closeout
classes:

| Area | Count |
|---|---:|
| `docs/qa/source-atlas/` root historical packets | 76 |
| `docs/qa/source-atlas/domain-expansion/**` historical packets | 101 |
| `docs/qa/source-atlas/frontier/**` historical packets | 5 |
| `docs/qa/source-atlas/governance/**` historical packets | 14 |

The deleted batch intentionally excludes R2, legal, native, production,
release-proof, proof-refresh, readiness, privacy, app-store, launch-floor, LFF,
and completion-audit packets. Those are retained or deferred to sibling leaves
with explicit ownership.

## Follow-Up Boundaries

This pass leaves three cleanup classes to their explicit sibling leaves or later
proof-retention passes:

1. AMB-1754 will choose the retained launch-floor ledger/corpus set before
   deleting older launch-floor and completion-audit-adjacent artifacts.
2. AMB-1755 will preserve only current public/reference R2 proof artifacts before
   deleting stale R2 or production-readiness packets.
3. Any remaining exact non-QA-referenced QA path must be removed only after the
   current referencing source, script, generated proof, or test is updated or
   retired.

## Closeout Ceiling

This batch supports AMB-1753 as QA packet consolidation. It does not close
AMB-1680 by itself and does not prove production R2 behavior, Source Atlas
readiness, privacy/legal approval, device proof, accessibility proof, TestFlight
readiness, App Store readiness, or Release Green.
