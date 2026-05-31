# AFRI-029 Spotlight And Handoff Reopening Proof

Issue: AMB-381 / AFRI-029

## Scope

- Added source-level reopening projections for Spotlight-safe index records and Handoff records.
- Covered goals, current step, receipts, and captures with canonical `ambitions://` routes.
- Added explicit `spotlight` and `handoff` external origins so route source context survives reopening.
- Kept Spotlight indexing disabled by default until separate device/platform/privacy proof exists; internal opt-in projection emits privacy-safe summaries only.
- Updated the `persistence_external_surfaces` concept lock to allow AMB-381 as the scoped external-surface reopening owner for this proof packet.

## Safety Boundaries

- Sensitive objects use generic titles such as `Goal in Ambitions` and `Step in Ambitions`; details stay private until the app opens.
- Index records are never eligible for public indexing.
- Handoff records are limited to goal detail and current step reopening.
- Receipt reopening routes through What Ambitions Knows / memory lens.
- SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows claims remain local and proof-bounded here.
- The concept-lock update is narrow to AMB-381 and does not unlock broader persistence, export/delete/reset, widget, share extension, or app container work.

## Validation

- Pre guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-381 --prompt /tmp/AMB-381-AFRI-029-guard-prompt.md`
- Focused indexing, redaction, and Handoff route tests: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/ExternalSurfaceActionPayloadTests -only-testing:AmbitionsTests/ExternalRoutingTests` passed with 47 tests, 0 failures.
- Post guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-381 --prompt /tmp/AMB-381-AFRI-029-guard-prompt.md --changed-from HEAD ...` passed Green after the `persistence_external_surfaces` lock was narrowed to allow AMB-381.
- Diff whitespace: `git diff --check` passed.
- Forbidden provider/tracking keyword scan over touched source/proof passed with no matches.

## Proof Boundary

This is source and focused-test evidence only. It does not claim real Spotlight indexing, real Handoff continuation, physical-device proof, App Store readiness, TestFlight readiness, public accessibility proof, privacy/legal approval, or release readiness.

## Rollback

Keep `ExternalObjectReopeningIndexGate.disabledUntilProof` as the default and remove the reopening projection tests/types if the system surface needs to remain fully unadvertised.
