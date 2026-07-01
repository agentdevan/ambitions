# VSP-07 Part 02 Attached Receipt Stack Refinements R1

Status: Yellow / Exploration

This frame note registers the VSP-07 Part 02 refinement board built from the owner-selected Part 01 direction `F Attached Receipt Stack`.

This is not a final VSP-07 candidate package and does not approve implementation.

## Frame Index

| Purpose | Frame | Node |
|---|---|---:|
| Exploration board | `EXPLORATION - VSP-07 - PART 02 - attached receipt stack refinements - R1` | `250:93` |
| Option A | `EXPLORATION - VSP-07 - Part 02 - Option A - Object Wake Stack - R1` | `250:104` |
| Option B - recommended | `EXPLORATION - VSP-07 - Part 02 - Option B - Receipt Aperture - R1` | `250:119` |
| Option C | `EXPLORATION - VSP-07 - Part 02 - Option C - Mutation Ledger Stack - R1` | `250:134` |
| Option D | `EXPLORATION - VSP-07 - Part 02 - Option D - Undo Corridor - R1` | `250:149` |
| Option E | `EXPLORATION - VSP-07 - Part 02 - Option E - Private Source Veil - R1` | `250:164` |
| Option F | `EXPLORATION - VSP-07 - Part 02 - Option F - Return Ribbon Stack - R1` | `250:179` |

## Intended Ownership

- VSP: `VSP-07`
- Category: contextual trust inspection detail
- Selected base: `F Attached Receipt Stack`
- Recommended Part 02 direction: `B Receipt Aperture`
- Canonical source owner for future implementation: `Native/Ambitions/Trust/`
- Allowed implementation support: `Native/Ambitions/Projection/OverlayScenes/`, `Sources/Components/TrustReceiptLayerPrimitives+02-SourceTrustReceiptStrip.swift`
- New primitive likely required after final package approval: `AttachedReceiptStack` / `ContextualTrustInspection`
- Forbidden: Trust root surface, Proof root surface, Source root surface, Privacy root surface, History root surface, Receipts root surface, activity feed, receipt feed, global history destination.

## Option Summary

- A Object Wake Stack: evidence blooms under the changed object and collapses back to it.
- B Receipt Aperture: one object-owned inspection aperture pages receipt layers inside a single detail.
- C Mutation Ledger Stack: a narrow ledger explains related cross-object changes without becoming chronological activity.
- D Undo Corridor: the inspection emphasizes reversible actions, review, and recovery.
- E Private Source Veil: privacy/source boundaries are explicit; this carries VSP-08 risk and must remain object inspection if used here.
- F Return Ribbon Stack: every receipt row carries a visible return path to its owning object.

## Recommendation

Use Option B Receipt Aperture as the next VSP-07 candidate-package base.

Rationale:

- It keeps one owning object in control of the inspection.
- It avoids global receipt-feed drift better than the broader cross-object variants.
- It can absorb Option F's return-ribbon rule without becoming a mixed design.
- It gives Reduce Motion a clear static proof-step equivalent.
- It is plausible as SwiftUI overlay/detail composition rather than shell navigation.

## Product Law

- Trust remains inspection, not a persistent surface.
- Proof, Source, Privacy, History, and Receipts remain details.
- The inspection opens from an owning object: Today, Goals, Time, Capture, or You.
- Capture remains the global composer, not a tab.
- Motion remains behavior, not a destination.
- VSP-07 remains content-only or mounted in the approved VSP-01 shell.
- VSP-07 may not mutate shell chrome, root IA, dock, Context Crown, Capture/Search placement, or route depth.

## Repairs Made During Build

- Replaced abstract line-only placeholders in B, D, and E with concrete receipt rows.
- Removed duplicate Reduce Motion pill collision from B Receipt Aperture.
- Kept all option frames content-only with no invented shell chrome.

## Acceptance Criteria For Future Candidate

- Owner selects one Part 02 direction or requests repair.
- Final candidate includes hero, state matrix, accessibility matrix, SwiftUI anatomy, presentation crop, and durable screenshots.
- Inspection is visibly attached to an owning object.
- The user can close inspection and return to the owning object.
- Proof/source/privacy/history/receipt affordances are details, not root IA.
- Dynamic Type and VoiceOver reading order are designed before source implementation.
- Reduce Motion has a static equivalent.
- No Visual Green or source readiness is claimed from Figma alone.

## Durable Proof

See `docs/qa/evidence/2026-07-01-vsp-07-part-02-attached-receipt-stack-refinements-r1/manifest.md`.
