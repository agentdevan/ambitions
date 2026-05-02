# CS04 Habits Ritual Plan Dry-Run Red Report

<!-- markdownlint-disable MD013 -->

Status: STOPPED ON RED.
Date: 2026-05-02

## Batch

- Formal batch ID: `CS04`
- Global order number: `043`
- Active prompt:
  `docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md`
- Dry-run result: Execution allowed: NO.

## Why Execution Is Blocked

CS04 is currently framed as a compatibility retirement batch for the
Habits/Ritual/Plan seam, but the seam is not yet narrow enough to execute safely.
Preflight discovery shows current repo references across:

- `Native/Ambitions/Domain/HabitsModels.swift`
- `Native/Ambitions/Domain/RitualModels.swift`
- `Native/Ambitions/Services/RitualOrchestrationService.swift`
- `Native/Ambitions/Features/Habits/**`
- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/Features/Shared/HabitGoalSemantics.swift`
- `Native/Ambitions/PreviewSupport/PreviewHabitsScenarios.swift`
- `Native/AmbitionsTests/Habits/**`
- `Native/AmbitionsTests/Ritual/**`
- `Native/AmbitionsTests/Plan/**`
- docs and historical audit references describing Habits as absorbed into
  Rituals, Plan, Today, Reviews, and You.

The existing CS04 prompt requires old payload survival proof, replacement maps,
route/deep-link review, schema/persistence review, widget/App Intent/Shortcut
review, import/export review, focused tests, rollback, and release-claim review
before deletion. Those maps and ledgers do not exist yet for CS04.

## Red Classification

| Red | Evidence | Required repair |
| --- | --- | --- |
| Seam owner ambiguity | Habits, Ritual, Plan, shared semantics, previews, and tests are all implicated. | Split CS04 into map/proof/retirement stages before implementation. |
| Route/raw/payload uncertainty | Current prompt mentions legacy payload survival, routes, widgets, App Intents, shortcuts, import/export, and persistence, but no CS04 ledger exists. | Create Habits/Ritual/Plan compatibility inventory and contract ledger first. |
| Deletion-before-proof risk | The prompt's compatibility action is `retires`; current evidence is not strong enough to retire anything. | Keep old names and compatibility paths until focused proof exists. |
| Product-semantics risk | Habits are absorbed into Rituals/Plan/Today/You, not simply deleted. | Map each Habit reference to ritual support, Plan shaping, Today loop, You review/trust, dead history, or future owner. |

## Non-Claims

This report does not claim CS04 is complete, does not retire any Habits seam,
does not claim Ritual/Plan migration complete, does not edit production Swift,
does not change routes, raw values, persistence, accessibility identifiers,
widgets, App Intents, import/export behavior, or product behavior, and does not
claim release, TestFlight, App Store, physical-device, public accessibility,
PXOS, Signature Interface, Product Depth, or AmbitionsOS implementation proof.

## Recommended Repair Prompt

Next prompt path:
`docs/codex/batches/CS04_Habits_Ritual_Plan_Compatibility_Retirement_Prompt.md`

Recommended next action:
Repair CS04 by splitting it into a Habits/Ritual/Plan compatibility map and
migration design stage, a focused compatibility-preservation proof stage, and
only then a narrow retirement stage. Mirror the CS02 and CS03 staged repair
pattern.
