# AMB-520 Screenshot / QA / Proof Matrix

Status: Accepted Yellow candidate
Date: 2026-06-06
Commit reviewed: `d4d1de11564d29d85b8ac84bc3dea91862991727`
Packet: AMB-520

## Proof Boundary

This packet stages and reviews the screenshot/proof matrix for the matured frontend. It does not contain rendered screenshots, screenshot baseline updates, human visual approval, manual VoiceOver traversal, measured performance proof, privacy/legal approval, device proof, TestFlight readiness, App Store readiness, or release readiness.

No screenshot or visual baseline was accepted, regenerated, or bulk-updated.

## Source Evidence Reviewed

| Area | Evidence | Finding |
|---|---|---|
| Runtime root | `Native/Ambitions/App/AmbitionsRootView.swift` | `AmbitionsRootView` owns the SwiftUI `TabView` runtime root after `AmbitionsApp` and `LaunchGateView`. |
| Top-level IA | `Native/Ambitions/App/AppTab.swift` | `AppTab.allCases` is `Today / Goals / Time / Motion / You`; `capture` remains compatibility and maps to Today for canonical routing. |
| Runtime inspection contract | `Native/Ambitions/App/AppTab.swift` | Surface contracts require `SourceRecord`, `Receipt`, `ReplayTrace`, and `You / What Ambitions knows`. |
| Today | `Native/Ambitions/Features/Today/DayRailViewState.swift`, `TodayStartHereSurface.swift` | Reality Meridian and Start Here include source, receipt, replay, and You inspection strings in source. |
| Capture | `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`, `CaptureScreen.swift` | Atmosphere Composer and route preview source includes local source, receipt seam, correction, and inspection copy. |
| Goals | `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`, `GoalsScreen.swift` | Goals source includes Constellation/Direction compatibility, receipt, source, replay, and You summary strings. |
| Time | `Native/Ambitions/Features/Time/TimeScreen.swift`, Time feature models found by source scan | Time remains the capacity surface; no rendered proof was produced in this packet. |
| Motion | `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift` | Motion Current exists as the proof/progress/inspection surface from AMB-519. |
| You | `Native/Ambitions/Features/You/YouScreen.swift`, `YouRootSurface.swift`, `YouFeatureService.swift` | You exposes Receipts & History, Trust & Automation, Personal Runtime, and What Ambitions knows paths in source. |

## Matrix Convention

Staged screenshot IDs use:

```text
P12_<surface>_<state>_<variant>_<commit>
```

`commit` for this staged matrix is `d4d1de115`.

## Surface Matrix

| Surface | Product object | Required states staged | Required variants staged | Source proof | Current artifact status |
|---|---|---|---|---|---|
| Today | Reality Meridian / Start Here | standard, empty, loading, error, recovery, source unavailable, low confidence, receipt | default, large, accessibility extra extra large, Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, tap-target notes | SourceRecord, Receipt, ReplayTrace, You inspection source present in Today rail/start source | Yellow: staged only; rendered screenshots not captured |
| Capture | Placement Field / Atmosphere Composer / Held Object | standard, empty, loading, error, recovery, source unavailable, low confidence, receipt | default, large, accessibility extra extra large, Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, tap-target notes | local source, receipt seam, correction, route proof, You inspection source present | Yellow: staged only; rendered screenshots not captured |
| Goals | Direction Atlas | standard, empty, loading, error, recovery, source unavailable, low confidence, receipt | default, large, accessibility extra extra large, Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, tap-target notes | source, receipt, replay, You summary strings present in Goals models | Yellow: staged only; rendered screenshots not captured |
| Time | LifeShape Field / Time Texture | standard, empty, loading, error, recovery, source unavailable, low confidence, receipt | default, large, accessibility extra extra large, Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, tap-target notes | capacity surface source present; rendered proof not produced | Yellow: staged only; rendered screenshots not captured |
| Motion | Motion Current | standard, empty, loading, error, recovery, source unavailable, low confidence, receipt | default, large, accessibility extra extra large, Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, tap-target notes | AMB-519 Motion source records origin, route, source, proof, receipt, control, and grouped nonvisual summary | Yellow: staged only; rendered screenshots not captured |
| You | User System Profile / Personal Runtime | standard, empty, loading, error, recovery, source unavailable, low confidence, receipt | default, large, accessibility extra extra large, Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, tap-target notes | Trust & Automation, Receipts & History, Personal Runtime, and What Ambitions knows source present | Yellow: staged only; rendered screenshots not captured |

