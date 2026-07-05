# AMB-1767 Offline / No-account Frontend Acceptance

Status: Implemented Yellow / offline no-account lane reconciled without runtime
testing
Date: 2026-07-05
Scope: AMB-1767, offline and no-account frontend acceptance
Baseline SHA: `0f4e5df58e99633935bb8cdf8321a8d923a49956`
Linear status before closeout: `In Progress`

## Purpose

AMB-1767 is the frontend acceptance lane for fresh-install no-account behavior,
airplane-mode core behavior, local goals, local captures, local closures, local
proof, local preferences, no network dependency for core value, and account
optionality proof where applicable.

The current user instruction authorizes issue completion without running tests.
This packet therefore completes AMB-1767 as Implemented Yellow by tying the
lane to source-level local-first evidence and retained frontend proof gates. It
does not produce fresh-install proof, airplane-mode proof, network-instrumented
proof, no-account device proof, screenshots, simulator proof, physical-device
proof, owner acceptance, privacy/legal approval, TestFlight readiness, App Store
readiness, or Release Green.

## Authority Inputs

- `docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/audits/root-ia-stage-shell-acceptance.md`
- `docs/audits/capture-global-composer-acceptance.md`
- `docs/audits/today-flagship-acceptance.md`
- `docs/audits/goals-flagship-acceptance.md`
- `docs/audits/time-flagship-acceptance.md`
- `docs/audits/you-flagship-acceptance.md`
- `docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md`
- `docs/audits/amb-1769-frontend-known-issue-mapping.md`
- `Native/Ambitions/Quality/ReleaseFrontendProofGate.swift`

## Required Acceptance Map

| Required area | Current evidence input | Current status |
| --- | --- | --- |
| Fresh install, no-account walkthrough | You and root IA acceptance packets show source-level account optionality and local-first posture. | Required, not runtime-run. |
| Airplane-mode core walkthrough | Today, Goals, Time, You, and Capture packets identify local source paths plus offline/degraded state routes. | Required, not runtime-run. |
| Local goals | Goals source acceptance records local repository-backed load, create, detail, proof, history, and mutation paths. | Source-present only. |
| Local captures | Capture source acceptance records local command execution, local capture creation, Today resurfacing, and Memory Lens find-again source. | Source-present only. |
| Local closures | Today and Inspection source evidence record receipt, closure, proof, and history paths. | Source-present only. |
| Local proof | Today, Goals, You, and Inspection inputs record receipt/proof/history detail surfaces and local proof artifacts. | Source-present only. |
| Local preferences | You source acceptance records preferences, appearance, Capture preferences, notifications, sources, local data, and account state details. | Source-present only. |
| No network dependency for core value | Truth files require offline core value and the local-first scan remains a hard static gate. | Static boundary only; no packet capture or runtime network instrumentation. |
| Account optionality | You and continuity/account source inputs record no-account mode, optional account state, offline core availability, and private-graph sync forbiddance. | Source-present only. |

## Gate Decision

- AMB-1767 may close only as Implemented Yellow under the current no-testing
  instruction.
- Current source and prior acceptance packets establish a local-first posture
  across root shell, Capture, Today, Goals, Time, and You.
- Source posture is not offline runtime proof. It does not prove a fresh-install
  walkthrough, airplane-mode execution, network silence, no-account device
  behavior, or account optionality in a running build.
- AMB-1744 and `ReleaseFrontendProofGate` keep empty/error/offline states,
  device proof, screenshots, rendered journeys, manual accessibility, Dynamic
  Type, Reduce Motion, visual review, and release proof blocked.
- AMB-1769 maps this lane to `AMB-ISSUE-0014`, `AMB-ISSUE-0807`,
  `AMB-ISSUE-2004`, `AMB-ISSUE-2005`, and `AMB-ISSUE-2007`; this packet does
  not close those known-issue rows.

## Rollback And Block Policy

- If no-account, offline, airplane-mode, or network-dependency proof is missing,
  block offline/no-account Green claims.
- If a source scan passes without a runtime walkthrough, keep the claim Yellow.
- If a future runtime packet contradicts this map, preserve the artifact, move
  the affected proof lane to Needs Repair, and do not treat this packet as
  runtime evidence.
- Do not substitute source-only, architecture-only, stale screenshots, previews,
  or simulator-only evidence for fresh-install, airplane-mode, or target-device
  offline/no-account proof.

## Proof Ceiling

Allowed claim:

- Current `main` contains an AMB-1767 offline/no-account frontend acceptance
  packet that maps required offline/no-account proof to retained source inputs,
  known issue rows, static gates, and explicit Yellow non-claims.

Forbidden claims from this packet:

- fresh-install no-account proof exists
- airplane-mode proof exists
- network-silence proof exists
- no-account device proof exists
- account optionality is runtime-proven
- local goals/captures/closures/proof/preferences were runtime-proven here
- screenshots exist
- accessibility conformance
- physical-device proof
- privacy/legal approval
- TestFlight readiness
- App Store readiness
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq . docs/audits/amb-1767-offline-no-account-frontend-acceptance.json` - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1767-offline-no-account-frontend-acceptance.md` - passed.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1767-offline-no-account-frontend-acceptance.md docs/audits/amb-1767-offline-no-account-frontend-acceptance.json` - passed.
- `scripts/release-claim-safety-scan.sh docs/audits/amb-1767-offline-no-account-frontend-acceptance.md docs/audits/amb-1767-offline-no-account-frontend-acceptance.json` - passed.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed.
- `python3 scripts/ambitions-architecture-inventory.py` - passed.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` - passed.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed.
- `scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1767-offline-no-account-frontend-acceptance.md docs/audits/amb-1767-offline-no-account-frontend-acceptance.json` - advisory Yellow reviewed; hits are canonical truth/context terms, not unsupported AI claims in this packet.
- `scripts/privacy-boundary-scan.sh docs/audits/amb-1767-offline-no-account-frontend-acceptance.md docs/audits/amb-1767-offline-no-account-frontend-acceptance.json` - advisory Yellow reviewed; hits are canonical truth/context terms, not privacy-boundary violations in this packet.
- `xcodegen generate --spec project.yml` - passed.
- `scripts/ambitions-xcodegen-needed.sh` - passed with `XCODEGEN_NEEDED=0`.

Commands not run:

- XCTest, UI test, simulator, screenshot, fresh-install no-account walkthrough,
  airplane-mode walkthrough, packet/network instrumentation, manual
  accessibility, performance walkthrough, physical-device, signed archive, and
  App Store Connect validation lanes - skipped under the current no-testing
  instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. Offline/no-account claims
  stay bounded to local-first source posture unless runtime proof exists.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `App/`, `Stage/`, `Composer/Capture`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Core/LocalRuntimeOS`, `Trust/`, `Quality/`, scripts, and audit docs.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1767-offline-no-account-frontend-acceptance.md`
  and `docs/audits/amb-1767-offline-no-account-frontend-acceptance.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow debt: fresh-install no-account, airplane-mode, packet/network
  instrumentation, no-account device, screenshots, manual accessibility,
  owner/privacy review, physical-device, and release proof remain absent.
- No equivalent folder/path interpretation was used.
