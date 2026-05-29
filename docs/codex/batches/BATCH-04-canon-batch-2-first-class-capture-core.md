# Batch 04 — Canon Batch 2 / First-Class Capture Core

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748, AMB28-stale_or_unknown_active_status-48393668

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Make capture a stable, first-class product system inside the app so later share extension, App Intent capture, memory intake, and triage automation can target one mature capture model safely.

## In Scope

- audit the current capture model/repository/service/UI state
- formalize capture states and state transitions
- implement or refine turn capture into goal
- implement or refine attach capture to existing goal
- add minimal capture-domain metadata needed for triage and revisit logic
- improve capture service/repository contracts only where needed
- add or update focused tests for capture state transitions, turn-into-goal, attach-to-goal, and persistence behavior

## Out Of Scope

- share extension
- App Intent capture
- voice capture
- automated capture triage beyond minimal stable rules
- planning engine v2
- recovery engine work
- time orchestration
- widgets / Live Activities
- sync
- life graph / household / device work
- large UI redesigns unrelated to capture core

## Current Repo Notes

- Existing capture foundations are already present and should be strengthened, not rebuilt:
  - `Capture`, `CaptureSourceType`, `CaptureRepository`, `DefaultCaptureService`, and SwiftData capture persistence exist.
  - Today quick capture already writes real captures.
  - The Capture surface is already routed through the app container and tab model.
  - Source types for notification, Share extension text/URL, and App Intent already exist as domain values, but those external intake surfaces remain out of scope for this batch.
- Legacy capture statuses may exist in persisted records or snapshots and should be normalized in repository mapping only.

## Exit Criteria

- canonical capture states and transitions are deterministic and covered by focused tests
- captures can be saved as seeds, archived, attached to an existing goal, or turned into a goal through service boundaries
- turn-into-goal reuses the existing goal creation path
- attach-to-goal validates against existing persisted goals
- minimal triage/revisit metadata round-trips through existing snapshot persistence
- build and targeted tests pass before this batch is marked completed

## Completion Note

Completed after XcodeGen generation, app build, targeted capture/persistence/Today/view-model tests, and the full AmbitionsTests unit suite passed on the available iPhone 17 simulator.

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
