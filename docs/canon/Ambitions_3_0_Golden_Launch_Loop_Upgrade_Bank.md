# Ambitions 3.0 — Golden Launch Loop Upgrade Bank

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Related locked Today spec: [Ambitions 3.0 — Day Rail SwiftUI Build Spec](./Ambitions_3_0_Day_Rail_SwiftUI_Build_Spec.md)  
Last updated: 2026-04-30

---

## Purpose

This document adds the full 230-upgrade Golden Launch Loop bank to Ambitions 3.0 front-end planning.

Canonical loop:

```text
Capture → Place → Plan → Do Today → Close / Recover → Save Proof
```

This is not a new product direction. It is the front-end upgrade backlog for perfecting the existing Ambitions launch loop while preserving the locked shell and the new Ambitions Day Rail invention.

---

## Locked Day Rail Compatibility Rule

The Ambitions Day Rail is now the canonical Today signature object. Any Do Today upgrade must reinforce the locked Day Rail, not replace it.

Do Today upgrades must preserve:

- `AmbitionsDayRailView` as the dominant Today object.
- The compact Today context header above the rail.
- The rail as the Now / Next / Later navigation spine.
- `Start here` as one recommended step, not a dashboard of competing recommendations.
- Rail row tap opens Step Detail; only `Start now` opens Step Session.
- Closure and proof appear inside or directly attached to the rail.
- No generic timeline, task list, calendar clone, focus-timer-first redesign, productivity score, streak system, or extra Today dashboard stack.
- No starfield treatment on Today. Starfield remains Capture and First Run only unless canon is revised.

If a future implementation would conflict with the Day Rail spec, the Day Rail spec wins.

---

## Upgrade Admission Rules

An upgrade is allowed only if it improves at least one of these:

1. Less friction.
2. More clarity.
3. More trust.
4. More emotional safety.
5. More proof.

An upgrade should be rejected or deferred if it adds exposed top-level width, duplicates the Day Rail, creates guilt, introduces fake AI theater, creates a generic task/calendar app feel, or weakens the premium iPhone-native surface.

---

# A. Highest-Impact Loop Upgrades

1. Universal Object Lifecycle — every object moves through Captured, Placed, Planned, Surfaced, Started, Closed, Proven.
2. Origin Metadata — every step, goal, plan item, proof item, and receipt knows where it came from.
3. Belonging Resolver — loose items can resolve into Today, Goal, Plan, Later, Proof, Review, Archive, or Not Needed.
4. Canonical Recommended Step Model — every major surface can point toward one next believable step.
5. Internal Step Believability Check — evaluate fit without exposing productivity scores.
6. Step Source Label — show whether a step came from goal, capture, plan, calendar, recovery, review, automation, or user.
7. Duration Source Label — show whether duration was user-set, suggested, historical, calendar-derived, or accepted from plan.
8. Why This Sheet — explain recommended steps with source facts and alternatives.
9. Step Detail Before Step Session — rail row opens detail; `Start now` starts the session.
10. Execution-First Step Session — optional timer only; never timer-first.
11. One Closure Sheet Everywhere — use the same Action Closure grammar across meaningful objects.
12. Still Counts Flagship Moment — partial or imperfect progress can become proof.
13. Soft Stale-Step Handling — old work needs closure, not shame.
14. One-Tap Recovery Explanation — recovery shows what stays, moves, closes, or rebuilds.
15. Receipt for Every Plan Change — every meaningful move, update, skip, or reflow leaves a receipt.
16. Proof Rail in Goal Detail — goals show evidence of movement, not only task progress.
17. What Counted Today Review — summarize done, still counted, moved, blocked, changed, and inherited work.
18. No Capture Dead Ends — every capture has a clear state after entry.
19. Secondary Needs a Place Queue — unresolved capture management stays below top level.
20. Make Smaller Action — every large step can become a smaller startable step.
21. Protected Free Time Awareness — open time is not always available time.
22. Not Now But Still Important — moving a step should feel neutral.
23. Guided Automation Default — suggest and ask before meaningful changes.
24. Trust Center With Real Examples — show recent suggestions, accepted changes, automatic changes, undone changes, and input facts.
25. First 60 Seconds Value — new user should capture, create, plan, start, or save proof within one minute.

---

# B. Capture Upgrades

