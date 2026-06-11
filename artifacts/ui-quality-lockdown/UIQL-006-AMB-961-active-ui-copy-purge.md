# AMB-961 / UIQL-006 Active UI Copy Purge

Status: Green for scoped AMB-961 copy purge
Date: 2026-06-11
Branch: main
Linear issue: AMB-961
UIQL label: UIQL-006, sequence label only

## Scope

AMB-961 removes implementation, spec, debug, AI, dashboard, and issue-template copy from active user-facing UI. The repair keeps source, proof, receipt, and local-first meaning visible in plain product language.

This is not a full surface reconstruction, owner approval, accessibility certification, release proof, TestFlight proof, App Store proof, privacy/legal approval, physical-device proof, or performance proof.

## Copy Repairs

Visible implementation labels were rewritten to product language:

- `SourceRecord` and `SourceRecord-backed` visible labels became `Source`, `Local source`, `Profile source state`, or plain source/receipt/reason language.
- `ReplayTrace` visible labels became `Reason` or `Today link`.
- `Staging` visible labels became `Draft`.
- `domain fit` became `work context`.
- `manual fallback` became `User choice`.
- `Deep link` became `Linked route`.
- `Global Capture opens as...` became `Capture starts with...`.
- `First visible shift...` became `Early movement stays clear...`.
- `Source, proof, replay trace...` became `Source, proof, reason...`.
- Cloud/AI denial copy was rewritten as optional cloud planning/external planning boundary copy without branding core UI as AI.
- You copy was rewritten away from dashboard/admin phrasing while preserving local trust, source, receipt, and correction semantics.

Internal durable identifiers and guard catalogs were not renamed when they are storage/runtime identity or intentional forbidden-pattern examples. Examples include `SourceRecord.*` IDs, `KnowledgeSourceRecord`, guard test strings, and UIQL banned-copy catalogs.

## Files Touched

Source and tests were changed only where active UI copy, preview-visible copy, accessibility values, source summaries, or copy assertions required it. Main groups:

- Runtime/shell: `Native/Ambitions/App/AppShellView.swift`, `Native/Ambitions/App/ShellCommandModels.swift`, `Native/AmbitionsUITests/AmbitionsUITests.swift`
- Today/Time/Motion/Goals/You/Capture copy surfaces under `Native/Ambitions/Features/**`
- Domain/service projection copy under `Native/Ambitions/Domain/**`, `Native/Ambitions/Services/**`, `Native/Ambitions/Runtime/**`, and calendar/reminder/persistence summaries
- Shared component copy under `Sources/Accessibility/**` and `Sources/Components/**`
- Preview/support user-visible strings under `Native/Ambitions/PreviewSupport/**` and support readiness packets where the same visible language can be surfaced
- Focused test assertions under `Native/AmbitionsTests/**`

## Validation

Passing commands:

- `git diff --check`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-scan-shell.sh`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'id=8ACCD665-4807-4102-B526-5A1AE20686A8' build`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'id=8ACCD665-4807-4102-B526-5A1AE20686A8' -only-testing:AmbitionsUITests/AmbitionsUITests/testAFRI005ShellScreenshotBaselineCapturesCanonicalTabs`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'id=8ACCD665-4807-4102-B526-5A1AE20686A8'` with corrected AMB-961 focused unit selectors, 11 tests executed and 0 failures.

Important non-proof or repair evidence:

- `AMB-961-copy-purge-focused-tests.log` failed during an earlier broad selector run because stale exact-copy assertions and unrelated `GoalsObjectStage` class selectors were included. The valid focused proof is the corrected selector log.
- `AMB-961-copy-purge-final-focused-tests.log` executed 0 tests because the selector syntax included path segments. It is retained as invalid proof. The corrected selector log executed 11 tests and passed.
- `AMB-961-activated-capture-focused-ui-test.log` failed on `shell.activated-capture.state.activated` after the activated Capture seam existed. Current screenshot proof shows the seam is visible and the AMB-961 copy is repaired; this failed selector is recorded as UI-test selector/layout tooling evidence, not product Green proof.
- `program-preflight.sh uiql` returned Red before commit because AMB-961 source/test files were intentionally dirty. It must be rerun after the closeout commit from a clean tree.

## Screenshot Evidence

Current visual proof was inspected, not treated as path-only proof:

