# AFRI-032 Widget And Live Activity Flagship Proof

Issue: AMB-384 / AFRI-032

## Scope

- Extended the existing external snapshot owner with optional flagship widget variants for current step, Today pressure, protected time, capture entry, and recovery state.
- Kept older ambient snapshot decoding compatible; missing flagship variants decode as absent instead of breaking existing snapshots.
- Projected the new variants through the existing widget projection and widget extension view without adding a second widget/runtime object graph.
- Added Live Activity proof labels that distinguish current, stale, and unavailable local snapshot state.
- Updated the external-surface verification checklist to record the new widget-family and Live Activity proof boundaries.

## Safety Boundaries

- External surfaces remain local snapshot readers only.
- Widget and Live Activity surfaces do not silently mutate user data.
- Mutation-capable actions remain app-open, confirmation/receipt-bound, and routed through existing shared command policy.
- SourceRecord, Receipt, ReplayTrace, and You / What Ambitions Knows inspection boundaries are not bypassed.
- Sensitive goal, step, capture, protected-time, recovery, and pressure details stay inside Ambitions by default.
- No entitlement, signing, App Group identifier, hosted service, tracking SDK, remote intelligence, backend, dependency, or privacy manifest change is included.

## Validation

- Pre guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-384 --prompt /tmp/AMB-384-AFRI-032-guard-prompt.md` passed Green after prompt-bound guard repair.
- Focused tests: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/ExternalWidgetProjectionTests -only-testing:AmbitionsTests/ExternalSurfaceSnapshotTests -only-testing:AmbitionsTests/ExternalSurfaceVerificationChecklistTests` passed with 26 tests, 0 failures.
- Xcode result: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_18-49-23--0400.xcresult`
- Post guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-384 --prompt /tmp/AMB-384-AFRI-032-guard-prompt.md --changed-from HEAD ...` passed Green.
- Diff whitespace: `git diff --check` passed.
- Forbidden provider/tracking scan over touched source/proof passed with no matches.

## Proof Boundary

This packet supports source and focused simulator test evidence only. It does not claim rendered widget gallery proof, Lock Screen review proof, Dynamic Island device proof, real-device ActivityKit lifecycle proof, App Store/TestFlight readiness, public accessibility proof, privacy/legal approval, performance readiness, CI proof, or release readiness.

## Rollback

Revert the AMB-384 commit to remove the optional flagship widget variants, projection rows, Live Activity proof labels, checklist updates, tests, and this proof packet while keeping the existing Next Step widget baseline intact.