26. Contextual Capture Placeholders — rotate calm prompts like What needs a place and Capture now, decide later.
27. Capture Type Detection — infer likely type while preserving user override.
28. No Sorting Yet Mode — let users save without deciding now.
29. Capture Route Confidence Labels — use looks like, could become, might belong, needs your decision.
30. Capture-to-Step Conversion — turn actionable captures into steps.
31. Capture-to-Goal Conversion — identify broad captures that should grow into goals.
32. Capture-to-Proof Conversion — save already-done captures as proof.
33. Capture Cleanup Ritual — route a small group of unplaced captures weekly.
34. Capture Aging States — age unresolved captures softly without red badges.
35. Smart Attachment to Goals — suggest attaching related captures to existing goals.
36. Smart Attachment to People — optionally attach person-related captures to relationship context.
37. Capture from Today — quick capture without disrupting the Day Rail.
38. Capture from Step Session — capture note, blocker, proof, follow-up, or decision during execution.
39. Capture from Plan — add to day, week, or place later.
40. Capture Visual Signature — use restrained dark-sky/starfield only on Capture and First Run.
41. Capture Receipt — confirm saved, placed, added, attached, or saved as proof.
42. Capture Privacy Label — mark sensitive captures private by default where appropriate.
43. Capture Decide Later Queue — secondary drill-down for Needs a Place, Ready to Place, Older, Private, Related.
44. Capture Duplicate Detection — merge, keep, replace, or ignore similar captures.
45. Capture Blocker Detection — identify cannot-progress language and route to blocker or recovery.
46. Capture Energy Detection — user-approved lighter planning when exhaustion is captured.
47. Capture as Command Surface — later natural commands for move, add, make goal, save proof.
48. Capture Unresolved Count — use 3 things need a place, never overdue inbox.
49. Clear With Dignity — archive captures without implying loss or failure.
50. Capture Quality Prompt — help vague captures become actionable only when useful.

---

# C. Place Upgrades

51. Explicit Placement Destinations — Today, Plan, Goal, Grow into Goal, Proof, Later, Archive.
52. Placement Consequence Copy — explain what will appear where before confirming.
53. Placement Confidence Hierarchy — recommend one route while keeping alternatives visible.
54. Place Into Existing Goal — attach as step, proof, note, blocker, or decision.
55. Place Into Life Area — broad items can belong to life areas without becoming generic folders.
56. Place Into Time — Today, tomorrow, this week, someday, specific date, good window, planning time.
57. Place Into Energy Context — low energy, deep focus, admin, errand, social, creative.
58. Place Into Location Context — home, work, car, store, phone call, computer, outside.
59. Place Into Waiting — waiting on person, date, money, information, or decision.
60. Place Into Decision Needed — ambiguous items can require decision before becoming steps.
61. Placement Preview — show the object that will be created before confirming.
62. Placement Receipt — confirm placement with undo, open, and add-detail actions.
63. Bulk Placement — place all suggested, review one by one, archive low-confidence, keep private.
64. Placement Rules — user defaults for common capture types.
65. Placement Memory — learn placement preferences but ask before broad automation.
66. Placement Conflict Detection — warn when Today is already full.
67. Placement Priority Check — ask whether a new Today item beats Start Here.
68. Placement Privacy Check — keep sensitive items out of widgets and summaries.
69. Placement Undo — every placement toast should support undo where safe.
70. Placement Audit Trail — preserve original capture, suggested route, chosen route, override, and time.

---

# D. Plan Upgrades

