# Ambitions Design Constitution

Status: Active Ambitions 2.0 design source of truth.

Current master product and visual direction: [../Ambitions_Master_Product_Visual_System_Spec_v2.md](../Ambitions_Master_Product_Visual_System_Spec_v2.md). The v2 spec supersedes older conflicting language around next-move wording, Focus as a CTA, guessed durations, vacation/free-time assumptions, silent reflow, stale overdue-task behavior, and punitive completion states.

This constitution supersedes conflicting active design, IA, UX writing, interaction, trust, accessibility, and external-surface language. Historical docs may remain when clearly marked as superseded.

Shared object names are locked in [../Ambitions_2_0_Object_Terminology.md](../Ambitions_2_0_Object_Terminology.md). Use that terminology source when changing docs, source copy, tests, previews, or compatibility notes.

## Source-Of-Truth Hierarchy

1. `docs/canon/design/Ambitions_Design_Constitution.md`
2. `docs/canon/Ambitions_2_0_Master_Plan.md`
3. `docs/canon/Ambitions_2_0_Product_Architecture.md`
4. `docs/canon/Ambitions_2_0_Visual_System.md`
5. Supporting design matrices/specs under `docs/canon/design/`

## 1. Product Identity

```text
Ambitions is a personal life organization system.

Opening promise:
My life feels organized, and I can accomplish what I set my mind to because Ambitions gives me concrete steps.

Immediate proof:
I know what matters now.

Expanded thesis:
Ambitions unlocks people's lives by turning ambitions, goals, tasks, plans, and real-world constraints into clear next steps, believable plans, proof of progress, and calm recovery when life changes.
```

Ambitions is not:

- a generic to-do app
- a habit tracker
- a calendar wrapper
- a detached analytics dashboard
- a chat-first AI wrapper
- a dashboard builder
- a corporate workflow tool

Normal UI copy should stay calmer and more specific than the product strategy language.

## 2. Top-Level Shell

Locked shell:

```text
Today
Goals
Capture
Plan
You
```

Rules:

```text
Today = what matters now
Goals = where I am headed
Capture = what needs a place
Plan = does this hold together
You = how my system works for me
```

`Capture` is a real top-level tab. The Capture tab opens the full Capture surface.

Quick Capture is a separate global action that opens the Quiet Command Sheet. The Capture tab must not behave like a floating action button.

The old active shell `Today / Goals / Plan / Insights / Profile` is superseded. Keep it only as marked historical context.

## 3. Insights Demotion

```text
Insights is not a top-level tab.
Insights is contextual intelligence.
```

Insight placement:

- Today: contextual insight tied to today's action.
- Goals: goal health, path explanation, and proof.
- Goal Detail: Why This / Why Changed / Decision Trail.
- Plan: believability, pressure, and calendar evidence.
- You: Reviews, memory, personal analytics, and trust.

No standalone Insights destination exists unless a future canon update explicitly reintroduces it.

## 4. Habits Absorption / Rituals Split

```text
Habits are absorbed.
User-facing language should lean toward Rituals when referring to recurring execution structures.
```

Placement:

- Plan: Ritual setup and scheduling.
- Today: Ritual execution when relevant.
- Goal Detail: goal-supporting ritual context.
- You: Ritual analytics, history, reflection, and preferences.

Do not treat Habits as a standalone top-level product area.

## 5. Object Model

Detailed definitions live in [../Ambitions_2_0_Object_Terminology.md](../Ambitions_2_0_Object_Terminology.md).

Canonical hierarchy:

```text
Life Area
-> Ambition / North Star
-> Goal
-> Path
-> Plan
-> Milestone
-> Step
-> Proof
-> Receipt / Review
```

Task distinction:

```text
Task = standalone One-Step Goal
Step = action inside a Goal, Path, or Plan
```

Rules:

