# Ambitions Implementation Acceptance Gates

Status: Active canon consolidation layer.

Purpose: Define what “done” means for future Ambitions implementation work. This document consolidates acceptance expectations from the roadmap, batch plan, visual review checklist, RC maturity plan, design contracts, accessibility posture, systems architecture, product decision Waves 1-19, the Golden Launch Loop, and the Human Language Review.

## Core Standard

A feature is not done because code compiles.

A feature is done when it is:

- aligned with active canon
- mapped to the Golden Launch Loop when launch-bound
- written in human, obvious language where user-facing
- integrated with the correct owning system
- visually coherent
- understandable in the first few seconds
- accessible enough for the claimed state
- resilient to empty/error/recovery cases
- honest about shipped versus planned behavior
- covered by practical validation evidence
- updated in docs/status where required

## Required Pre-Implementation Gate

Before implementing a non-trivial Ambitions change, the implementer must identify:

1. Active batch or roadmap owner.
2. Current shipping behavior.
3. Active canon documents read.
4. Whether `GOLDEN_LAUNCH_LOOP.md` applies to launch-critical scope.
5. Whether `HUMAN_LANGUAGE_REVIEW.md` applies to visible copy.
6. Surface owner.
7. System owner.
8. Whether the work is UI, domain model, system logic, QA, release, or docs-only.
9. What must not be touched.
10. Planned-canon versus shipped-code distinction.
11. Whether any unresolved question needs a canon proposal or decision-log entry.

Required reading order:

1. `docs/codex/BATCH_REGISTRY.md`
2. `docs/canon/SOURCE_OF_TRUTH_MAP.md`
3. `docs/canon/PRODUCT_DECISIONS.md`
4. `docs/canon/GOLDEN_LAUNCH_LOOP.md` for launch scope and product-strength cutline
5. `docs/canon/HUMAN_LANGUAGE_REVIEW.md` for user-facing language work
6. `docs/canon/AMBITION_CANON_COMPLETION_REPORT.md`
7. batch file if one exists
8. relevant product/design/system/focused canon docs from the source map
9. current implementation files
10. tests/previews/fixtures affected by the change

## Canon Alignment Gate

A change passes canon alignment when:

- It does not contradict `MASTER_PRODUCT_SPEC.md`.
- It follows `PRODUCT_DECISIONS.md` for Waves 1-19.
- It follows `GOLDEN_LAUNCH_LOOP.md` for launch-critical scope and roadmap/batch cutline.
- It follows `HUMAN_LANGUAGE_REVIEW.md` for normal user-facing copy.
- It follows `Ambitions_Design_Constitution.md` for design, IA, UX writing, interaction, trust, accessibility, and external-surface behavior.
- It follows Product Architecture for surface ownership.
- It follows Systems Architecture for engine ownership.
- It follows focused canon docs for implementation detail.
- It does not recreate a standalone Insights tab, Habits tab, Tasks tab, Calendar tab, Life Areas tab, or Profile tab.
- It preserves the locked shell: Today, Goals, Capture, Plan, You.
- It distinguishes Profile compatibility code from user-facing `You` canon.
- It distinguishes Task from Step.
- It distinguishes shipped, planned, deferred, and decision-gated behavior.
- It does not treat archived docs as active canon.
- It does not introduce new canon unless explicitly labeled as a canon proposal.

## Golden Launch Loop Gate

A launch-bound change passes when it strengthens at least one step in the Golden Launch Loop:

```text
1. Capture one meaningful goal or task.
2. Put it in the right place.
3. Turn it into a doable plan.
4. Show what to do today.
5. When today is too much, make it doable.
6. Save proof that progress happened.
```

Required mapping for launch-bound roadmap or batch work:

```markdown
## Golden Launch Loop Mapping
- Capture:
- Place/routing:
- Plan/doable path:
- Today/next action:
- Recovery:
- Proof/receipt:
- Trust/privacy:
- Launch status: launch-critical / post-launch / deferred / decision-gated
```

Rules:

- If every mapping line is empty, the work is not launch-critical.
- Launch-critical work must make one meaningful goal easier to organize, make doable, act on today, recover, or prove.
- Post-launch, deferred, and decision-gated work may stay in roadmap docs, but must not be treated as required for launch.
- The recommended demo story is `Release 3 songs by August 1`, unless a later explicit decision picks a different example.