71. Plan Is Not a Calendar Clone — Plan answers whether life can hold the work.
72. Day / Week / Month Scope Chip — Day is execution, Week is pressure, Month is life shape.
73. Day Capacity View — show fixed commitments, open windows, protected blocks, steps, risk, recovery space.
74. Week Pressure View — show heavy days, light days, deadlines, goal distribution, and recovery risk.
75. Month Life Shape — show milestones, pressure weeks, protected time, life areas, arcs, away time.
76. Believability Check — evaluate fit, recovery space, duration realism, stacking, and fixed commitments.
77. Plan Pressure Labels — Calm, Full, Tight, Overloaded, Needs Recovery.
78. Protected Time — support no planning, family, recovery, sleep, date night, creative, errands, admin.
79. Schedule & Availability Setup Value — explain why Ambitions needs schedule data.
80. Planning Defaults — step size, deep work length, admin length, planning time, off days, buffers, automation, notifications, energy.
81. Vacation / Away Time — default unavailable unless parts are explicitly available.
82. Plan Reflow — when reality changes, ask what to keep, move, close, or rebuild.
83. No Silent Meaningful Reflow — meaningful user-owned steps require visibility and approval.
84. Early Completion Reflow — user can pull next step forward, protect space, recover, or review later.
85. Plan Friction Detection — repeated moves suggest too large, blocked, wrong context, or wrong goal.
86. Plan Impossibility Detection — if the plan does not fit, keep top one, move rest, extend, or rebuild.
87. Plan Source Labels — calendar, user-set, suggested, goal-derived, capture-derived, recovered, recurring, protected.
88. Planning Receipt — accepted plans record included, moved, recovery space, and user changes.
89. Morning Plan Review — Today has real windows and a Start Here recommendation.
90. Evening Plan Review — close what happened and keep tomorrow clean.
91. Plan Conflict Types — time, energy, goal, priority, deadline, protected-time, vacation.
92. Hard vs Soft Items — separate fixed commitments from flexible intentions.
93. Commitments vs Intentions — committed, intended, suggested, optional, waiting.
94. One Thing Protected — each day can identify the protected key step.
95. Good Enough Day — one meaningful step, one closure, one proof item.
96. Weekly Cleanup — what still matters, what no longer matters, what is blocked, what needs a place, what deserves proof.
97. Goal-to-Plan Preview — show where a goal appears this week.
98. Capture-to-Plan Preview — show where a placed capture fits best.
99. Today-to-Plan Preview — from Today, see the rest of the day without weakening the rail.
100. Anti-Overcommitment Rule — no infinite suggested steps without a warning.

---

# E. Do Today Upgrades — Day Rail Protected

All Do Today upgrades are admitted only as additive refinements to the locked Ambitions Day Rail. They must strengthen the rail as the Today signature object and must not create a second competing Today system.

101. One Today Question — Today answers what matters now through the Day Rail.
102. Start Here Panel — preserved as the Day Rail hero recommended step card.
103. Adaptive Hero Size — rail hero stays compact unless explanation, recovery, or closure is needed.
104. Rail as Navigation Spine — Now / Next / Later rows remain tappable rail navigation.
105. Rail Row States — ready, in progress, later, blocked, waiting, needs closure, moved, done, still counts.
106. Non-Shaming Rail Language — no overdue, failed, missed, behind, or incomplete copy.
107. Context Bar — context belongs in the rail header or compact Today header.
108. Time Window Intelligence — rail can show open window fit without becoming a calendar.
109. Next Commitment Awareness — rail respects next event, commute, protected block, workday end, sleep boundary.
110. Start Friction Reducer — before starting, user can make smaller, move, block, close, or start.
111. Step Warm Start — Step Detail or Step Session shows the first two-minute entry action.
112. Starter Checklist — optional micro-checklist inside Step Detail or Step Session, not rail clutter.
113. Dependency Visibility — blocked/waiting facts appear in row detail or explanation.
114. Evidence Label — source facts appear as rail labels and Why This content.
115. Step Swap — user can swap Start Here with another rail row, with receipt.
116. Step Split — large steps can split from Step Detail or Adjust Plan.
117. Step Defer Reasons — capture no time, no energy, waiting, not important, unclear, wrong context.
118. Step Protect — user can protect one step and let other items move first.
119. Today Recovery Mode — rail shifts to protect-one-step recovery when overloaded.
120. Today Quiet Mode — rail can show one small step on low-energy days.
121. Today Success Minimum — one step can be enough today.
122. Today Receipts — started, completed, moved, still counts, blocked, recovered, changed.
123. Why Changed — any rail change can explain what changed and why.
124. Hide Optional — optional steps can collapse when overwhelmed.
125. End-of-Day Closure — rail wrap state closes loops and previews tomorrow inheritance.
126. No-Plan State — rail offers capture, pick goal, plan today, or add one step.
127. No-Schedule State — rail points to Schedule & Availability without blocking use.
128. No-Goal State — rail helps create first ambition or capture an idea.
129. Chaotic-Day State — rail says keep one thing moving when conflicts exist.
130. Restrained Celebration — saved as proof, closed, still counts, plan updated.

---

# F. Close / Recover Upgrades