- A Task can exist without an Ambition, Goal, Plan, or Life Area.
- A Task can still have category, time, reminder, location, priority, proof, history, and review value.
- A Step belongs to a larger plan/path/goal structure.
- A Task can be promoted into a Goal.
- A Task can be attached to an existing Goal.
- A Task can become a Ritual.
- A Goal can be demoted into a Task when the structure was too heavy, with a receipt.
- Do not create a top-level Tasks tab.

## 6. Life Areas And North Stars

```text
Life Areas are visible.
Life Areas are not a sixth tab.
Life Areas are a primary organization lens inside Goals and You.
```

Life Area drill-down:

```text
Life Area
-> Ambitions / North Stars
-> Goals
-> Plans / Paths
-> Milestones
-> Steps / Tasks
-> Proof / Decisions / Reviews
```

Locked terms:

- North Star = long-range dormant or identity-level ambition.
- Parked = intentionally paused active goal.
- Goal = active outcome.
- Task = standalone One-Step Goal.
- Life Areas Overview = plain user-facing surface.
- Life Areas Atlas = richer visual system name.

Dormant Ambitions / North Stars live under Life Areas and can exist without active goals or plans.

## 7. Screen Contracts

The detailed matrix lives in [screen-contract-matrix.md](screen-contract-matrix.md).

- Today asks `What matters now?` and requires Hero Decision Panel, Now Layer, Today Plan Layer, compact timeline, relevant One-Step Goals, open-window/free-busy awareness, and recovery support. Today must show the planned day, not only the current step.
- Goals asks `Where am I headed?` and requires Direction hero, Goal Lifecycle Rail, Active Goals, Life Areas preview, North Stars rail, controlled One-Step Goals section, and Semantic Zoom.
- Goal Detail asks `What is the state of this goal, and what happens next?` and uses Mission Control lanes: Overview, Path, Steps, Proof, Decisions, Risks, Archive.
- Capture asks `What needs a place?` and requires fast input, Needs a Place, suggested routes, recent captures, Smart Attachment, and editable receipts.
- Plan asks `Does this hold together?` and requires believability hero, Weekly Plan Strip, Rich Timeline Widget, Ritual setup, scheduling, open windows, calendar-aware mode, and recovery/review prompts.
- You asks `How is my system working for me?` and is the Personal System Center with Profile, Personalization, Memory / What Ambitions Knows, Reviews, Analytics, Trust & Explanations, Privacy, Sync / Export, Integrations, Appearance, Notifications, Accessibility, and Settings.

## 8. Navigation Behavior

```text
Each top-level tab preserves its own navigation stack.
Tap current tab once = scroll current view to top.
Tap current tab twice = return to tab root.
Same object = same canonical detail screen.
Origin Chip / stable title / object identity header preserve orientation.
```

Avoid desktop breadcrumb clutter.

## 9. Grouped Navigation List

The detailed spec lives in [grouped-navigation-list-spec.md](grouped-navigation-list-spec.md).

Official naming:

- Pattern: Grouped Navigation List.
- Visual descriptor: Settings-style grouped list.
- Section: Navigation Section.
- Primary row: Navigation Row.
- Chevron row: Disclosure Navigation Row.
- Toggle row: Preference Row.
- Status/value row: Status Navigation Row.
- Destructive row: Destructive Action Row.
- Code component: `GroupedNavigationList`.

Usage:

- You: heavily, categorized.
- Goal Detail: selectively for subpages/settings/history/depth.
- Plan: controls, preferences, calendar, rituals, review archive.
- Capture: routing categories/settings/archive-like depth only.

Do not use Grouped Navigation Lists as the primary execution UI.

## 10. Visual / Component System

The detailed matrix lives in [component-contract-matrix.md](component-contract-matrix.md).

Hierarchy:

```text
Screen
-> Region
-> Panel
-> Row / Control
```

Panel is the primary visual object. Card is secondary.

Panel doctrine:

