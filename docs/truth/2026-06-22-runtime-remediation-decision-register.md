# 2026-06-22 Runtime Remediation Decision Register

**Status:** Canonical decision register for the 2026-06-22 runtime QA remediation.  
**Owner posture:** Product, architecture, QA, and Codex implementation law.  
**Linked Linear project:** `Ambitions Runtime QA Remediation — 2026-06-22 Device Review`.  
**Evidence set:** `docs/qa/evidence/2026-06-22-device-review/` and Linear issue `AMB-1181` attachment `More issues.zip`.

This document records the locked product, architecture, interaction, visual, runtime, proof, and Codex operating decisions made after the 2026-06-22 on-device review. It is not an implementation proof packet. It is the decision base that all remediation dossiers and Codex runs must obey.

---

## 1. Codex operating law

Codex must not be given vague work such as “fix Capture,” “make Goals better,” or “polish the shell.” Every execution bundle requires a repo-backed implementation dossier that states:

- what to delete,
- what to preserve,
- what to build,
- what runtime state is real,
- what fake state is forbidden,
- what visual law applies,
- what copy is allowed or forbidden,
- what gestures/actions exist,
- what proof is required,
- what status ceiling applies if proof is missing.

Codex may decide low-level Swift implementation mechanics and local refactors needed to compile the scoped train. Codex may not decide product behavior, IA, copy density, route behavior, fake-state policy, proof standards, or what “fixed” means.

Execution model:

```text
Parent train = architecture/product decision layer
Execution bundle = what Codex implements
QA leaves = acceptance criteria and proof checklist
```

Execution order:

1. `AMB-1191` — Theme / Design System Tokens
2. `AMB-1194` — Shell / Stage OS
3. `AMB-1192` — Capture Route Graph + Composer
4. `AMB-1193` — Goals Root / Detail Rebuild
5. `AMB-1195` — Today Reality Window / Action Gating
6. `AMB-1196` — Search Find / Act / Inspect
7. `AMB-1197` — Time Native Life Calendar
8. `AMB-1198` — You Settings / Appearance / Privacy
9. `AMB-1199` — Final Proof / Accessibility / Release Gate
10. `AMB-1200` — Register Sync / Control Closeout

Status ceiling:

```text
No validation = Red
Source/test only = Source Green / Runtime Yellow max
Simulator-only visual proof = Visual Yellow max
Device screenshot/video + tests + docs update = Candidate Runtime/Visual Green
Owner acceptance = Done
```

---

## 2. Runtime object law

Ambitions is not avoiding tasks. Ambitions must be capable of excellent task behavior as a contained feature. It must not frame itself as a task app.

Canonical object model for the remediation:

```text
Goal = durable direction
Step = actionable unit
Free-floating Step = valid when no goal currently fits
Thought = valid modular capture destination
Life Area = default or custom organizing domain
Capture = global intake + resolver + creation flow for all of the above
```

Free-floating steps are equal candidates to goal-linked steps when they fit. Conflicts should be resolved in Capture, pathing, Time Fit, or Goal Detail, not by hard-coded demotion of unlinked work.

Runtime app paths must be real. If a runtime path is unavailable, the app must build the real path, hide it, disable it honestly, or show an honest unavailable state. Fake success, fake placement, fake proof, dead controls, fake route certainty, and source-only closure are forbidden.

---

## 3. Theme and design-system law

The design-system remediation uses a full design-system package/layer, not scattered color extensions. It must include or prepare for semantic color tokens, material tokens, spacing tokens, typography tokens, motion tokens, haptic semantics, a semantic glyph registry, preview matrices, and audit hooks.

Light Mode is native Apple luminous graphite-on-mist: mist, pearl, pale graphite, restrained celestial warmth, high contrast, and no grey-on-grey washout. Dark and Light are rebuilt from one semantic token model. Light Mode must not be patched around dark-mode assumptions.

Proof requires a screenshot matrix, token audit, safe-area audit, Dynamic Type, Light/Dark/System live-switch proof, and route proof that navigation, Capture access, and Search access still work.

---

## 4. Shell / Stage OS law

Shell is Stage OS. It owns navigation, route depth, global gestures, Capture/Search access, safe-area behavior, motion, haptics, accessibility actions, and semantic glyphs.

Visible root shell:

- four separate floating icon-only navigation buttons,
- structurally coordinated by an invisible rail,
- active state is accent-colored icon only,
- no visible labels by default,
- no rings, underline, glow, badge, capsule, or dock border.

