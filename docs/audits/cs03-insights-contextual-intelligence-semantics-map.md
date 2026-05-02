# CS03 Insights Contextual Intelligence Semantics Map

<!-- markdownlint-disable MD013 -->

Status: CS03A semantics map for global order `042`.
Date: 2026-05-02

## Purpose

This map prevents CS03 from deleting meaningful contextual-intelligence,
review, proof, or history semantics merely because their current symbols use the
legacy `Insights` name.

## Semantic Classification

| Semantic meaning | Current evidence | Current owner | Future owner candidate | Safe action now | Unsafe action |
| --- | --- | --- | --- | --- | --- |
| Old top-level tab compatibility | `AppTab.insights`; `ambitions://tab/insights`; shell tests reject visible Insights tab. | CS / App shell | CS03B then CS10 | Preserve raw compatibility; prove no visible tab. | Delete raw value or re-add top-level tab. |
| Current support route label/history | `AppTab.insights.title == "History"`; `openInsightsRoute(.history)`; `insights.history.screen`. | You/Profile support route today | CS03B/CS10 decision; PD15/PD17 if proof/history center changes | Preserve until owner decision. | Force Plan display without route proof. |
| Plan surface functionality | `InsightsReviewConstellation` and history screens can hand off to `PlanRouteTarget.weeklyReview`; Plan owns weekly review route. | Plan for weekly review; Insights support screen for origin | CS03B/PD12-PD17 depending depth | Map handoffs; do not collapse semantics. | Claim all Insights already belongs to Plan. |
| Analytics/review history | `InsightsHistoryLayerState`, history route, monthly review route, UI smokes. | Insights support models/screens | You reviews / PD15 / PD17 | Preserve history semantics and tests. | Delete as stale tab residue. |
| Recommendation explanation | `InsightsHeroAction`, continuity ribbons, pattern clusters can point to goals/plan/insights routes. | Insights service | AOS/PD where runtime or proof is touched | Preserve until AOS/PD owner exists. | Rename into generic Plan copy or fake AI explanation. |
| Proof/trust summary | proof/wins/friction/pattern state in `InsightsFeatureService`. | Insights service | Trust/receipt/PD17/AOS proof owners | Preserve; document source/freshness if changed. | Delete proof semantics without replacement. |
| Obsolete/dead concept | No current source symbol is proven dead by CS03A. | None | CS03C only after proof | Treat as live. | Broad deletion. |
| Future AOS/PD-owned concept | pattern truth, adaptation, review constellation, history/proof continuity. | Current support service/models | PD15-PD18 and AOS expression gates where relevant | Defer with owner. | Claim AmbitionsOS implemented or Product Depth complete. |

## Current Routing Semantics

Current implementation routes legacy `insights` tab compatibility to the
You/Profile support stack with `insightsPath = [.history]`. Plan remains a
visible top-level tab and owns weekly review and planning routes. CS03A does not
decide a destination migration. CS03B may prove current compatibility and name a
future owner for any Plan/You destination realignment.

## Red Lines

- Do not remove `InsightsRouteTarget` before all route and UI proof is Green.
- Do not delete `InsightsModels` or `InsightsFeatureService` as naming cleanup.
- Do not blur review/proof/pattern semantics into generic Plan copy.
- Do not claim AmbitionsOS, Product Depth, or Signature Interface implementation.

## Result

Green for CS03A semantics mapping with accepted Yellow: the final owner of
legacy Insights history/review semantics remains a staged decision, not a
current retirement.
