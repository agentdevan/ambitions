# Owner Rejection Rebaseline: Frontend Frontier Queue Freeze

## 1. Title

Owner Rejection Rebaseline for `frontend-flagship-shippability-remediation` (July 2026)

## 2. Purpose

This rebaseline records a mandatory override after real-device owner review and must be treated as the active governance baseline for all future frontend Codex work. It replaces assumptions from prior simulator-only/Packet 4.2 execution planning.

## 3. Owner real-device rejection verdict

"Owner real-device review supersedes Codex self-scored Yellow. A packet may be Yellow by source/simulator proof and still be owner-rejected."

The owner rejected the current frontend for these reasons:

1. Today has no actionable value when it shows “No step is required right now.”
2. Capture is visually poor and the UI/UX flow is wrong.
3. Capture must be a first-class surface, but not a dock/root tab.
4. Capture must use the entire screen while respecting safe area.
5. Navigation back behavior is broken.
6. A created goal could not be found in Goals.
7. Goals constellation / Life Area Atlas design is rejected and should be retired.
8. Goals should move toward native Apple Reminders-style hierarchy.
9. Time does not look or behave like Apple Calendar-grade time.
10. Today needs to scroll forward and backward through time windows; it should feel rotary.
11. Shell/dock/chrome should be rebuilt using the newest Facebook iOS app as a clarity reference.
12. You is closest to acceptable, but copy is still bad.
13. You should remove trailing value words next to chevrons.
14. You settings must connect to runtime or honestly show unavailable state.
15. Overall app is ugly, hard to navigate, and lacks functional value.

## 4. Rejected assumptions

- “Simulator source/screenshot success is sufficient for frontend quality.”
- “Packet scoring can remain Yellow when core navigability and discoverability are broken.”
- “Capture can remain modal/chatbot-like and still be first-class.”
- “Constellation/Life Area Atlas can remain the Goals canonical representation.”
- “Today passive copy state is acceptable as long as a route exists.”
- “Time segment chips and visual abstraction are enough for Calendar-grade behavior.”
- “Dock/chrome can be cosmetic if targets remain visible somewhere in screenshots.”

## 5. Superseded packet statuses

- Packet 1.3 Appearance Mode Proof: Needs Repair because a real detail route can show Light selected while content remains dark/dim/unreadable.
- Packet 3.1 Today Core Thesis Proof: Needs Repair because Today can show no actionable value.
- Packet 3.3 Goals State Legibility: Needs Repair / Product Direction Superseded because constellation/atlas grammar is rejected.
- Packet 3.4 Goals Editing / Proof / Handoff: Needs Repair because it depends on rejected Goals grammar and created-object discoverability failed owner review.
- Packet 3.5 Time Calendar-Grade Redesign: Needs Repair because Time still reads as a segmented card/control panel, not Calendar-grade.
- Packet 4.1 Capture Visual Grammar Repair: Needs Repair despite improvement because Capture remains sparse, visually weak, and not first-class.
- Navigation/back behavior: Red blocker.
- Created object discoverability: Red blocker.
- You Native Settings / Privacy Controls: Yellow retained only for structural direction; needs copy/runtime repair.

Historical packet closeouts remain preserved as evidence. This is an ownership override layer, not a deletion of history.

## 6. New active product decisions

1. **Capture is first-class but not a root tab**
   - Must be full-screen and route-ready globally.
   - Not a persistent dock/root destination.
   - No modal prompt-box feel.
   - No chatbot/fake AI classifier feel.
   - Dense dead-space is not acceptable.
   - Must show route affordances, review-before-save, destination before save, exact destination after save, open destination from receipt, cancel/back/close behavior, and remain globally reachable.

2. **Goals constellation/atlas design is retired**
   - Move toward Apple Reminders-style hierarchy.
   - Keep life areas as groups/folders/sections.
   - Keep goals as visible rows.
   - Keep active paths as rows/details.
   - No radial constellation, no abstract orbit nodes, no decorative radial map.
   - Remove “Create your first goal” trapped-in-diagram patterns.

3. **Time must become Calendar-grade**
   - Day/week scroll, now line, protected/open/fixed blocks.
   - Scheduled step blocks.
   - Conflict/reflow review and placement proposal.
   - Clear temporal navigation.
   - No segmented-card dashboard or abstract gauge treatment.

4. **Today must become actionable and rotary**
   - Keep useful paths when no step is required.
   - Scroll forward/back through time windows.
   - Show window context and Start Here when a real step exists.

5. **Shell/chrome clarity direction**
   - Rebuild shell/chrome clarity using Facebook iOS as reference principle only.
   - Apply: “Facebook-clear, Apple-native, Ambitions-private.”
   - Preserve four roots only: Today / Goals / Time / You.
   - Keep Capture global, global-search global, top header context visible, and no decorative/inert chrome.