Labels may appear in first-run teaching, long press, and accessibility. VoiceOver always has labels and selected state.

Capture and Search have no persistent buttons. They must remain reachable through global gestures, App Shortcuts, keyboard commands, VoiceOver custom actions, and first-run/progressive teaching. Capture’s primary discoverable gesture is long-press empty Stage, with optional advanced edge gesture if conflict-free. Search uses pull-down from Stage.

Shell gesture priority:

```text
system gestures
accessibility
active control gestures
route gestures
shell gestures
```

Dock appears only on root surfaces. Capture, Search, Goal Detail, Area Detail, Time Fit, and other drilldowns hide root dock. Stage background full-bleeds; interactive chrome respects true status/gesture safe zones. No artificial shelves.

Motion must express route depth and material continuity, not decoration. Reduce Motion is required. Semantic haptics include tab switch, Capture open, Search open, commit receipt, invalid action, and protection set, while respecting system/user settings.

---

## 5. Capture route graph and composer law

Capture is a typed route graph and full-screen Stage composer, not a sheet, tab, floating card, or quick-entry box.

First-class intent routes include free capture, goal seed, step seed, proof, time protect, note/thought, constraint/fixed point, and attachment/context capture. `Task` is not user-facing language.

Capture presentation:

- full-screen Stage takeover,
- field-first atmospheric canvas,
- no placeholder text,
- spatial cursor and iconography,
- ambient input affordances,
- one-time gesture teaching,
- no route categories while typing.

Voice uses native keyboard dictation only for this remediation. Codex must not build a fake custom mic/transcription path. A visible microphone affordance must either invoke native keyboard dictation through the text input path if supported or be absent.

Attachments are real local capture attachments. Attachment role depends on destination: proof, reference, source, or context.

Dynamic flow:

```text
Composer -> optional context/depth collection -> Proposal -> Commit / Receipt
```

Contextual launch example: tapping `+` in Work life area opens global Capture with intent `Goal`, lifeArea `Work`, skips destination picker, starts goal-direction capture, collects context, proposes a goal thread, and returns to Goals Work area after commit.

Proposal screen contains captured text, proposed destination, editable fields, relevant life area/goal/time window, accept, change, and undo. The resolver is local/deterministic. Explanation is hidden behind a glyph and shown inline only when the user asks.

Capture supports new goal, custom life area, thought, free-floating step, and Open Field destinations. It must not force every input into a tiny fixed category set or junk drawer.

Receipt uses ambient proof stitch with destination, change destination, undo, and inspect. Persistence proof requires create capture, reload/reopen store, verify object still exists, and route/inspect still works.

---

## 6. Goals root atlas law

Goals root is a broad, customizable Life Area Atlas. Life areas are the root object. Goals, free-floating steps, thoughts, proof, receipts, settings, and history live inside area drilldowns.

Goals root is not a goal list, constellation gimmick, dashboard, report card, or diagnostic console.

Default life areas:

```text
Work
Body
Home
People
Self
Future
```

Each area can be renamed, hidden, reordered, assigned an icon, and customized. Users can create custom areas from Goals root and Capture Proposal.

Life areas are simple, modern, elegant regions/tiles/zones. They must not render as generic cards. Empty defaults remain visible with icon/name and minimal create affordance. No fake example content.

Area drilldown owns depth: goals, free-floating steps, thoughts, proof, receipts, sources/context, area settings, accomplished goals, and history.

Root behavior:

- active goals appear as thread glyphs,
- free-floating steps appear as minimal beads/chips when useful,
- thoughts appear as subtle sparks/marks with operational detail in drilldown,
- Open Field is a valid holding area, not Inbox and not junk drawer,
- life areas are never “done,”
- accomplished goals remain in history/proof,
- Today relationship appears as minimal focus/highlight/lift when relevant, never `Feeds Today` copy,
- Time relationship is inside area drilldown, not root,
- Global Search handles Goals search,
- tapping an area opens full-screen Area Detail,
- tapping a goal thread uses inline preview only if elegant, otherwise full-screen Goal Detail on iPhone,
- area customization uses long press and area detail.

No root percentages. Movement/proof/accomplished state only. Root density is sparse-to-medium.

---

## 7. Goal detail / path timeline law

Goal Detail combines goal profile, operational path surface, and historical journal.

Central object: horizontal/scrubbable path field with anchored nodes. Past proof/history lives left, current step is centered, future path lives right. Default focus is current step, or “choose next step” if no current step exists.

Node types:

```text
Proof
Step
Decision
Recovery
Pause
Accomplished
```

