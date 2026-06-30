# VSP-02 Rail-Attached Time Bands + Current Aperture R6

Figma evidence:
- File: `SWtHm9ouHTPbEFfNrrtZwv`
- Board node: `134:44`
- Board frame: `CANDIDATE - VSP-02 - Rail-Attached Time Bands + Current Aperture - selected direction - R6`
- Viewport node: `134:48`
- Viewport frame: `CANDIDATE - VSP-02 - Rail-Attached Time Bands + Current Aperture viewport - R6`
- Timeline object node: `134:90`
- Timeline object: `TodayVerticalTimelineBand / Rail-Attached Time Bands + Current Aperture`

Selected direction:
- Rail-Attached Time Bands are the base object.
- Current Aperture expands the centered current step.
- Non-current events compress into duration bands physically attached to the continuous day rail.
- Risk, open time, drive, and proof signals are integrated into the viewport object, not detached KPI rows.

Basis:
- VSP-01 Nightglass Authority Shell owner-approved shell authority.
- VSP-10 Code-Connect-free source-owner map.
- VSP-09 accessibility, motion, haptics, contrast, transparency, focus, and static-equivalent matrix.

Scope:
- Today content object only.
- No shell mutation.
- No root navigation change.
- No Capture tab/root/inbox/chatbot.
- No Motion destination.
- No dashboard, task list, calendar clone, KPI panel, or card feed.

Figma repair made:
- Renamed the R6 board and viewport to the selected Rail-Attached Time Bands + Current Aperture direction.
- Added shared plugin provenance metadata for shell boundary, source owner, selected direction, and proof ceiling.
- Added `CANDIDATE - VSP-02 - R6 selected direction handoff marker`.
- Repaired the current-time marker collision by moving the cursor line right of the rail and shortening the visible current-time label to `1:24`.

SwiftUI source-owner expectation:
- `Native/Ambitions/Surfaces/Today/TodaySurface.swift`
- `Native/Ambitions/Surfaces/Today/TodayObjectView.swift`
- `Native/Ambitions/Surfaces/Today/TodayAccessibility.swift`
- `Sources/Components/RealityMeridianTimeBand.swift`
- New or repaired vertical day-rail/current-aperture primitive under the Today/design-system ownership path.

Evidence paths:
- `docs/qa/evidence/2026-06-30-vsp-02-r6-rail-aperture/vsp-02-rail-aperture-board-r6.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r6-rail-aperture/vsp-02-rail-aperture-viewport-r6.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r6-rail-aperture/vsp-02-rail-aperture-viewport-r6-readable-export.png`
- `docs/qa/evidence/2026-06-30-vsp-02-r6-rail-aperture/manifest.md`

Export caveat:
- Current Figma PNG export drops SF Pro/system-font text in the live viewport export.
- `vsp-02-rail-aperture-viewport-r6-readable-export.png` was produced from a temporary Inter-font clone and then the clone was removed.
- The live Figma candidate remains system-font aligned for SwiftUI plausibility.

Non-claims:
- No Visual Green.
- No source implementation.
- No runtime proof.
- No device evidence.
- No accessibility conformance.
- No final Done status.
- No shell authority change.

Recommended next action:
- Owner reviews R6 as the VSP-02 selected Today direction.
- If accepted for implementation handoff, record explicit owner approval tied to node `134:44` / `134:48`.
- Codex implementation may then be shaped as a Today content-only leaf inside VSP-01 shell.
