# Ambitions Implementation Acceptance Gates

Status: Active canon consolidation layer.

Purpose: Define what “done” means for future Ambitions implementation work. This document consolidates acceptance expectations from the roadmap, batch plan, visual review checklist, RC maturity plan, design contracts, accessibility posture, systems architecture, and product decision Waves 1-3.

## Core Standard

A feature is not done because code compiles.

A feature is done when it is:

- aligned with active canon
- integrated with the correct owning system
- visually coherent
- understandable in the first few seconds
- accessible enough for the claimed state
- resilient to empty/error/recovery cases
- honest about shipped versus planned behavior
- covered by practical validation evidence

## Required Pre-Implementation Gate

Before implementing a non-trivial Ambitions change, the implementer must identify:

1. Active batch or roadmap owner.
2. Current shipping behavior.
3. Active canon documents read.
4. Surface owner.
5. System owner.
6. Whether the work is UI, domain model, system logic, QA, release, or docs-only.
7. What must not be touched.
8. Planned-canon versus shipped-code distinction.

Required reading order:

1. `docs/codex/BATCH_REGISTRY.md`
2. `docs/canon/SOURCE_OF_TRUTH_MAP.md`
3. `docs/canon/PRODUCT_DECISIONS.md`
4. batch file if one exists
5. relevant product/design/system docs from the source map
6. current implementation files
7. tests/previews/fixtures affected by the change

## Canon Alignment Gate

A change passes canon alignment when:

- It does not contradict `MASTER_PRODUCT_SPEC.md`.
- It follows `Ambitions_Design_Constitution.md` for design, IA, UX writing, interaction, trust, accessibility, and external-surface behavior.
- It follows Product Architecture for surface ownership.
- It follows Systems Architecture for engine ownership.
- It follows `PRODUCT_DECISIONS.md` for resolved product wording/state decisions.
- It does not recreate a standalone Insights tab, Habits tab, Tasks tab, or sixth Life Areas tab.
- It preserves the locked shell: Today, Goals, Capture, Plan, You.
- It distinguishes Profile compatibility code from user-facing `You` canon.
- It distinguishes Task from Step.
- It does not treat archived docs as active canon.

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
| Today | immediate execution, best next action, daily recovery | full analytics, dense histories, raw ledgers |
| Goals | direction, goal portfolio, health, lifecycle, goal detail entry | standalone task manager, dense KPI dashboard |
| Capture | intake, Needs a Place, Smart Attachment, route receipts | long-term graveyard inbox, chat-first AI |
| Plan | day/week shaping, believability, rituals, calendar-aware planning | onboarding permissions, raw calendar clone |
| You | personalization, memory, reviews, trust, settings | primary execution UI |
| Trust Center | trust, receipts, privacy, memory controls, sync/export truth, platform status | numerical trust score at launch, marketing claims |
| What Ambitions Knows | user-visible Memory inspection, correction, confirmation, pause/delete controls | hidden profiling or unreviewable memory |

## Visual Quality Gate

A UI change passes visual quality when:

- It uses the calm shell / rich panel / meaningful state model.
- It uses shared tokens/components where available.
- It has one dominant first-screen decision or purpose.
- It avoids equal-weight card walls.
- It avoids paragraph-heavy top-level UI.
- It respects spacing, radius, typography, and surface hierarchy.
- It works in dark and light mode if the surface is user-visible.
- It avoids hard-coded one-off colors when tokens exist.
- It preserves Appearance Studio compatibility.
- It avoids visual effects that reduce readability or performance.

## UX Writing Gate

A copy/UI-language change passes when:

- It is calm, adult, specific, clear, and non-shaming.
- It uses approved labels such as `Why This`, `Why Now`, `Why Changed`, `What This Uses`, `Needs Confirmation`, and `Update This`.
- It uses Wave 2 state language: `No Longer Relevant` for dropped goals, `End Goal` for intentional ending, `Park Goal` for pause, `Needs Protection` for fragile plan state, and `No Longer Holds` for broken plan state.
- It uses Wave 3 trust language: `You are in control` for Trust Center top status, `What Ambitions Knows` for the memory section, and `Memory` for the object/type.
- It avoids numerical Trust Score language at launch.
- It avoids AI/model terminology in normal UI.
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
- Delete-all-memory offers export/reminder first where export exists, or truthfully states export is unavailable.
- Low-risk memories are visible and correctable.
- Sensitive/high-impact memories require confirmation before use.
- Health, relationship/family, financial, location, calendar-derived, and sensitive Life Area memories require confirmation.
- Display/density preferences, recovery preferences, and repeated task routing may auto-create with receipt/visibility.
- Work/career memory is treated contextually.
- Users can pause memory learning globally and by category where implemented.
- User can mark any Life Area sensitive.
- Sensitive Life Area details hide in notifications/widgets and collapse on Today at launch.
- Sensitive Life Areas use generic labels such as `Private item` in compact surfaces.
- Explanation distinguishes evidence from assumption.
- Goal Weather correction happens through inputs, not direct manual override.
- Sensitive details hide by default in external surfaces.
- Permission prompts occur only after relevant user action.
- Sync/export/accessibility/platform claims are truthful.
- Advanced sensitive privacy claims such as Face ID, export exclusion, local-only enforcement, or screenshot hiding are not made until implemented and verified.
- Failure states explain what remains safe.