Past proof is append-corrected, not overwritten. Original receipt remains inspectable. Late proof can attach to historical nodes and may reflow the entire goal path.

Future path editing is a moat. Users can move, replace, pause, delete, split, and locally/deterministically regenerate/propose future path while preserving history. Deleting a future step offers remove or mark skipped when appropriate.

Goal deletion hard-deletes only if no proof/history exists. Otherwise archive/accomplish/pause semantics protect history. Direction changes create revision events; large changes can become a new goal.

Accomplished goals preserve proof/history, may suggest next direction, and may offer share/create output. No gamified celebration.

Today pulls best fit from goal path; detail can nominate/protect candidates. Time places real steps and inspects time pressure/capacity. All additions route through contextual Capture with prefilled context.

Actions include add proof, add step, pause/resume, recover, revise direction, archive/accomplish, change area, split, merge, convert loose steps, delete, modify, and share/create output. Advanced actions hide behind long press/more/inspection.

Recovery reduces path pressure, creates smaller next step, and may ask Today to stop pulling temporarily. Paused goals remain visible, keep proof/history, stop generating Today candidates, and can resume.

Proof stitches attach to path nodes; receipt drawer shows full trail. Thoughts can attach to path node, future step, goal root, or goal thought pool, and can grow into steps/goals.

---

## 8. Today / Reality Window law

Today root is a visually rich, actionable Reality Window. It is not a generic planner, task list, dashboard, timeline clone, or CTA stack.

When a valid Start Here step exists, Today uses day-context mode plus token-in-window behavior: day reality stays visible and the actionable step is placed inside the viable current window.

When no valid step exists, Today shows a recovery state. It protects capacity instead of making the user feel broken.

Root actions are state-gated. No fixed CTA row. No dead actions. The token itself is the primary action. Accessibility action can say “Begin.” Closure appears only after a step has been started or is proof-eligible.

Remove generic `Capture what changed` from Today. If a current step is active/proof-eligible, show proof/closure as a state-specific glyph. `Shape Time` opens a focused Time Fit flow, never the Time root. `Protect this window` opens a scoped Protect Window flow now and may support direct manipulation later. `Review context` is removed; inspection glyph/long press exposes why-this, why-now, source, capacity, and constraints.

Root uses small semantic glyphs for fit reasons. Tapping expands/drills into explanation. Next fixed point is a meridian/window anchor glyph with accessible label. Protected time is boundary shading plus protection glyph.

Remove Start Here/Meridian toggle, root rail copy, and nonsemantic timeline icons. Replace visible `Live now` copy with subtle current-node behavior. No goal candidates show calm Open Field/recovery-adjacent state. Too little time offers smaller step, recovery, later placement, or Time Fit when real. Low capacity offers recovery or smaller step. Free-floating steps are equal candidates. Thoughts surface only when they can become action or need placement. Closure creates proof stitch; detail reveals receipt.

Root copy is almost none: step title, tiny state labels, accessible labels. Tap/expand/drilldown can explain.

---

## 9. Search Find / Act / Inspect law

Search is a unified Find / Act / Inspect surface. It is not a chatbot, shallow sheet, or generic text search.

Invocation: global gesture, keyboard command, App Shortcut, VoiceOver action, first-run teaching, no persistent button. Presentation: full-screen Stage takeover with soft origin context. Query field: command field with optional tokens.

Search supports goals, steps, thoughts, proof, receipts, life areas, captures, time windows, settings/actions/system areas. Results are ranked/grouped by intent and context.

Row anatomy:

```text
object glyph
title
source/area
state
one valid action
optional inspect glyph
```

Copy is icon-first with one short human line only where needed. Internal routing labels such as `Inspectable route` and source freshness copy are forbidden on primary rows.

Scope is global with origin-biased ranking. Empty state is minimal with one contextual action. Default tap opens; secondary gesture/action exposes valid operations. Mutating actions are state-gated and receipt-backed.

Indexing is local deterministic SearchIndex first; Spotlight may mirror later. No cloud/LLM query path. Ranking uses text, origin context, current day relevance, object state, and user correction feedback.

Search passes query into Capture with prefilled input/context. It does not create objects directly. Search navigates precisely into Goals, Time, and proof contexts; mutations happen in operation surfaces or Capture/Time Fit.

---

## 10. Time native Life Calendar law

Time is Ambitions’ native Life Calendar: as obvious as Apple Calendar, as rich as Weather, and as intelligent as the Private Life Runtime. It is not avoiding calendar behavior. It is a first-class calendar-grade surface enriched by capacity, protection, placement, proof, recovery, and goal-path intelligence.

