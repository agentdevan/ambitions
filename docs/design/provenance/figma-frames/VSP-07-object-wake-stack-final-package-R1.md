# VSP-07 Object Wake Stack Final Package R1

Status: Yellow / Ready For Review

This frame note maps the VSP-07 final Figma candidate package to Code-Connect-free provenance. It is a handoff record for owner review, not implementation authority, Visual Green, source parity, device proof, accessibility conformance, runtime proof, Release Green, or Done.

## Source Direction

- Approved Part 01 direction: `F Attached Receipt Stack`
- Approved Part 02 direction: `A Object Wake Stack`
- Part 02 source node: `250:104`
- Final package board: `257:93`
- Figma file: `SWtHm9ouHTPbEFfNrrtZwv`

The owner approved `A Object Wake Stack` as the VSP-07 Part 02 direction on 2026-07-01. The final package board now needs explicit owner review before source implementation begins.

## Final Package Frames

| Purpose | Frame | Node |
|---|---|---:|
| Package board | `CANDIDATE - VSP-07 - Object Wake Stack final package - R1` | `257:93` |
| Hero | `CANDIDATE - VSP-07 - Object Wake Stack hero - R1` | `257:102` |
| State matrix | `CANDIDATE - VSP-07 - Object Wake Stack state matrix - R1` | `257:151` |
| Accessibility matrix | `CANDIDATE - VSP-07 - Object Wake Stack accessibility matrix - R1` | `257:238` |
| SwiftUI anatomy | `CANDIDATE - VSP-07 - Object Wake Stack SwiftUI anatomy - R1` | `257:273` |
| Presentation crop | `MARKETING_RENDER - VSP-07 - Object Wake Stack presentation crop - R1` | `257:312` |
| Proof non-claims | `CANDIDATE - VSP-07 - Object Wake Stack proof non-claims - R1` | `257:355` |
| Package readback | `CANDIDATE - VSP-07 - Object Wake Stack package readback - R1` | `257:389` |

## Intended Ownership

- VSP: `VSP-07`
- Category: contextual trust inspection detail
- Shell authority: VSP-01 owns shell, Stage, dock, chrome, Capture/Search placement, and route depth. VSP-07 may not mutate shell.
- Canonical source owner for future implementation: `Native/Ambitions/Trust/`
- Allowed implementation support: `Native/Ambitions/Projection/OverlayScenes/`, `Sources/Components/TrustReceiptLayerPrimitives+02-SourceTrustReceiptStrip.swift`, `Sources/Components/ObjectStageSurfaces.swift`, `Sources/Components/FlagshipObjectStagePrimitives.swift`
- New primitive likely required after owner package approval: `ObjectWakeStackInspection`, `ObjectWakeReceiptWake`, `ObjectWakeProofRow`

## Product-Law Checklist

- Today / Goals / Time / You remain the only persistent surfaces.
- Capture remains global composer, not a tab/root surface.
- Motion remains behavior, not a root destination.
- Proof / Source / Privacy / History / Receipts remain inspection details.
- VSP-07 opens from an owning object and closes back to that object.
- No Trust, Proof, Source, Privacy, History, Receipts, activity-feed, or receipt-feed root surface is introduced.
- Offline no-account value remains required.
- R2 / Source Atlas remains public/reference/freshness infrastructure only.
- Private life graph egress remains forbidden.

## Acceptance Criteria For Future Source Leaf

- Implement VSP-07 as content mounted inside the approved VSP-01 shell.
- Preserve exact VSP-01 shell authority; no new dock, crown, Capture, Search, route, status, or navigation chrome.
- Build object-attached inspection under `Native/Ambitions/Trust/`.
- Keep receipt wake physically and semantically attached to the changed object.
- Missing proof must be explicit and honest; no fake proof or fabricated certainty.
- Source/privacy rows must state local/private graph boundaries without cloud or R2 private data assumptions.
- Closing inspection must return to the owning object.
- Reduce Motion must use a static proof step.
- Dynamic Type, VoiceOver order, Increase Contrast, Reduce Transparency, and haptics-off behavior require source/device proof after implementation.

## Non-Goals

- No source implementation in this package.
- No Code Connect claim.
- No Visual Green.
- No SwiftUI parity claim.
- No device proof.
- No accessibility conformance.
- No runtime behavior proof.
- No privacy/account/R2 readiness claim.
- No Release Green.
- No Done.

## Durable Proof

See `docs/qa/evidence/2026-07-01-vsp-07-object-wake-stack-final-package-r1/manifest.md`.

The PNG proof images are durable local render mirrors of the Figma package structure anchored to the Figma node IDs above. Direct Figma PNG export through the plugin response channel was not used as the source of these repo images, so the proof ceiling remains Yellow and the Figma node IDs remain the design authority anchors.