## System Ownership Gate

A change passes system ownership when it uses the owning shared system instead of creating duplicate logic.

Examples:

- Now State logic uses Canonical Now State.
- Calendar and capacity logic use the Reality / Plan layer.
- Believability uses Believability Kernel / Goal Believability models.
- Recovery uses Execution Resilience / Reality Reflow concepts.
- Receipts use Action Closure.
- Proof uses Proof Rail / proof relationship model.
- Memory uses Memory / Event Ledger / Trust Layer.
- Commands use Command Pipeline.
- Capture routing uses Capture 2.0 / Smart Attachment.

Failure examples:

- A screen computes its own separate goal health.
- A widget has its own next-action logic.
- Plan silently writes calendar blocks.
- Capture creates a separate long-term inbox model.
- A toast replaces receipt behavior for meaningful actions.

## Surface Ownership Gate

A change passes surface ownership when content lives in the right place.

| Surface | Owns | Does not own |
| --- | --- | --- |
| Onboarding | first useful object, static preview, first-run route receipt, safe skip-to-Today | upfront calendar, notifications, account setup, display-density setup, full questionnaire |
| Today | next action, right-now explanation, immediate execution, full daily schedule below main action, recovery | task dump, calendar clone, analytics dashboard, motivation wall, AI/producty copy |
| Goals | direction, most important goal, goal detail, Goal Weather, Proof | standalone task manager, project-management-board top level, KPI dashboard |
| Capture | Quiet Command Sheet, intake, Needs a Place, Smart Attachment, route receipts | long-term graveyard inbox, chat-first AI, generic notes app |
| Plan | doable day/week shaping, daily schedule, rituals, calendar-aware planning | onboarding permissions, raw calendar clone, silent rescheduling |
| You | settings, trust, memory, reviews, personalization, data controls | generic settings page, junk drawer, social profile, primary execution UI, data-console language |
| Trust Center | trust, receipts, privacy, memory controls, sync/export truth, platform status | numerical trust score at launch, marketing claims, paywalled privacy |
| What Ambitions Knows | user-visible Memory inspection, correction, confirmation, pause/delete controls | hidden profiling or unreviewable memory |

## Launch Scope Gate

A launch-bound change passes when it supports the launch proof:

```text
A meaningful goal can become organized, doable, and actionable today.
```

Rules:

- It must map to the Golden Launch Loop when launch-critical.
- Prefer fewer complete loops over more partial features.
- Do not ship fake AI, broken sync claims, unclear data controls, dead-end flows, or AI-feeling copy.
- Advanced canon may remain planned/deferred when labeled accurately.
- Delay sync, advanced memory, widgets / Live Activities, native AI-style suggestions, advanced reviews, and long-range path intelligence if not excellent.
- MVP must not mean ugly, untrustworthy, incomplete, confusing, or robotic.

## Roadmap Governance Gate

A roadmap or batch change passes when:

- It optimizes for coherent product loops.
- It respects dependency order.
- It maps launch-critical work to the Golden Launch Loop.
- It distinguishes shipped, planned, deferred, duplicate, superseded, decision-gated, and needs-canon-proposal work.
- It does not add tabs casually.
- It does not rename canon casually.
- It does not implement fake capability.
- It does not skip validation/status updates.
- Canon conflicts pause implementation until resolved.
- Unresolved questions become canon proposals or decision-log entries.

## Onboarding Gate

An onboarding or first-run change passes when:

- It uses a static premium preview at launch; animation is optional later, not required.
- The first prompt is `What do you want to organize?`.
- First-run success is any useful object created.
- First object creation shows the receipt inside the destination.
- The route receipt includes object type, destination, next useful action, and correction route.
- Life Area is inferred when possible and asked only when uncertain.
- Life Area remains correctable from the receipt.
- Display density is not asked during onboarding.
- Default display setting is `Balanced + Comfortable`.
- Calendar permission is not requested during onboarding.
- Notification permission is not requested during onboarding.
- Calendar permission is only requested from Plan after a calendar-aware planning action.
- Notification permission is only requested after reminder value.
- Default examples cover Career, Creative, Finance, Health, Home, and Relationships / Family.
- Baby/family examples appear only when contextually relevant.
- Skipping onboarding lands in Today with a strong empty state and Capture action.
- The static preview has an equivalent VoiceOver description.