131. Closure Required for Stale Steps — required as reality sync, not punishment.
132. Fast Closure — one sheet, one tap, optional note.
133. Reversible Closure — undo where safe.
134. Closure Note — optional what changed note for proof.
135. Completed State — finished as intended.
136. Still Counts State — imperfect progress becomes proof.
137. Moved State — still important, new time.
138. Skipped / Not Needed State — intentionally removed, not failed.
139. Blocked State — obstacle prevents progress.
140. Waiting State — dependent on someone or something.
141. Needs Recovery State — plan needs repair.
142. Needs Review State — user is unsure.
143. Closure Reason Taxonomy — no time, no energy, wrong context, blocked, waiting, no longer needed, too large, forgot, reprioritized, completed differently.
144. Closure Informs Planning — repeated too-large closures make future steps smaller.
145. Closure Informs Energy — repeated moved deep work changes future suggestions.
146. Closure Informs Trust — repeated rejected suggestions reduce automation assertiveness.
147. Recovery Receipt — records what stayed, moved, closed, and changed.
148. Recovery Modes — light recovery, rebuild today, rebuild tomorrow, protect one step, clear stale, review goal.
149. Overwhelm Recovery — pick one thing to keep and move the rest.
150. Missed Day Recovery — yesterday needs closure; nothing failed.
151. Long Absence Recovery — rebuild from what still matters.
152. Vacation Return Recovery — reopen plan after away time.
153. Deadline Pressure Recovery — prioritize, rescope, extend, or mark blocked.
154. Impossible Goal Recovery — reduce scope, split milestone, pause goal, or rebuild plan.
155. Repeated Skip Recovery — ask whether the step is still important.

---

# G. Save Proof Upgrades

156. Proof Separate From Completion — proof includes progress, decision, obstacle, improved plan, conversation, evidence, reduced risk, clarity.
157. Proof Rail — Goal Detail shows chronological evidence.
158. Proof Types — completion, progress, decision, evidence, learning, recovery, consistency, milestone, blocker resolved, commitment made.
159. Proof Source — step closure, capture, review, plan change, manual entry, calendar, automation.
160. Proof Privacy — normal, private, sensitive, hidden from summaries, excluded from widgets.
161. Proof Attachments — note, photo, file, link, calendar event, receipt, text snippet.
162. What Counted View — weekly proof view for counted, moved, clearer, blocked, changed.
163. Proof-to-Review — proof feeds daily review, weekly review, goal progress, life area progress, personal narrative.
164. No Primary Gamification — proof avoids cheap streak-first mechanics.
165. Identity-Supportive Proof — use kept showing up language, not streak pressure.
166. Proof Milestones — accumulated proof can suggest milestone completion.
167. Proof Search — search by goal, life area, date, closure type, source, privacy, keyword, proof type.
168. Privacy-Safe Proof Export — full, redacted, goal-only, proof-only, date range.
169. Proof Correction — rename, reassign goal, change privacy, add note, remove from summary.
170. Proof Deletion — explain history effects without undoing original step.
171. Proof as Motivation — subtly remind prior progress on similar work.
172. Proof as Trust — recommendations can cite recent proof and clear next step.
173. Proof as Recovery — show movement when the user feels behind.
174. Proof Summary Cards — premium summaries like this week counted, goal moved, plan recovered.
175. Proof as Product Moat — Ambitions preserves evidence of personal movement.

---

# H. Trust Upgrades

176. Trust Receipt Everywhere Meaningful — important changes leave receipts.
177. What Changed Link — every receipt answers what changed.
178. Why Changed Link — suggested and automatic changes explain basis.
179. Who Changed It Label — you, suggested accepted, automatic, calendar, capture.
180. Undo Window — show undo where available and explain when not.
181. Trust Levels — Manual, Guided, Adaptive.
182. Automation Boundary Labels — say what Ambitions can suggest, ask, adjust, never delete.
183. Trust Onboarding — Ambitions does not silently change meaningful plans.
184. Trust Control Center — automation, what Ambitions knows, receipts, privacy, export, memories, planning defaults.
185. Trust History — accepted, rejected, automatic, undone, and data-used records.
186. Trust Preview — before Adaptive, show what can change automatically.
187. Trust Downgrade — if suggestions are often rejected, offer to ask more.
188. Trust Escalation — if suggestions are often accepted, offer low-risk automation.
189. No Dark Patterns — never guilt for notifications, setup, subscription, reviews, or automation.
190. Trust Plain Language — suggested, based on, fits, you approved, changed because.

---

# I. AI / Personalization Upgrades

191. Recommendation Ledger — candidates, chosen step, reasons, exclusions, response, outcome, correction.
192. Not That Feedback — user can reject with reason.
193. Recommendation Humility — suggested and likely fits, never optimal or AI recommends.
194. Personal Planning Style — tiny steps, focused blocks, flexible plans, reminders, planning time.
195. Energy Pattern Learning — learn best deep-work/admin windows and high-friction days.
196. Step-Size Learning — suggest smaller if smaller steps succeed more often.
197. Goal Momentum Learning — recent proof, clear next step, deadline, pinned importance, low friction, consequence.
198. Recovery Prediction — flag tight days before they break.
199. Explanation Quality Scoring — explanations must be specific, grounded, non-creepy, actionable, short.
200. No Black-Box Motivation — avoid creepy diagnoses; frame suggestions around fit and timing.