## Screenshot Candidate IDs

| Screenshot ID | Surface | State | Variant | Expected proof path |
|---|---|---|---|---|
| P12_today_standard_default_d4d1de115 | Today | standard | default Dynamic Type | `docs/audits/screenshots/AMB-520/P12_today_standard_default_d4d1de115.png` |
| P12_today_recovery_reduce-motion_d4d1de115 | Today | recovery | Reduce Motion | `docs/audits/screenshots/AMB-520/P12_today_recovery_reduce-motion_d4d1de115.png` |
| P12_capture_receipt_accessibility-xxl_d4d1de115 | Capture | receipt | accessibility extra extra large | `docs/audits/screenshots/AMB-520/P12_capture_receipt_accessibility-xxl_d4d1de115.png` |
| P12_goals_low-confidence_increase-contrast_d4d1de115 | Goals | low confidence | Increase Contrast | `docs/audits/screenshots/AMB-520/P12_goals_low-confidence_increase-contrast_d4d1de115.png` |
| P12_time_source-unavailable_reduce-transparency_d4d1de115 | Time | source unavailable | Reduce Transparency | `docs/audits/screenshots/AMB-520/P12_time_source-unavailable_reduce-transparency_d4d1de115.png` |
| P12_motion_recovery_differentiate-without-color_d4d1de115 | Motion | recovery | Differentiate Without Color | `docs/audits/screenshots/AMB-520/P12_motion_recovery_differentiate-without-color_d4d1de115.png` |
| P12_you_receipt_tap-target-notes_d4d1de115 | You | receipt | tap-target notes | `docs/audits/screenshots/AMB-520/P12_you_receipt_tap-target-notes_d4d1de115.png` |

These IDs are staged names only. The files do not exist in this commit.

## Anti-Generic Screenshot Review

Source/proof review found no current evidence that the proof packet accepted screenshots showing:

- Capture as a top-level tab.
- Pulse as an active tab.
- Plan as a top-level tab.
- Profile as the active You tab label.
- KPI tile surface replacing Motion Current.
- AI-branded recommendation copy as active product truth.
- Screenshot proof being used as release, accessibility, privacy, performance, TestFlight, or App Store readiness proof.

This is a source/proof review, not rendered visual approval.

## Accessibility Variant Notes

| Variant | Staged expectation | Current proof status |
|---|---|---|
| VoiceOver summaries | Object-level summaries must name the surface object and preserve source/receipt/replay/You inspection where relevant. | Yellow: source strings found in representative paths; manual traversal not run. |
| Dynamic Type default / large / accessibility extra extra large | Primary object and primary action must remain readable, not clipped, and must not become a generic card stack. | Yellow: staged only; screenshots not captured. |
| Reduce Motion | Relationship/state meaning must remain available without motion. | Yellow: staged only; device/simulator proof not captured. |
| Increase Contrast | Boundaries must strengthen without color-only meaning. | Yellow: staged only; screenshots not captured. |
| Reduce Transparency | State must remain readable with atmospheric materials reduced. | Yellow: staged only; screenshots not captured. |
| Differentiate Without Color | Source, receipt, recovery, and low-confidence states must have text or shape equivalents. | Yellow: staged only; screenshots not captured. |
| Tap targets | Primary and repeated controls should preserve 44 pt minimum and preferably 48 pt for primary actions. | Yellow: staged notes only; tap measurement not run. |

## Root Shell Review

Accepted runtime-root chain:

```text
AmbitionsApp -> LaunchGateView -> AmbitionsRootView -> SwiftUI TabView
```

`AppMeridianShell.swift` was not used as runtime-root proof. It remains support/preview compatibility unless future source evidence proves otherwise.

## Remaining Gaps

- Rendered screenshots were not produced.
- Human visual review was not performed.
- Manual VoiceOver traversal was not performed.
- Dynamic Type, Reduce Motion, Increase Contrast, Reduce Transparency, Differentiate Without Color, and tap-target proof remain staged, not verified.
- Performance, privacy/legal, physical-device, TestFlight, App Store, and release readiness were not verified.

## Status

Accepted Yellow is appropriate for AMB-520 if validation remains Green because the proof matrix is produced and explicitly gap-bound, no baseline was updated, no readiness claims are made, and accessibility variants are documented as staged rather than verified.
