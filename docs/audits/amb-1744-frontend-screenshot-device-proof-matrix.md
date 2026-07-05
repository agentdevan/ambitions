# AMB-1744 Frontend Screenshot / Device Proof Matrix

Status: Implemented Yellow / App Store frontend Green blocked
Date: 2026-07-05
Scope: AMB-1744, M11 Device Proof / App Store Frontend Gate
Baseline SHA: `6b41d8f3837c5978b48d18ccb83ba34ff1fee126`
Linear status before closeout: `In Progress`

## Purpose

AMB-1744 is the frontend device/App Store gate. It closes only by making the
required proof matrix explicit, keeping the current release posture blocked, and
preventing simulator-only, architecture-only, source-only, or Accepted Yellow
evidence from becoming App Store frontend Green.

The current user instruction authorizes issue completion without running tests.
This packet therefore completes the device/screenshot/release proof matrix as
Implemented Yellow. It does not produce current screenshots, physical-device
evidence, manual accessibility proof, owner visual review, signed archive proof,
or App Store Connect validation.

## Release Gate Inputs

Retained gate inputs:

- `Native/Ambitions/Quality/ReleaseFrontendProofGate.swift`
- `Native/Ambitions/Support/ReleaseCandidateLockDecisionReport.swift`
- `Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift`
- `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.md`
- `docs/audits/amb-1750-visual-green-app-store-frontend-proof-gate.json`
- `docs/audits/amb-1749-frontend-evidence-harness.md`
- `docs/audits/amb-1743-release-grade-frontend-qa-acceptance.md`

Current release blocker IDs from source:

- `frontend-visual-app-store-proof`
- `physical-device-smoke`
- `manual-accessibility`
- `signed-archive-store-validation`
- `external-platform-proof`
- `store-material-assets`

## Device Matrix

| Device class | Required proof | Current status | Release result |
| --- | --- | --- | --- |
| Primary current iPhone | Fresh install, launch, root shell, safe areas, keyboard behavior, Capture, Today, Goals, Time, You, inspection details, offline/no-account paths, and performance smoke. | Not run under current no-testing instruction. | Red for App Store frontend Green; Yellow issue completion only. |
| Accessibility-size iPhone run | Dynamic Type accessibility sizes, VoiceOver order, clipping/overlap, tap targets, contrast, Reduce Motion, and non-color meaning. | Not run. Automated requirement coverage exists, but manual/rendered proof is missing. | Red for accessibility or release claims. |
| Lower/smaller supported iPhone class | Root shell, dock, first viewport, keyboard, modal/sheet fit, and scroll depth. | Not run. | Yellow risk until proven on current supported device class. |
| External surface/device integration | Widget/share/notification/shortcut/handoff/device shared-container behavior where enabled. | Not run. External surface proof remains release-blocking. | Red for platform claims. |

No physical device can be counted Green from this packet.

## Screenshot Matrix

| Screenshot scope | Required evidence | Current status | Claim status |
| --- | --- | --- | --- |
| Launch/root shell | Current screenshot with build SHA, safe-area review, and root destination review. | Not captured. | Blocked. |
| Global Capture | Current screenshot covering composer, keyboard clearance, save/placement affordance, and dismissal path. | Not captured. | Blocked. |
| Today | Current Start here / Reality Meridian screenshot, detail/recovery state, receipt/proof affordance. | Not captured. | Blocked. |
| Goals | Current Constellation Atlas, goal detail, create/edit route, proof/history affordance. | Not captured. | Blocked. |
| Time | Current LifeShape Field, weekly review, reflow/constraint detail, Dynamic Type and Reduce Motion variants. | Not captured. | Blocked. |
| You | Current User System Profile, privacy/local-first/account state, settings/detail rows, proof/history/receipts. | Not captured. | Blocked. |
| Inspection details | Proof, Source, Privacy, History, Receipts invocation and return path. | Not captured. | Blocked. |
| Empty/error/offline states | Offline/no-account, degraded, denied permission, empty data, and recovery states. | Not captured. | Blocked. |
| Dynamic Type | Accessibility-size screenshots across root shell and launch-critical paths. | Not captured. | Blocked. |

AMB-1749 defines stable screenshot artifact lanes, but no current artifacts are
attached by this AMB-1744 packet.

## Known-Risk Ledger

| Risk | Severity | Current evidence | Required release action |
| --- | --- | --- | --- |
| Current physical-device proof missing | Red | `ReleaseCandidateLockDecisionReport` blocker `physical-device-smoke`. | Run target-device journeys or keep App Store/TestFlight frontend claims blocked. |
| Final screenshot packet missing | Red | `ReleaseExternalTruthReadinessPacket.screenshots` is `needsHumanAsset`; AMB-1749 only defines artifact lanes. | Capture and review current screenshots from final build data. |
| Manual accessibility proof missing | Red | `ReleaseCandidateLockDecisionReport` blocker `manual-accessibility`. | Complete manual VoiceOver, Dynamic Type, Reduce Motion, contrast, motor/tap-target, and external-surface proof. |
| Owner visual review missing | Red | AMB-1750 keeps frontend status Yellow until human review and current artifacts exist. | Record explicit owner review before any Visual Green claim. |
| Accepted Yellow counted as Green | Blocked by gate | `ReleaseFrontendProofGate.acceptedYellowCountsAsGreen` is false. | Preserve separation; do not downgrade this rule. |
| External platform proof missing | Red | `ReleaseCandidateLockDecisionReport` blocker `external-platform-proof`. | Verify enabled widgets/share/notifications/shortcuts/handoff on device or remove claims. |
| Store material assets missing | Red | `ReleaseCandidateLockDecisionReport` blocker `store-material-assets`. | Provide curated screenshots and live support/privacy URLs before submission. |
| Signed archive/App Store validation missing | Red | `ReleaseCandidateLockDecisionReport` blocker `signed-archive-store-validation`. | Run signed archive and App Store Connect validation on the release Mac. |

