# Ambitions 3.0 F23 Accessibility / ADHD / Dynamic Type / VoiceOver QA Report

Date: 2026-05-01
Train: F17-F30 FAANG Handoff Completion Train
Batch: F23 Accessibility / ADHD / Dynamic Type / VoiceOver QA
Gate: Green

## Result

F23 is Green.

Accessibility and ADHD/cognitive-load evidence was reviewed across the active
shell and major surfaces. One scoped recovery-copy issue was fixed: visible
widget, preview, Rituals, and planner examples that leaned on `streak` language
now use calmer `rhythm` / `cadence` wording. Internal compatibility names were
not renamed.

This report does not claim external accessibility conformance, physical-device
proof, or manual VoiceOver/Dynamic Type certification. Those remain locked until
human/manual evidence exists.

FAANG handoff remains PARTIAL until F27 explicitly passes.

## Source Truth

- `docs/canon/Ambitions_3_0_Accessibility_Conformance_Plan.md`
- `Sources/Accessibility/AccessibilityNutrition.swift`
- `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`
- representative Today, Capture, Goals, Plan, You, shell, widget, and preview
  source files

## Surfaces Reviewed

Today / Reality Rail:

- `TodayRealityRail` exposes accessibility summary labels and values.
- Reality Rail hero and rows are tappable cards/rows, not tiny rail nodes only.
- Step Detail exposes stable accessibility identifiers and private-state labels.
- Reduce Motion environment is present in Today background and screen flows.

Capture:

- composer input has the label `What needs a place?`;
- voice capture explains it is not connected yet;
- Smart Attachment preview has combined labels, values, and route-change hints;
- save/error paths preserve calm language.

Goals:

- goal cards expose combined state, weather, next visible step, proof, and
  momentum labels;
- Life Areas, North Stars, One-Step Goals, and state chips expose labels,
  values, hints, and stable identifiers.

Plan:

- Plan uses explicit recovery/reflow copy and keeps calendar awareness
  Plan-owned;
- pressure and recovery states include text labels, not color alone.

You / Profile:

- user-facing navigation title is `You`;
- grouped rows use readable labels and values;
- trust/memory/accessibility surfaces remain inside the You/Profile ownership
  seam.

Meridian/fallback shell:

- Meridian destinations expose name, selected state, hint, and stable
  accessibility identifiers;
- fallback shell keeps canonical top-level destinations and global action
  labels.

Widgets / previews:

- F23 removed pressure-oriented visible `streak` copy from active widget and
  preview examples where it could read as a user-facing promise or shame loop.

## Fixes Made

User-facing recovery/cognitive-load copy:

- `No streak yet` -> `No rhythm yet`
- `7 day streak` -> `7 steady days`
- `Current streak` -> `Current rhythm`
- `Best streak` -> `Best rhythm`
- `daily streak` -> `daily rhythm`
- `streak quality` -> `rhythm quality`
- `streak milestones` -> `rhythm milestones`
- `Streaks stay useful...` -> `Rhythm stays useful...`
- `streaks break` -> `rhythms get disrupted`
- `6-day streak` -> `6 steady days`

Internal values left intact:

- widget family `.streak`;
- `StreakWidget` / `StreakContent` type names;
- Rituals/Habits internal compatibility model names;
- progress strategy raw values such as `.streakLength`.

Those are compatibility/internal implementation seams, not visible copy, and
should be reviewed during F27.5 rather than renamed opportunistically in F23.

## Evidence Classification

VoiceOver:

- Partially supported by source inspection and focused tests.
- Primary controls and major panels expose labels, values, hints, or grouped
  accessibility elements.
- Manual VoiceOver rotor/order testing was not performed and is not claimed.

Dynamic Type:

- Partially supported by source inspection.
- Shell and Meridian use `dynamicTypeSize` and minimum scale constraints where
  the rail could compress.
- Full large-accessibility-size screenshot/manual proof was not performed and
  is not claimed.

Reduce Motion:

- Partially supported by source inspection.
- Screens use `accessibilityReduceMotion` and design-system motion hooks.
- No new motion-only meaning was introduced in F23.

Touch targets:

- Partially supported by source inspection.
- Rail nodes are not the only primary target; cards, rows, and buttons carry
  actions.
- Manual one-handed target measurement was not performed.

Color-not-only meaning:

- Supported by checklist tests and source inspection.
- Accessibility checklist requires non-color support for every category.
- Major semantic states include text, icons, labels, values, or hierarchy.

ADHD / cognitive load:

- Improved.
- F23 reduced pressure-oriented `streak` copy to `rhythm` / `cadence`.
- Existing recovery copy emphasizes lighter next steps, non-shaming recovery,
  and safe escape paths.

Public accessibility claims:

- Locked.
- `AccessibilityNutritionChecklistTests` verify user-facing claims default to
  unverified and publishable accessibility claims remain unavailable without
  manual evidence.

## Validation

Commands:

- accessibility/source keyword scan:
  `835` accessibility-related anchors found across active shell/surface/widget
  source.
- recovery-copy scan:
  no remaining targeted visible-copy hits for `No streak yet`, `7 day streak`,
  `daily streak`, `Best streak`, `Current streak`, `[0-9]+-day streak`,
  `streak quality`, `streak milestones`, `streaks break`, or
  `Streaks stay useful` in active app/widget/preview/planner paths after fixes.
- focused tests:
  `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination
  'platform=iOS Simulator,name=iPhone 17'
  -only-testing:AmbitionsTests/AccessibilityNutritionChecklistTests`
  Result: PASS, `10` tests, `0` failures.
  Log: `output/logs/f23-accessibility-tests-20260501-152000.log`.
- `scripts/build-local.sh`: PASS.
  Log: `output/logs/build-local-20260501-152020.log`.
- `git diff --check`: PASS before report creation.

Not verified:

- full `scripts/test-local.sh`;
- full UI smoke;
- manual VoiceOver traversal;
- manual Dynamic Type screenshots;
- physical-device accessibility behavior;
- external accessibility conformance.

## Gate Decision

Green.

F23 fixed scoped recovery-copy pressure language, found no inaccessible new
shell path in source inspection, preserved claim locks for public accessibility
statements, and passed focused accessibility tests plus local build.

F24 Privacy / Trust / Local Data / Redaction QA is unblocked next.
