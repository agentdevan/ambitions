# CS04 Habits/Ritual/Plan Retirement Risk Map

<!-- markdownlint-disable MD013 -->

Status: CS04A retirement risk map for global order `043`.
Date: 2026-05-02

## Purpose

This map prevents CS04 from treating Habits as dead naming residue. Current source truth shows Habits is a compatibility surface around Plan-owned Rituals, recurring-goal support, external payloads, and UI automation identifiers.

## Risk Map

| Seam | Current owner | Risk | Safe action now | Required proof before retirement |
| --- | --- | --- | --- | --- |
| `AppTab.habits` raw value | App shell/routing | Red if removed | Preserve | Raw-value parser, selected/preferred/default tab, external route, shell, UI proof |
| `PlanRouteTarget.habits` | App navigation / Plan support route | Red if removed | Preserve | Deep-link, widget/notification payload, back/return, Plan route proof |
| `ambitions://tab/habits` | External routing | Red if removed | Preserve | External route compatibility test and replacement adapter proof |
| `ambitions://plan/habits` | External routing | Red if removed | Preserve | External route compatibility test and route payload proof |
| Widget/notification `tab=habits` | External payload handling | Red if removed | Preserve | Widget/notification parsing proof |
| Preferred/default tab `.habits` | Persistence/app preferences | Red if broken | Preserve canonicalization to `.plan` | SwiftData/app-state/preferences proof |
| `habits.*` accessibility ids | Habits route UI | Red if renamed without proof | Freeze | UI/accessibility identifier proof and alias/deprecation map |
| `HabitsFeatureService` and `HabitsModels` | Plan-owned Rituals route projection | Yellow/Red if renamed broadly | Preserve | Habits service tests, Plan tests, compatibility aliases |
| `RitualModels` and `RitualOrchestrationService` | Recurring-loop semantic model | Yellow/Red if conflated with naming cleanup | Preserve | Ritual tests, external snapshot tests, semantic owner replacement |
| Plan support route copy | Plan/Habits features | Yellow if regressed to top-level Habits posture | Preserve Rituals/Plan-owned copy | Plan/Habits copy tests |
| UI tests for Plan-to-Rituals route | UI smoke | Yellow if stale but useful | Preserve as proof | UI run if identifiers or visible route changed |

## Safe-To-Retire Later

No current CS04A source symbol is proven safe to retire now.

## Must Preserve

- `AppTab.habits`
- `PlanRouteTarget.habits`
- `ambitions://tab/habits`
- `ambitions://plan/habits`
- widget/notification payload `tab=habits`
- `habits.*` accessibility identifiers
- Plan-owned Rituals route behavior
- `RitualModels` and `RitualOrchestrationService`

## Unknown / Defer

- Whether `Native/Ambitions/Features/Habits/**` should eventually be renamed to a Rituals owner.
- Whether generated ids such as `plan-habits` can be renamed without breaking UI tests.
- Whether external snapshot ritual cues create additional migration constraints beyond existing CS08 proof.

## Result

CS04C is blocked. CS04B may add focused proof. Retirement remains unsafe until the proof matrix is Green or accepted Yellow with named owner.
