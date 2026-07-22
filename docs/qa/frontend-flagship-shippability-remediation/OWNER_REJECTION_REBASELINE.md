# Owner Rejection Rebaseline: Historical Frontend Control Plane

Status: Historical owner evidence; conflicting direction superseded 2026-07-22
Installed: July 2026  
Scope: Ambitions frontend remediation  
Authority: Owner real-device review superseding simulator-Yellow packet closeouts

This document preserves the July 2026 real-device rejection evidence. Its shell,
Goals, and Today prescriptions are superseded where they conflict with
`docs/audits/rp-01-08-evidence-audit/13-owner-reconciliation-decisions.md` and
`RECONCILED_FLAGSHIP_RECONSTRUCTION_PLAN.md`. The evidence and non-conflicting
quality findings remain historical inputs; this file no longer authorizes an
implementation queue.

## 1. Purpose

The prior remediation train produced useful source, simulator, screenshot, and governance proof, but real-device owner review showed that the app still fails the product bar. This document records the override so future Codex sessions do not continue from the false premise that simulator-Yellow equals product progress.

Historical packet logs remain useful process evidence. They are not product acceptance.

## 2. Owner real-device rejection verdict

**Owner real-device review supersedes Codex self-scored Yellow. A packet may be Yellow by source/simulator proof and still be owner-rejected.**

The owner rejected the current frontend for these reasons:

1. Today has no actionable value when it shows “No step is required right now.”
2. Capture is visually poor and the UI/UX flow is wrong.
3. Capture must be a first-class surface, but not a dock/root tab.
4. Capture must use the entire screen while respecting safe area.
5. Navigation back behavior is broken.
6. A created goal could not be found in Goals.
7. Goals constellation / Life Area Atlas design is rejected and must be retired.
8. Goals should move toward native Apple Reminders-style hierarchy.
9. Time does not look or behave like Apple Calendar-grade time.
10. Today needs to scroll forward and backward through time windows; it should feel rotary.
11. Shell/dock/chrome should be rebuilt using the newest Facebook iOS app as a clarity reference.
12. You is closest to acceptable, but copy is still bad.
13. You should remove trailing value words next to chevrons.
14. You settings must connect to runtime or honestly show unavailable state.
15. Overall app is ugly, hard to navigate, and lacks functional value.

## 3. Rejected assumptions

These assumptions are no longer allowed:

- Simulator source/screenshot success is sufficient for frontend quality.
- Packet scoring can remain Yellow when core navigability and discoverability are broken.
- Capture can remain modal/chatbot-like and still be first-class.
- Constellation / Life Area Atlas can remain the Goals canonical visual representation.
- Today passive no-step copy is acceptable as long as a route exists somewhere.
- Time segmented controls, abstract gauges, or visual-system facts are enough for Calendar-grade behavior.
- Dock/chrome can be cosmetic if targets remain visible somewhere in screenshots.
- Created-object workflows can pass if the object cannot be found by the user.
- Settings can appear connected without runtime behavior or an honest unavailable state.

## 4. Superseded packet statuses

Prior Yellow / Ready For Review statuses remain historical evidence, but they are owner-rejected where contradicted below:

- Packet 1.3 Appearance Mode Proof: **Needs Repair** because a real detail route can show Light selected while content remains dark/dim/unreadable.
- Packet 3.1 Today Core Thesis Proof: **Needs Repair** because Today can show no actionable value.
- Packet 3.3 Goals State Legibility: **Needs Repair / Product Direction Superseded** because constellation/atlas grammar is rejected.
- Packet 3.4 Goals Editing / Proof / Handoff: **Needs Repair** because it depends on rejected Goals grammar and created-object discoverability failed owner review.
- Packet 3.5 Time Calendar-Grade Redesign: **Needs Repair** because Time still reads as a segmented card/control panel, not Calendar-grade.
- Packet 4.1 Capture Visual Grammar Repair: **Needs Repair** despite improvement because Capture remains sparse, visually weak, and not first-class.
- Navigation/back behavior: **Red blocker**.
- Created-object discoverability: **Red blocker**.
- You Native Settings / Privacy Controls: **Yellow retained only for structural direction**; copy/runtime repair remains required.

## 5. Historical product decisions

### 5.1 Capture is first-class but not a root tab

Capture is a global, first-class creation surface. It is not a persistent root, dock tab, inbox, notes feed, chatbot, or AI classifier.

Capture must:

- use the full screen while respecting safe area
- feel like a native iPhone creation surface
- expose route affordances clearly
- support review before save
- show destination before save
- show exact destination after save
- allow opening the destination after save
- support cancel, back, and close correctly
- remain globally reachable
- make unsupported routes honest and bounded

Capture must not:

- become a dock tab
- become an inbox
- become a notes feed
- look like a prompt box
- look like a chatbot
- look like an AI resolver/classifier
- hide destination behind vague copy
- claim persistence if the object cannot be found

### 5.2 Goals constellation / atlas design is retired

The current constellation / Life Area Atlas visual direction is rejected.

Goals must move toward native Apple Reminders-style hierarchy. Do not clone Apple Reminders one-to-one; extract native hierarchy grammar:

