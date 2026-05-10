<!-- markdownlint-disable MD013 -->

# Defect Regression Ledger

Status: Active defect-memory ledger  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/*` and current source/test evidence

This ledger defines how Codex records defects and recurrence prevention. It is
not proof that defects are fixed unless a row cites current evidence.

## 1. Defect Memory Rule

When Codex fixes or triages a bug, it must record enough context for a future
session to avoid repeating the failure: symptom, owner seam, cause, test/proof,
regression guard, and rollback.

## 2. Ledger Template

| ID | Date | Symptom | Owner seam | Root cause | Fix/proof | Regression guard | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| _none current_ | 2026-05-10 | Setup pass only | N/A | N/A | No app defect fixed in this pass | Future defects must add rows | template |

## 3. Required Fields

Every defect entry must include:

- stable ID
- date
- commit
- affected golden path
- affected primitive or source owner
- reproduction steps
- expected behavior
- actual behavior
- root cause or current hypothesis
- files changed
- tests/proof run
- recurrence guard
- remaining risk
- rollback path

## 4. Defect Categories

| Category | Examples | Required guard |
| --- | --- | --- |
| Product drift | obsolete IA, generic dashboard, fake certainty | truth/copy scan or product review |
| Visual regression | clipping, overlap, broken layout | screenshot/visual proof |
| Accessibility regression | VoiceOver, Dynamic Type, Reduce Motion, contrast | accessibility/motion gate |
| State regression | stale source, missing recovery, bad receipt | focused tests and source review |
| Performance regression | slow render, memory growth, scroll hitch | performance budget measurement |
| Build/test regression | compile failure, stale test, generated project mismatch | build/test command and owner seam |
| Privacy/trust regression | provider drift, hidden learning, silent mutation | privacy/trust scan and no-claim review |
| Release-claim regression | false readiness wording | forbidden-claim scan and release review |

## 5. Recurrence Prevention

A defect is not fully closed until one of these exists:

- focused test
- validation script
- visual proof comparison
- accessibility checklist
- performance budget measurement
- docs/process gate
- explicit owner-accepted reason no guard is possible

## 6. Red Conditions

Stop on:

- repeated bug without a new guard
- bug fix that changes unrelated behavior
- claim that a bug is fixed without reproduction or proof
- regression guard that depends on hosted CI, provider, backend, or release
  systems not approved by truth files

## 7. Phase 11 Gate Result

Phase 11 result: Green.

Validation:

- docs-only defect ledger template
- no app defect fixed or claimed fixed
- no app/source/runtime files touched

