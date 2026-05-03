# CS06 User-Facing Copy And Accessibility Language Ledger

Status: CS06A docs/protocol ledger. This file identifies copy and assistive-language candidates only; it does not change user-facing copy or accessibility identifiers.

## Source-Truth Rule

Ambitions canon forbids shame-oriented visible language such as `failed`, `failure`, `missed`, `behind`, and streak-pressure language where it describes the user. The same canon allows precise technical failure states when they represent command failures, system failures, automation non-execution, or validation evidence.

## Ledger

| Seam | Current evidence | Classification | Safe action now | Required proof before copy/accessibility change | Owner |
|---|---|---|---|---|---|
| `docs/canon/Ambitions_3_0_Product_Language_System.md` forbidden list includes `failed` | Canon explicitly marks `failed` as avoided user-facing language | user-facing rename candidate guardrail | Preserve guardrail | None; this is source truth | CS06A |
| `docs/canon/PXOS_Copy_Language_And_Explanation_System.md` says avoid success/failure framing | PXOS copy canon | user-facing rename candidate guardrail | Preserve guardrail | None; this is source truth | CS06A |
| Feature view strings such as "Unable to load Today/Goals/Plan/You" | User-visible recovery copy currently avoids "failed" and names what did not load | must preserve technical state with humane copy | Preserve | Focused view-model/screen tests if copy changes | CS06B/CS06C |
| `LaunchGateView` rendering of bootstrap `.failed` | Potential user-visible launch failure presentation | unknown/defer | Inventory only | Launch UI proof and accessible copy review | CS06B/CS06C |
| `CreateGoalScreen`, `CapturesScreen`, `TodayScreen`, `GoalsScreen`, `PlanScreen`, `InsightsScreen`, `HabitsScreen`, `ProfileScreen` switch on `.failed` | Technical state drives degraded UI | must preserve technical state | Preserve | Focused screen/view-model tests and Dynamic Type/VoiceOver review for touched surfaces | CS06B/CS06C |
| Safe-automation receipt display for `.failedSafely` as "Safely blocked" | User-facing phrasing already avoids "failed" while preserving technical state | must preserve technical state | Preserve | Receipt display tests if changed | CS06B/CS06C |
| Plan safe failure fallback text | User-facing safe fallback copy explains unchanged state | must preserve technical state with humane copy | Preserve | Plan service/screen tests if changed | CS06B/CS06C |
| MemoryLensService skip explanation says skip is not failure | Canon-aligned copy | user-facing rename candidate already satisfied | Preserve | None unless modified | CS06C only if touched |
| Preview fixture copy "not failure" | Preview/user-facing scenario language | user-facing rename candidate, low risk | Preserve for CS06A | Preview/screenshot evidence if changed | CS06C |
| Accessibility labels/hints with exact `failed` text | No broad rename allowed; exact rendered assistive copy requires targeted inventory | unknown/defer | Inventory only | UI/accessibility tests or manual accessibility evidence; identifiers must remain stable unless alias strategy exists | CS06B/CS06C |
| Accessibility identifiers containing legacy terms | Compatibility surface | must preserve technical state | Preserve | Alias/deprecation proof plus UI test update | CS06B/CS06C |

## CS06A Decision

CS06A changes no copy and no accessibility identifiers. Later CS06C may improve visible recovery language only where CS06B proves the change does not alter command behavior, async state behavior, receipt semantics, persistence, accessibility compatibility, or historical evidence.
