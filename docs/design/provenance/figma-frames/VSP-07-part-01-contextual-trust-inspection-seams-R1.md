# VSP-07 Part 01 Contextual Trust Inspection Seams R1

Status: Yellow / Owner-selected direction

This frame note registers the first VSP-07 workshop board. The owner selected Option F Attached Receipt Stack on 2026-07-01 for Part 02 refinement. This does not approve source implementation.

## Frame Index

| Purpose | Frame | Node |
|---|---|---:|
| Exploration board | `EXPLORATION - VSP-07 - PART 01 - contextual trust inspection seam options - R1` | `244:93` |
| Option A | `EXPLORATION - VSP-07 - Option A - Proof Wake - R1` | `244:105` |
| Option B | `EXPLORATION - VSP-07 - Option B - Thread Lens - R1` | `244:184` |
| Option C | `EXPLORATION - VSP-07 - Option C - Boundary Receipt - R1` | `244:263` |
| Option D | `EXPLORATION - VSP-07 - Option D - Route Trace - R1` | `244:344` |
| Option E | `EXPLORATION - VSP-07 - Option E - Privacy Boundary - R1` | `244:423` |
| Option F - owner selected | `EXPLORATION - VSP-07 - Option F - Attached Receipt Stack - R1` | `244:502` |

## Intended Ownership

- VSP: `VSP-07`
- Category: contextual inspection
- Canonical source owner for future implementation: `Native/Ambitions/Trust/`
- Allowed implementation support: `Native/Ambitions/Projection/OverlayScenes/`, `Sources/Components/TrustReceiptLayerPrimitives+02-SourceTrustReceiptStrip.swift`
- Forbidden: Trust root surface, Proof root surface, Source root surface, Privacy root surface, History root surface, Receipts root surface.

## Product Law

- Trust remains inspection, not a persistent surface.
- Proof, Source, Privacy, History, and Receipts remain details.
- The inspection must open from an owning object: Today, Goals, Time, Capture, or You.
- Inspection must not become an activity feed, analytics dashboard, Source Atlas center, account center, or global history destination.
- Copy cannot overclaim proof, privacy, source certainty, R2 readiness, account readiness, or release readiness.

## Owner-Selected Direction

Use Option F Attached Receipt Stack as the Part 02 base.

Prior review recommended Option C Boundary Receipt, but owner selection now controls the next workshop step. Option C remains useful as a guardrail for keeping receipts attached to changed objects. Option E Privacy Boundary should inform VSP-08 external boundaries rather than becoming the VSP-07 base.

Required Part 02 repair pressure: Option F must not become an activity feed, receipts destination, history destination, or global Trust surface.

## Acceptance Criteria For Future Candidate

- Frame is content-only or mounted in approved VSP-01 shell.
- Inspection is visibly attached to an owning object.
- The user can close the inspection and return to the object.
- Proof/source/privacy/history/receipt affordances are details, not root IA.
- Dynamic Type and VoiceOver reading order are designed before source implementation.
- Reduce Motion has a static equivalent.
- No Visual Green or source readiness is claimed from Figma alone.

## Durable Proof

See `docs/qa/evidence/2026-07-01-vsp-07-part-01-contextual-trust-inspection-seams-r1/manifest.md`.

Selection proof: `docs/qa/evidence/2026-07-01-vsp-07-option-f-attached-receipt-stack-selection-r1/manifest.md`.
