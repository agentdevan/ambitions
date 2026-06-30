# VSP-03 Part 02 Living Map Territory Refinements R1

Status: Yellow exploration, D5 selected for candidate-package buildout.

Claim boundary: this is Figma exploration evidence only. It is not a VSP-03 candidate package, not owner approval, not Visual Green, not source implementation, not live SwiftUI parity, not device proof, and not accessibility conformance.

## Figma Frame

- File: `SWtHm9ouHTPbEFfNrrtZwv`
- Board node: `169:93`
- Board name: `EXPLORATION - VSP-03 - PART 02 - Living Map Territory refinements - R1`
- Link: https://www.figma.com/design/SWtHm9ouHTPbEFfNrrtZwv?node-id=169-93

## Refinement Basis

Owner direction selected the Part 01 `D Living Map Territories` concept family for deeper exploration, but not the exact Part 01 D frame. Part 02 therefore explores six complete territory-map refinements rather than combining directions.

## Selection Result

Owner selected `D5 Focus Lens Territory` as the direction to move into VSP-03 candidate-package buildout. This is a direction selection only, not final VSP-03 owner approval.

## Option Frames

| Option | Node | Name | Intended object model | Preliminary risk |
|---|---:|---|---|---|
| D1 | `169:221` | Continuous Territory Field | Goals root as one connected atlas object with life areas as organic regions and the active path crossing the field. | Strong living-object read; needs tap target and VoiceOver traversal proof. |
| D2 | `169:318` | Editable Atlas Boundaries | Customizable life areas with visible seam handles and boundary edit affordance without settings/dashboard drift. | Highest edit-mode complexity; can become tool UI if not carefully scoped. |
| D3 | `169:418` | Path Overlay Territory | Active goal path and proof/history stitches overlay the territory map. | Strong path/proof read; must keep proof as detail, not root inspection surface. |
| D4 | `169:517` | Capacity Weather Map | Pressure, recovery, and protected capacity are integrated as weather/contours in the atlas. | Can drift into analytics/KPI dashboard if capacity is detached from the object. |
| D5 | `169:614` | Focus Lens Territory | Selected life area expands as a lens while neighboring areas remain spatially present. | Strongest focus/state behavior; needs reduced-motion static equivalent and Dynamic Type proof. |
| D6 | `169:708` | Open Field Shoreline | Free-floating steps/thoughts live as a shoreline inside the atlas until they gain life-area meaning. | Must not become Capture, inbox, or a new persistent root surface. |

## Product-Law Review

- VSP-01 shell authority preserved: yes. The board is content-only and does not include dock, crown, Search, Capture, status bar, tab bar, shell glass, route depth, or persistent nav.
- Capture preserved as global composer: yes. D6 includes open field meaning inside Goals only; it is not Capture, an inbox, a tab, or a root surface.
- Motion preserved as behavior: yes. Territory reshape/lens/weather behavior is a Goals object behavior, not a Motion destination.
- Trust preserved as inspection detail: yes. Proof/history stitches are object details only, not persistent root surfaces.
- Goals ownership preserved: yes. All options remain Goals Life Area Atlas root-object explorations.
- Local-first/R2/private graph boundary: unchanged; no cloud, account-gated core, external LLM, or R2 private graph behavior is introduced.

## SwiftUI Plausibility Tags

- D1 Continuous Territory Field: `New SwiftUI primitive required` `LifeAreaAtlasField`; possible reusable support from `GoalsObjectView`.
- D2 Editable Atlas Boundaries: `New SwiftUI primitive required` `LifeAreaBoundaryEditor`; exploration only until edit-mode scope is bounded.
- D3 Path Overlay Territory: `New SwiftUI primitive required` `GoalPathOverlayCanvas` plus proof-stitch rendering.
- D4 Capacity Weather Map: `New SwiftUI primitive required` `LifeAreaCapacityWeatherField`; analytics must stay object-integrated.
- D5 Focus Lens Territory: `New SwiftUI primitive required` `LifeAreaFocusLens`; likely strongest candidate for state behavior.
- D6 Open Field Shoreline: `New SwiftUI primitive required` `LifeAreaOpenFieldShoreline`; must route free-floating steps without Capture-tab drift.

## Visual Audit

- Typography: repaired after initial export. Current durable proof uses proof-safe Inter text because the current Figma screenshot pipeline drops SF Pro/system-font text. SwiftUI implementation remains system-font aligned.
- Spatial: phone frames are full-bleed content-only surface objects. In-phone explanatory legends were removed so the screenshots read as product surfaces rather than annotated mockups.
- Material: restrained night/celestial palette with organic territory shapes, subtle seams, proof stitches, and no card grid or project-board root.
- Accessibility: not proven. Selection must be followed by Dynamic Type, VoiceOver order, Reduce Motion, Reduce Transparency, Increase Contrast, tap-target, and haptic notes.
- SwiftUI implementation: plausible as new Goals design-system primitives, but not implemented.

## Durable Proof

- `docs/qa/evidence/2026-06-30-vsp-03-part-02-living-map-territory-refinements-r1/manifest.md`
- `docs/qa/evidence/2026-06-30-vsp-03-part-02-living-map-territory-refinements-r1/vsp-03-part-02-territory-refinements-board-r1.png`
- `docs/qa/evidence/2026-06-30-vsp-03-part-02-living-map-territory-refinements-r1/vsp-03-part-02-d1-continuous-territory-field-r1.png`
- `docs/qa/evidence/2026-06-30-vsp-03-part-02-living-map-territory-refinements-r1/vsp-03-part-02-d2-editable-atlas-boundaries-r1.png`
- `docs/qa/evidence/2026-06-30-vsp-03-part-02-living-map-territory-refinements-r1/vsp-03-part-02-d3-path-overlay-territory-r1.png`
- `docs/qa/evidence/2026-06-30-vsp-03-part-02-living-map-territory-refinements-r1/vsp-03-part-02-d4-capacity-weather-map-r1.png`
- `docs/qa/evidence/2026-06-30-vsp-03-part-02-living-map-territory-refinements-r1/vsp-03-part-02-d5-focus-lens-territory-r1.png`
- `docs/qa/evidence/2026-06-30-vsp-03-part-02-living-map-territory-refinements-r1/vsp-03-part-02-d6-open-field-shoreline-r1.png`

## Required Next Step

Build the D5 candidate package with hero, state matrix, accessibility matrix, SwiftUI anatomy, presentation crop, non-claims, and durable screenshot proof. Do not synthesize D5 with other options by default.
