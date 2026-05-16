# Ambitions Status Ledgers

Status: Active status ledger index  
Authority: Supporting only; subordinate to `docs/truth/*`

This directory records current repo status, cleanup decisions, implementation evidence posture, archive safety, generated-report classification, reference-dependency decisions, and one-time audit receipts. It is not product canon, implementation proof, release proof, or a substitute for live source inspection.

## Required read order

Before using any status ledger, read:

1. `../truth/README.md`
2. `../truth/IMPLEMENTATION_TRUTH.md`
3. `../truth/RELEASE_TRUTH.md`
4. `../truth/HISTORICAL_POLICY.md`

## Ledger roles

| Ledger | Owner role | Use for | Do not use for |
|---|---|---|---|
| `current-implementation-map.md` | Current source/implementation evidence map | Source-present, scaffolded, implemented-foundation, compatibility debt, and validation-dependent areas | Product vision, release proof, or historical cleanup decisions |
| `release-evidence-packet.md` | Release/proof posture | Validation evidence, release-claim boundaries, local proof requirements, and no-proof status | Product canon or source implementation claims beyond evidence |
| `cleanup-decision-register.md` | Cleanup decision ledger | Human cleanup decisions, direct cleanup receipts, classification decisions, and next cleanup steps | Current release proof or product truth |
| `archive-and-stale-material-ledger.md` | Archive/delete safety ledger | Stale material classification, archive/delete candidates, inbound-reference requirements, and destructive-change guardrails | Immediate deletion approval by itself |
| `archive-delete-candidate-register.md` | Phase 11 archive/delete candidate register | Current candidate-family table, inbound-reference result, replacement authority, stub need, and rollback rule | Archive/delete approval by itself |
| `reference-dependency-scan-cleanup-plan.md` | Reference-dependency cleanup plan | Current Phase 11 rules before archive/delete/move work | Proof that links are fully checked or that moves are safe |
| `repo-governance-master-cleanup-plan.md` | Cleanup train control plane | 22-item cleanup progress, phase status, direct-main policy, rollback expectations | Release readiness or build/test proof |
| `old-canon-classification-index.md` | Old canon family classification | Which old canon families are active, supporting, historical, quarantine, archive-candidate, or delete-candidate | Detailed content extraction or final archive/delete proof |
| `generated-report-classification.md` | Generated artifact classification | How generated `build/reports/*` artifacts should be read before deletion/archive decisions | Current source truth, current release proof, or deletion approval by itself |
| `train-b-historical-header-quarantine-receipt-2026-05-16.md` | One-time Train B receipt | Traceability for partial historical-header quarantine work | Living authority or proof that all old canon is physically patched |
| `train-c-active-surface-hygiene-receipt-2026-05-16.md` | One-time Train C receipt | Traceability for active surface hygiene/routing/scanner work | Living authority or proof that scanners were run locally |
| `train-d-reference-dependency-scan-receipt-2026-05-16.md` | One-time Train D Phase 11 receipt | Traceability for non-destructive reference-dependency scan and archive/delete block decisions | Archive/delete approval or full static-link proof |
| `codex-free-github-api-audit-2026-05-15.md` | One-time audit receipt | Traceability for the 2026-05-15 direct GitHub API audit and direct commits | Living authority or future cleanup status |

## Status label rules

- `Active` means the file is a current authority or live evidence owner for its limited scope.
- `Supporting` means useful context that cannot override `docs/truth/*`.
- `Historical` means retained for traceability only.
- `Quarantine` means retained but unsafe for default use until reconciled.
- `Archive-candidate` means movement may be appropriate after reference checks.
- `Delete-candidate` means deletion may be appropriate only after extraction, reference checks, and rollback planning.

## Release-claim boundary

No status ledger may claim build, test, simulator, device, TestFlight, App Store, accessibility, privacy, or release readiness unless current proof is linked and consistent with `../truth/RELEASE_TRUTH.md`.

## Cleanup operating rule

When a status file conflicts with active truth files, live source, or current proof:

1. `docs/truth/*` wins for truth hierarchy.
2. live source/project/test/script evidence wins for implementation facts.
3. current validation logs and release evidence win for readiness facts.
4. historical/audit/batch/prompt material loses unless explicitly promoted.

## Destructive-change rule

No archive/delete/move action is approved until `archive-delete-candidate-register.md` and `reference-dependency-scan-cleanup-plan.md` show inbound references, replacement authority, stub requirements, and rollback path for the selected family.
