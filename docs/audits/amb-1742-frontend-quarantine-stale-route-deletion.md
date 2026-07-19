# AMB-1742 Frontend Quarantine / Stale Route Deletion

Status: Implemented Yellow / completion authorized without runtime testing
Date: 2026-07-05
Scope: AMB-1742, M09 Frontend Deletion / Quarantine
Baseline SHA: `415b2d8f99076560fffff6ad114146a4bea7e6ad`
Linear status before closeout: `In Progress`

## Purpose

AMB-1742 classifies frontend deletion and quarantine candidates so stale
surfaces, preview-only UI, fake fixture flows, duplicate routes, and internal
jargon cannot be mistaken for launch-ready product evidence.

This packet does not delete launch-critical source. The current user instruction
authorizes completion of issues without running tests, but AMB-1742 still cannot
claim Green because its Linear acceptance requires build, route, screenshot, and
accessibility proof. This packet therefore closes the source-owner quarantine
contract as Implemented Yellow and preserves exact follow-up proof gates before
any route deletion or visual/release claim.

## Controlling Scope

Linear required these classifications:

- Keep and harden.
- Replace in place.
- Strangle with new implementation.
- Quarantine.
- Delete.
- Unknown until route/test proves use.

Linear required proof that deletion/quarantine candidates have route or
source-owner evidence, that launch-critical journeys are not deleted without
replacement, that preview-only or fixture UI does not remain in primary runtime
paths, that Motion-as-destination and inspection-as-surface violations are
removed or linked to repair, and that builds, tests, screenshots, and
accessibility checks prove launch and journey reachability.

## Classification Ledger

| Candidate | Classification | Evidence | Decision |
| --- | --- | --- | --- |
| Canonical root shell | Keep and harden | `AmbitionsSurface` exposes only Today, Goals, Time, You; `AmbitionsRootStageSurfaceHost` switches only those roots; `StageDockDestination.all` derives from those roots; `SurfaceOwnershipRegistry` validates Capture/Motion are not root surfaces. | Keep. This is launch-critical and cannot be deleted. |
| Today / Goals / Time / You surface routes | Keep and harden | `docs/audits/frontend-screen-route-registry.md` maps each root to source owners and proof gaps. | Keep. Deletion would break the product spine. |
| Global Capture composer | Keep and harden | `SurfaceOwnershipRegistry.globalComposer` has no canonical tab, and shell routing presents Capture as overlay/composer. | Keep as global composer, not a root destination. |
| Stage/Motion behavior layer | Keep and harden | `SurfaceOwnershipRegistry.motionBehavior` marks Motion as behavior only, and Stage Motion actions route into canonical roots or overlays. | Keep under `Stage/Motion`; no Motion root deletion needed because no active Motion root was found. |
| Trust inspection wrappers | Keep and harden / proof-limited | `ProofInspectionView`, `SourceInspectionView`, `PrivacyInspectionView`, `HistoryInspectionView`, and `ReceiptInspectionView` are contextual trust details, with You route ownership documented in the screen registry. | Keep, but do not cite as rendered route proof until invocation evidence exists. |
| Preview/development assets under `Native/Ambitions/PreviewSupport` | Quarantine | `project.yml` keeps this path only as `DEVELOPMENT_ASSET_PATHS`; no primary runtime route may cite it as proof. | Quarantine as preview-only. Do not delete before production-import scan and Xcode validation. |
| Historical screenshot and VSP/Figma evidence folders | Quarantine | `docs/audits/frontend-deletion-quarantine-candidates.md` classifies historical screenshots and prototype packages as docs-only/design-reference evidence. | Quarantine as historical or prototype evidence, not current rendered proof. |
| Stale root labels in tests and fixtures | Quarantine | Current scan finds stale labels in negative assertions, fixtures, and copy audits, not as active production roots. | Keep negative assertions; quarantine fixture/copy hits from product-evidence claims. |
| `ShellCommandDestination.staleIADestinationBlockers` | Keep and harden | Active guard blocks stale destinations such as Plan, Pulse, Profile, Calendar, and Inbox. | Keep. Deleting this guard would remove current stale-route protection. |
| You copy containing profile terminology | Replace in place | AMB-1740 normalized first-viewport/detail language toward `User System Profile`; remaining test/copy references need focused review. | Replace only with source-owner review and screenshots when testing returns. |
| Time calendar-language copy | Keep and harden / review | Canon allows calendar-grade Time behavior while forbidding calendar-clone or silent-write claims. | Keep unless a focused copy audit proves stale root-route framing. |
| External route and snapshot contracts | Unknown until route/test proves use | Screen registry marks deep links, widgets, share extension, app intents, and external snapshots as source-present but proof-limited. | Do not delete in frontend cleanup; require external-route proof train. |
| Actual source deletion batch | Delete: none selected | No launch/runtime/screenshot proof was run under the current no-testing instruction. | No production source deletion is authorized by this packet. |

## Runtime Path Quarantine Rules

- `Native/Ambitions/PreviewSupport/**` can support previews and development
  assets only.
- `docs/qa/evidence/**` historical screenshots, VSP packages, and Figma packages
  can support historical/design-reference context only.
