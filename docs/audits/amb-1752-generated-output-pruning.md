# AMB-1752 Generated Output Pruning Ledger

Status: first bounded pruning batch complete
Issue: AMB-1752
Parent: AMB-1680 Source Atlas Scope Freeze
Baseline: `main` at `e17599dd5a4799c3de23f22c06b0ed46a996017b`
Date: 2026-07-03

## Scope

This ledger records the first bounded deletion batch for generated Source Atlas
outputs under `tools/source-atlas/generated/**`.

The batch is intentionally conservative. It deletes only tracked generated files
that have no non-generated repo references and are not app resources, native
test fixtures, current proof packet dependencies, or current release evidence.

This ledger does not promote generated proof to current release proof.

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
git ls-files 'tools/source-atlas/generated/**'
rg --no-heading -o "tools/source-atlas/generated/[A-Za-z0-9._~/%:+@=-]+" -g '!tools/source-atlas/generated/**' .
rg -n "lff-m02-l02-current|lff-m02-schema-gate-current|source-atlas-completion-audit" -g '!tools/source-atlas/generated/**' .
```

Summary before deletion:

| Class | Count | Decision |
|---|---:|---|
| Tracked generated files | 2,855 | Review under AMB-1752 and follow-up leaves. |
| Kept by non-generated reference | 2,804 | Retain for now; many are referenced by QA packets, tooling, native resources, or native tests. |
| No non-generated repo reference | 51 | Candidate set; launch-floor-specific outputs deferred to AMB-1754 except the stale completion-audit batch below. |

## Keep Allowlist

The following generated classes are retained in this batch:

| Class | Reason |
|---|---|
| Files referenced by `Native/**` source, resources, or tests | Current source/test/resource dependency. |
| Files referenced by `tools/source-atlas/**` retained tooling or tests | Current tooling/test dependency. |
| Files referenced by `docs/qa/source-atlas/**` | Defer until AMB-1753 consolidates QA packets so tracked docs do not point at deleted artifacts. |
| `tools/source-atlas/generated/source-atlas-completion-audit/lff-m00-current/**` | Referenced by current QA packet `source-atlas-completion-audit-lff-m00`. |
| `tools/source-atlas/generated/source-atlas-completion-audit/lff-m01-current/**` | Referenced by current QA packet `source-atlas-completion-audit-lff-m01`. |
| `tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-l03-current/**` | Referenced by current QA packet `source-atlas-completion-audit-lff-m02`. |
| `tools/source-atlas/generated/source-atlas-completion-audit/train-129-current/**` | Referenced by retained Train 129 QA packet and broad launch-floor audit. |
| `tools/source-atlas/generated/source-atlas-completion-audit/train-131-tetradeca-final/**` | Referenced by retained Train 131 QA packet and broad launch-floor audit. |
| `tools/source-atlas/generated/source-atlas-completion-audit/train-132-current/**` | Referenced by retained Train 132 QA packet and broad launch-floor audit. |
| `tools/source-atlas/generated/source-atlas-launch-floor-ledger/**` | Deferred to AMB-1754 launch-floor retention pass. |
| `tools/source-atlas/generated/source-atlas-launch-floor-golden-intent-corpus/**` | Deferred to AMB-1754 launch-floor retention pass. |
| R2 production, publisher, live inventory, owner approval, and readback generated outputs | Deferred to AMB-1755 R2 proof retention pass unless already required by Native resources/tests. |

## Deleted Batch

Deleted 10 tracked generated files from two stale completion-audit variants with
no non-generated repo references:

```text
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-l02-current/closeout.md
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-l02-current/completion-requirements.json
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-l02-current/next-work-queue.json
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-l02-current/source-atlas-completion-audit-report.json
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-l02-current/source-atlas-completion-audit-report.md
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-schema-gate-current/closeout.md
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-schema-gate-current/completion-requirements.json
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-schema-gate-current/next-work-queue.json
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-schema-gate-current/source-atlas-completion-audit-report.json
tools/source-atlas/generated/source-atlas-completion-audit/lff-m02-schema-gate-current/source-atlas-completion-audit-report.md
```

The retained `lff-m02-l03-current` completion-audit output remains the current
referenced LFF M02 completion-audit packet for the tracked QA ledger.

## Follow-Up Boundaries

This pass intentionally leaves three cleanup classes to their explicit sibling
leaves:

1. AMB-1753 will consolidate `docs/qa/source-atlas/**` before deleting generated
   outputs referenced only by stale QA packets.
2. AMB-1754 will choose the retained launch-floor ledger/corpus set before
   deleting older launch-floor generated outputs.
3. AMB-1755 will preserve only current public/reference R2 proof artifacts before
   deleting stale R2 production-readiness packets.

## Closeout Ceiling

This batch supports AMB-1752 as a generated-output pruning step. It does not
close AMB-1680 by itself and does not prove production R2 behavior, Source Atlas
readiness, privacy/legal approval, device proof, accessibility proof, TestFlight
readiness, App Store readiness, or Release Green.
