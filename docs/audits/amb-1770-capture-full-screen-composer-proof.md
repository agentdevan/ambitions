# AMB-1770 Capture Full-screen Composer Proof

Status: Implemented Yellow / full-screen source proof mapped without rendered
testing
Date: 2026-07-05
Scope: AMB-1770, Capture full-screen composer proof
Baseline SHA: `b3565302ab4619b3d5c1d853f2c09077c0e0879b`
Linear status before closeout: `In Progress`

## Purpose

AMB-1770 proves Capture is intended as the global full-screen composer and not a
tab, half-sheet, stale fake route, or root destination. The current user
instruction authorizes issue completion without running tests. This packet
therefore closes AMB-1770 only as Implemented Yellow by mapping the source route,
source full-screen seam, rollback policy, and missing proof lanes.

This packet does not produce a current Capture screenshot, keyboard screenshot,
manual VoiceOver proof, Dynamic Type proof, Reduce Motion proof, hit-target
proof, runtime route proof, simulator proof, physical-device proof, owner visual
approval, TestFlight readiness, App Store readiness, or Release Green.

## Authority Inputs

- `docs/audits/root-ia-stage-shell-acceptance.md`
- `docs/audits/capture-global-composer-acceptance.md`
- `docs/audits/amb-1744-frontend-screenshot-device-proof-matrix.md`
- `docs/audits/amb-1766-frontend-accessibility-acceptance.md`
- `docs/audits/amb-1769-frontend-known-issue-mapping.md`
- `Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift`
- `Native/Ambitions/Stage/Overlays/ShellOverlayState.swift`
- `Native/Ambitions/Stage/StagePathStore.swift`
- `Native/Ambitions/Stage/Chrome/DockBehaviorPolicy.swift`
- `Native/Ambitions/Stage/AmbitionsStage.swift`
- `Native/Ambitions/Stage/StageStore.swift`
- `Native/Ambitions/App/AppShellActivatedCaptureSeam.swift`
- `Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift`

## Source Proof Map

| AMB-1770 requirement | Current source evidence | Current status |
| --- | --- | --- |
| Capture is not a tab | Root IA acceptance records exactly Today, Goals, Time, and You as persistent roots; Capture is global composer only. | Source-present; not runtime-tapped here. |
| Capture is not a fake route | `StageStore.presentGlobalCaptureComposer(source:)` presents a real quick-Capture overlay state, not a new root surface. | Source-present. |
| Capture is not a half-sheet when activated | `QuietCommandCaptureOverlay.captureComposerRedirect` dismisses the quick sheet and calls `presentGlobalCaptureComposer(source:)`. `ShellOverlayState.isActivatedCaptureComposer` classifies quick-Capture overlays separately from ordinary sheets. | Source-present; no screenshot proof. |
| Full-screen seam exists | `StagePathStore.overlayPresentation(for:)` returns `.activatedCaptureComposer`; `AmbitionsStage.shellActivatedCaptureComposerSeam` renders `AppShellActivatedCaptureSeam` with max width and max height infinity. | Source-present; no rendered proof. |
| Dock/chrome does not make Capture a fifth root | `DockBehaviorPolicy.showsRootDock` only shows dock when overlay presentation is `.none`, so activated Capture is not dock/root-tab chrome. | Source-present; no screenshot proof. |
| Composer has local save path | `AppShellActivatedCaptureSeam.saveCapture()` routes `.quickCapture` through the shell command router; AMB-1736 maps that to local Capture creation and receipt/source paths. | Source-present; not executed here. |
| Dismissal/rollback path exists | `AppShellActivatedCaptureSeam` exposes close and accessibility dismissal actions that call `navigation.dismissOverlay()`. | Source-present; not runtime verified. |
| Accessibility source hooks exist | The seam has accessibility label, hint, dismissal action, stable identifiers, and Capture input identifiers; AMB-1766 keeps manual accessibility proof blocked. | Source-present; not manually verified. |
| Screenshot proof is required | AMB-1744 requires a current Global Capture screenshot covering composer, keyboard clearance, save/placement affordance, and dismissal path. | Required, not captured. |

## Gate Decision

- AMB-1770 may close only as Implemented Yellow under the current no-testing
  instruction.
- Current source supports the intended full-screen Capture composer route and
  blocks the obvious stale interpretations: Capture as root tab, half-sheet, or
  dead fake route.
- Source proof is not rendered product proof. Full-screen visual fit, keyboard
  clearance, safe areas, save/placement affordance, dismissal behavior,
  VoiceOver order, Dynamic Type, Reduce Motion, hit targets, and target-device
  behavior remain unproven.