## Capture Gate

A Capture change passes when:

- Capture feels like a Quiet Command Sheet.
- Primary placeholder is `What needs a place?`.
- Nothing gets lost.
- Every capture gets a clear next route.
- Low-confidence capture asks one question or saves to Needs a Place.
- Capture routes use launch/core routes unless an advanced route is explicitly scoped.
- No general Notes object is introduced at launch.
- Task-to-goal promotion is user-confirmed.
- Route receipts use `Saved as...` / `Attached as...` patterns.
- Normal UI uses plain copy such as `Suggested place` or `Move it here?`, not AI/classification/confidence language.

## Today / Now State Gate

A Today change passes when:

- It helps the user know what matters now.
- It prioritizes one next action first.
- Normal UI says `Do this next` or equivalent plain copy.
- It shows the full daily schedule below the main action when shown.
- It uses Now State as an internal concept, but user-facing copy says `Right now` / `Why this now`.
- Broken-day behavior offers recovery and asks what should stay on today.
- Recovery uses plain copy such as `Too much for today` and `Make today doable`.
- Main recovery concept is `Save the Day`, but supporting copy stays human and obvious.
- Rituals/routines appear only if relevant now.
- Sensitive/private items collapse as `Private item` at launch.
- Today does not become a task dump, calendar clone, analytics dashboard, motivation wall, or AI-feeling command center.

## Goals Gate

A Goals change passes when:

- It helps the user choose direction.
- Top-level Goals prioritizes the most important goal and goal status/health.
- Goal Detail leads with `What is next?` or `What is the next visible step?`.
- Goal Detail also answers `Is this goal still doable?` / `Is this goal still believable?`.
- Goal Weather communicates how the goal is going without fake progress.
- Progress percentages appear only when measurable and honest.
- Proof can include completed steps, artifacts, decisions, feedback, blockers resolved, and reviews.
- Manual proof attaches to a goal, milestone, or step.
- Missing next step asks/suggests rather than merely warning.
- Normal UI says `Most important goal`, not `protected goal`.
- Top-level Goals does not become a project management board, spreadsheet, KPI dashboard, or quote wall.

## Plan Gate

A Plan change passes when:

- It shapes a doable day/week.
- It can build the daily schedule as part of making goals executable.
- It remains plan-first with optional calendar awareness.
- It answers `Can this week actually hold?`.
- It supports `What daily schedule makes this hold?`.
- Calendar-aware behavior reads events, suggests open windows, and compares against commitments.
- Calendar writes require explicit confirmation every time.
- First calendar CTA may internally be calendar-aware, but normal UI should prefer plain copy such as `Find open time from Calendar`.
- Overload behavior suggests a lighter plan and asks what should stay.
- Rituals/routines do not become a standalone Habits tab.
- Visible state labels prefer `Looks doable`, `Tight`, `Too much planned`, and `No longer works`.
- Plan does not shame, silently reschedule, pretend impossible weeks are fine, or become a raw calendar clone.

## You / Reviews Gate

A You change passes when:

- User-facing language uses `You`, not `Profile`, except legacy compatibility references.
- You functions as the user's settings, trust, memory, reviews, and personalization area.
- Top status is `You are in control`.
- Settings-style areas use Grouped Navigation Lists.
- Reviews turn what happened into what should happen next.
- Analytics appear only as Reviews/Patterns, not dashboard analytics.
- Export/import appears only when implemented and through Trust Center / Data controls.
- Appearance Studio belongs in You.
- Normal UI avoids data-console language such as `user model`, `memory graph`, `system center`, or `identity substrate`.
- You does not become a junk drawer, analytics dashboard, generic settings page, or social profile.

## Intelligence / Automation Gate

An intelligence or automation change passes when:

- It primarily explains, suggests, and prepares.
- Normal UI avoids AI/model language.
- Suggestions feel like calm options.
- Meaningful suggestions include why this, evidence/assumption, user control, and dismiss/change option.
- Confidence is qualitative only outside normal UI; normal UI should not say confidence/model.
- Important plan/goal changes require user confirmation.
- Safe local reversible actions can use receipt + undo.
- External actions require confirmation.
- Intelligence never hides uncertainty, pretends certainty, shames the user, or makes external changes silently.