- Every panel has a job.
- Not every panel needs an action.
- Some panels exist to make life visually understandable and can be drilled into.

Panel jobs: Decide, Act, Explain, Orient, Show state, Prove progress, Recover, Route, Review, Configure, Warn, Summarize, Remember.

Required panel types: Hero Decision Panel, Progress Panel, Timeline Panel, Schedule Panel, Insight Panel, Recovery Panel, Trust Panel, Receipt Panel, Capture Panel, Review Panel, Settings / Preference Panel, Today Plan Panel, Life Areas Panel, One-Step Goals Panel.

## 11. Density And Size

The detailed spec lives in [panel-density-size-spec.md](panel-density-size-spec.md).

```text
Display Density: Minimal / Balanced / Detailed
Panel Size: Compact / Comfortable / Large
Default: Balanced + Comfortable
```

Rules:

- Density = how much information appears.
- Size = how large the same information feels.
- Large panels show fewer things at once.
- Compact panels must not become cramped.
- Large panels must not feel like stretched UI.

Modularity guardrails:

- Hero panels are anchored.
- Critical panels cannot fully hide.
- Supporting panels can reorder only within safe zones.
- Noncritical panels can hide.
- Critical panels collapse into a signal, ribbon, badge, or required state.

Do not let modularity become dashboard-builder behavior.

## 12. UX Writing

The detailed matrix lives in [ux-writing-state-language-matrix.md](ux-writing-state-language-matrix.md).

Voice: calm, adult, specific, non-shaming, clear, direct, emotionally safe, action-oriented.

```text
Ambitions is not an AI product.
Ambitions is an intelligent product.
```

Avoid normal UI labels such as `AI Explanation`, `AI Confidence`, `Model Reasoning`, and `Fix AI`.

Use `Why This`, `Why Now`, `Why Changed`, `What This Uses`, `Needs Confirmation`, and `Update This`.

Recovery language: Save the Day, Save the Week, Make Lighter, Move This, Protect Later, Needs a New Place, Drifted.

Capture language: Needs a Place; Saved as [object] · [area] · [route].

Button rules: verb-led, 1-3 words where possible, exact labels for meaningful actions, vague OK/Continue/Done only when harmless.

## 13. Smart Attachment

The detailed spec lives in [smart-attachment-spec.md](smart-attachment-spec.md).

Smart Attachment is the Ambitions system that infers whether a capture belongs to an existing Life Area, Ambition, Goal, Plan, Step, Task, Proof item, Decision, Ritual, or Waiting item, then saves with the least friction possible and lets the user correct the route.

Confidence behavior:

- High confidence = attach automatically + editable receipt.
- Medium confidence = save standalone + suggest attachment in receipt.
- Low confidence = save to Needs a Place.
- Clarification = compact 1-3 choices, not chat.

Example:

```text
Input:
find NASA contacts on LinkedIn later

High confidence:
Saved as Step · Career · Become an Astronaut · Later
Change
Keep Standalone

Medium confidence:
Saved as Task · Career · Later
Suggestion: Attach to Become an Astronaut

Low confidence:
Saved to Needs a Place
Choices: Task / Goal / Seed
```

The Quiet Command Sheet must not be a chat interface, but it should feel important, modern, and high-quality.

## 14. Trust, Memory, Receipts, Privacy

```text
Trust = privacy + explanation + correction + receipts + user control.
```

Placement:

- Contextual everywhere.
- Control center under You -> Trust Center.

Memory user-facing area: You -> What Ambitions Knows.

Memory rules: visible, editable, deletable, correctable, freshness-aware, and recoverable briefly if technically safe.

Freshness labels: Current; May Need Review; Based on Older Context.

Receipts are trust objects. Receipts are searchable later. Privacy-sensitive receipts hide details by default.

Receipt anatomy:

- What happened.
- What changed.
- Why it changed.
- Undo if safe.
- Correction if relevant.
- Timestamp/source when useful.

