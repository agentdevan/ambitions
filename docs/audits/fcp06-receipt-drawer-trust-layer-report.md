# FCP06 Receipt Drawer Trust Layer Report
<!-- markdownlint-disable MD013 -->

Result: Green with accepted Yellow advisory backlog.
Date: 2026-05-05.
Train: FCP01-FCP30 Flagship Completion Train.
Batch: FCP06 Receipt Drawer / Trust Layer.
Owner: Shared Trust.

## Summary

FCP06 implements the shared Receipt Drawer and Source Fold foundation inside the
existing trust receipt primitive seam. It reconciles the older manifest
dependency on FCP05 with the newer global order by building the shared trust
foundation first and deferring Start Here attachment to FCP05.

No top-level tab, route/raw value, persistence/schema, sync/cloud/account,
notification, widget, Live Activity, App Intent, entitlement, workflow,
dependency, AI runtime, LDI runtime, release, legal/privacy, or public
accessibility claim is changed.

## Files Read

- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/canon/Ambitions_Found_Life_Layer.md`
- `docs/audits/fcp17-schedule-availability-defaults-center-report.md`
- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Previews/TrustReceiptLayerPreviews.swift`
- `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift`
- `.codex/skills/staff-ios-architect.md`
- `.codex/skills/swiftui-composition-reviewer.md`
- `.codex/skills/accessibility-reduced-motion-reviewer.md`
- `.codex/skills/anti-agentic-slop-reviewer.md`

## Files Changed

- `Sources/Components/TrustReceiptLayerPrimitives.swift`
- `Sources/Previews/TrustReceiptLayerPreviews.swift`
- `Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift`
- `docs/codex/batches/FCP06_Receipt_Drawer_Trust_Layer_Prompt.md`
- `docs/audits/fcp06-receipt-drawer-trust-layer-report.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Implementation

- Added receipt fact fields for why, change/no-change, and correction while
  preserving the existing `TrustReceiptLayerItem` initializer through defaults.
- Added `ReceiptDrawerSection` as the typed grouping model.
- Added `SourceFold` to expose source, freshness, and privacy as a reusable
  trust primitive.
- Added `ReceiptDrawer` to present receipt sections, empty state, receipt rows,
  source fold, why/change/correction facts, and review/undo controls.
- Expanded trust previews for drawer, source, private, stale, local, and
  professional-boundary states.
- Added focused tests proving drawer items preserve source, freshness, privacy,
  why, change/no-change, correction, review, and undo facts.

## Product Decisions Preserved

- Top-level IA remains Today / Goals / Capture / Plan / You.
- FCP06 does not create a receipt inbox, activity feed, analytics log UI,
  dashboard, new route, or new tab.
- Receipts remain consequence and reversibility, not notifications.
- Proof remains evidence, not achievement.
- Source remains freshness/conflict/review boundary, not AI certification.
- Privacy remains user control, not surveillance.
- Start Here attachment is deferred to FCP05 because FCP05 is not complete.

## Accessibility / Reduced Motion

The new drawer and fold use visible text facts, combined accessibility labels
and values, stable accessibility identifiers, Dynamic Type-aware source fold
layout, and no motion-only or color-only meaning. Public accessibility
conformance remains unclaimed without manual/device proof.

## Privacy / Trust

The drawer exposes source, freshness, privacy, consequence, correction, review,
and undo posture without exposing private content by default. It adds no
storage, sync, external surface, notification, widget, Live Activity, App
Intent, AI runtime, or LDI runtime behavior.

## Repairs Attempted

- Recoverable source-truth mismatch: the older FCP manifest described FCP06 as
  dependent on FCP05 and attached to Start Here first, while the newer global
  order selected FCP06 before FCP05. Repaired by scoping FCP06 to the shared
  trust foundation and deferring Start Here attachment to FCP05.
- Recoverable missing prompt: no standalone FCP06 prompt existed. Repaired by
  creating `docs/codex/batches/FCP06_Receipt_Drawer_Trust_Layer_Prompt.md`
  from the train manifest and global-order boundary.

## Validation Commands

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/TrustReceiptLayerDesignSystemTests`
- `scripts/build-local.sh`
- `scripts/cqs-product-drift-scan.sh Sources/Components/TrustReceiptLayerPrimitives.swift Sources/Previews/TrustReceiptLayerPreviews.swift Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift docs/audits/fcp06-receipt-drawer-trust-layer-report.md || true`
- `scripts/cqs-prompt-built-smell-scan.sh Sources/Components/TrustReceiptLayerPrimitives.swift Sources/Previews/TrustReceiptLayerPreviews.swift Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift || true`
- `scripts/cqs-privacy-security-claim-scan.sh Sources/Components/TrustReceiptLayerPrimitives.swift Sources/Previews/TrustReceiptLayerPreviews.swift Native/AmbitionsTests/App/TrustReceiptLayerDesignSystemTests.swift docs/audits/fcp06-receipt-drawer-trust-layer-report.md || true`
- `scripts/cqs-accessibility-motion-scan.sh Sources/Components/TrustReceiptLayerPrimitives.swift Sources/Previews/TrustReceiptLayerPreviews.swift || true`
- `git diff --check`
- Touched-file trailing whitespace scan
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- `xcodegen generate`: Pass.
- Focused trust receipt test lane: Pass. `TrustReceiptLayerDesignSystemTests`
  executed 4 tests with 0 failures. Simulator logs included expected
  `NOT_CODESIGNED` app-group messages under `CODE_SIGNING_ALLOWED=NO`; tests
  still passed.
- `scripts/build-local.sh`: Pass. Native simulator build succeeded for the app,
  widget extension, share extension, and app intent metadata extraction path.
- `git diff --check`: Pass.
- Touched-file trailing whitespace scan: Pass.
- CQS product drift scan: Pass with zero hits on the first touched scan root.
- CQS prompt-built smell scan: Pass with zero hits on the first touched scan
  root.
- CQS privacy/security/legal claim scan: Pass with zero hits on the first
  touched scan root.
- CQS accessibility/motion scan: Accepted Yellow review hit. It reported
  accessibility labels and foreground-style lines in the new primitive file;
  FCP06 includes explicit labels/values, visible text facts, Dynamic Type-aware
  layout, and no motion-only or color-only meaning.
- `scripts/run-doc-qa.sh || true`: Accepted Yellow advisory backlog. Lychee
  reported 650 OK and 0 errors. Existing repo-wide markdown and deprecated
  language advisories are not introduced by FCP06 production source changes.
- `scripts/batch-train-gate-check.sh || true`: Accepted Yellow dirty-tree hint
  before commit, expected while FCP06 files are uncommitted.

## Remaining Yellow Items

- FCP06 does not attach the drawer to Start Here; FCP05 owns that integration.
- The existing repo-wide doc-QA advisory backlog remains expected.

## Hard Red Review

No Hard Red was found. FCP06 did not require route/raw-value edits,
schema/data changes, sync/account/cloud behavior, unsupported
legal/privacy/release claims, or weakening Ambitions canon.

## Rollback Path

Revert the FCP06 commit to remove the shared drawer/fold primitive and docs
updates. No persistence, schema, route, entitlement, workflow, dependency, sync,
or release file changed.

## Next Eligible Batch

FCP05 Start Here Surface.