## Frontend Release Packet

Current packet status:

- Frontend quality status: Yellow.
- Accepted Yellow counts as Green: false.
- Visual Green claim allowed: false.
- App Store frontend claim allowed: false.
- Device-sensitive claims require device evidence: true.

Current app posture from source remains not App Store submission-ready. The
investor/demo posture may be prepared with limitations, but that is not
TestFlight, App Store, device, accessibility, or release proof.

## Acceptance Mapping

| AMB-1744 acceptance criterion | Current result |
| --- | --- |
| Core journeys pass on target device matrix or have explicit Yellow risk. | No target-device journeys were run. Every required device journey is classified Red/Yellow release risk above. |
| Screenshots prove launch, root shell, Capture, Today, Goals, Time, You, inspection details, empty/error/offline states, and Dynamic Type. | Not produced. Required screenshot scopes are enumerated and remain blocked. |
| Accessibility and motion settings are verified for release-critical paths. | Not verified. Manual/rendered accessibility and motion proof remain required. |
| Accepted Yellow is not counted as Green. | Present through `ReleaseFrontendProofGate.acceptedYellowCountsAsGreen == false`. |
| Release-readiness claims are scoped and evidence-backed. | Present as a non-claim gate: App Store/TestFlight/frontend Green claims remain blocked. |
| Final screenshot packet is current, labeled, and reviewable. | Not produced; stable lanes exist through AMB-1749 only. |
| Release-critical VoiceOver, Dynamic Type, contrast, and motion-sensitive behavior have proof. | Not produced; proof remains required before release claims. |
| Simulator-only or architecture-only proof cannot close device/App Store frontend Green. | Present. This packet keeps App Store frontend Green blocked. |
| Rollback plan blocks release claim and links follow-up for Yellow/Red gaps. | Present. There is no current Green build in this packet; rollback is to block release claims and keep follow-up gates open. |

## Rollback And Block Policy

- If any required device, screenshot, accessibility, visual-review, external
  platform, store asset, or signed validation proof is missing, block the
  release claim.
- If a later proof lane is flaky, disable that lane only with artifact capture
  preserved and a Needs Repair follow-up.
- Do not replace missing proof with simulator-only, source-only, architecture,
  preview, fixture, or old screenshot evidence.
- If a future build is ever accepted as Green, retain that exact build SHA and
  artifact packet before any rollback. This packet does not establish such a
  Green build.

## Proof Ceiling

Allowed claim:

- Current `main` has an explicit frontend device/App Store proof matrix, known
  risk ledger, release packet mapping, and rollback/block policy that keeps
  frontend release quality Yellow and App Store frontend Green blocked.

Forbidden claims from this packet:

- final screenshot packet exists
- current rendered visual quality
- owner visual approval
- accessibility conformance
- motion/accessibility readiness
- physical-device behavior
- external platform/device proof
- signed archive validation
- TestFlight readiness
- App Store readiness
- frontend Visual Green
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq . docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.json`
  - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md`
  - passed, `Summary: 0 error(s)`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.json`
  - passed, `GREEN: unsupported completion/readiness claim scan passed`.
- `scripts/release-claim-safety-scan.sh docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.json`
  - passed, `GREEN proof-sensitive release terms are framed as non-claims,
  boundaries, or future proof`.
- `python3 scripts/ambitions-screenshot-artifact-audit.py` - passed,
  `ambitions-screenshot-artifact-audit GREEN`.
- `python3 scripts/ambitions-device-proof-required.py` - passed,
  `ambitions-device-proof-required GREEN`.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed,
  `GREEN remediation governance guard passed`.
- `python3 scripts/ambitions-architecture-inventory.py` - passed,
  `GREEN final-tree parity achieved`.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` - passed,
  `GREEN: canonical and active vocabulary terms are present and explicit ban
  terms are absent`.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py` - passed,
  `GREEN: truth paths resolve or are explicitly planned/internal, and active
  stale terms are quarantined`.
- `python3 scripts/ambitions-green-standard-audit.py` - passed,
  `GREEN: no disallowed architecture-as-UI strings found in active primary UI
  source`.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed,
  `GREEN: local-first/account/R2/hosted-AI boundary checks passed in active
  authority files`.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed,
  `valid=true`, `invalidAcceptedYellowIssues=0`.
- `scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.json`
  - advisory Yellow; review showed contextual non-claim terms only.
- `scripts/privacy-boundary-scan.sh docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.json`
  - advisory Yellow; review showed contextual privacy/local-first terms only.
- `xcodegen generate --spec project.yml` - passed.
- `scripts/ambitions-xcodegen-needed.sh` - passed, `XCODEGEN_NEEDED=0`.

Commands not run:

- XCTest, UI test, simulator, screenshot, manual accessibility, performance
  walkthrough, physical-device, signed archive, and App Store Connect validation
  lanes - skipped under the current no-testing instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. The gate prevents the
  personal-life product experience from being promoted to release quality
  without current human/device proof.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `Quality/`, `Support/`, `App/`, `Stage/`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Composer/Capture`, `Trust/`, release support, scripts, and audit docs.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md`
  and `docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: current screenshots, owner visual review, manual
  accessibility, Dynamic Type, Reduce Motion, physical-device proof, external
  platform proof, signed archive validation, App Store Connect validation, and
  live support/privacy URL proof remain outside this packet.
- Next proof train: AMB-1765, AMB-1766, AMB-1767, AMB-1770, AMB-1774, and
  AMB-1775 when testing/device proof is re-enabled.
- No equivalent folder/path interpretation was used.
