# VSP-02 Owner Review Package R1

Figma evidence:
- File: `SWtHm9ouHTPbEFfNrrtZwv`
- Board node: `160:93`
- Board frame: `CANDIDATE - VSP-02 - owner review package - Rail Aperture Today - R1`

Package frames:
- `160:100` - `CANDIDATE - VSP-02 - hero - Rail Aperture Today - R1`
- `160:200` - `MARKETING_RENDER - VSP-02 - presentation crop - Rail Aperture Today - R1`
- `160:300` - `CANDIDATE - VSP-02 - SwiftUI anatomy - Rail Aperture Today - R1`
- `160:343` - `CANDIDATE - VSP-02 - accessibility matrix - Rail Aperture Today - R1`
- `160:386` - `CANDIDATE - VSP-02 - state matrix - Rail Aperture Today - R1 pointer`
- `160:390` - `CANDIDATE - VSP-02 - owner review non-claims - R1`

Purpose:
- Package the selected VSP-02 Rail-Attached Time Bands + Current Aperture direction for owner review.
- Make the required VSP-02 handoff frames explicit without redesigning the selected object.
- Preserve VSP-01 shell authority by keeping VSP-02 content-only.

Basis:
- `CANDIDATE - VSP-02 - Rail-Attached Time Bands + Current Aperture - selected direction - R6` (`134:44`)
- `CANDIDATE - VSP-02 - Rail-Attached Time Bands + Current Aperture viewport - R6` (`134:48`)
- `CANDIDATE - VSP-02 - Rail-Aperture State Matrix - R1` (`152:93`)
- VSP-01 approved shell authority
- VSP-09 accessibility/motion/haptics expectations
- VSP-10 Code-Connect-free provenance/source-owner map

SwiftUI source-owner expectation:
- `Native/Ambitions/Surfaces/Today/TodaySurface.swift`
- `Native/Ambitions/Surfaces/Today/TodayObjectView.swift`
- `Native/Ambitions/Surfaces/Today/TodayAccessibility.swift`
- `Native/Ambitions/Projection/StageScenes/TodayStageScene.swift`
- New or repaired vertical rail/current-aperture primitives under Today/design-system ownership.

Accessibility acceptance target:
- Dynamic Type target exists, but live proof is still missing.
- VoiceOver order target is current aperture, active action, state, time, condition ribbon, surrounding day bands, then proof detail on request.
- Reduce Motion target is the static proof step from the R1 state matrix.
- Reduce Transparency, Increase Contrast, and haptics remain proof gaps until live SwiftUI/device evidence exists.

Export note:
- The selected live R6/R1 candidate remains SF Pro/system-font aligned for SwiftUI plausibility.
- Current MCP screenshot export drops SF Pro/system-font text in this file.
- Durable proof images for this owner-review package use readable Inter proof clones. This is screenshot-proof scaffolding only, not a SwiftUI font change.

Evidence paths:
- `docs/qa/evidence/2026-06-30-vsp-02-r1-owner-review-package/vsp-02-owner-review-package-r1-board.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r1-owner-review-package/vsp-02-owner-review-package-r1-hero.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r1-owner-review-package/vsp-02-owner-review-package-r1-marketing-crop.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r1-owner-review-package/vsp-02-owner-review-package-r1-accessibility-matrix.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r1-owner-review-package/vsp-02-owner-review-package-r1-swiftui-anatomy.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r1-owner-review-package/manifest.md`

Non-claims:
- No Visual Green.
- No source implementation.
- No runtime proof.
- No simulator or device evidence.
- No accessibility conformance.
- No owner approval for implementation handoff.
- No shell authority change.

Recommended next action:
- Owner reviews node `160:93` together with R6 selected direction (`134:44` / `134:48`) and R1 state matrix (`152:93`).
- If accepted, record explicit owner approval before shaping the Today SwiftUI implementation leaf.
