# Batch 10 — Canon Batch 7 / Ambient Surfaces Bundle

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Build the ambient surfaces bundle so notifications, widgets, Live Activities, and other glanceable surfaces consume the canonical external action pipeline and canonical Now State instead of carrying their own business logic.

## In Scope

- audit existing widget, Live Activity, notification, and shared snapshot seams
- harden notification action payloads so they route through the canonical command pipeline
- wire widgets to the canonical privacy-safe Now State snapshot
- wire Live Activity state to the same shared snapshot / command model where justified
- add or refine shared glanceable view models only if needed for existing widget/live-activity targets
- update shared URL / route generation if existing surface targets need the canonical payload format
- add/update focused tests for notification payload routing, snapshot compatibility, widget/live-activity data consumption, and backward-safe decode behavior
- keep all surface behavior powered by existing shared services and Batch 6 infrastructure

## Out Of Scope

- App Intents
- controls
- share extension UI
- sync
- life graph / household / device work
- broad UI redesign
- speculative new ambient product concepts not already supported by current targets
- new business logic living only inside widgets, notifications, or Live Activities

## Dependency Rules

- do not skip ahead
- no new surface-specific business logic
- widgets / Live Activities / notifications must consume the canonical command pipeline and canonical Now State
- strengthen existing widget/live-activity targets instead of creating parallel surface stacks
- keep shared snapshot privacy-safe
- prefer additive compatibility changes over schema breaks

## Current Repo Notes

- Batch 6 already added `ExternalActionCommandService`, deterministic route/payload normalization, and additive privacy-safe Now State fields.
- `project.yml` already defines `AmbitionsWidgetExtension`, and both app and widget targets already include the shared App Group entitlement.
- `NextStepWidget`, `NextStepLiveActivityWidget`, notification categories, and `SharedExternalSnapshotStore` already exist and should be hardened as consumers rather than replaced.
- App Intents and controls remain explicitly deferred; no interactive widget buttons should be added in this batch.

## Exit Criteria

- notification payloads are generated and parsed through a canonical privacy-safe payload shape while preserving old keys
- widget and Live Activity surfaces prefer `ExternalSurfaceSnapshot.nowState` when present and safely fall back to old `nextAction` snapshots
- widget and Live Activity URLs use shared route generation instead of local URL construction
- notification and widget payloads can flow through `ExternalActionCommandService` without `AppBootstrapper` owning bespoke action logic
- no App Intents, controls, sync, broad UI redesign, or new ambient product concepts are added
- generation, simulator build, targeted tests, and full `AmbitionsTests` validation pass before this batch is marked completed

## Completion Notes

- Added shared extension-safe payload and URL generation for ambient surfaces without including user-entered goal titles, capture text, notes, summaries, or detailed step text.
- Preserved legacy payload keys (`goalID`, `stepID`, `surface`, `tab`) while standardizing generated notification/widget payloads on the canonical command shape.
- Wired notification/widget payload handling through `ExternalActionCommandService` after normalization, without adding bespoke action execution logic to surface files.
- Updated widget and Live Activity consumption to prefer `ExternalSurfaceSnapshot.nowState` and safely fall back to legacy `nextAction` snapshots.
- Kept snapshot/activity changes additive and backward-decodable.
- Validation passed on `iPhone 17` simulator:
  - `xcodegen generate`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -sdk iphonesimulator -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/ExternalRoutingTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/ExternalActionCommandServiceTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/LocalNotificationFoundationTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/NotificationResponsePayloadParserTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests/ExternalSurfaceActionPayloadTests test`
  - `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=iPhone 17" -only-testing:AmbitionsTests test`

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
