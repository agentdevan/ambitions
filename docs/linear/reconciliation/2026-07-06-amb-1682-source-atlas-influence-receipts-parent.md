# AMB-1682 Source Atlas Influence Receipts Parent Closeout

Status: Implemented Yellow parent closeout
Date: 2026-07-06T02:54:31Z
Branch: `main`
Baseline main SHA: `d17335e10a2b1b0aaf73719393ac866a50679912`
Environment: local Codex macOS workspace at `/Users/devan/Documents/GitHub/ambitions`
Xcode version: Xcode 26.6, build version 17F113
Project: Architecture Simplification + Flagship Readiness Remediation (`59c3917f-f662-4ca3-b412-b532613f3a7a`)
Issue: `AMB-1682` Parent Feature - Source Atlas Influence Receipts
Artifact paths: this packet and `docs/linear/reconciliation/2026-07-06-amb-1682-source-atlas-influence-receipts-parent.json`

## Scope

This packet closes the parent-level Source Atlas influence receipt scope as
Implemented Yellow under the current instruction to skip build proof until
advised otherwise.

Primary implementation evidence:

- Child leaf `AMB-1803` is `Done`.
- `docs/qa/evidence/2026-07-05-amb-1803-source-influence-receipt/manifest.md`
- `docs/qa/evidence/2026-07-05-amb-1803-source-influence-receipt/source-influence-receipt.json`
- `Native/Ambitions/Core/LocalRuntimeOS/Planning/SourceAtlasVerifiedPublicPlanningBridgeModels.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/Planning/SourceAtlasStepCandidateFieldVerifiedPublicContext.swift`
- `Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/SourceAtlasBridgeReceiptReplayModels.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceInfluenceReceiptTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasVerifiedPublicPlanningBridgeTests.swift`
- `Native/AmbitionsTests/LocalRuntimeOS/SourceAtlas/SourceAtlasOfflineNoAccountPlanningScaleTests.swift`

The current source scan also confirms that `publicPlanningContext` is supplied
only by `SourceAtlasStepCandidateFieldBridge.expandVerifiedPublicPlanningContext`.
Other `publicPlanningContext` references are helper parameters within that
verified bridge path. There is no second production call site that supplies a
public planning context while bypassing `SourceInfluenceReceipt`.

## Source State

The source-present influence path now has:

- a versioned `SourceInfluenceReceipt` schema;
- deterministic receipt IDs;
- Source Atlas/public-reference ownership flags;
- private runtime ownership flags;
- explicit `privateInputIncluded=false` and `privateLifeGraphIncluded=false`
  contract fields;
- a `canInfluenceLocalPlanning` gate;
- bridge replay receipt kind `.sourceAtlasInfluenceReceiptRecorded`;
- deterministic replay fingerprinting on
  `SourceAtlasVerifiedPublicPlanningBridgeOutput`;
- fail-closed rejected receipts for unavailable, mismatched, unsafe, or blocked
  public context;
- offline/no-account local fallback behavior covered by source-level tests;
- You projection receipt copy for `.sourceAtlasInfluenceReceiptRecorded`,
  added in commit `d17335e10a2b1b0aaf73719393ac866a50679912`.

## Acceptance Mapping

| AMB-1682 requirement | Current source status | Proof ceiling |
| --- | --- | --- |
| Define `SourceInfluenceReceipt`. | Implemented in `SourceAtlasVerifiedPublicPlanningBridgeModels.swift`. | Static/source and existing test source only. |
| Attach source receipts to any path/time-fit decision using Source Atlas data. | The only non-nil `publicPlanningContext` production call flows through `expandVerifiedPublicPlanningContext`, which creates `SourceInfluenceReceipt` before returning usable candidates. | Build/runtime proof skipped. |
| Add user-facing inspection copy. | You projection now maps `.sourceAtlasInfluenceReceiptRecorded` to `Influence receipt recorded`. | Rendered UI proof skipped. |
| Add tests proving a plan can explain source influence. | Test source exists in `SourceInfluenceReceiptTests` and `SourceAtlasVerifiedPublicPlanningBridgeTests`. | XCTest execution skipped. |
| Add replay tests with source-pack version pinned. | Deterministic replay fingerprint source and tests exist; AMB-1803 evidence records static proof. | XCTest execution skipped. |
| Add stale-source and offline behavior tests. | `SourceAtlasOfflineNoAccountPlanningScaleTests` includes offline/no-account and fail-closed stale/revoked/missing/unsafe cases. | XCTest execution skipped. |

