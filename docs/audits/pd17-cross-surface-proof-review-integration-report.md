# PD17 Cross-Surface Proof and Review Integration Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: Product Depth
Batch ID: PD17

## Result

PD17 completed as a bounded Product Depth implementation batch. You/Profile now
includes a cross-surface proof and review map inside Receipts & History so the
user can see how Capture, Today, Goals, Plan, and You relate through proof,
receipts, and review boundaries without creating a new dashboard, feed, tab, or
runtime automation layer.

## Files Read

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/batches/PD17_Cross_Surface_Proof_And_Review_Integration_Prompt.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileTrustHistoryCenterCard.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`

## Files Changed

- `Native/Ambitions/Domain/ProfileCrossSurfaceProofReviewModels.swift`
- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/ProfileCrossSurfaceProofReviewCard.swift`
- `Native/Ambitions/Features/Profile/ProfileCrossSurfaceProofReviewProjector.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`
- `docs/audits/pd17-cross-surface-proof-review-integration-report.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Implementation Summary

- Added typed `ProfileCrossSurfaceProofReviewState` and item models.
- Added a deterministic projector that summarizes Capture-to-Goal proof, Today
  completion proof, Plan reflow receipts, Goal changes in You history, receipt
  detail routing, and sparse review prompts from existing local repositories.
- Added a You/Profile card inside the Receipts & History detail sheet instead
  of adding a new route, tab, raw log, or dashboard.
- Added a focused Profile service test proving the cross-surface map preserves
  owning-surface review, proof-as-evidence language, receipt-not-feed posture,
  and forbidden-copy boundaries.

## Product Decisions Preserved

- Top-level tabs remain `Today / Goals / Capture / Plan / You`.
- You remains the Personal System Center; Profile remains an internal
  compatibility seam.
- Proof remains evidence, never a reward.
- Receipts remain consequence/review posture, not notification-feed posture.
- Source review remains freshness/conflict/review posture, not AI
  certification.
- Capture, Today, Goals, and Plan retain ownership of their own review flows;
  PD17 only summarizes where review belongs.

## Caveats Preserved

- PD17 does not implement AOS runtime, LDI runtime, sync, persistence/schema,
  route/raw-value changes, hidden proof mutation, or deep-link routing.
- Receipt/detail navigation is represented as an owning-surface review boundary,
  not a new navigation stack.
- User-facing copy remediation remains staged.
- Existing large Profile files remain a maintainability advisory; PD17 added
  small extracted model/projector/card files and touched the larger service and
  screen narrowly.
- Product Depth is not complete until PD18 closes.
- Public accessibility conformance, physical-device proof, TestFlight
  readiness, App Store readiness, legal/privacy compliance, and release
  readiness remain unclaimed.

## Candidate Items

No Candidate items were finalized. PD17 did not promote future source-review,
receipt-navigation, AOS proof, LDI runtime, or global proof-mesh behavior beyond
the named Product Depth scope.

## Conflicts Found

No unrecoverable conflicts. The known Product Experience Pack caveats remain:

- Accent taxonomy/default mismatch remains Yellow and out of scope.
- MissionControlTimeSpine order was not changed.
- User-facing copy remediation remains staged.
- Month LifeShape calendar-clone risk was not touched.

## Validation

Commands run:

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `xcodegen generate`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ProfileFeatureServiceTests`
- `scripts/build-local.sh`
- `git diff --check`
- Product Depth touched-path copy/product-drift/release scan
- Touched-doc trailing whitespace scan
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Repair loop:

- Initial touched-path copy scan found one new visible label using the
  forbidden `achievement` concept as a contrast phrase.
- The copy was repaired in scope to `Evidence, not a prize`.
- The focused Profile service lane and local build were rerun after repair.

Focused result:

- `ProfileFeatureServiceTests`: 23 tests, 0 failures.

Build result:

- `scripts/build-local.sh`: PASS.

Additional validation:

- `git diff --check`: PASS.
- Product Depth touched-path copy/product-drift/release scan: PASS WITH YELLOW.
  Hits are existing internal compatibility names, existing test guard
  assertions, and explicit no-claim guardrails; the new user-facing forbidden
  copy hit was repaired.
- Touched-doc trailing whitespace scan: PASS.
- `scripts/run-doc-qa.sh || true`: PASS WITH ADVISORY. Lychee returned 650 OK
  and 0 errors; markdown/stale/deprecated-language backlog remains
  pre-existing.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW. The only
  current hint is expected dirty-worktree state before commit.

## Remaining Yellow Items

- Existing Profile implementation files are large. PD17 mitigated new growth
  with extracted model/projector/card files, but broader file-size repair
  belongs to a later maintainability or flagship objectization batch.
- Cross-surface review remains a local summary over existing repositories. It
  does not prove runtime AOS/LDI proof propagation, sync, persistence migration,
  or navigation/deep-link behavior.

## Rollback Path

Revert the PD17 commit to remove the cross-surface proof/review models,
projector, card, Profile service/screen wiring, focused test, audit report, and
train-state documentation updates.

## Next Eligible Batch

PD18 Product Depth Handoff And Next-Lane Readiness is next if PD17 commits,
pushes, the worktree is clean, and global/Product Depth continuation gates allow
it. The newly requested CQS operating-system layer may be inserted before PD18
if PD17 is Green and global order is updated safely.