Time root is a calendar-grade LifeShape Calendar Field. Day/week/month/year/list are real calendar orientations with Ambitions overlays. First view is current day around now with native access to week/month/year/list.

Now is a native seam/line related to next fixed point and current open window. Fixed points are calendar-native event anchors with semantic glyphs and tap detail. No unexplained dots. Open capacity is visible as open windows with subtle capacity quality.

Lenses:

```text
Open Capacity
Protected Time
Pressure
Recovery
Goal Load
Transition
```

Place Step appears only for a real Step object and opens focused placement flow. No real step means no Place Step. No real window means honest unavailable/recovery/shape options. A real Step may be goal-linked or free-floating and must have title, estimated size/duration, source, and state.

Free-floating steps have equal placement rights. Thoughts convert through Capture/Proposal. Time may show unresolved thought pressure in inspection/Open Field.

Protect Window is a calendar-native selection/protection flow. Protected time is a boundary object with start/end, reason, strength, recurrence, source, and conflict behavior. It actively affects placement. Conflicts use local deterministic proposals with alternatives; no silent auto-resolve.

Today and Time use the same placement/protection model. Goals owns path direction; Time tests feasibility and places real steps into real windows. Capture can create fixed points, protected windows, step candidates, constraints, and time notes through typed routes.

Proof residue may appear on calendar windows; receipt detail opens in drilldown. Day/week/list are operational first; month/year can start summary-focused but must be real. List mode is calendar-grade agenda plus operational queue and accessibility equivalent.

Copy is sparse native labels plus tap-to-explain. No root `TIME · LifeShape Field` or `LifeShape Field` marketing copy. Internal name is inspection/help only. Light Mode uses full semantic tokens with misted graphite calendar field.

---

## 11. You settings law

You = Apple iOS Settings structure + ChatGPT iOS settings clarity/compactness + Ambitions material, privacy, local-first, proof, and life-system cohesion.

You is a native Settings/Profile control surface backed by User System Profile. It is not a dashboard, product manifesto, or diagnostic console.

Root style: Apple Settings grouping, ChatGPT compact clarity, Ambitions materials. No table dividers. No bottom glow. No status dashboard.

Root hierarchy:

```text
Appearance
Capture
Life Areas
Privacy
Local Data
Sources
Receipts
Accessibility
About
```

A small profile/local-status capsule may appear at top.

Row anatomy: SF Symbol/Ambitions glyph, title, optional short secondary state only if useful, chevron or native control, no root paragraphs.

Appearance supports System/Light/Dark with live propagation. Preview tiles may exist only if rendered from real tokens. Capture settings include input behavior, keyboard dictation behavior, attachment defaults, gesture teaching reset, and permission state. Life Areas can be managed in You while Goals/Capture provide contextual creation. Privacy is a native control surface for local-only status, permissions, data boundaries, export/delete, source access. Local Data supports export, erase, backup/sync status if applicable, local store status, migration state, and deeper diagnostics. Sources supports add/remove/disable/inspect. Receipts is a searchable proof ledger by goal, step, capture, time, date, and surface. Accessibility includes Dynamic Type, Reduce Motion, Increase Contrast, haptics, icon labels, and VoiceOver actions. About includes version, build, local-first note, privacy/legal, and diagnostics export.

Every visible row opens real detail or honest unavailable state. No dead settings.

---

## 12. Proof and evidence control law

The Linear project remains Red / Off Track while P0 runtime issues remain open. `More issues.zip` remains attached to `AMB-1181`. The repo stores durable evidence index, screenshot map, and manifest under `docs/qa/evidence/2026-06-22-device-review/`. Historical evidence never proves a fix; fresh proof is required for repaired builds.

Every train must update `docs/qa/KNOWN_ISSUES.md` and provide a proof packet before In Review. Owner acceptance is required for Done.

---

## 13. Accepted tradeoffs

- No persistent Capture/Search buttons increases discoverability burden; mitigations are first-run teaching, progressive hints, gesture map in You/Help, VoiceOver actions, keyboard commands, and App Shortcuts.
- Large binary evidence is not repo-native; current policy is Linear attachment plus repo index. Future policy may use Git LFS, R2, or artifact storage.
- Time must remain calendar-grade; it is a Life Calendar, not an anti-calendar.
- Ambitions can contain best-in-class task behavior through Step/free-floating Step capability without becoming a task app.