---

# J. Visual / Interaction Upgrades

201. One Premium Surface Per Tab — Today rail, Goals mission/proof, Capture composer/sky, Plan life shape, You system center.
202. Reduce Top-Level Cards — top screens show only what earns attention.
203. Drill-Down Richness — depth belongs below top-level calm.
204. Receipt Toast Design — small, premium, non-intrusive confirmations.
205. Motion Restraint — motion only clarifies rail changes, receipts, closure, and reflow preview.
206. Rail Micro-Motion — node completion and proof appearance stay subtle.
207. Reflow Preview Animation — before/after for stays, moves, closes.
208. Capture Starfield Restraint — emotional signature, not decoration.
209. Premium Dark Mode — charcoal, warm graphite, soft depth, subtle materials.
210. Serious Light Mode — warm off-white, soft shadows, graphite text, calm panels.
211. Useful Empty States — empty states suggest one calm next action.
212. Native Loading States — skeletons only where needed.
213. Trust-Preserving Error States — clearly say when nothing changed.
214. Offline States — saved locally language supports local-first trust.
215. Premium Haptics — subtle haptics for saved, started, closed, proof, accepted.

---

# K. Content / Language Upgrades

216. Replace Generic Task Language — prefer step, plan item, proof, capture, closure, review, goal path.
217. Human But Not Cute Copy — direct, calm, not childish or hustle-coded.
218. Recovery Copy Bank — nothing failed, keep what matters, close what happened.
219. Trust Copy Bank — you approved this, based on today window, ask before changing.
220. Proof Copy Bank — saved as proof, still counts, progress recorded.
221. Capture Copy Bank — what needs a place, decide later, could become a step.
222. Plan Copy Bank — this fits today, this day is tight, protect one step.
223. CTA Grammar — Start now, Open step, Place it, Add to plan, Save as proof, Close loop, Adjust plan, Why this, Make smaller, Move later.

---

# L. Product Moat Upgrades

224. Proof Moat — track what counted, not only completion.
225. Recovery Moat — make drift recoverable instead of punished.
226. Trust Moat — show why, what changed, and who approved.
227. Life-Shape Moat — show pressure and goal shape, not just calendar boxes.
228. Closure Moat — understand reality beyond done/not done.
229. Capture Moat — route thoughts into life structure.
230. Guided Automation Moat — automation feels negotiated, not controlling.

---

## Roadmap Packaging

### P0 — Must perfect before adding more

1. Canonical Today rail.
2. Hero Step Panel.
3. Step Detail.
4. Step Session.
5. Action Closure sheet.
6. Receipt toast.
7. Capture placement flow.
8. Plan source labels.
9. Proof creation.
10. You trust controls.

### P1 — Make it feel flagship

1. Proof Rail in Goal Detail.
2. Today recovery mode inside the Day Rail.
3. Plan reflow preview.
4. Schedule & Availability setup.
5. Planning Defaults setup.
6. Vacation / Away flow.
7. Receipt search.
8. What counted today.
9. Make smaller action.
10. Trust explanation sheets.

### P2 — Make it differentiated

1. Month Life Shape.
2. Recommendation ledger.
3. Personal planning style.
4. Energy-aware suggestions.
5. Closure intelligence.
6. Proof-based reviews.
7. Goal momentum view.
8. Overcommitment detection.
9. Recovery from absence.
10. Exportable proof history.

### P3 — Later, after the loop is excellent

1. Cloud sync.
2. Shared goals.
3. Calendar integrations.
4. AI assistant commands.
5. Advanced analytics.
6. Widgets.
7. Live Activities.
8. Shortcuts.
9. Subscription packaging.
10. Public launch campaign.

---

## Final Product Rule

Every meaningful object in Ambitions should be able to answer:

```text
1. Where did this come from?
2. Where does it belong?
3. What is the next believable step?
4. When should it surface?
5. Why is it recommended?
6. What happened to it?
7. Did it still count?
8. What changed because of it?
9. Can the user undo or correct it?
10. Where is the proof?
```

If a surface cannot answer these questions, it is not yet integrated into the Golden Launch Loop.
