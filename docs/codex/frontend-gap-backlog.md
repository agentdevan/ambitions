# Frontend Gap Backlog

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge, Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-80023145, AMB28-same_source_file_targeted_by_multiple_active_batches-28870643, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: active audit backlog
Source audit: `docs/audits/frontend/FRONTEND_GAP_REVIEW_2026-05-24.md`
Machine report: `build/reports/frontend_gap_review_2026-05-24.json`

This backlog is implementation routing, not implementation proof, release proof, accessibility proof, or flagship readiness.

## Ordered Batches

| Order | Batch | Scope | iOS 26 policy | Gates | Validation | Rollback |
|---:|---|---|---|---|---|---|
| 1 | `FRONTEND-PROOF-01` | Current screenshots and manual visual proof for Today, Goals, Capture, Time, You, shell. | Optional; existing iOS 26 chrome allowed, no new API required. | Red until screenshots are tied to commit, simulator, SDK, and non-claims. | `git diff --check`, `xcodebuild -list`, focused simulator screenshot workflow. | Delete new proof packet only. |
| 2 | `IOS26-GLASS-CHROME-QA-01` | Prove Liquid Glass chrome under standard, Reduce Transparency, Increased Contrast, Dynamic Type, VoiceOver. | Required for existing shared glass paths; no extra novelty APIs. | Red if `.glassEffect` paths lack rendered/accessibility proof. | focused design-system tests, screenshot pass, `git diff --check`. | Restore proof/report files; source rollback only if the batch changes code. |
| 3 | `TODAY-REALITY-MERIDIAN-PROOF-01` | Prove Reality Meridian, Start Here, Recommended step, Start now, Open step, receipts, rejection, replacement, closure. | Optional; direct root adoption forbidden until proof identifies a concrete need. | Red if recommendation/source/receipt path is unproven. | Today focused tests, screenshot matrix, accessibility traversal notes. | Restore Today-only changes/proof. |
| 4 | `TIME-LIFESHAPE-PROOF-01` | Prove LifeShape Field over calendar/dashboard; resolve `.plan` visual-context debt where safe. | Optional; consider only for LifeShape canvas/accessibility gains. | Red if Time still reads as card surface or calendar clone. | Time focused tests, screenshot matrix, stale-language scan. | Restore Time-only changes/proof. |
| 5 | `CAPTURE-ATMOSPHERE-COMPOSER-PROOF-01` | Prove idle, typing, route reveal, receipt, uncertain parse, error, Dynamic Type, Reduce Motion. | Optional; no adoption for novelty. | Red if route and receipt behavior is not product-proven. | Capture focused tests, screenshot matrix, receipt check. | Restore Capture-only changes/proof. |
| 6 | `GOALS-CONSTELLATION-ATLAS-PROOF-01` | Prove Constellation Atlas object-first shape; repair user-facing `Task` copy if confirmed. | Optional; use only for atlas fidelity or drilldown chrome. | Red if Goals remains panel stack or stale object language leaks. | Goals focused tests, stale-language scan, screenshot matrix. | Restore Goals-only changes/proof. |
| 7 | `YOU-SYSTEM-PROFILE-PROOF-01` | Prove grouped User System Profile, trust controls, reset/forget, accessibility lock posture. | Forbidden unless a concrete native settings/sheet improvement is identified. | Yellow until grouped navigation and trust controls have manual proof. | You focused tests, accessibility notes, screenshot matrix. | Restore You-only changes/proof. |
| 8 | `FRONTEND-RECEIPT-COVERAGE-01` | Convert control-plane receipt gaps into source/proof-backed receipt coverage for root actions. | Unreviewed; no iOS 26 requirement. | Red while root action receipts are missing or only control-plane listed. | `python3 scripts/ambitions-frontend-receipt-check.py`, focused root tests. | Restore receipt/proof-only changes. |
| 9 | `FRONTEND-ACCESSIBILITY-PROOF-01` | Manual VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, Reduce Transparency proof. | Existing iOS 26 glass must be included. | Red until manual proof exists; public claims remain locked. | focused simulator/manual proof, accessibility report. | Restore proof files only. |
| 10 | `FRONTEND-CONTROL-PLANE-HONESTY-01` | Repair generated surface language that says Green while proof is out of scope. | Not applicable. | Yellow until reports separate routing health from product proof. | frontend scripts, prompt audit. | Restore reports/control-plane files. |

## Green / Yellow / Red Gates

- Green requires source, current validation logs, current screenshots, accessibility notes, and receipt/proof evidence tied to the current commit.
- Yellow is acceptable for source-present work with scoped proof gaps and explicit non-claims.
- Red applies to source-present root surfaces without proof, stale top-level object language, generic dashboard/card/list regressions, missing receipts, or unproven iOS 26 chrome behavior.

## Proof Artifacts Required

- `docs/proof/frontend/<batch>/screenshots/**`
- `docs/proof/frontend/<batch>/manual-visual-review.md`
- `docs/proof/frontend/<batch>/accessibility-notes.md`
- `build/reports/<batch>.json`
- raw validation logs under `output/logs/` or `.codex/logs/`

## Non-Claims

This backlog does not claim flagship readiness, iOS 26 readiness, accessibility conformance, release readiness, current build success, current test success, device proof, TestFlight proof, App Store proof, performance proof, privacy/legal approval, or product completion.

STATUS: RED

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
