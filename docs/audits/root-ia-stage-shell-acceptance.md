# AMB-1735 Root IA / Stage Shell Acceptance

Status: Implemented Yellow / source-route acceptance
Date: 2026-07-05
Scope: AMB-1735
Baseline SHA: `4247dc2eb59f0fb1c269e81d4c1c5a8ac24a2a49`

## Purpose

AMB-1735 accepts the current root IA and Stage shell source-route spine before
surface polish continues.

This is a parent synthesis artifact. It does not implement UI, produce new
screenshots, run UI journeys, prove accessibility, prove device behavior, close
AMB-1479, or claim Visual Green.

## Current Acceptance Result

| Acceptance area | Current source result | Proof ceiling |
| --- | --- | --- |
| Persistent surfaces | `AmbitionsSurface` exposes exactly `.today`, `.goals`, `.time`, and `.you`; raw-value init rejects other roots. | Source-route Yellow until current launch/screenshot/device proof runs. |
| Root shell host | `AmbitionsRootStageSurfaceHost` switches only Today, Goals, Time, and You. | Source-route Yellow; no rendered route journey was run here. |
| Dock chrome | `StageDockDestination.all` derives from `AmbitionsSurface.allCases`; `StageDockRail` renders only those destinations. | Source-route Yellow; no screenshot, hit-target, or VoiceOver pass was run here. |
| Capture | `SurfaceOwnershipRegistry.globalComposer` has `canonicalTab: nil`; Capture routes through overlays/seams, not root tabs. | Source-route Yellow until AMB-1736/AMB-1770 produce Capture journey proof. |
| Motion | `SurfaceOwnershipRegistry.motionBehavior` has `canonicalTab: nil`; Motion routes behavior to canonical surfaces/overlays. | Source-route Yellow until rendered/reduced-motion proof exists. |
| Trust inspection | `SurfaceOwnershipRegistry.trustInspection` is contextual; You routes own History and detail inspection paths. | Source-route Yellow until invocation and return-route proof exists. |
| Stale IA drift | AMB-1768 classifies stale labels and guard language; no active product-law drift remains blocking AMB-1735 source acceptance. | Yellow label/copy debt remains for AMB-1776 and label hygiene. |
| Dead/unclear routes | AMB-1751 found no active production route exposing `Plan`, `Pulse`, `Profile`, `Captures`, `Motion`, or `Capture` as a root tab. | Yellow until current runtime route and screenshot proof runs. |

## Evidence Chain

Current source evidence:

- `Native/Ambitions/Stage/AmbitionsSurface.swift`
  - four canonical cases: Today, Goals, Time, You
  - `allCases` returns only those four
  - invalid raw values return `nil`
- `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift`
  - root switch contains only Today, Goals, Time, You
  - Goals, Time, and You details stay inside their owning navigation stacks
- `Native/Ambitions/Stage/StageChrome.swift`
  - dock destinations derive from `AmbitionsSurface.allCases`
- `Native/Ambitions/Stage/Chrome/StageDockRail.swift`
  - shell rail renders the derived destination list with accessibility labels
- `Native/Ambitions/Stage/SurfaceOwnershipRegistry.swift`
  - persistent surfaces are Today, Goals, Time, You
  - Capture is global composer only
  - Motion is behavior only
  - Proof / Source / Privacy / History / Receipts are contextual inspection

Current docs/evidence artifacts:

- `docs/audits/amb-1747-stage-shell-frontend-reality-audit.md`
- `docs/audits/frontend-screen-route-registry.md`
- `docs/audits/frontend-journey-registry.md`
- `docs/audits/frontend-missing-screen-audit.md`
- `docs/audits/frontend-deletion-quarantine-candidates.md`
- `docs/audits/frontend-product-law-drift-scan.md`

Pre-existing route-test evidence is recorded in AMB-1747, but those tests were
not rerun for AMB-1735 under the current no-testing instruction.

## Root IA Decision

AMB-1735 may close as Implemented Yellow because the current source-route spine
meets the product-law structure:

- Today / Goals / Time / You are the only persistent root surfaces.
- Capture is global and not a tab.
- Motion is behavior and not a destination.
- Proof / Source / Privacy / History / Receipts remain inspection paths.
- Dead or unclear root routes are classified in AMB-1751 and AMB-1768.

AMB-1735 must not close Green because the issue's visual/accessibility proof
requirements are not met in this pass.

## Remaining Yellow Debt

- AMB-1479 remains the visual specification authority repair blocker for broad
  visual authority and UI implementation claims.
- Root shell screenshots for target iPhone size, Dynamic Type, Reduce Motion,
  and offline/empty state were not produced here.
- VoiceOver names and traversal order were not exercised here.
- Hit targets, safe areas, route-depth visual behavior, and first-viewport
  hierarchy were not validated here.
- Device proof was not produced here.
- Capture save/placement/dismissal proof remains AMB-1736/AMB-1770 scope.
- Search Find / Act / Inspect proof remains AMB-1764/AMB-1771 scope.
- Stale label and copy cleanup remains AMB-1776 and label hygiene scope.

## Follow-Up Routing

| Follow-up | Owner | Reason |
| --- | --- | --- |
| AMB-1479 | Visual specification authority | Blocks Visual Green and broad UI implementation authority. |
| AMB-1736 | Capture-to-Today usable flow | Proves Capture as global composer with local save and visible return path. |
| AMB-1743 / AMB-1766 | Accessibility acceptance | Proves VoiceOver, Dynamic Type, Reduce Motion, contrast, and hit targets. |
| AMB-1744 / AMB-1765 / AMB-1775 | Screenshot and device proof | Produces current shell/surface screenshot matrix and device proof. |
| AMB-1764 / AMB-1771 | Search acceptance | Proves local-only Find / Act / Inspect behavior and stale destination blockers. |
| AMB-1776 | Copy/state language audit | Cleans dashboard, pulse, profile, chatbot, guilt, fake certainty, and stale-root language. |

## Proof Ceiling

Claim status for AMB-1735: Implemented Yellow.

Allowed claim:

- Current source and current audit artifacts support the root IA / Stage shell
  source-route structure.

Forbidden claims from this packet:

- root shell Green
- rendered frontend Green
- Visual Green
- accessibility conformance
- screenshot proof
- device proof
- release readiness
- App Store readiness
- AMB-1479 closure

## Rollback

This packet adds docs only. Roll back by reverting the AMB-1735 audit artifact
without changing the current Stage shell source. If future shell source changes
regress the four-root structure, revert the source change and retain the
AMB-1751/AMB-1768 evidence as the comparison baseline.
