# AFRI-017 Same Intent Different Context Runtime Proof

Status: Local proof packet for AMB-369 / AFRI-017.

## Scope

- Extended the existing `AmbitionsMoatScenarioProof98Tests` harness instead of creating a parallel moat proof path.
- Added explicit capacity, protected time, recovery state, source record, receipt, and replay continuity checks to the same-intent/different-context proof.
- Added `explanation-diff.json` to the local proof packet so reviewers can inspect why the same intent yields different Start Here outputs.
- Preserved local-only runtime boundaries with no cloud LLM, hosted inference, analytics, backend, or network dependency.

## Proof Boundaries

- This is focused executable proof for the local runtime moat scenario.
- It does not claim final Today UI completion, device validation, accessibility proof, privacy/legal signoff, TestFlight/App Store readiness, or release readiness.
- The proof packet is simulator-local evidence only.

## Validation

- Pre-implementation guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-369 --prompt /tmp/AMB-369-AFRI-017-guard-prompt.md`
  - Result: Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-369-pre.md`
- Focused runtime proof validation: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/AmbitionsMoatScenarioProof98Tests`
  - Result: Green, 1 test, 0 failures.
  - Final rerun after ReplayTrace artifact repair: Green, 1 test, 0 failures.
  - Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_13-22-23--0400.xcresult`
- Post-implementation guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-369 --prompt /tmp/AMB-369-AFRI-017-guard-prompt.md --changed-from 878a9aa8b --changed-path Native/AmbitionsTests/Domain/AmbitionsMoatScenarioProof98Tests.swift --changed-path docs/proof/amb-fe-be/moat-scenario-proof-98/README.md --changed-path docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-a.json --changed-path docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-b.json --changed-path docs/proof/amb-fe-be/moat-scenario-proof-98/explanation-diff.json --changed-path docs/proof/afri/afri-017-same-intent-different-context-runtime-proof.md`
  - Result: Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-369-post.md`

## Proof Artifacts

- `docs/proof/amb-fe-be/moat-scenario-proof-98/README.md`
- `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-a.json`
- `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-b.json`
- `docs/proof/amb-fe-be/moat-scenario-proof-98/diff-summary.json`
- `docs/proof/amb-fe-be/moat-scenario-proof-98/explanation-diff.json`
- `docs/proof/amb-fe-be/moat-scenario-proof-98/replay-output.json`
- `docs/proof/amb-fe-be/moat-scenario-proof-98/privacy-boundary.log`

## Rollback

- Remove the added explanation-diff artifact model and assertions from `AmbitionsMoatScenarioProof98Tests`.
- Remove `explanation-diff.json` and revert generated proof packet changes.
- Revert this proof packet.