- AMB-1744, AMB-1766, AMB-1769, and the known-issue mapping keep screenshot,
  accessibility, device, and release claims blocked.

## Rollback And Block Policy

- If a future runtime build shows Capture as a root tab, ordinary half-sheet, or
  unreachable route, move AMB-1770 to Needs Repair and block Capture proof
  claims.
- If screenshots or manual accessibility proof are missing, block Capture Green
  and release/frontend Green claims.
- If a source-only change preserves the route but alters the rendered layout,
  require a fresh screenshot/accessibility packet before any Green promotion.
- Do not substitute source-only, architecture-only, stale screenshot, preview,
  or simulator-only evidence for current Capture screenshot and target-device
  proof.

## Proof Ceiling

Allowed claim:

- Current `main` contains an AMB-1770 source proof packet showing the intended
  Capture full-screen composer route, source seam, non-tab/non-half-sheet
  routing, accessibility hooks, and rollback policy.

Forbidden claims from this packet:

- rendered full-screen Capture proof exists
- keyboard clearance proof exists
- Capture screenshot proof exists
- manual VoiceOver proof exists
- Dynamic Type proof exists
- Reduce Motion proof exists
- hit-target proof exists
- save/dismissal was runtime-verified here
- physical-device proof exists
- Capture Green
- Visual Green
- TestFlight readiness
- App Store readiness
- Release Green

## Validation

Commands run from `/Users/devan/Documents/GitHub/ambitions`:

- `git diff --check` - passed.
- `jq . docs/audits/amb-1770-capture-full-screen-composer-proof.json` - passed.
- `npx markdownlint-cli2 --no-globs docs/audits/amb-1770-capture-full-screen-composer-proof.md` - passed.
- `python3 scripts/ambitions-unsupported-claim-scan.py docs/audits/amb-1770-capture-full-screen-composer-proof.md docs/audits/amb-1770-capture-full-screen-composer-proof.json` - passed.
- `scripts/release-claim-safety-scan.sh docs/audits/amb-1770-capture-full-screen-composer-proof.md docs/audits/amb-1770-capture-full-screen-composer-proof.json` - passed.
- `python3 scripts/ambitions-screenshot-artifact-audit.py` - passed as static artifact-lane audit; no screenshots were produced.
- `python3 scripts/ambitions-device-proof-required.py` - passed as static device-proof guard; no device proof was produced.
- `python3 scripts/ambitions-remediation-governance-check.py` - passed.
- `python3 scripts/ambitions-architecture-inventory.py` - passed.
- `python3 scripts/ambitions-vocabulary-drift-scan.py` - passed.
- `python3 scripts/ambitions-truth-path-vocabulary-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `python3 scripts/ambitions-accepted-yellow-misuse-audit.py` - passed.
- `scripts/no-unsupported-ai-claim-scan.sh docs/audits/amb-1770-capture-full-screen-composer-proof.md docs/audits/amb-1770-capture-full-screen-composer-proof.json` - advisory Yellow reviewed; hits are canonical truth/context terms, not unsupported AI claims in this packet.
- `scripts/privacy-boundary-scan.sh docs/audits/amb-1770-capture-full-screen-composer-proof.md docs/audits/amb-1770-capture-full-screen-composer-proof.json` - advisory Yellow reviewed; hits are canonical truth/context terms, not privacy-boundary violations in this packet.
- `xcodegen generate --spec project.yml` - passed.
- `scripts/ambitions-xcodegen-needed.sh` - passed with `XCODEGEN_NEEDED=0`.

Commands not run:

- XCTest, UI test, simulator, screenshot, Capture keyboard walkthrough, manual
  accessibility, performance walkthrough, physical-device, signed archive, and
  App Store Connect validation lanes - skipped under the current no-testing
  instruction.

## Closeout Notes

- Private Life Orchestration relationship: preserved. Capture remains a global
  intent intake object, not a fifth tab or generic route.
- Final Architecture Tree inspected: yes.
- Canonical owners inspected: `Stage/`, `App/`, `Composer/Capture`, `Quality/`,
  scripts, and audit docs.
- Canonical owners touched: none in production source.
- Files created: `docs/audits/amb-1770-capture-full-screen-composer-proof.md`
  and `docs/audits/amb-1770-capture-full-screen-composer-proof.json`.
- Files moved: none.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow debt: current screenshot, keyboard, safe-area, dismissal, manual
  accessibility, Dynamic Type, Reduce Motion, hit-target, physical-device,
  owner visual review, and release proof remain absent.
- No equivalent folder/path interpretation was used.