## Accessibility Gate

A user-visible change passes the baseline accessibility gate when:

- Dynamic Type does not hide the primary action.
- VoiceOver labels summarize purpose, state, and action.
- Interactive rows/buttons have stable tap targets.
- Color is not the only meaning carrier.
- Reduce Motion preserves equivalent state clarity.
- Required gestures have visible alternatives.
- Destructive actions require confirmation.
- Screen readers can understand status/value rows.
- No user-facing accessibility claims appear before verification evidence exists.

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
- receipt + undo for reversible local changes where safe

The state must offer one useful next action and no dead end.

## Data And Persistence Gate

A data/model change passes when:

- It is additive or migration-safe where possible.
- It preserves existing local data.
- It handles legacy decode/default values.
- It avoids fake successful writes.
- It emits Event Ledger / receipt history only for actual executed changes.
- It distinguishes representation-only future commands from real executed mutations.
- It does not introduce duplicate stores for shared objects.
- It preserves internal separation between `cancelled` and `dropped` where the domain model requires it, even if launch UI simplifies wording.
- It does not allow delete-all-memory to delete goals/tasks/plans unless explicitly included in a separate destructive action.
- It preserves memory learning pause without deleting existing memory.

## Test / Validation Gate

A change should include the highest practical validation for its scope.

Recommended evidence:

- unit tests for deterministic logic
- view model tests for state mapping
- UI tests for shell/navigation-critical behavior
- preview scenarios for major visual states
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
- Batch registry/status is updated only when status changed.
- New docs are added to the right index.
- Superseded docs are marked historical rather than silently contradicted.
- Completion summary names changed files, validation, and remaining gaps.

## Batch Completion Gate

A batch is complete only when:

1. Scope matches the batch file.
2. No unrelated roadmap drift was introduced.
3. Required source-of-truth docs remain aligned.
4. Tests or validation appropriate to the change were run or explicitly not run.
5. Visual/UX/accessibility acceptance is satisfied for user-visible work.
6. Empty/error/recovery states are not broken.
7. Confirmation/receipt behavior matches trust gates.
8. Memory/sensitive-area behavior matches Wave 3 gates where relevant.
9. Completion summary distinguishes implemented behavior from planned future canon.
10. `BATCH_REGISTRY.md` is updated if the batch status changed.
11. Follow-up work is captured without moving the active batch prematurely.

## Red Flags

Stop or revise if a change:

- creates a new top-level tab without canon approval
- reintroduces Insights, Habits, or Tasks as standalone top-level surfaces
- requests calendar permission during onboarding
- silently changes calendar/user data
- silently changes major deadlines
- deletes memory without confirmation
- deletes all memory without confirming scope and preserving goals/tasks/plans unless explicitly requested
- creates sensitive/high-impact memory without confirmation
- creates calendar-derived memory without confirmation
- exposes sensitive Life Area details in notifications/widgets or Today compact summaries
- claims Face ID, export exclusion, local-only enforcement, or screenshot hiding without verified implementation
- creates duplicate now/plan/recovery/goal-health logic
- uses AI/model terminology in normal UI
- uses `Dropped`, `Fragile`, or `Broken` as normal user-facing copy when softer Wave 2 labels apply
- uses a numerical Trust Score at launch
- claims sync, memory, automation, or accessibility that is not verified
- breaks local-first behavior
- removes correction/undo paths from meaningful actions
- turns top-level screens into dense dashboards
- changes roadmap status without evidence

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
- Planned-vs-shipped distinction:

## Validation
- Commands run:
- Manual review:
- Not run / limitations:

## Acceptance Gates
- Canon alignment:
- System ownership:
- Visual/UX:
- Accessibility:
- Empty/error/recovery:
- Trust/privacy:
- Confirmation/receipt behavior:
- Memory/sensitive-area behavior:

## Remaining Gaps
- ...
```

## Open Questions For Future Waves

- Should every future batch include a formal gate checklist in its batch doc?
- Should the repo enforce doc-index checks for new canon docs?
- Should visual UI batches require screenshot artifacts before completion?
- Should completion summaries require before/after implementation-state wording?