## Visual Quality Gate

A UI change passes visual quality when:

- It feels like a premium calm OS.
- It uses the calm shell / rich panel / meaningful state model.
- It uses shared tokens/components where available.
- It has one dominant first-screen decision or purpose.
- It avoids equal-weight card walls.
- It avoids dense dashboards.
- It avoids paragraph-heavy top-level UI.
- It avoids too many exposed controls.
- Rich panels communicate meaningful state, hierarchy, and context.
- Motion is subtle and meaningful.
- Motion communicates where things went, what changed, or state transitions.
- Reduce Motion preserves equivalent clarity.
- Celebration is rare and reserved for meaningful completions.
- It works in dark and light mode if the surface is user-visible.
- It avoids hard-coded one-off colors when tokens exist.
- It preserves Appearance Studio compatibility.
- It avoids visual effects that reduce readability or performance.

## UX Writing Gate

A copy/UI-language change passes when:

- It is calm, adult, specific, clear, non-shaming, and human.
- It follows `HUMAN_LANGUAGE_REVIEW.md`.
- It prefers plain phrases such as `Do this next`, `Most important today`, `Too much for today`, `Make today doable`, `Move this later`, `Keep this on today`, `Looks doable`, and `No longer works` where they fit.
- It uses approved explanation labels such as `Why This`, `Why Now`, `Why Changed`, `What This Uses`, `Needs Confirmation`, and `Update This`.
- It uses Wave 2 state language only where still appropriate and translates internal labels into human UI copy when needed.
- It uses Wave 3 trust language: `You are in control` for Trust Center top status, `What Ambitions Knows` for the memory section, and `Memory` for the object/type.
- It uses Wave 4 onboarding language: `What do you want to organize?`, `Organize This`, and contextual first-run route receipts.
- It uses `Focus Support`, not ADHD Mode or Neurodivergent Mode.
- It avoids numerical Trust Score language at launch.
- It avoids AI/model/confidence terminology in normal UI.
- It avoids `protected/protection/protect`, `anchor`, `execution context`, `optimize`, `leverage`, `engine`, `graph`, and other product/system language in normal UI unless literally about privacy/security.
- It avoids shame language.
- It avoids exposing `Dropped`, `Fragile`, or `Broken` as normal user-facing copy unless the context explicitly requires internal/debug language.
- Buttons are verb-led and specific.
- Empty/error/recovery states say what happened, what remains safe, and what action follows.
- User-facing claims are backed by implementation evidence.

## Trust And Privacy Gate

A trust-sensitive change passes when:

- Meaningful actions create receipts.
- Ordinary reversible local changes prefer receipt + undo.
- Undo duration is action-appropriate and truthfully represented.
- Destructive actions, external writes, and major deadline changes require confirmation.
- Calendar write requires confirmation.
- Memory deletion and delete-all-memory require confirmation.
- Delete-all-memory affects memory only.
- Delete-all-memory offers export/reminder first where export exists, or truthfully states export is unavailable.
- Low-risk memories are visible and correctable.
- Sensitive/high-impact memories require confirmation before use.
- Health, relationship/family, financial, location, calendar-derived, and sensitive Life Area memories require confirmation.
- Display/density preferences, recovery preferences, and repeated task routing may auto-create with receipt/visibility.
- Users can pause memory learning globally and by category where implemented.
- User can mark any Life Area sensitive.
- Sensitive Life Area details hide in notifications/widgets and collapse on Today at launch.
- Sensitive Life Areas use generic labels such as `Private item` in compact surfaces.
- Explanation distinguishes evidence from assumption.
- Goal Weather correction happens through inputs, not direct manual override.
- Permission prompts occur only after relevant user action.
- Trust/privacy/data controls are not paywalled.
- Sync/export/accessibility/platform claims are truthful.
- Advanced sensitive privacy claims such as Face ID, export exclusion, local-only enforcement, or screenshot hiding are not made until implemented and verified.
- Failure states explain what remains safe.

## Data / Local-First Gate

A data/model change passes when:

