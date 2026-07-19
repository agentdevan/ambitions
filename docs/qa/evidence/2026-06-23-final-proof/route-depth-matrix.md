# Route-Depth Matrix

| Target | Proof | Status | Evidence | Remaining gap |
|---|---|---|---|---|
| Root dock visible on Today root | Root screenshot baseline | Yellow | Today screenshot in `screenshot-index.md` | Device proof and Light/System proof missing. |
| Root dock visible on Goals root | Root screenshot baseline | Yellow | Goals screenshot in `screenshot-index.md` | Visual defect: text splitting and dock overlap. |
| Root dock visible on Time root | Root screenshot baseline | Yellow | Time screenshot in `screenshot-index.md` | Visual defect: dock overlaps lower content. |
| Root dock visible on You root | Root screenshot baseline | Yellow | You screenshot in `screenshot-index.md` | Visual defect: dock overlaps Local Data row. |
| Root dock hidden in Goal Detail | UI test | Green for simulator route-depth only | `AmbitionsUITests/AmbitionsUITests/testUIQL002GoalDetailDrilldownHidesRootDock` passed; summary `.codex/xcode-summaries/AMB-1199-final-proof/20260623T212235Z-AmbitionsUITests-AmbitionsUITests-testUIQL002GoalDetailDrilldownHidesRootDock-95338-7927/focused-test-summary.json` | Screenshot/back-route proof missing. |
| Root dock hidden in Capture | Not produced in successful AMB-1199 focused run | Red | Broad UI bundle failed with AX initialization timeout before screenshots. | Rerun focused Capture route after simulator reliability is stable. |
| Root dock hidden in Search | Not produced in successful AMB-1199 focused run | Red | Broad UI bundle failed with AX initialization timeout before screenshots. | Search overlay route proof missing. |
| Root dock hidden in Goals Area Detail | Not produced | Red | No focused AMB-1199 pass for `goals.area-detail.screen`. | Area detail route test/screenshot needed. |
| Root dock hidden in Time drilldowns | Not produced in successful focused run | Red | Broad UI bundle included Time drilldown but failed before execution. | Time drilldown route test/screenshot needed. |
| Root dock hidden in You detail | Not produced in successful focused run | Red | Broad UI bundle did not produce You detail screenshots. | You detail route-depth proof needed. |
| Back/dismiss returns to origin | Partial | Yellow/Red | Existing focused Goal Detail test only checks dock hiding. | Explicit back/dismiss return assertions needed for each route. |

