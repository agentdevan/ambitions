# CS03 Insights/Plan Accessibility Identifier Ledger

<!-- markdownlint-disable MD013 -->

Status: CS03A accessibility identifier freeze ledger for global order `042`.
Date: 2026-05-02

## Freeze Policy

No `insights.*` or `plan.*` accessibility identifier is renamed in CS03A.
Identifier changes are compatibility-affecting and require an alias or
replacement strategy plus focused UI/test proof.

## Identifier Inventory

| Identifier family | File path | Current role | Test/automation dependency | Safe action now | Unsafe action | Owner |
| --- | --- | --- | --- | --- | --- | --- |
| `insights.screen` | `Native/Ambitions/Features/Insights/InsightsScreen.swift` | Main support route screen identifier | UI smoke and route proof may depend on it | Freeze | Rename/delete without alias proof | CS03B/CS03C |
| `insights.monthly-review.screen` | `InsightsScreen.swift` | Monthly review route screen | UI smoke uses it | Freeze | Rename/delete without route proof | CS03B/CS03C |
| `insights.history.screen` | `InsightsScreen.swift` | History route screen | UI smoke uses it | Freeze | Rename/delete without route proof | CS03B/CS03C |
| `insights.monthly-review.open-weekly-review` | `InsightsScreen.swift` | Handoff from review to Plan weekly review | UI route proof may use it | Freeze | Rename without UI proof | CS03B/CS03C |
| `insights.history.open-weekly-review` | `InsightsScreen.swift` | Handoff from history to Plan weekly review | UI route proof may use it | Freeze | Rename without UI proof | CS03B/CS03C |
| `insights.hero.primary-action` | `InsightsScreen.swift` | Main action on History/Insights support screen | UI/accessibility surface | Freeze | Rename as copy cleanup | CS03C |
| `insights.hero-card` | `InsightsScreen.swift` | Support screen hero card | UI/accessibility surface | Freeze | Rename as card cleanup | CS03C/SI if redesigned |
| `insights.continuity-ribbon` | `InsightsScreen.swift` | Continuity support component | UI/accessibility surface | Freeze | Rename before semantic owner exists | CS03C/future PD |
| `insights.compare-period` | `InsightsScreen.swift` | Review/comparison component | UI/accessibility surface | Freeze | Delete without semantic mapping | CS03C/future PD |
| `insights.pattern-truth` | `InsightsScreen.swift` | Pattern/contextual intelligence component | UI/accessibility surface | Freeze | Delete or genericize | CS03C/future AOS/PD |
| `insights.review-constellation` | `InsightsScreen.swift`; UI tests | Review constellation component | UI smoke references it | Freeze | Rename without UI test update/proof | CS03B/CS03C |
| `insights.open-history` | `InsightsScreen.swift` | Open history route affordance | UI/accessibility surface | Freeze | Rename without replacement | CS03C |
| `insights.open-monthly-review` | `InsightsScreen.swift` | Open monthly review route affordance | UI/accessibility surface | Freeze | Rename without replacement | CS03C |
| `insights.history-layer` | `InsightsScreen.swift` | History list/layer component | UI/accessibility surface | Freeze | Delete without history owner | CS03C/future PD |
| `plan.*` identifiers | `Native/Ambitions/Features/Plan/**` | Canonical Plan surface identifiers | Plan UI tests and routing | Preserve | Use as replacement for Insights without proof | CS03B/CS03C |
| `shell.meridian.destination.plan` | `AppShellPresentationMode.swift` / shell tests | Visible Plan tab destination | Shell tests | Preserve | Add `shell.meridian.destination.insights` to top-level shell | Every CS batch |

## Required Before Any Identifier Retirement

- replacement identifier map;
- affected UI/unit tests listed;
- old and new route behavior documented;
- VoiceOver/user-facing copy check;
- focused UI or closest available proof;
- rollback path restoring the old identifier.

## Result

Green for CS03A. The identifier contract is frozen. Future rename or deletion
without alias/deprecation proof is Red.