- Negative-assertion tests that mention stale roots may support absence checks,
  but cannot be cited as active surface evidence.
- Inspection wrappers are contextual trust details under their owner routes, not
  top-level surfaces.
- Capture remains a global composer/action layer, not a tab.
- Motion remains Stage behavior, not a destination.

## Acceptance Mapping

| AMB-1742 acceptance criterion | Current result |
| --- | --- |
| Every deletion/quarantine candidate has route evidence or source-owner evidence. | Present for the candidates classified above, backed by the AMB-1751 route registry, journey registry, and deletion/quarantine registry. |
| No launch-critical journey is deleted without replacement. | Present. No production route or launch-critical source was deleted in this packet. |
| Preview-only/fake fixture UI cannot remain in primary runtime paths. | Present as a quarantine rule and source-owner classification. `PreviewSupport` remains development assets only. |
| Motion-as-destination and inspection-as-surface violations are removed or linked to repair. | No active Motion root was found. Inspection routes remain contextual under You/Trust and are proof-limited until invocation evidence exists. |
| Build/tests/screenshots prove the app still launches and journeys remain reachable. | Not run by user instruction. This blocks Green and leaves AMB-1742 Implemented Yellow. |

## Follow-Up Gates

| Gate | Scope | Required proof before deletion or Green |
| --- | --- | --- |
| AMB-1742-FU-01 | PreviewSupport quarantine hardening | Production import scan, XcodeGen drift check, focused build validation, and proof that no runtime path depends on preview-only fixtures. |
| AMB-1742-FU-02 | Stale label cleanup | Split negative assertions from stale fixture/copy references and run copy scans plus focused screenshots for any user-facing copy change. |
| AMB-1742-FU-03 | Trust inspection invocation proof | Rendered route proof for Proof, Source, Privacy, History, and Receipts under their owning routes, including return paths. |
| AMB-1742-FU-04 | External route retention/deletion proof | Deep link, widget, share extension, app intent, notification, and handoff route proof before any external contract deletion. |
| AMB-1742-FU-05 | Deletion batch proof | Revertable deletion commit, retained removed-path inventory, build/test/screenshot/accessibility evidence, and rollback note. |

## Proof Ceiling

Allowed claim:

- Current `main` has a source-owner deletion/quarantine contract for AMB-1742
  that classifies stale route, preview-only, fake-fixture, trust-inspection,
  Capture, Motion, and external-route candidates without deleting
  launch-critical product paths.

Forbidden claims from this packet:

- Visual Green
- rendered route proof
- accessibility conformance
- physical-device behavior
- TestFlight readiness
- App Store readiness
- Release Green
- broad deletion safety for any future source batch

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq . docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.json`
  - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.md`
  - passed, `Summary: 0 error(s)`.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.md docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.json`
  - passed, `GREEN: unsupported completion/readiness claim scan passed`.
- `scripts/release-claim-safety-scan.sh docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.md docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.json`
  - passed, `GREEN proof-sensitive release terms are framed as non-claims,
  boundaries, or future proof`.
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
- `scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.md docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.json`
  - advisory Yellow; hit broad truth-file context and did not identify an
  unsupported claim in this packet.
- `scripts/privacy-boundary-scan.sh docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.md docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.json`
  - advisory Yellow; hit broad privacy/local-first truth-file context and did
  not change this packet's non-claim boundary.
- `xcodegen generate --spec project.yml` - passed.
- `scripts/ambitions-xcodegen-needed.sh` - passed, `XCODEGEN_NEEDED=0`.

Commands not run:

- `python3 scripts/ambitions-vocabulary-drift.py` - not present on current
  `main`; replaced with `python3 scripts/ambitions-vocabulary-drift-scan.py`.
- `python3 scripts/ambitions-no-unsupported-ai-claims.py` - not present on
  current `main`; replaced with `scripts/no-unsupported-ai-claim-scan.sh`.
- `python3 scripts/ambitions-privacy-boundary-scan.py` - not present on current
  `main`; replaced with `scripts/privacy-boundary-scan.sh`.
- XCTest, UI test, simulator, screenshot, accessibility runtime, and device
  lanes - skipped under the current no-testing instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. The packet protects the
  active Today / Goals / Time / You root spine, global Capture, Motion behavior,
  contextual trust inspection, and local route evidence boundaries.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `App/`, `Stage/`, `Stage/Motion/`, `Trust/`,
  `Surfaces/Today`, `Surfaces/Goals`, `Surfaces/Time`, `Surfaces/You`,
  `Composer/Capture`, `Projection/ExternalSnapshots`, `Quality/`, and
  `PreviewSupport`.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.md`
  and `docs/audits/amb-1742-frontend-quarantine-stale-route-deletion.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: rendered launch, route, screenshot, accessibility,
  external-route, and deletion-batch proof remain outside this packet.
- Next repair/proof train: AMB-1742-FU-01 through AMB-1742-FU-05, with AMB-1749
  evidence harness and AMB-1750 visual/release gate before any Green claim.
- No equivalent folder/path interpretation was used.