- Default data posture remains local-first.
- Launch does not require an account.
- Launch does not claim sync.
- Export exists before cloud sync if cloud sync is introduced.
- Export uses user-selectable categories when implemented.
- Export does not feel hostage.
- Data controls live under You -> Trust Center / Data controls.
- UI does not show sync/export claims before implementation.
- Export failure explains data remains safe, offers retry, and offers review export option.
- User can understand what is stored, remembered, exported, and deleted.
- It is additive or migration-safe where possible.
- It preserves existing local data.
- It handles legacy decode/default values.
- It avoids fake successful writes.
- It emits Event Ledger / receipt history only for actual executed changes.
- It distinguishes representation-only future commands from real executed mutations.
- It does not introduce duplicate stores for shared objects.
- It preserves internal separation between `cancelled` and `dropped` where the domain model requires it, even if launch UI simplifies wording.
- It preserves memory learning pause without deleting existing memory.
- It preserves first-run user input on save failure.

## External Surfaces Gate

An external surface change passes when:

- It surfaces the right next thing safely.
- External-surface north star is calm continuity.
- Notifications are sparse by default and calm/operational.
- Sensitive/private details collapse as `Private item` at launch.
- Widgets show next action / Today slice, not dashboards.
- Live Activities show active focus time or time-sensitive plan slice.
- App Intents / Shortcuts support capture without losing input.
- Safe local actions create receipts where meaningful.
- External writes require app confirmation.
- External copy stays especially plain because it appears out of context.
- External surfaces do not expose private details, spam the user, show fake urgency, or replace core app context.

## Accessibility Gate

A user-visible change passes the baseline accessibility gate when:

- Accessibility is treated as core product quality.
- Focus Support reduces decisions and keeps the next action clear.
- Dynamic Type does not hide the primary action.
- VoiceOver labels summarize purpose, state, and action.
- Interactive rows/buttons have stable tap targets.
- Color is not the only meaning carrier.
- Reduce Motion preserves equivalent state clarity.
- Required gestures have visible alternatives.
- Destructive actions require confirmation.
- Screen readers can understand status/value rows.
- Static previews have equivalent VoiceOver descriptions.
- No user-facing accessibility claims appear before verification evidence exists.
- Focus Support does not infantilize, remove depth, label the user, or turn the app into training wheels.

## Monetization Gate

A monetization change passes when:

- Business model feels like a premium life OS.
- No ads are introduced.
- Free tier is useful but limited and proves one meaningful goal can become organized.
- Paid value comes from deep planning, reviews, memory, personalization, and advanced external surfaces.
- Export does not feel hostage.
- Trust/privacy/data controls are not paywalled.
- Monetization avoids shame, artificial friction, manipulative urgency, and data lock-in.
- Pricing posture remains premium but accessible.

## Empty / Error / Recovery Gate

A screen or flow passes this gate when it handles:

- empty state
- loading state
- success state
- save failure
- unavailable permission
- denied permission
- stale data
- unsupported future action
- recovery / drift
- destructive confirmation where needed
- external-write confirmation where needed
- major-deadline-change confirmation where needed
- sensitive/high-impact memory confirmation where needed
- delete-all-memory confirmation
- memory learning paused states where implemented
- sensitive Life Area collapsed/private-item states where relevant
- onboarding skip state
- first-run save failure with preserved input
- receipt + undo for reversible local changes where safe

The state must offer one useful next action and no dead end.

## Test / Validation Gate

A change should include the highest practical validation for its scope.

Recommended evidence:

- unit tests for deterministic logic
- view model tests for state mapping
- UI tests for shell/navigation-critical behavior
- preview scenarios for major visual states
- onboarding skip and first-object scenarios for onboarding work
- manual visual review checklist for UI batches
- accessibility checklist for visible components
- build/test command output in completion summary

If full validation is impossible, the completion summary must say exactly what was not run and why.

## Performance Gate

A rich UI or system change passes when:

- It avoids recomputing large graph/ledger/proof queries on every render.
- It uses lightweight snapshots for widgets/external surfaces.
- It keeps scroll-heavy screens smooth.
- It degrades gracefully under Reduce Motion or lower performance conditions.
- It avoids expensive blur stacking.
- It bounds Semantic Zoom / graph rendering and provides list fallback.

## Documentation Gate

A change passes documentation gate when:

