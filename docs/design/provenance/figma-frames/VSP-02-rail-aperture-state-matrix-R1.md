# VSP-02 Rail-Aperture State Matrix R1

Figma evidence:
- File: `SWtHm9ouHTPbEFfNrrtZwv`
- Board node: `152:93`
- Board frame: `CANDIDATE - VSP-02 - Rail-Aperture State Matrix - R1`
- Live candidate typography: SF Pro/system-font aligned
- Readable proof typography: temporary Inter export clone, removed after export

Purpose:
- Extend the selected R6 Rail-Attached Time Bands + Current Aperture direction into a production state matrix.
- Keep VSP-02 content-only inside approved VSP-01 shell authority.
- Apply VSP-09 accessibility/motion/haptics expectations and VSP-10 source-owner provenance to the Today object.

State frames:
- `CANDIDATE - VSP-02 - state calm-default - R1`
- `CANDIDATE - VSP-02 - state overloaded-pressure - R1`
- `CANDIDATE - VSP-02 - state protected-time - R1`
- `CANDIDATE - VSP-02 - state waiting-blocked - R1`
- `CANDIDATE - VSP-02 - state moved-still-counts - R1`
- `CANDIDATE - VSP-02 - state not-needed-recovery - R1`
- `CANDIDATE - VSP-02 - state dynamic-type-stress - R1`
- `CANDIDATE - VSP-02 - state reduce-motion-static-proof - R1`

Design decisions:
- Rail-Attached Time Bands remain the base object.
- Current Aperture remains centered and visually dominant.
- Analytics, risk, drive, open-time, and proof signals remain integrated into the Today object through the condition ribbon.
- Separate proof affordances were removed from the state frames after export review because they collided with the lower rail/ribbon area.
- Ghost movement traces were lowered below text so they read as memory traces, not strikethrough decoration.
- Reduce Motion uses a static proof step: Before / Static proof step / After, with explicit `Still counts` and `Undo`.

SwiftUI source-owner expectation:
- `Native/Ambitions/Surfaces/Today/TodaySurface.swift`
- `Native/Ambitions/Surfaces/Today/TodayObjectView.swift`
- `Native/Ambitions/Surfaces/Today/TodayAccessibility.swift`
- `Sources/Components/RealityMeridianTimeBand.swift`
- New or repaired vertical day-rail/current-aperture primitive under Today/design-system ownership.

Evidence paths:
- `docs/qa/evidence/2026-06-30-vsp-02-r1-state-matrix/vsp-02-rail-aperture-state-matrix-r1-readable-board.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r1-state-matrix/vsp-02-rail-aperture-state-calm-default-r1-readable.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r1-state-matrix/vsp-02-rail-aperture-state-reduce-motion-r1-readable.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r1-state-matrix/manifest.md`

Non-claims:
- No Visual Green.
- No source implementation.
- No runtime proof.
- No device evidence.
- No accessibility conformance.
- No owner approval for VSP-02 implementation handoff.
- No shell authority change.

Recommended next action:
- Owner reviews R6 selected direction plus R1 state matrix together.
- If accepted, shape a bounded Codex implementation leaf for Today vertical rail/current-aperture parity inside the approved VSP-01 shell.