User-facing term is `Receipt` or `Result`; internal/docs term can remain `Action Closure`.

## 15. Calendar And Permissions

```text
Calendar permission remains Plan-owned.
Calendar read permission is requested only after explicit Plan action.
Calendar write requires explicit confirmation.
Plan works without calendar access.
```

Allowed Plan triggers:

- Make Plan calendar-aware.
- Find real open windows.

External data labels:

- From your calendar.
- Created in Ambitions.
- Based on your plan.

Calendar-derived insight remains local-first. Store only minimum derived information needed for believability, conflict, open-window, recovery, and review. Do not copy external data into unrelated stores.

Do not request calendar access during onboarding.

## 16. Interaction

```text
Interaction doctrine:
Speed + clarity, beauty through restraint.
```

Rules:

- Common actions reachable in one or two taps.
- Reversible actions use receipt + undo, not confirmation.
- Destructive/irreversible/permission/external-write/trust-critical actions require confirmation.
- Hero panel body tap = inspect / expand / explain.
- Hero panel button tap = act.
- Gestures are allowed but never required.
- Swipe supports Complete / Move / Park / Archive.
- Drag/reorder has visible alternatives.
- Long press has visible alternatives.

Remove-from-now behavior:

- Default remove-from-now action = Park / Not Today.
- Park / Not Today triggers Reality Reflow.
- Reality Reflow updates the plan and warns if the deadline becomes tighter, unrealistic, or impossible.

## 17. Motion

```text
Motion explains state change first.
Premium feel second.
Delight only when earned.
Motion never compensates for unclear layout.
```

Required:

- Formal motion grammar.
- Performance budgets.
- Reduced Motion variants.

Reduce Motion must preserve equivalent state clarity. Smart Attachment motion should communicate where the item went, not AI thinking or magic. Plan Reflow motion should communicate cause, result, and deadline impact.

## 18. Accessibility

The detailed matrix lives in [accessibility-nutrition-screen-matrix.md](accessibility-nutrition-screen-matrix.md).

```text
Accessibility is core product quality.
Ambitions is ADHD-safe by default.
User-facing setting = Focus Support, not ADHD Mode.
Dynamic Type required.
Reduce Motion required.
No color-only meaning.
No required hidden gestures.
Accessibility Nutrition checklist per screen.
No user-facing accessibility claims before verification.
```

Panel Size and Display Density must be tested across Minimal / Balanced / Detailed and Compact / Comfortable / Large.

Component accessibility contracts must include Dynamic Type behavior, VoiceOver label/value/hint, Reduce Motion behavior, contrast requirements, no color-only state, tap target requirements, gesture alternatives, focus/keyboard behavior where applicable, and large/compact panel behavior.

## 19. Onboarding, Notifications, External Surfaces

The detailed contract lives in [external-surfaces-contract.md](external-surfaces-contract.md).

Onboarding:

- Get the user to first useful life object quickly.
- Natural-language capture + compact clarification.
- Ask: "What do you want to organize?"
- Lightly ask detail level and panel size.
- No upfront permission requests.
- First-run success = one useful object created and user knows next step.

Notifications:

- Sparse by default.
- Contextual, operational, calm, specific.
- Sensitive details hidden by default.
- Allowed actions: Start / Move / Park / Mark Done / Open Plan.
- Styles: Essential / Balanced / Supportive.

Widgets:

- Included after Now State is stable.
- Show Now / Next Step / protected block / plan status.
- Multiple sizes.
- Sensitive details hidden by default.
- Lightweight snapshots.

Live Activities:

- Included after Now State and Command Pipeline are stable.
- Support active focus block / protected block / current plan window.
- No sensitive goal names by default.
- Defined beginning/end.
- Glanceable only.

App Intents:

- Capture.
- Start Next Step.
- Mark Done.
- Save the Day.
- Open Plan.

Confirm destructive, external, or sensitive effects.