- The relevant source-of-truth doc is updated only if doctrine changed.
- `PRODUCT_DECISIONS.md` is updated when a product ambiguity is resolved.
- New canon is introduced only as a canon proposal unless explicitly approved.
- Batch registry/status is updated only when status changed.
- New docs are added to the right index.
- Superseded docs are marked historical rather than silently contradicted.
- Completion summary names changed files, validation, and remaining gaps.

## Batch Completion Gate

A batch is complete only when:

1. Scope matches the batch file.
2. No unrelated roadmap drift was introduced.
3. Required source-of-truth docs remain aligned.
4. Launch-bound work maps to the Golden Launch Loop or is marked post-launch/deferred/decision-gated.
5. User-facing copy follows `HUMAN_LANGUAGE_REVIEW.md`.
6. Tests or validation appropriate to the change were run or explicitly not run.
7. Visual/UX/accessibility acceptance is satisfied for user-visible work.
8. Empty/error/recovery states are not broken.
9. Confirmation/receipt behavior matches trust gates.
10. Memory/sensitive-area behavior matches Wave 3 gates where relevant.
11. Onboarding behavior matches Wave 4 gates where relevant.
12. Completion summary distinguishes implemented behavior from planned future canon.
13. `BATCH_REGISTRY.md` is updated if the batch status changed.
14. Shipped/planned/deferred/decision-gated status is clear.
15. Follow-up work is captured without moving the active batch prematurely.

## Red Flags

Stop or revise if a change:

- creates a new top-level tab without canon approval
- reintroduces Insights, Habits, Tasks, Calendar, Life Areas, or Profile as standalone top-level surfaces
- treats a non-Golden-Launch-Loop feature as launch-critical without justification
- requests calendar permission during onboarding
- requests notification permission during onboarding
- asks for display density during onboarding
- uses onboarding completion as the first-run success metric instead of useful-object creation
- requires account creation at launch
- claims launch sync
- makes export feel hostage
- paywalls trust/privacy/data controls
- silently changes calendar/user data
- silently changes major deadlines
- deletes memory without confirmation
- deletes all memory without confirming scope and preserving goals/tasks/plans unless explicitly requested
- creates sensitive/high-impact memory without confirmation
- creates calendar-derived memory without confirmation
- exposes sensitive Life Area details in notifications/widgets or Today compact summaries
- claims Face ID, export exclusion, local-only enforcement, or screenshot hiding without verified implementation
- creates duplicate now/plan/recovery/goal-health logic
- uses AI/model/confidence terminology in normal UI
- uses protected/protection/protect, anchor, execution context, optimize, leverage, engine, graph, or system-center language in normal UI unless literally about privacy/security
- uses `Dropped`, `Fragile`, or `Broken` as normal user-facing copy when softer labels apply
- uses a numerical Trust Score at launch
- claims sync, memory, automation, export, accessibility, privacy, or platform behavior that is not verified
- breaks local-first behavior
- removes correction/undo paths from meaningful actions
- turns top-level screens into dense dashboards
- changes roadmap status without evidence
- implements unresolved questions instead of creating canon proposals

## Completion Summary Template

Use this structure for Codex completion summaries:

```markdown
## Summary
- ...

## Files Changed
- ...

## Canon Alignment
- Active docs read:
- Surface owner:
- System owner:
- Golden Launch Loop mapping:
- Human language review:
- Planned-vs-shipped distinction:
- Shipped/planned/deferred/decision-gated status:

## Validation
- Commands run:
- Manual review:
- Not run / limitations:

## Acceptance Gates
- Canon alignment:
- Golden Launch Loop:
- System ownership:
- Surface ownership:
- Visual/UX:
- Human language:
- Accessibility:
- Empty/error/recovery:
- Trust/privacy:
- Data/local-first:
- External surfaces:
- Confirmation/receipt behavior:
- Memory/sensitive-area behavior:
- Onboarding behavior:
- Launch scope:
- Roadmap governance:

## Remaining Gaps
- ...

## Canon Proposals Needed
- ...
```

## Open Questions

- Should every future batch include a formal gate checklist in its batch doc?
- Should canon proposals live in their own folder or inside decision docs?
- What exact validation commands should be required by batch type?
- Should visual UI batches require screenshot artifacts before completion?
- Should completion summaries require before/after implementation-state wording?
