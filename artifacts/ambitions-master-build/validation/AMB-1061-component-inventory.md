# AMB-1061 Component Inventory

Issue: AMB-1061
Train: M04.T04
Scope: Core reusable component set: native interaction primitives

Status: Green for the scoped reusable interaction primitive inventory after focused XCTest, champion coverage, parallel guard, renderer proof, and main-agent visual inspection.

## Primitive Families

| Family | Existing primitive bridge | Intended launch-path use |
|---|---|---|
| Primary action | `AmbitionsActionButton` | Start here and Start now commands with stable tap targets and canonical copy. |
| Disclosure row | `GroupedDisclosureNavigationRow` | Open step, Open goal thread, Review time fit, and Inspect proof rows. |
| Preference toggle | `GroupedPreferenceRow` | You trust/preferences controls such as Private by default. |
| Status pill | `AmbitionChip` | Source needed, Local only, Ready, Loading, Recovery, and Waiting state cues. |
| Recovery action | `AmbitionsActionButton` | Recovery option commands without shame or urgency framing. |
| Global Capture action | `AmbitionChromeButton` | Capture context as Global Capture / Atmosphere Composer, not root navigation. |
| Destructive confirmation | `GroupedDestructiveActionRow` | Confirm change paths with explicit confirmation semantics. |

## Launch-Path Role Contracts

| Role | Surface owner | Primary object | Family | Canonical action/copy | Accessibility posture |
|---|---|---|---|---|---|
| Start here | Today | Reality Meridian / Start Here | Primary action | Start here | Button label and hint identify why the flagship recommendation is actionable. |
| Start now | Today | Recommended step | Primary action | Start now | Button label preserves launch semantics without generic task language. |
| Open step | Today | Step Detail | Disclosure row | Open step | Row exposes disclosure intent and non-color state cues. |
| Open goal thread | Goals | Constellation Atlas | Disclosure row | Open goal thread | Row stays tied to Goals direction and proof context. |
| Review time fit | Time | LifeShape Field / Time Texture | Disclosure row | Review time fit | Row avoids free/busy or scheduling-score language. |
| Inspect proof | Motion | Motion Current | Disclosure row | Inspect proof | Row keeps SourceRecord, Receipt, and ReplayTrace inspectable. |
| Recovery option | Today | Recovery path | Recovery action | Recovery option | Action copy is recovery-aware and non-shaming. |
| Capture context | Global Capture | Atmosphere Composer | Global Capture action | Capture context | Contract keeps Capture as a global action layer, not a root tab. |
| Private by default | You | User System Profile | Preference toggle | Private by default | Preference semantics stay local-first and user-controlled. |
| Confirm change | You | Confirmation step | Destructive confirmation | Confirm before change | Explicit confirmation route for sensitive changes. |

## State Coverage

| State | Semantic status | Non-color cue | Action enabled |
|---|---|---|---|
| Ready | Ready | circle icon | yes |
| Selected | Selected | target icon | yes |
| Loading | Loading | document/magnifier icon | no |
| Disabled | Disabled | accessibility icon | no |
| Source needed | Source needed | exclamation icon | yes |
| Local only | Local only | lock icon | yes |
| Recovery | Recovery | arrow counterclockwise icon | yes |
| Waiting | Waiting | clock icon | no |
| Destructive confirmation | Confirm before change | xmark icon | yes |

## Screenshot Proof

- `artifacts/ambitions-master-build/screenshots/AMB-1061/core-reusable-interaction-primitives.png`
- `artifacts/ambitions-master-build/screenshots/AMB-1061/core-reusable-interaction-primitives-dynamic-type.png`

Visual evaluation: both PNGs render AMB-1061 content at 1170 x 1800, including the Recommended step panel, Start here, Start now, Recovery option, Inspect proof, Private by default, state pills, and the role matrix. Capture is represented as Global Capture / Atmosphere Composer rather than as a root destination. The rendered frames are not blank and show no obvious text clipping in the represented preview frame.

## Validation Evidence

- Champion coverage: `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-1061`; Green; report `build/reports/intelligence-consolidation/champion-coverage-check.md`.
- Parallel implementation guard pre: Green; `build/reports/parallel-implementation-guard/AMB-1061-pre.md`.
- Focused XCTest: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath output/DerivedData-AMB1061 -only-testing:AmbitionsTests/CoreReusableInteractionPrimitiveTests -skip-testing:AmbitionsUITests -enableCodeCoverage NO COMPILER_INDEX_STORE_ENABLE=NO`; 7 selected tests, 0 failures; log `artifacts/ambitions-master-build/validation/AMB-1061-focused-component-tests.log`.
- SwiftUI preview renderer: `python3 scripts/codex/amb-master-render-core-interaction-preview.py`; wrote two PNG proof artifacts under `artifacts/ambitions-master-build/screenshots/AMB-1061/`.
- Parallel implementation guard post: Green; `build/reports/parallel-implementation-guard/AMB-1061-post.md`.

## Boundaries

- This inventory proves the scoped reusable interaction primitive contracts, focused tests, coverage/guard evidence, and renderer screenshot proof only.
- It does not claim full app accessibility certification, physical-device proof, measured performance certification, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, owner approval, or full project completion.
