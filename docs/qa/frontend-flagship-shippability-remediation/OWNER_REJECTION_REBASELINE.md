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
   - Capture must be a full-screen creation surface.
   - It is global and first-class.
   - It is not a persistent dock/root destination.
   - Must use the full screen while respecting safe area.
   - Must feel like a real native creation surface.
   - No modal prompt-box feel.
   - No chatbot/fake AI classifier feel.
   - Dense dead-space is not acceptable.
   - expose route affordances clearly.
   - Must show route affordances, review-before-save, destination before save, exact destination after save, open destination from receipt.
   - Must support cancel/back/close correctly and remain globally reachable.
   - Do not claim persistence if the object cannot be found.
   - must not be a dock tab.
   - must not become an inbox.
   - must not become a notes feed.

2. **Goals constellation/atlas design is retired**
   - The current constellation / Life Area Atlas visual direction is rejected.
   - Goals must move toward native Apple Reminders-style hierarchy.
   - Do not clone Apple Reminders one-to-one, but use its native grammar:
     - clear list hierarchy
     - life areas as groups/folders/sections
     - goals as visible rows
     - active paths as rows/details
     - clean add/edit flow
     - created goals immediately visible
     - detail drilldowns
     - practical row heights
     - clear back navigation
   - Keep life areas as groups/folders/sections.
   - Keep goals as visible rows.
   - Keep active paths as rows/details.
   - No radial constellation, no abstract orbit nodes, no decorative radial map.
   - no “Create your first goal” box trapped in a diagram.
   - no unclear proof/status tiny marks.
   - Remove “Create your first goal” trapped-in-diagram patterns.

3. **Time must become Calendar-grade**
   - Time must feel structurally closer to Apple Calendar.
   - Do not clone Calendar one-to-one, but use native calendar grammar:
     - day/week scroll
     - now line
     - time blocks/windows
     - protected time
     - open time
     - fixed points
     - scheduled step blocks
     - conflict/reflow review
     - placement proposal
     - clear temporal navigation
   - Time must not read as:
     - segmented control panel
     - dashboard card
     - abstract gauge
     - productivity score
     - static list of system facts

4. **Today must become actionable and rotary**
   - Today must not be a passive empty state.
   - Useful actions when no step is required:
     - Build today
     - Capture
     - Add a step
     - Review open time
     - Protect time
     - Inspect why nothing fits
   - Scroll forward and backward through time windows.
   - Today should feel like a living rotary meridian, not a static empty poster.
   - Show:
     - current window
     - previous windows
     - next windows
     - Start Here when a real step exists
     - useful no-step state
     - action path
     - proof/receipt after action

5. **Shell/chrome clarity direction**
   - Owners provided current Facebook iOS screenshots as a shell/chrome reference.
   - Extract only shell/chrome principles.
   - Ambitions shell should be: “Facebook-clear, Apple-native, Ambitions-private.”
   - Facebook-clear: controls are obvious, touchable, and navigable.
   - Apple-native: proportions, safe areas, lists, sheets, scrolling, navigation, and detail routes feel like real iOS.
   - Ambitions-private: no feed, no social graph, no attention mechanics, no noisy badges, no Meta branding, no engagement UI.
   - Apply target shell behavior:
     - clear top command header
     - working back on drilldowns
     - visible surface identity
     - visible mode/context
     - clear Search action
     - clear Capture action
     - one contextual action where needed
     - large touch targets
     - readable contrast in light/dark
     - no decorative-only icons
     - no broken/inert controls
     - rounded anchored bottom dock
     - four persistent roots only: Today / Goals / Time / You
     - strong selected dock state
     - content never hidden behind dock
     - Capture remains global, not dock tab
     - root surfaces scroll as real product surfaces
     - detail routes are full native navigable surfaces

6. **You cleanup**
   - Remove trailing value words next to chevrons.
   - Avoid noisy right-side labels like “On device,” “No account,” “Light,” “Ready,” “Goals,” “Time.”
   - Put secondary details as subtitles under row titles or inside detail pages.
   - Connect settings to runtime where possible.
   - Show unavailable honestly where not connected.
   - Repair Appearance detail unreadability.
   - Keep local-first/privacy controls real and inspectable.

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
- working back behavior
- obvious top command header
- modern rounded bottom dock
- clear selected root
- global Capture action
- global Search action
- practical touch targets
- content scrolls under stable chrome
- no dock/content collision
- no header/content collision
- no decorative-only icons
- light/dark proof where practical
- screenshots for Today, Goals, Time, You, Capture, and one detail route

The shell should use Facebook iOS screenshots as a clarity reference only.
If back fails, Red.
If Capture looks like a modal prompt, Needs Repair.
If dock looks decorative or ambiguous, Needs Repair.
If screenshots are less clear/tappable than the reference, Needs Repair.

### P0.3 Capture First-Class Surface Reconstruction

Target:
- full-screen Capture surface
- respects safe area
- no modal prompt-box feel
- no sparse dead surface
- clear route affordances
- free capture
- goal seed
- step seed
- proof
- protected time
- note/thought
- constraint/fixed point
- attachment if supported
- review before save
- destination before save
- receipt with exact destination after save
- open destination from receipt
- cancel/back works
Unsupported route types must show honest unavailable/bounded states.
Do not fake support.

### P0.4 Goals Native Hierarchy Reconstruction

Target:
- retire constellation/atlas root
- replace with native list hierarchy
- life areas as groups/folders/sections
- goals as visible rows
- active paths as rows/details
- add goal creates visible row
- goal detail is native drilldown
- no radial constellation
- no abstract orbit node UI
- no dashboard wall
- no proof/root clutter

### P0.5 Today Actionable Rotary Meridian

Target:
- Today scrolls forward and backward through time windows
- current window is clear
- previous/next windows are accessible
- no-step state has primary action
- Start Here appears when real step exists
- Capture/build/protect/review paths are visible
- no passive empty root

### P0.6 Time Calendar-Native Reconstruction

Target:
- day/week calendar grammar
- now line
- protected/open/fixed blocks
- scheduled Step block
- conflict/reflow review
- placement proposal
- no segmented card dashboard
- no abstract gauge/control panel

### P0.7 You Runtime Settings Cleanup

Target:
- remove trailing value words beside chevrons
- move secondary values to subtitles/details
- connect settings to runtime
- verify Appearance back navigation
- repair Appearance detail unreadability
- verify actual setting changes affect app state
- keep unavailable controls honest

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
