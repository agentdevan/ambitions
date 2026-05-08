# AFI13 Visual QA And Drift Gallery Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Status: Accepted Yellow
Batch: AFI13 Visual QA And Drift Gallery

## Result

AFI13 added source/test visual QA scorecards and drift-gallery examples for
Today, Goals, Capture, Time, and You. The scorecards enforce 95+ minimum targets
with 98 targets for Today and Capture, name required rendered screenshot
inventories, and keep every surface Yellow until rendered screenshots and human
visual review exist.

## Files Changed

- `Sources/Previews/SignatureInterfaceVisualQAFixtures.swift`
- `Sources/Previews/SignatureInterfaceVisualQAPreviews.swift`
- `Native/AmbitionsTests/App/SignatureInterfaceVisualQAFixtureTests.swift`
- batch/state/report docs

## Behavior Changed

No runtime app behavior changed. The Swift changes are preview/test proof
infrastructure only.

## Tests Run

- `git diff --check` passed.
- `python3 scripts/ai/acx_impact.py $(git diff --name-only)` completed and
  routed the touched docs/state/source/test files to docs and batch-closeout
  proof.
- `xcodegen generate` passed.
- Focused Visual QA fixture lane passed: 7 selected tests, 0 failures.
  Raw log: `.codex/logs/2026-05-08T18-afi13-focused-tests.raw.log`.
- `./scripts/build-local.sh` passed.
  Raw log: `output/logs/build-local-20260508-150409.log`.
- `python3 scripts/ai/acx_local.py bundle docs` passed with ACX Green and
  known historical advisory findings.
- `python3 scripts/ai/acx_local.py bundle batch-closeout` passed with ACX
  Green and known historical advisory findings.
- `python3 scripts/ai/acx_repair.py diagnose` returned Yellow
  `NoActiveRepairEvidence`, no hard stop, and no state written.
- `scripts/global-train-next-batch.sh` resolved
  `AFI14 Cross-Surface Coherence Review`.
- `python3 scripts/ai/acx_visual_packet.py` ran for Today, Goals, Capture,
  Time, and You against the AFI13 preview/fixture files. These packets list
  required proof fields and make no human visual approval, public accessibility,
  release, App Store, or TestFlight claims.

## Tests Not Run

- Rendered screenshot capture.
- Human visual QA review.
- Manual accessibility/visual traversal.
- Full UI test suite.
- Physical-device validation.
- Signed archive validation.

## Known Risks

- The scorecards intentionally remain Yellow because rendered proof is absent.
- Simulator output still includes unsigned app-group `NOT_CODESIGNED` warnings;
  this is local simulator proof, not signed archive proof.
- Historical SI/FVQ/DAV visual proof remains useful context but does not count
  as fresh AFI13 rendered visual proof.
- The preserved pre-sync stash remains Yellow evidence and was not applied.

## Claims

AFI13 source/test scorecard and drift-gallery proof exists for the active
top-level AFI surfaces.

## Non-Claims

No rendered visual QA pass, human visual approval, accessibility conformance,
production readiness, release readiness, TestFlight readiness, App Store
readiness, privacy/legal approval, physical-device proof, signed archive proof,
all-tests-pass, CI green, migration safety, sync readiness, backend completion,
or performance-budget proof is claimed.

## Next Eligible Batch

AFI14 Cross-Surface Coherence Review.
