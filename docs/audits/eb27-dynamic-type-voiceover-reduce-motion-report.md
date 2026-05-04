# EB27 Dynamic Type VoiceOver And Reduce Motion Report

Date: 2026-05-04

Result: PASS WITH YELLOW

## Batch

- Batch: EB27 Dynamic Type VoiceOver And Reduce Motion
- Starting HEAD: `dee498d9`
- Kernel owner: Accessibility and Cognitive Load / shared accessibility evidence
- Prompt: `docs/codex/batches/EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt.md`
- Next eligible after closeout: EB28 Plain Language Anxiety Safe Copy And
  Explain This Screen

## Source Truth Read

- `docs/codex/batches/EB27_Dynamic_Type_VoiceOver_And_Reduce_Motion_Prompt.md`
- `docs/canon/Ambitions_4_0_Accessibility_And_Cognitive_Load_Kernel.md`
- `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `Sources/Accessibility/AccessibilityNutrition.swift`
- `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`
- `docs/audits/eb27-dynamic-type-voiceover-reduce-motion-report.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md`
- `scripts/global-train-next-batch.sh`

## Implementation Summary

EB27 adds a source-backed shared accessibility evidence package:

- `AccessibilityAdjustmentAxis`
- `AccessibilityAdjustmentEvidenceRequirement`
- `EB27AccessibilityAdjustmentEvidence`

The package names the owner file, automated proof target, required fallback,
manual proof still required, and public-claim lock for Dynamic Type layout,
VoiceOver order, and Reduce Motion equivalents.

No surface consumes the package yet, so EB27 creates the safe evidence and test
lane without changing current UI behavior.

## Boundary Proof

- Production Swift touched: yes, scoped to shared accessibility evidence models
  and focused accessibility tests.
- App behavior changed: no current screen or setting consumes the new evidence
  package yet.
- User-facing behavior changed: no directly rendered surface changed in this
  batch.
- Route/raw values changed: no app routes or persisted raw values changed. New
  raw-value enums are non-persistent accessibility evidence primitives.
- Persistence/schema changed: no.
- Top-level tabs changed: no.
- Dependencies/workflows/signing changed: no.

## Accessibility / Cognitive Load Evidence

- Dynamic Type layout evidence names `Sources/Theme/PanelDensitySize.swift` as
  owner and requires lower-density fallback for accessibility sizes.
- VoiceOver order evidence names `Sources/Accessibility/AccessibilityNutrition.swift`
  as owner and keeps manual traversal proof explicit.
- Reduce Motion equivalent evidence names
  `Sources/Components/DynamicAdaptiveVisualPrimitives.swift` as owner and
  requires static state, text, icon, disclosure, or opacity fallback.
- Every EB27 requirement disallows user-facing accessibility claims from source
  and automated evidence alone.
- Every EB27 requirement keeps non-color meaning required.

## Preview Evidence

- No new rendered screenshot was produced.
- Existing DAV preview lanes include high Dynamic Type and Reduce Motion
  scenarios in `Sources/Previews/DynamicAdaptiveVisualPreviews.swift`; EB27 did
  not alter preview rendering.

## Validation Results

- Focused accessibility tests:
  `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AccessibilityNutritionChecklistTests | xcbeautify`
  PASS, 12 tests, 0 failures.
- `git diff --check`: PASS.
- `swift build || true`: PASS.
- `bash scripts/build-local.sh`: PASS.
- `bash scripts/eb-active-train-integration-gate.sh || true`: PASS with
  source-truth matches.
- `bash scripts/eb-no-unsupported-claim-scan.sh || true`: YELLOW existing
  repo-wide advisory backlog.
- `bash scripts/eb-no-5-version-drift-scan.sh || true`: PASS.
- `bash scripts/no-fake-proof-gate.sh || true`: GREEN for changed EB27 report
  and docs after validation.
- `bash scripts/canon-language-drift-scan.sh || true`: YELLOW existing
  repo-wide language backlog.
- `bash scripts/release-claim-safety-scan.sh || true`: YELLOW advisory backlog.
- `bash scripts/run-doc-qa.sh || true`: YELLOW existing docs advisory backlog;
  link check completed.
- `bash scripts/batch-train-gate-check.sh || true`: YELLOW_HINT because the
  working tree contained the intended EB27 changes before commit staging.

## Red Issues

- Reds encountered: none.
- Reds repaired: none.
- Reds remaining: none.

## Yellow Advisories

- No current UI surface consumes the EB27 evidence package yet.
- No rendered screenshot proof was produced because no UI changed.
- No human device review was run.
- No human VoiceOver review was run.
- No toggled Reduce Motion walkthrough was run.
- No Instruments or battery profiling was run.
- Existing repo-wide release-claim/canon-language/doc QA advisory backlog
  remains.

## Claim Boundaries

EB27 may claim only that the scoped Dynamic Type, VoiceOver, and Reduce Motion
evidence requirements, focused accessibility tests, Swift build, and local build
passed as recorded here. It must not claim production readiness, TestFlight or
App Store readiness, public accessibility compliance, physical-device proof,
privacy/legal signoff, battery safety, rendered UI proof, manual VoiceOver
proof, or whole External Brain completion.
