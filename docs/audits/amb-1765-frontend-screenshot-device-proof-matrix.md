# AMB-1765 Frontend Screenshot / Device Proof Matrix

Status: Implemented Yellow / duplicate proof lane reconciled without runtime testing
Date: 2026-07-05
Scope: AMB-1765, frontend screenshot and device proof matrix
Baseline SHA: `7d66a83e31fe860dd3791fdc1c96376ba6ea5eb1`
Linear status before closeout: `In Progress`

## Purpose

AMB-1765 is the proof-lane version of the screenshot/device matrix. It is
closed by pointing the lane to the already-committed AMB-1744 matrix, adding the
AMB-1765 issue linkage, and preserving the proof ceiling that blocks Visual
Green, accessibility Green, device claims, TestFlight readiness, App Store
readiness, and Release Green.

The current user instruction authorizes issue completion without running tests.
This packet therefore completes AMB-1765 as Implemented Yellow. It does not
produce screenshots, simulator evidence, physical-device evidence, manual
accessibility proof, Dynamic Type proof, Reduce Motion proof, or owner visual
approval.

## Matrix Inputs

- `docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md`
- `docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.json`
- `docs/audits/amb-1749-frontend-evidence-harness.md`
- `docs/audits/amb-1749-frontend-evidence-harness.json`
- `docs/audits/amb-1743-release-grade-frontend-qa-acceptance.md`
- `Native/Ambitions/Quality/ReleaseFrontendProofGate.swift`
- `Native/Ambitions/Support/ReleaseCandidateLockDecisionReport.swift`
- `Native/Ambitions/Support/ReleaseExternalTruthReadinessPacket.swift`

## AMB-1765 Required Matrix

| Required scope | Current lane | Current status |
| --- | --- | --- |
| Shell root | AMB-1744 screenshot matrix | Required, not captured. |
| Drilldown / route depth | AMB-1749 route-depth lanes plus AMB-1744 matrix | Required, not run in this packet. |
| Today | AMB-1744 screenshot matrix | Required, not captured. |
| Goals | AMB-1744 screenshot matrix | Required, not captured. |
| Time | AMB-1744 screenshot matrix | Required, not captured. |
| You | AMB-1744 screenshot matrix | Required, not captured. |
| Capture | AMB-1744 screenshot matrix | Required, not captured. |
| Search | AMB-1744 screenshot matrix plus AMB-1764 / AMB-1771 source packets | Required, not captured. |
| Light / System / Dark | AMB-1744 matrix and AMB-1191 proof ceiling | Required, not captured. |
| Dynamic Type | AMB-1744 matrix and AMB-1743 QA ladder | Required, not manually/run-time verified. |
| Reduce Motion | AMB-1744 matrix and AMB-1743 QA ladder | Required, not manually/run-time verified. |
| First viewport | AMB-1744 matrix | Required, not captured. |
| Safe area | AMB-1744 matrix and release gate | Required, not captured. |
| Real device proof | AMB-1744 device matrix | Required before visual quality claims; not produced. |

## Gate Decision

- AMB-1744 is the parent screenshot/device proof matrix and remains the
  authoritative artifact for the required device/screenshot/release proof lanes.
- AMB-1765 adds no new device evidence. It reconciles the leaf issue to that
  parent matrix and keeps the same Green blockers.
- AMB-1479 remains a Visual Specification Authority blocker for Visual Green and
  broad frontend visual promotion.
- AMB-1751 provides current-main route/screen/journey evidence input, but it is
  not screenshot, device, accessibility, or release proof.

## Rollback And Block Policy

- If any required screenshot, device, accessibility, safe-area, route-depth,
  Dynamic Type, Reduce Motion, owner visual review, signed archive, or App Store
  proof is missing, block the corresponding readiness claim.
- Do not replace missing proof with source-only, matrix-only, stale screenshot,
  simulator-only, or historical device-review evidence.
- If later screenshots contradict the matrix, keep the artifact, move the lane
  to Needs Repair, and preserve the blocking issue reference.

## Proof Ceiling

Allowed claim:

- Current `main` contains an AMB-1765 leaf-level screenshot/device proof matrix
  reconciliation that points to AMB-1744 and blocks visual/device/release claims
  until current artifacts exist.

Forbidden claims from this packet:

- screenshots were captured
- device proof exists
- safe-area proof exists
- Dynamic Type proof exists
- Reduce Motion proof exists
- manual accessibility proof exists
- owner visual approval exists
- frontend Visual Green
- Accessibility Green
- TestFlight readiness
- App Store readiness
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq . docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.json`
  - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.md`
  - passed, `Summary: 0 error(s)`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.md docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.json`
  - passed, `GREEN: unsupported completion/readiness claim scan passed`.
- `scripts/release-claim-safety-scan.sh docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.md docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.json`
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
- `scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.md docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.json`
  - advisory Yellow; review showed truth-file context and explicit non-claims.
- `scripts/privacy-boundary-scan.sh docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.md docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.json`
  - advisory Yellow; review showed broad truth-file privacy/local-first context
  and explicit AMB-1765 non-claims.
- `xcodegen generate --spec project.yml` - passed.
- `scripts/ambitions-xcodegen-needed.sh` - passed, `XCODEGEN_NEEDED=0`.

Commands not run:

- XCTest, UI test, simulator, screenshot, manual accessibility, performance
  walkthrough, physical-device, signed archive, and App Store Connect validation
  lanes - skipped under the current no-testing instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. Release-sensitive proof
  remains blocked unless current artifacts support it.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `Quality/`, `Support/`, `App/`, `Stage/`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Composer/Capture`, `Trust/`, release support, scripts, and audit docs.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.md`
  and `docs/audits/amb-1765-frontend-screenshot-device-proof-matrix.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow debt: all current screenshots, physical-device proof, manual
  accessibility, Dynamic Type, Reduce Motion, safe-area, route-depth, owner
  visual review, signed archive, and App Store Connect proof remain absent.
- Next proof train: AMB-1765 remains a matrix closeout only until testing/device
  proof is re-enabled; AMB-1775 owns shell chrome screenshot detail.
- No equivalent folder/path interpretation was used.