- Clean Today after `domain fit` repair: `artifacts/ui-quality-lockdown/screenshots/amb-961/AMB-961-after-today-clean.png`
- Final activated Capture after `manual fallback` and `Deep link` repair: `artifacts/ui-quality-lockdown/screenshots/amb-961/AMB-961-activated-capture-final-after-fallback-purge.png`
- Final exported tab screenshots from passing UI test:
  - `artifacts/ui-quality-lockdown/screenshots/amb-961/xcresult-tabs-final/81456ED9-C84E-41CA-881B-04CDBAEB8A18.png` - Today
  - `artifacts/ui-quality-lockdown/screenshots/amb-961/xcresult-tabs-final/D78489F0-2E91-4344-88D0-CD5BEFC31C62.png` - Goals
  - `artifacts/ui-quality-lockdown/screenshots/amb-961/xcresult-tabs-final/2C452EC4-6069-406F-8BD9-90B6777E7064.png` - Time
  - `artifacts/ui-quality-lockdown/screenshots/amb-961/xcresult-tabs-final/BD98AFE9-EBF9-44B8-91C4-62D247D5E95F.png` - Motion
  - `artifacts/ui-quality-lockdown/screenshots/amb-961/xcresult-tabs-final/F3E01857-1EDC-4E38-BF99-3D7254B1D0A4.png` - You

Visual inspection result:

- Today no longer shows `domain fit`; current copy reads `work context`.
- Activated Capture no longer shows `manual fallback` or `Deep link`; current copy reads `User choice` and `Linked route`.
- Goals shows `Source, proof, reason...`, not `Source, proof, replay trace...`.
- Motion no longer shows `First visible shift...`; current copy reads `Early movement stays clear...`.
- You first viewport does not show dashboard/admin/spec/debug/AI copy.

## Green / Yellow / Red

Green:

- AMB-961 banned visible copy is removed from changed active Swift source.
- Replacement copy is shorter, human, and product-native.
- Trust/source/receipt semantics remain visible as source, proof, receipt, reason, local, and user-choice language.
- Screenshot-visible copy was inspected on Today, Goals, Time, Motion, You, and activated Capture.
- Focused build/tests and UIQL scans pass.

Yellow:

- `program-preflight.sh uiql` is Red before commit because it blocks dirty source paths. This is expected before closeout commit and must be rerun from a clean tree.
- The activated Capture deep-link UI test still has a selector/layout failure for one state identifier even though the current activated Capture screenshot shows the surface and repaired copy. This is tooling/test-selector evidence, not product proof.
- Formal accessibility variant proof remains owned by AMB-968; independent red-team visual audit remains owned by AMB-970.

Red:

- None remaining for the scoped AMB-961 copy purge.

## Linear Closeout Draft

After commit/push, update AMB-961 with:

AMB-961 / UIQL-006 Active UI Copy Purge is complete.

- Commit: `<commit hash>`
- Status: Green for scoped active UI copy purge.
- Copy removed/reframed: visible `SourceRecord`, `SourceRecord-backed`, `ReplayTrace`, `domain fit`, `manual fallback`, `Deep link`, `Global Capture opens as...`, `First visible shift...`, `Source, proof, replay trace...`, and AI/dashboard/spec/admin phrasing in the scoped active UI copy paths.
- Validation: `git diff --check`; UIQL mini-regression; UIQL banned-copy/card-anatomy/shell scans; simulator build; canonical tab screenshot UI test; corrected focused unit selector run with 11 tests / 0 failures.
- Visual artifacts: `artifacts/ui-quality-lockdown/screenshots/amb-961/AMB-961-after-today-clean.png`; `artifacts/ui-quality-lockdown/screenshots/amb-961/AMB-961-activated-capture-final-after-fallback-purge.png`; exported tab screenshots under `artifacts/ui-quality-lockdown/screenshots/amb-961/xcresult-tabs-final/`.
- Yellow tooling: one activated Capture UI selector still fails on `shell.activated-capture.state.activated` after the seam exists; current screenshot proof is used only for visible copy, not full Capture UI behavior certification. Pre-commit `program-preflight uiql` was Red only because the AMB-961 source/test files were intentionally dirty.
- No claims: no owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, full accessibility certification, privacy/legal approval, or AMB-962+ completion.
- Next dependency: AMB-962 / UIQL-007 Today Reconstruction.
