# CS04 Habits/Ritual/Plan Accessibility Identifier Ledger

<!-- markdownlint-disable MD013 -->

Status: CS04A accessibility identifier freeze ledger for global order `043`.
Date: 2026-05-02

## Freeze Policy

No `habits.*`, `plan.*`, or Plan-to-Ritual route identifier is renamed in CS04A. Identifier changes are compatibility-affecting and require an alias or replacement strategy plus focused UI/test proof.

## Identifier Inventory

| Identifier family | File path | Current role | Test/automation dependency | Safe action now | Unsafe action | Owner |
| --- | --- | --- | --- | --- | --- | --- |
| `habits.screen` | `Native/Ambitions/Features/Habits/HabitsScreen.swift` | Plan-owned Rituals route screen identifier | UI smoke references it | Freeze | Rename/delete without alias proof | CS04B/CS04C |
| `habits.retry-button` | `HabitsScreen.swift` | Degraded-state retry action | UI/accessibility surface | Freeze | Rename as copy cleanup | CS04C/SI if redesigned |
| `habits.return-to-plan` | `HabitsScreen.swift`; UI tests | Return affordance to Plan | UI smoke references it | Freeze | Rename without UI proof | CS04B/CS04C |
| `habits.open-weekly-review` | `HabitsScreen.swift` | Plan weekly review route affordance | UI/accessibility surface | Freeze | Rename without route proof | CS04B/CS04C |
| `habits.empty.return-plan` | `HabitsScreen.swift` | Empty-state return-to-Plan action | UI/accessibility surface | Freeze | Rename without replacement | CS04C |
| `plan.open-habits-button` | `PlanScreen.swift` | Plan support route entry | UI/accessibility surface | Freeze | Rename without replacement | CS04B/CS04C |
| `plan.open-plan-habits-button` | `PlanScreen.swift`; UI tests | Plan secondary destination button for Rituals | UI smoke references it | Freeze | Rename without UI proof | CS04B/CS04C |
| `plan.resilience.habits` / `plan.open-plan-habits-button` variants | `PlanScreen.swift`, Plan projections | Plan-owned support route row/lane | Plan/UI tests may depend on generated ids | Freeze | Rename generated ids without test proof | CS04B/CS04C |
| `shell.meridian.destination.plan` | shell destination tests | Visible Plan tab destination | Shell tests | Preserve | Add top-level `shell.meridian.destination.habits` | Every CS batch |
| `plan.*` identifiers | `Native/Ambitions/Features/Plan/**` | Canonical Plan surface identifiers | Plan UI tests and routing | Preserve | Use as replacement for Habits ids without proof | CS04B/CS04C |

## Required Before Any Identifier Retirement

- replacement identifier map;
- affected UI/unit tests listed;
- old and new route behavior documented;
- VoiceOver/user-facing copy check;
- focused UI or closest available proof;
- rollback path restoring the old identifier.

## Result

Green for CS04A. The identifier contract is frozen. Future rename or deletion without alias/deprecation proof is Red.
