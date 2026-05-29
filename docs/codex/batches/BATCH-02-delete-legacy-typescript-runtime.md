# Batch 02 — Delete Legacy TypeScript Runtime

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-42981412

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Remove any remaining legacy TypeScript / Expo / React Native runtime artifacts and stale backend/runtime docs so the repo truth is fully Swift-native and future Codex runs do not inherit dead-path assumptions.

## In Scope

- delete remaining legacy TS / Expo / React Native root/runtime files if present
- delete old node-based runtime scripts if present and truly unused
- remove stale backend/runtime docs that only supported the deleted path
- update `README.md` so it clearly states the repo is Swift-only
- update `docs/README.md` to remove deleted entries and stale references
- preserve all native app code paths, Swift packages, and current canon docs
- verify the repo truth now reflects native SwiftUI + XcodeGen only

## Out Of Scope

- any Batch 01 product/runtime changes
- domain foundation work
- capture enhancements beyond what already exists
- App Intents
- widgets / Live Activities
- sync
- planning/recovery/time-orchestration work
- any later canon batches

## Current Repo Notes

- The classic legacy root runtime files called out for deletion are already absent at the repo root.
- Batch 02 should therefore verify those absences, delete only the legacy/runtime artifacts that still remain, and clean up repo-truth references that still imply an active Expo/React Native/TypeScript runtime path.
- Native app code, Swift packages, canon docs, and iOS validation workflow must remain untouched except for truthful reference cleanup.

## Exit Criteria

- No active repo docs or control files imply a live TypeScript / Expo / React Native runtime path.
- Remaining legacy runtime artifacts are either deleted or explicitly justified as still needed.
- `README.md` and `docs/README.md` describe the repo as Swift-native / XcodeGen-driven.
- Native validation surfaces remain intact.

## Completion Note

- Batch 02 is complete as a bounded repo-truth pass.
- The live repo no longer carries root TypeScript / Expo runtime artifacts, and active docs already describe the project as Swift-native / XcodeGen-driven.
- Canon Batch 1 / Domain foundation is now the active implementation batch.

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
