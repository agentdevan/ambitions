# Today Open Vitality R14 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repair the twelve owner-identified R13 native-fidelity defects and add the narrowly authorized fixture-only returned-Today route to `step.send-launch-brief`.

**Architecture:** Preserve the existing fixture snapshots, `TodayFlagshipJourneyState`, typed navigation path, and journey-local SwiftUI views. Extend the typed fixture state only enough to focus the revealed launch-brief Step, then make visual repairs inside the existing Today Vitality composition and host without adding runtime routing or production integration.

**Tech Stack:** Swift 6, SwiftUI, XCTest/XCUI, Swift Package Manager, Xcode Simulator, existing Native Visual Foundry host.

## Global Constraints

- Branch remains `codex/today-open-vitality-r13`; `main` is not merged, rebased, modified, or pushed.
- Fixture family remains `today-flagship/preparing-for-baby/still-counts/v1`.
- The new launch-brief route is fixture-only and non-mutating; no production route, runtime adapter, command, receipt, history, undo, or mutation is added.
- R13 evidence remains immutable; R14 screenshots are evaluation references with `production_baseline = false`.
- Native `NavigationStack`, back behavior, scrolling, safe areas, sheets, Dynamic Type, and accessibility remain default.
- Liquid Glass is limited to functional dock chrome with the existing opaque Reduce Transparency equivalent.
- No dependency, canon, generated canon, app-entry, runtime, legacy frontend, or unrelated-root change is permitted.

---

### Task 1: Primary journey fidelity and fixture-only revealed-Step route

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipJourneyState.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalityRootView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalityFocusedStepView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalityReviewView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalitySettlementView.swift`
- Test: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayFlagshipJourneyStateTests.swift`
- Test: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayVitalityRootTests.swift`
- Test: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayVitalityFocusedStepTests.swift`
- Test: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayVitalityReviewTests.swift`
- Test: `Packages/AmbitionsPresentation/Tests/AmbitionsNativeVisualFoundryTests/TodayVitalitySettlementTests.swift`
- Test: focused fixture-host UI test files for root, focused Step, review, and settlement.

**Interfaces:**
- Consumes: `visibleStartHereStepID`, `TodayFlagshipNavigationDestination.step(id:)`, existing immutable Step snapshots.
- Produces: a phase-preserving, non-mutating typed route from `.todayReturned` to `step.send-launch-brief`, plus a focused presentation selected by stable Step ID.

- [x] Add package and UI assertions for the authorized route, stable identity, non-mutation, truthful back return, saving comparison, settlement identity, and returned Continue.
- [x] Run focused tests and confirm failures are caused by the missing R14 behavior.
- [x] Implement the minimum state and SwiftUI changes for corrections A, B, C, E, and F.
- [x] Run focused package and UI tests to green and render the five affected native states.
- [x] Commit primary-journey source and tests.

### Task 2: Root, Full Day, shell, and accessibility fidelity

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalityRootView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalityTimelineView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalityFullDayView.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalityShell.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipNavigationChrome.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayFlagshipCalibrationView.swift`
- Test: corresponding Root, FullDay, Shell, and Accessibility package/UI tests.

**Interfaces:**
- Consumes: existing root scroll progress, dock commands, full-day objects, and adaptive-navigation commands.
- Produces: safe root terminal action, Now-visibility-driven Full Day chrome, scroll-distinct Peek, edge-owned expanded dock, and authored accessibility grouping.

- [x] Add failing layout/visibility/order assertions for corrections D, G, H, I, and L.
- [x] Run focused tests and confirm expected failures.
- [x] Implement native-safe-area, scroll-visibility, and shell presentation repairs without changing shell routes.
- [x] Run focused package/UI tests and render compact, Pro, Pro Max, scrolled, expanded-dock, and accessibility states.
- [x] Commit root, Full Day, shell, and accessibility repairs.

### Task 3: Supporting-depth and recovery fidelity

**Files:**
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalitySupportingDepth.swift`
- Modify: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalityRecoveryView.swift`
- Modify only if required locally: `Packages/AmbitionsPresentation/Sources/AmbitionsNativeVisualFoundry/TodayVitalityGrammar.swift`
- Test: corresponding SupportingDepth, Recovery, and Resilience package/UI tests.

**Interfaces:**
- Consumes: existing supporting routes, immutable snapshots, recovery commands, and Vitality palette/node roles.
- Produces: open-plane supporting depths and a single localized interrupted/saved-progress seam without semantic changes.

- [x] Add failing source/UI assertions for open-plane grammar and non-nested recovery anatomy.
- [x] Run focused tests and confirm expected failures.
- [x] Implement corrections J and K using existing local grammar only.
- [x] Run focused tests and render all affected supporting and recovery states.
- [x] Commit supporting-depth and recovery repairs.

### Task 4: Evidence and final verification

**Files:**
- Create: the remaining requested files under `docs/qa/evidence/2026-07-28-today-open-vitality-r14/`
- Modify: focused screenshot-capture UI tests only where required for stable R14 capture.

**Interfaces:**
- Consumes: final native host frames and preserved R13 comparison artifacts.
- Produces: R14 affected screenshots, contact sheets, machine metadata, changed-file inventory, command log, validation results, limitations, and undecided owner review.

- [x] Regenerate affected frames and contact sheets without recordings.
- [x] Dispatch the single focused implementation reviewer; repair only contract violations.
- [x] Run package build/tests, fixture-host build, the complete UI suite once, SwiftLint, canon/compiler checks, boundary/direct-write/weak-implementation/Gitleaks/metadata/contact-sheet/changed-path/authority audits, `git diff --check`, and final status inspection.
- [x] If any complete UI-suite assertion is repaired, rerun the entire suite from the final source HEAD until one run reports zero failures.
- [x] Dispatch the final authority/validation reviewer and resolve blocking findings.
- [x] Commit evidence and final validation records; verify a clean unmerged, unpushed branch.

## Plan self-review

- The four tasks cover corrections A–L and the owner-authorized fixture-only route.
- No task changes product canon, runtime integration, production entry, IA, fixture truth, or another root.
- Every behavior change begins with a failing focused test and ends with fresh rendered or automated evidence.
- The only subagents remaining are the focused implementation reviewer and final authority/validation reviewer.
