# Ambitions visual design provenance

Status: `HISTORICAL_REFERENCE`

This directory is the durable visual-reference library for Ambitions. It keeps
directions selected at the time, component anatomy, SwiftUI mappings,
accessibility matrices, and the reasoning behind historical product-specific
visual choices. No Figma frame in this directory is currently selected.

It is not an approval system. The former `owner-approvals/` attestations were
not restored; their actual product selections are consolidated in the package
map below without recreating owner self-approval, authorization, CI, or merge
requirements.

## Current relationship

1. Product behavior and boundaries come from
   [the Constitution](../../canon/CONSTITUTION.md) and owning specifications.
2. The sole active VC-01–VC-14 baseline is the
   [Visual Closure Input Contract](../../canon/design/VISUAL_CLOSURE_INPUT_CONTRACT.md).
3. The VSP packages below preserve detailed object composition and historical
   design decisions. Where an older VSP styling choice conflicts with Visual
   System R1, Revision 1 governs the new styling while the owning product
   specification continues to govern behavior.
4. Repository screenshots under [docs/qa/evidence](../../qa/evidence/) are
   visual references and provenance, not evidence that the current app matches
   them.

## Historical VSP package map

“Selected” or “approved” inside a package records its historical state at the
time. It does not survive as current selection, Figma authorization, SwiftUI
approval, implementation authority, or VC baseline input.

| VSP | Design direction | Figma file/node | Detailed package |
| --- | --- | --- | --- |
| VSP-01 | Nightglass shell boundary | `SWtHm9ouHTPbEFfNrrtZwv` / `87:2` | root shell, Stage, chrome, dock, Search/Capture placement |
| VSP-02 | Rail-Aperture Today | `SWtHm9ouHTPbEFfNrrtZwv` / `160:93` | [package](figma-frames/VSP-02-owner-review-package-R1.md) |
| VSP-03 | D5 Focus Lens Territory | `SWtHm9ouHTPbEFfNrrtZwv` / `177:93` | [package](figma-frames/VSP-03-D5-focus-lens-owner-review-package-R1.md) |
| VSP-04 | Apple-Native Life Calendar | `SWtHm9ouHTPbEFfNrrtZwv` / `202:93` | [package](figma-frames/VSP-04-F-apple-native-life-calendar-owner-review-package-R1.md) |
| VSP-05 | Quiet Placement Review | `SWtHm9ouHTPbEFfNrrtZwv` / `217:93` | [package](figma-frames/VSP-05-F-quiet-placement-review-owner-review-package-R3.md) |
| VSP-06 | Preference Weave | `SWtHm9ouHTPbEFfNrrtZwv` / `240:93` | [package](figma-frames/VSP-06-preference-weave-final-package-R1.md) |
| VSP-07 | Object Wake Stack | `SWtHm9ouHTPbEFfNrrtZwv` / `257:93` | [package](figma-frames/VSP-07-object-wake-stack-final-package-R1.md) |
| VSP-08 | Airlock Review boundary | `SWtHm9ouHTPbEFfNrrtZwv` / `272:93` | [package](figma-frames/VSP-08-airlock-review-gate-final-package-R1.md) |
| VSP-09 | Accessibility, motion, and haptics matrix | `SWtHm9ouHTPbEFfNrrtZwv` / `92:2` | [matrix](figma-frames/VSP-09-accessibility-motion-haptics-matrix-R1.md) |
| VSP-10 | Implementation anatomy/source-owner map | `SWtHm9ouHTPbEFfNrrtZwv` / `91:2` | [map](figma-frames/VSP-10-implementation-anatomy-source-owner-map-R1.md) |

## Reference entry points

- [Component Gallery](Component-Gallery.md)
- [VSP to SwiftUI Provenance Map](VSP-SwiftUI-Provenance-Map.md)
- [Component Registry](component-registry.json)
- [Figma Node Index](figma-node-index.json)

Historical alternatives remain useful for understanding rejected tradeoffs, but
they are not parallel product authority and are never required artifacts for a
code change.