- life areas as groups, folders, or sections
- goals as visible rows
- active paths as rows/details
- clean add/edit flow
- created goals immediately visible
- native drilldowns
- practical row heights
- clear back navigation
- state visible through rows, sections, subtitles, counts, or detail surfaces

Goals must not use:

- radial constellation
- abstract orbit nodes
- decorative atlas map
- “Create your first goal” trapped in a diagram
- tiny proof/status marks as the primary state language
- dashboard/KPI wall
- generic project-management board

### 5.3 Time must become Calendar-grade

Time must feel structurally closer to Apple Calendar without cloning Calendar one-to-one.

Time must use native calendar grammar:

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

Time must not read as:

- segmented control panel
- dashboard card
- abstract gauge
- productivity score
- static list of system facts

### 5.4 Today must become actionable and rotary

Today must not be a passive empty state.

When no step is required, Today still needs useful action:

- Build today
- Capture
- Add a step
- Review open time
- Protect time
- Inspect why nothing fits

Today must scroll forward and backward through time windows and feel like a living rotary meridian, not a static poster.

Today must show:

- current window
- previous windows
- next windows
- Start Here when a real step exists
- useful no-step state
- action path
- proof/receipt after action

### 5.5 Shell/chrome clarity direction

Owner provided current Facebook iOS screenshots as a shell/chrome reference. Do not copy Facebook’s product, feed, social graph, notification model, stories model, branding, engagement loops, or visual identity.

Extract only shell/chrome principles.

Ambitions shell should be:

**Facebook-clear, Apple-native, Ambitions-private.**

Meaning:

- Facebook-clear: controls are obvious, touchable, and navigable.
- Apple-native: proportions, safe areas, lists, sheets, scrolling, navigation, and detail routes feel like real iOS.
- Ambitions-private: no feed, no social graph, no attention mechanics, no noisy badges, no Meta branding, no engagement UI.

The shell target:

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
- no broken or inert controls
- rounded anchored bottom dock
- four persistent roots only: Today / Goals / Time / You
- strong selected dock state
- content never hidden behind dock
- Capture remains global, not dock tab
- root surfaces scroll as real product surfaces
- detail routes are full native navigable surfaces

### 5.6 You cleanup

You may retain the native Settings direction, but must repair:

- remove trailing value words next to chevrons
- avoid noisy right-side labels like “On device,” “No account,” “Light,” “Ready,” “Goals,” and “Time”
- put secondary details as subtitles under row titles or inside detail pages
- connect settings to runtime where possible
- show unavailable honestly where not connected
- repair Appearance detail unreadability
- keep local-first/privacy controls real and inspectable

## 6. New Red blockers

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

## 7. Active P0 repair sequence

Future implementation must run this sequence before resuming the old packet queue.

### P0.1 Navigation and Object Reality Gate

Target:

- back arrow works from all current detail routes
- Capture-created goal appears in Goals
- created object can be opened from Goals
- created object is searchable if Search exists
- relaunch preserves created object if persistence is supported
- if persistence is not supported, UI makes that honest
- Capture/Create Goal receipt shows exact destination
- no fake success

Required proof:

- open You Appearance detail, tap back, return to You
- open Goals detail, tap back, return to Goals
- open Time review, tap back, return to Time
- open Capture, cancel/close, return to previous root
- create a goal through Capture/Create Goal
- verify it appears in Goals and can be opened
- verify object found by Search if search indexed
- relaunch durability if supported

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

Acceptance:

- If back fails, Red.
- If Capture looks like a modal prompt, Needs Repair.
- If dock looks decorative or ambiguous, Needs Repair.
- If screenshots are less clear/tappable than the Facebook clarity reference, Needs Repair.

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

Unsupported route types must show honest unavailable/bounded states. Do not fake support.

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

## 8. Relationship to old packet queue

The old Packet 4.2 path is frozen.

The pre-rebaseline packet queue is historical process evidence only. It may not be resumed until the P0 owner-rejection repair sequence is complete or the owner explicitly re-authorizes a narrower sequence.

Future Codex sessions must not:

- continue old Packet 4.2 first
- treat old Packet 4.1/4.2 Yellow as owner acceptance
- add code assuming durable create/discoverability
- treat Search, shell, or Capture as pass when route/back/receipt proofs are missing
- restart old packet ordering without reading this rebaseline

## 9. Required future validation discipline

1. No packet may move from Red to Ready For Review while a P0 target proof item is unmet.
2. No fake durability claims when persistence/search are unavailable.
3. Real-device review evidence remains authoritative over simulator self-score.
4. Navigation/creation/discoverability issues are blocking failures, not cosmetic debt.
5. Every P0 packet requires Depth Map, Visual Delta, focused runtime proof, screenshot proof where UI is touched, and explicit repair cycles.
6. Keep historical packet evidence in place, then layer rebaseline decisions explicitly.

## 10. Resume instructions

- Do not continue old Packet 4.2.
- Treat Packet 4.2 as frozen behind this rebaseline.
- Resume implementation from **P0.1 Navigation and Object Reality Gate**.
- Do not start any other implementation packet until P0.1 and prerequisite P0 checks above are completed or explicitly re-authorized by owner.
- Preserve historical packet logs as process evidence, but let owner real-device evidence control current status.