## Validation Run

Completed for this parent packet:

| Command | Exit code | Result |
| --- | ---: | --- |
| `rg -n "publicPlanningContext:" Native/Ambitions Native/AmbitionsTests` | 0 | Only the verified bridge supplies non-nil public planning context in production. |
| `rg -n "SourceInfluenceReceipt|sourceInfluenceReceipt|sourceAtlasInfluenceReceiptRecorded" Native/Ambitions Native/AmbitionsTests docs/qa/evidence/2026-07-05-amb-1803-source-influence-receipt` | 0 | Receipt contract, bridge attachment, tests, and evidence are present. |
| `python3 -m json.tool docs/qa/evidence/2026-07-05-amb-1803-source-influence-receipt/source-influence-receipt.json` | 0 | Existing AMB-1803 evidence JSON parsed. |
| `python3 -m json.tool docs/linear/reconciliation/2026-07-06-amb-1682-source-atlas-influence-receipts-parent.json` | 0 | This packet JSON parsed. |
| `git diff --check` | 0 | Passed. |
| `python3 scripts/ambitions-remediation-governance-check.py --json` | 0 | Passed; no findings. |
| `python3 scripts/ambitions-quality-gate.py` | 0 | Passed. |
| `python3 scripts/ambitions-accepted-yellow-misuse-audit.py --json` | 0 | Passed. |
| `python3 scripts/ambitions-architecture-inventory.py` | 0 | Passed. |
| `python3 scripts/ambitions-green-standard-audit.py` | 0 | Passed. |
| `python3 scripts/ambitions-vocabulary-drift-scan.py` | 0 | Passed. |
| `python3 scripts/ambitions-local-first-boundary-scan.py` | 0 | Passed. |
| `python3 scripts/ambitions-unsupported-claim-scan.py ...` | 0 | Passed for this packet and paired JSON. |

## Validation Not Run

Build proof is intentionally skipped under the current user instruction.

Not run:

- xcodebuild build
- xcodebuild build-for-testing
- XCTest
- simulator app launch
- rendered You inspection proof
- runtime replay walkthrough
- Source Atlas production R2 proof
- privacy/legal review
- archive, TestFlight, App Store upload, or physical-device procedure

## Non-Claims

- No Implemented Green claim.
- No final Source Atlas Green.
- No app-wide Source Atlas production readiness.
- No production R2 readiness.
- No build/test pass claim.
- No rendered UI proof.
- No runtime/device proof.
- No privacy/legal approval.
- No release readiness.
- No TestFlight or App Store readiness.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched by source implementation: `Core/LocalRuntimeOS/Planning`,
  `Core/LocalRuntimeOS/SourceAtlas`, `Surfaces/You/Projection`.
- Files moved or created in this packet:
  - `docs/linear/reconciliation/2026-07-06-amb-1682-source-atlas-influence-receipts-parent.md`
  - `docs/linear/reconciliation/2026-07-06-amb-1682-source-atlas-influence-receipts-parent.json`
- Governance files edited in this packet:
  - `docs/adr/ADR-2026-07-02-source-atlas-scope-freeze.md`
- Source files edited in this packet: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- New `+02`, `+03`, or `+04` split files added: none.
- New broad `Models.swift` files added: none.
- New runtime, persistence, projection-materialization, receipt, replay,
  side-effect, migration, repair, privacy, sync, diagnostics, or Source Atlas
  authority added in this packet: none.
- Yellow architecture/proof debt remains: yes, only because build, XCTest,
  rendered UI, runtime, device, R2 production, privacy/legal, and release proof
  are intentionally skipped.
- Next repair train if debt remains: re-run Source Atlas receipt tests and
  rendered inspection proof when build proof is re-enabled.
- Confirmation: no equivalent-folder or alternate-path interpretation was used.

## Rollback

Reopen `AMB-1682` to `Spec Ready` if a production call site is added that
supplies `publicPlanningContext` without returning `SourceInfluenceReceipt`, or
if build/test proof later shows the AMB-1803 receipt contract does not compile
or execute.