6. **You cleanup**
   - Connect settings to runtime where possible.
   - Remove trailing value words beside chevrons and noisy right labels.
   - Show unavailable states honestly.
   - Repair appearance unreadability and runtime-inspected row behavior.

## 7. Facebook shell/chrome reference translation

- Clear top command header.
- Content-first layout; actions are obvious.
- One clear global search and one clear global capture action.
- Rounded anchored bottom dock with 4 persistent roots.
- Strong selected dock state and large touch targets.
- Practical navigation and back behavior on detail routes.
- No decorative icon-only controls without functional clarity.
- No noisy badges, no engagement loops, no social/feed identity.

## 8. New Red blockers

1. Back navigation does not work reliably.
2. Created goal cannot be found in Goals.
3. Today can show no actionable next step.
4. Capture is not a first-class full-screen creation surface.
5. Goals constellation design is rejected.
6. Time is not Calendar-grade.
7. Appearance detail route can be unreadable in selected light mode.
8. You settings copy/detail values are too noisy and not fully runtime-connected.
9. Existing Yellow scores are over-optimistic because real-device UX remains poor.
10. Shell/chrome is decorative and insufficiently navigable.
11. Created-object destination is unclear after Capture/Create Goal.

## 9. New P0 repair sequence

### P0.1 Navigation and Object Reality Gate

Target:
- back arrow works from all current detail routes.
- Capture-created goal appears in Goals.
- created object is searchable if Search exists.
- relaunch preserves created object if persistence is supported; if not, no fake durable-success claims.
- Capture receipt shows exact destination.
- no fake success.

Required proof:
- open You Appearance detail, tap back → You.
- open Goals detail, tap back → Goals.
- open Time review, tap back → Time.
- open Capture, cancel/close → previous root.
- create a goal through Capture/Create Goal.
- verify appears in Goals and can be opened.
- verify object found by Search if search indexed.
- relaunch durability if supported.

### P0.2 Shell / Chrome Clarity Rebuild

Target:
- clear top command header and modern rounded bottom dock.
- clear selected root + global Capture + global Search.
- practical touch targets.
- no dock/content collision; no collision between header and content.
- no decorative-only icons.

Required proof:
- Today/Goals/Time/You/Capture + one detail screenshot lane.
- redress any route or screenshot ambiguity against Facebook iOS clarity reference.

### P0.3 Capture First-Class Surface Reconstruction

Target:
- full-screen safe-area-respecting capture.
- clear route affordances and destination before/after save.
- review before save, destination confirmation, and local action states.
- goal/step seed, proof, protected time, note/thought, constraints, fixed point, attachment if supported.
- cancellation/return works and is honest when features are unavailable.

### P0.4 Goals Native Hierarchy Reconstruction

Target:
- remove constellation/atlas root.
- list hierarchy with groups/folders and visible goal rows.
- native drilldown and active paths.
- create goal appears as visible list row.
- no abstract orbit nodes or dashboard wall.

### P0.5 Today Actionable Rotary Meridian

Target:
- forward/back time-window navigation.
- useful non-step state with primary action.
- Start Here when a real step exists.
- review/protect/review paths visible.

### P0.6 Time Calendar-Native Reconstruction

Target:
- day/week calendar structure.
- now line.
- protected/open/fixed windows.
- conflict/reflow placement review.
- remove segmented card/control-panel behavior.

### P0.7 You Runtime Settings Cleanup

Target:
- remove trailing value words beside chevrons.
- move secondary details into subtitles or detail pages.
- connect settings actions to runtime and prove unavailable states honestly.
- repair appearance unreadability.
- verify actual setting changes affect app state.

## 10. Required future validation discipline

1. No packet may move from Red to Ready for Review while a P0 target proof item is unmet.
2. No fake durability claims when persistence/search are unavailable.
3. Real-device review evidence remains authoritative over simulator self-score.
4. Navigation/creation/discoverability issues are blocking failures, not cosmetic debt.
5. Keep historical packet evidence in place, then layer rebaseline decisions explicitly.

## 11. What future Codex sessions must not do

- must not continue Packet 4.2 without completing P0 sequence.
- must not claim prior Packet 4.1/4.2 Yellow as sufficient for owner acceptance.
- must not add code assuming durable create/discoverability.
- must not treat Search, shell, or Capture behavior as pass when route/back/receipt proofs are missing.
- must not restart old packet ordering without rechecking this rebaseline.

## 12. Resume instructions

- Do not continue Packet 4.2.
- Treat Packet 4.2 as frozen behind this rebaseline.
- Resume implementation from **P0.1 Navigation and Object Reality Gate**.
- Do not start any other implementation packet until P0.1 and prerequisite P0 checks above are completed or explicitly re-authored by owner.
