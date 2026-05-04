# EB05 Capture Clusters Review Bundles And Open Loops Report

Date: 2026-05-03

Result: PASS WITH YELLOW

Starting HEAD: 008d9d7a

## Source Truth Read

- `docs/codex/batches/EB05_Capture_Clusters_Review_Bundles_And_Open_Loops_Prompt.md`
- `docs/canon/Ambitions_4_0_Universal_Capture_Kernel.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `Native/Ambitions/Domain/SmartAttachmentModels.swift`
- `Native/Ambitions/Services/SmartAttachmentService.swift`
- `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`

## Implementation Summary

EB05 completed as a bounded, non-persistent Smart Attachment review projection.
It adds computed capture cluster, review bundle, and open-loop signal
projections from the existing `SmartAttachmentResult` state.

The implementation does not create a new Capture surface, durable inbox,
memory, sync, account, cloud, calendar, or persistence behavior. The projection
is local, deterministic, and derived from existing route, clarification,
candidate, evidence-label, action, and safe-failure state.

## Files Changed

- `Native/Ambitions/Domain/SmartAttachmentModels.swift`
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`
- `docs/audits/eb05-capture-clusters-review-bundles-open-loops-report.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md`
- `scripts/global-train-next-batch.sh`

## Boundary Proof

- Production Swift touched: yes, bounded to Smart Attachment domain projection
  and focused tests.
- App behavior changed: no new UI, persistence, routing, networking, calendar,
  or top-level navigation behavior.
- Route/raw values changed: no.
- Persistence/schema changed: no.
- Dependencies changed: no.
- Workflow/signing/App Store/TestFlight files changed: no.

## Capture Cluster Proof

`SmartAttachmentCaptureCluster` groups a single current Smart Attachment result
by its safe local route state. Needs-a-place and clarification states group as
`Unplaced capture`; proof states group as `Proof candidate`; other placed
states group by existing route type.

## Review Bundle Proof

`SmartAttachmentReviewBundle` exposes the local review title, summary,
clusters, open-loop signals, action titles, and accessibility summary. It is a
computed projection on `SmartAttachmentResult` and is not persisted.

## Open Loop Proof

Open-loop signals are created only when existing result state already requires
review:

- Needs-a-place or clarification creates `Route needs a choice`.
- Suggested local attachments create `Suggested attachment available`.
- Safe failure creates `Capture kept safely`.

## Privacy And Trust Evidence

The review projection uses existing local Smart Attachment state. It does not
inspect external sources, create durable memory, write private data to a new
store, or hide inference. Suggested attachments preserve explicit user-choice
signals before placement.

## Accessibility Evidence

`SmartAttachmentReviewBundle.accessibilitySummary` summarizes bundle title,
open-loop count, and available actions without AI/model language. Focused tests
verify the ambiguous review bundle includes an open-loop count and avoids AI
wording.

## Preview / Screenshot Evidence

No new UI preview or screenshot was produced because EB05 changed a domain
projection only. Existing Capture preview lanes remain owned by DAV04/DAV12 and
EB03B. Future Capture Review UI must consume this projection or name a newer
owner seam.

## Validation Results

- `git diff --check`: PASS.
- Focused first run:
  `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/SmartAttachmentServiceTests | xcbeautify`:
  RED, 1 failing EB05 assertion. The route-review cluster used standalone
  selected evidence instead of suggested attachment evidence.
- Repair: changed `reviewBundle` cluster evidence preference to use
  `suggestedCandidate` evidence before selected standalone evidence.
- Focused rerun:
  `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/SmartAttachmentServiceTests | xcbeautify`:
  PASS, 16 tests, 0 failures.
- `swift build || true`: PASS.
- `scripts/build-local.sh`: PASS.
- `scripts/eb-active-train-integration-gate.sh || true`: PASS with existing
  source-truth matches.
- `scripts/eb-no-unsupported-claim-scan.sh || true`: Yellow, existing advisory
  backlog only.
- `scripts/eb-no-5-version-drift-scan.sh || true`: PASS/no output.
- `scripts/no-fake-proof-gate.sh || true`: Yellow, existing advisory backlog
  only.
- `scripts/canon-language-drift-scan.sh || true`: GREEN for changed files;
  existing backlog advisory remains.
- `scripts/release-claim-safety-scan.sh || true`: Yellow, existing advisory
  backlog only.

## Yellow Advisories

- No rendered screenshot, physical-device proof, human VoiceOver review,
  Instruments run, battery profile, public accessibility proof, TestFlight/App
  Store proof, or release-readiness proof was produced.
- Existing repo-wide claim/copy advisory backlog remains outside EB05.

## Red Issues Repaired

- Focused EB05 test initially failed because review-bundle cluster evidence
  preferred the standalone selected route evidence over suggested attachment
  evidence. Repaired inside `SmartAttachmentResult.reviewBundle` and reran the
  focused suite green.

## Rollback

Rollback scope is limited to:

- Remove `SmartAttachmentCaptureCluster`,
  `SmartAttachmentOpenLoopSignal`, `SmartAttachmentReviewBundle`, and
  `SmartAttachmentResult.reviewBundle` from
  `Native/Ambitions/Domain/SmartAttachmentModels.swift`.
- Remove EB05 tests from
  `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`.
- Revert EB05 run-state and train-status edits.

## Claim Boundaries

EB05 may claim a bounded local review projection exists for Smart Attachment
results after commit. It must not claim a user-facing Capture Review UI,
durable memory, full External Brain implementation, production readiness,
App Store/TestFlight readiness, physical-device proof, human accessibility
review, Instruments/battery proof, legal/privacy signoff, or release readiness.

## Next Eligible Batch

EB06 Capture Receipts Undo And Reclassification is next after EB05 is committed
and pushed.
