# Source Reconciliation Report — 2026-06-22

**Baseline commit reviewed:** `ce75bb77122350fcab9500806e5ff26f8ee02e58`

## What changed

- Converted the prior screenshot-review backlog into a current source-reconciled live issue register.
- Marked source-repaired architecture/shell/Time items as `Candidate resolved` or `Source partially repaired`, not Closed.
- Kept runtime-only items open where no current screenshots, simulator tests, device proof, crash logs, or accessibility transcripts were available.
- Added two new source-reconciliation issues: stale internal tab routing vocabulary and possible Time mutation trust-metadata leak.

## Strong source improvements identified

- Native/Ambitions/Stage/AmbitionsSurface.swift:8-15 — AmbitionsSurface only includes today/goals/time/you and allCases returns those four.
- Native/Ambitions/App/AmbitionsRootScene.swift:10-23; Native/Ambitions/DesignSystem/StagePrimitives/SharedUI/LaunchGateView.swift:10-18; Native/Ambitions/App/AmbitionsStageHost.swift:14-18 — launch resolves into AmbitionsStageHost/AmbitionsStage.
- Native/Ambitions/Stage/StageOverlay.swift:13-25 — activated Capture composer is an overlay state and hides root dock.
- Native/Ambitions/Stage/Chrome/DockBehaviorPolicy.swift:7-12 — root dock shows only at root and not during activated Capture composer.
- Commit 545b1b0864a8cd3a5f028848ff9177e6b849ce65 — AMB-1161 added ShellChromeAudit/SafeAreaAudit tests for duplicate nav, dock hidden in drilldowns, activated Capture dock hiding, and clearance.
- Commit 0c0de3491ca9c1f36f0ff23189d21e820d1305dc — AMB-1163 wired Time/Today clock behavior through AmbitionsClock/SystemClock, clock context refresh, and time-zone-aware day boundary logic.
- Linear AMB-1164 through AMB-1177 Done — LifeShape data contract, Open/Protected engines, TimeLens/Today coupling, SwiftUI-first field, mutations, inspection, pressure/buffer, visual pass, old Time fallback deletion, sequencing guard.
- Commit 51031169f4535fba21eae7cbdb7a3c251d33c181 — AMB-1175 deleted old Time root fallback/continuity dock implementation and renamed week shape copy toward week fit.
- Commit 8dabd04abc3a8eaadb8b99d4e7b02495f15e0fe3 — AMB-1176A installed rendered product acceptance skills and status ceilings: Ready for Visual Review vs Visual Green/Release Green.
- Commits a678f4b2dbe7d6da966be3f81c7cde161124fc6b and ce75bb77122350fcab9500806e5ff26f8ee02e58 — AMB-1180 rebuilt Time/LifeShape field object after acceptance enforcement.

## Still requiring runtime proof

- Capture no-crash expansion
- Mic/voice permission behavior
- Keyboard/dock choreography
- Duplicate nav actually absent on device
- Today clock marker visually accurate
- Closure visibly mutates Today
- Time visual object quality after AMB-1180
- Goals current quality
- You current quality
- Search current quality
- VoiceOver/Dynamic Type/Reduce Motion/Reduce Transparency/High Contrast proof

## New source-only issues

- `AMB-ISSUE-0912` — internal route/deep-link vocabulary still uses tab/rootTab/openTab terminology.
- `AMB-ISSUE-0913` — Time mutation proof banner may expose receipt/proof/haptic metadata in primary flow; needs direct current-source check and screenshot proof.

## Validation not run

- App build
- Simulator/device run
- UI tests
- Visual regression harness
- Accessibility audits
- Real-device rendering checklist

## Status ceiling

This pass can only produce Source Green / Candidate Resolved statuses. It cannot produce Runtime Green, Visual Green, or Release Green.
