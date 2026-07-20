# VSP-04 F Apple-Native Life Calendar Owner Review Package R1

Status: Yellow owner-approved visual/Figma target.

Claim boundary: this packages the owner-approved VSP-04/F Apple-Native Life Calendar visual/Figma target. It is not Visual Green, not source implementation, not live SwiftUI parity, not device proof, not runtime behavior proof, not accessibility conformance, not Release Green, and not Done.

## Figma Frame

- File: `SWtHm9ouHTPbEFfNrrtZwv`
- Board node: `202:93`
- Board name: `CANDIDATE - VSP-04 - F Apple-Native Life Calendar owner review package - R1`
- Link: https://www.figma.com/design/SWtHm9ouHTPbEFfNrrtZwv?node-id=202-93

## Owner Review State

- Direction approval source: owner message in Codex thread, `Owner approved`
- Direction approval date: 2026-06-30
- Selection record: `docs/design/provenance/README.md`
- Package approval source: owner message in Codex thread, `Owner approved`
- Package approval date: 2026-06-30
- Selection record: `docs/design/provenance/README.md`
- Approval scope: visual/Figma target only.

## Child Frames

| Frame | Node |
|---|---|
| `CANDIDATE - VSP-04 - F Apple-Native Life Calendar hero - R1` | `202:229` |
| `CANDIDATE - VSP-04 - F Apple-Native Life Calendar state matrix - R1` | `202:392` |
| `CANDIDATE - VSP-04 - F Apple-Native Life Calendar accessibility matrix - R1` | `202:935` |
| `CANDIDATE - VSP-04 - F Apple-Native Life Calendar SwiftUI anatomy - R1` | `202:974` |
| `MARKETING_RENDER - VSP-04 - F Apple-Native Life Calendar presentation crop - R1` | `202:1021` |
| `CANDIDATE - VSP-04 - F Apple-Native Life Calendar non-claims - R1` | `202:1268` |

## Product-Law Review

- VSP-01 shell authority preserved: yes. The package is content-only and does not include dock, crown, Search, Capture, status bar, tab bar, shell chrome, route depth, or persistent nav.
- Capture preserved as global composer: yes. Capture is not a tab, inbox, root surface, or chatbot.
- Motion preserved as behavior: yes. Reflow, protected time, and recovery are object behaviors inside Time, not a Motion destination.
- Trust preserved as inspection detail: yes. Proof residue and source confidence are handoff details, not root surfaces.
- Time ownership preserved: yes. VSP-04 remains the Time Life Calendar / LifeShape content object.
- Local-first/R2/private graph boundary preserved: yes. The package introduces no account-gated core, cloud LLM core, R2 private graph storage, or Source Atlas private data behavior.

## Design Finding

VSP-04/F moves the Time direction from selected month concept into a complete owner-review package. The top-level Time object is a familiar native month calendar enriched with Ambitions-native semantics: capacity, fixed points, protected windows, recovery, pressure, reflow, goal fit, and local proof residue.

The candidate intentionally avoids side KPI rails, dashboard cards, calendar-clone-only behavior, Today-owned current-step timelines, and stale top-level IA. Analytics stay inside the calendar object as seams, bands, apertures, markers, and a single integrated month readout.

## State Coverage

- default month with weekday rail, fixed points, open windows, current date aperture, and integrated readout;
- constrained month with a thin pressure seam that remains calendar-native;
- protected and recovery windows embedded inside the month object;
- moved/still-counts reflow trace with static before/after proof equivalent;
- reduced-motion static proof step requirement.

## Accessibility And Motion Notes

- Dynamic Type: month cells keep day numbers and semantic markers; event labels collapse to icon/color/count before clipping. Month readout grows below grid.
- VoiceOver: month summary, current date, now marker, fixed points, open capacity, protected windows, pressure seam, zoom level, then Today anchor. Decorative star field is hidden.
- Reduce Motion: glass/reflow animation becomes static proof step: before position, decision, after position, receipt affordance.
- Reduce Transparency: Liquid/glass resolves to solid tonal surfaces; separators and semantic rails stay visible without blur.
- Increase Contrast: meaning does not rely on color alone; seam thickness, rails, labels, counts, and explicit protected/recovery words carry semantics.
- Haptics: visible/static confirmation is primary; haptics are reinforcement only for protected confirmation, reflow saved, unavailable, and conflict resolved states.

## SwiftUI Plausibility Tags

- `Existing SwiftUI primitive`: `TimeSurface`, `TimeObjectView`, `TimeAccessibility`, `TimeSurfaceState`, `TimeLifeShapeSemanticProjection`, `LifeShapeFieldView`, `LifeShapeRenderer`.
- `New SwiftUI primitive required`: `MonthLifeCalendarGrid`.
- `New SwiftUI primitive required`: `MonthLifeCalendarSemanticOverlay`.
- `New SwiftUI primitive required`: `MonthReflowProtectionMarker`.
- Canonical owners: `Native/Ambitions/Surfaces/Time`, `Native/Ambitions/Core/LocalRuntimeOS/Scheduling`, `Native/Ambitions/DesignSystem/ProductObjects`, `Native/Ambitions/Rendering/CanvasPrimitives`, `Sources/Components`.
- Rejected for root: VSP-01 shell mutation, generic calendar clone, KPI dashboard, side analytics rail, Today-owned current-step timeline, Plan/Profile/Habits/Insights IA, Capture tab, Motion destination.

## Export Note

PNG proof uses readable Inter export text where needed because the current Figma screenshot pipeline can drop SF Pro/system-font text. SwiftUI implementation remains system-font/SF aligned.

## Durable Proof

- `docs/qa/evidence/2026-06-30-vsp-04-f-owner-review-package-r1/manifest.md`
- `docs/qa/evidence/2026-06-30-vsp-04-f-owner-review-package-r1/vsp-04-f-owner-review-package-r1-board.png`
- `docs/qa/evidence/2026-06-30-vsp-04-f-owner-review-package-r1/vsp-04-f-owner-review-package-r1-hero.png`
- `docs/qa/evidence/2026-06-30-vsp-04-f-owner-review-package-r1/vsp-04-f-owner-review-package-r1-state-matrix.png`
- `docs/qa/evidence/2026-06-30-vsp-04-f-owner-review-package-r1/vsp-04-f-owner-review-package-r1-accessibility-matrix.png`
- `docs/qa/evidence/2026-06-30-vsp-04-f-owner-review-package-r1/vsp-04-f-owner-review-package-r1-swiftui-anatomy.png`
- `docs/qa/evidence/2026-06-30-vsp-04-f-owner-review-package-r1/vsp-04-f-owner-review-package-r1-marketing-crop.png`
- `docs/qa/evidence/2026-06-30-vsp-04-f-owner-review-package-r1/vsp-04-f-owner-review-package-r1-non-claims.png`

## Required Next Gate

Create a bounded Codex implementation leaf before source work begins. The leaf must include approved frame IDs, source owners, non-goals, required SwiftUI primitives, Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, Increase Contrast, haptic/static feedback acceptance criteria, validation commands, proof artifacts, and rollback plan.

Even with owner approval, VSP-04 remains Yellow until source, device, runtime, accessibility, and validation proof are separately produced.
