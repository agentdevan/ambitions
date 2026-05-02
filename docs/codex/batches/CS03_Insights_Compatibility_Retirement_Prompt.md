# CS03 Insights Compatibility Retirement Prompt

<!-- markdownlint-disable MD013 -->

Status: Repaired Ambitions 4.0 compatibility batch; internally staged under formal global order `042`; CS03A complete pending validation/commit evidence; CS03B is the next narrowed proof step only if dry-run says `Execution allowed: YES`; CS03C is blocked until CS03A and CS03B are Green or accepted Yellow.

## Batch Identity

- Formal batch ID: `CS03`
- Name: Insights Compatibility Retirement
- Compatibility action: staged map/prove/retire
- Candidate seam: `Insights` route/model/raw/default/accessibility/contextual-intelligence compatibility.
- Global order number: `042`
- Formal batch count impact: none; CS03A, CS03B, and CS03C are internal stages of formal CS03, so the Ambitions 4.0 total remains `113 formal batches`.

## Repair Context

The original CS03 direct retirement dry-run returned `Execution allowed: NO` because `Insights` is not a narrow deletion seam. Current repo truth shows:

- `Insights` is not a visible top-level tab.
- `Plan` remains the visible top-level planning surface.
- `AppTab.insights` remains a hidden raw compatibility value.
- Current shell/navigation compatibility maps legacy `.insights` toward the You/Profile history support route, not directly to Plan.
- `InsightsRouteTarget`, `insightsPath`, `ambitions://insights/*`, `Insights` feature/domain files, tests, and `insights.*` accessibility identifiers are live compatibility and contextual-intelligence surfaces.

Therefore CS03 must not delete, rename, or retire Insights symbols until compatibility proof is stronger than the seam being removed.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_4_0_Execution_Program.md`
- `docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md`
- `docs/canon/PXOS_Visual_Interaction_System.md`
- `docs/canon/Ambitions_Product_Depth_Plan.md`
- `docs/canon/Ambitions_Signature_Interface_System.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/GLOBAL_BATCH_REPAIR_LOOP_PROTOCOL.md`
- `docs/codex/GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`
- `docs/codex/GLOBAL_BATCH_AUTOMATED_GATE_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- CS01, CS07, CS08, and CS02 compatibility reports and ledgers.
- `.codex/skills/compatibility-migration-architect.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `rg -n "AppTab.insights|\\.insights|InsightsRouteTarget|InsightsScreen|InsightsFeatureService|InsightsModels|Insights" Native docs .codex || true`
- `rg -n "insights|Insights|plan|Plan" Native/AmbitionsTests Native/AmbitionsUITests docs/codex docs/canon .codex || true`
- `rg -n "accessibilityIdentifier|accessibility\\(identifier" Native || true`
- `rg -n "defaultTab|selectedTab|rawValue|AppTab|RouteTarget" Native || true`
- `find Native -iname "*Insights*" -o -iname "*Plan*" | sort`

Stop if predecessor CS gates are not Green or accepted Yellow, if the seam owner is unclear, if source truth conflicts would cause implementation risk, or if route/raw/default/accessibility/external/contextual-intelligence impact cannot be mapped.

## CS03A — Insights/Plan Compatibility Map And Migration Design

Type: docs/audit/protocol only.

Purpose: define the compatibility seam, migration plan, aliases, contextual-intelligence semantics, test strategy, rollback path, and allowed retirement sequence.

Allowed files:

- `docs/audits/cs03-insights-plan-compatibility-seam-inventory.md`
- `docs/audits/cs03-insights-plan-compatibility-contract-ledger.md`
- `docs/audits/cs03-insights-plan-accessibility-identifier-ledger.md`
- `docs/audits/cs03-insights-contextual-intelligence-semantics-map.md`
- `docs/audits/cs03-insights-plan-compatibility-seam-split-report.md`
- This prompt.
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

Forbidden files:

- `Native/**`
- production Swift
- tests
- route/raw values
- persistence/defaults
- accessibility identifiers
- dependencies/lockfiles/workflows
- release/platform claim docs unrelated to CS03 status truth

Green criteria:

- Full seam inventory exists.
- Compatibility contract ledger exists.
- Accessibility identifier ledger exists.
- Contextual-intelligence semantics map exists.
- Original CS03 prompt is repaired into staged execution.
- No production code or tests are touched.
- No route/raw/default/accessibility behavior changes occur.
- CS03B is narrow enough to dry-run safely.

## CS03B — User-Facing Plan Alias And Insights Compatibility Preservation

Type: narrow compatibility proof implementation only if dry-run says `Execution allowed: YES`.

Purpose: prove current user-facing `Plan` canon and legacy `insights` compatibility can coexist without duplicate destinations, route/raw/default drift, accessibility identifier break, or contextual-intelligence semantic loss.

Allowed files:

- Focused app shell/navigation tests.
- Focused external routing tests.
- Focused compatibility fixtures for legacy `insights` values, if already supported by repo test conventions.
- CS03B audit/report/status docs.

Production Swift may be edited only if CS03B dry-run identifies a specific, compatibility-preserving adapter gap that cannot be proven by tests alone. Any production change must be narrowly limited to route/default/display compatibility helpers and must preserve old raw values.

Forbidden work:

- Deleting `AppTab.insights`.
- Deleting `InsightsRouteTarget`.
- Broad Insights-to-Plan rename.
- Renaming Insights folders/types.
- Changing route raw values without migration proof.
- Changing selected/default-tab persistence without fallback proof.
- Changing accessibility identifiers without alias/deprecation proof.
- Creating duplicate `Insights` and `Plan` destinations.
- Changing shell navigation behavior except to preserve compatibility.
- Collapsing contextual-intelligence semantics into generic Plan copy.
- Weakening tests.

Green criteria:

- Old `insights` raw values and external routes still resolve to the current compatible surface.
- Visible top-level tab label remains `Plan`.
- No visible top-level `Insights` tab appears.
- `InsightsRouteTarget` remains compatible or is safely delegated with proof.
- Focused route/shell/external tests pass.
- Accessibility identifiers are unchanged or explicitly aliased with proof.
- Contextual-intelligence semantics are preserved or mapped to an owner.

## CS03C — Narrow Internal Insights Retirement

Type: implementation, blocked until CS03A and CS03B are Green or accepted Yellow.

Purpose: retire only internal Insights names that are proven safe and not part of routes, raw values, persistence/defaults, accessibility identifiers, external assumptions, contextual-intelligence semantics, tests, previews, or compatibility.

Allowed work:

- Small internal type/file renames where all references are local and focused tests prove no behavior change.
- Deprecated aliases or wrappers where migration risk remains.
- CS03C report/status docs.

Forbidden work:

- Broad rename.
- Route/raw/default/accessibility break.
- Removing aliases prematurely.
- Deleting `InsightsRouteTarget` without proof.
- Behavior changes.
- Contextual-intelligence semantic deletion.
- Folder/type churn without proof.

Green criteria:

- No compatibility break.
- No route/default/accessibility break.
- No contextual-intelligence semantic loss.
- Focused tests pass.
- Diff stays narrow and reviewable.
- Rollback path is clear.

## Required Route And Compatibility Proof Matrix

| Input / legacy assumption | Expected resolution | Required proof |
| --- | --- | --- |
| `insights` raw tab value | Current compatible support surface; repo currently normalizes to You/Profile history support | Focused shell/navigation test or documented CS03B proof |
| `InsightsRouteTarget` usage | Compatible history/review route behavior | Focused app navigation or external routing test |
| `ambitions://tab/insights` | Compatible legacy tab handling without visible Insights tab | External route test |
| `ambitions://insights/history` | Compatible history route | External route test |
| `ambitions://insights/monthly-review` | Compatible review route | External route test |
| Unknown tab/route value | Safe fallback | Existing external routing test or CS03B added proof |
| Duplicate Plan/Insights destination | Must not exist | Inventory plus shell test |
| User-facing tab label | Must remain `Plan` | Shell/display proof |

## Accessibility Identifier Freeze Policy

Accessibility identifiers are compatibility surfaces. CS03 must inventory every `insights.*` and `plan.*` identifier, keep old identifiers stable unless an alias/deprecation strategy exists, and update tests only in the batch that explicitly owns proof.

## Contextual Intelligence Preservation Rule

`Insights` may mean legacy tab compatibility, historical review, contextual intelligence, proof/trust summary, recommendation explanation, or future PD/AOS-owned intelligence expression. Do not delete an `Insights` symbol merely because user-facing top-level IA no longer says Insights.

## Display Name Versus Internal Seam Rule

User-facing product language should preserve `Plan` as the visible top-level planning surface. Internal `Insights` symbols may remain when they preserve routing, payloads, historical tests, external assumptions, review/history behavior, or contextual intelligence. A file/type/folder rename is not required for user-facing canon compliance.

## Required Validation Commands

For CS03A:

- `git status --short`
- `git diff --check`
- `grep -R "CS03A\\|CS03B\\|CS03C\\|Insights/Plan Compatibility\\|Insights-To-Plan Compatibility" docs .codex | cat || true`
- `grep -R "Insights Compatibility Retirement" docs/codex/batches docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md docs/codex/BATCH_REGISTRY.md | cat || true`
- `grep -R "AppTab.insights\\|InsightsRouteTarget\\|insights.*Plan\\|Plan.*insights\\|defaultTab\\|selectedTab\\|accessibilityIdentifier" docs/audits docs/codex/batches .codex | cat || true`
- `grep -R "App Store ready\\|TestFlight ready\\|production ready\\|physical device passed\\|Insights seam retired\\|Plan migration complete\\|AmbitionsOS implemented" README.md docs .codex | cat || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

For CS03B/CS03C when implementation or tests are touched:

- the CS03A commands above
- focused app tab routing tests
- focused default/selected tab compatibility tests, if present
- focused shell navigation tests
- focused external routing tests
- focused accessibility identifier expectations, if identifiers are touched
- tests around `InsightsRouteTarget`, if the route target is touched
- `scripts/build-local.sh || true` when production app code changes

## Green / Yellow / Red Criteria

Green: replacement/compatibility map is complete, old payloads still open, focused compatibility proof passes when implementation/tests are touched, rollback exists, contextual-intelligence semantics are preserved or owned, and no release/platform claim is introduced.

Yellow: a nonblocking legacy seam remains intentionally preserved with owner; current repo maps legacy `insights` toward You/Profile history rather than Plan and this is documented as a source-truth adjustment; docs/tooling backlog is advisory only.

Red: broad Insights-to-Plan rename, route/deep-link uncertainty, raw-value uncertainty, default/persistence uncertainty, `InsightsRouteTarget` deletion without proof, accessibility identifier mismatch, duplicate Insights/Plan destination, contextual-intelligence semantic deletion, public copy regression, deletion before proof, weakened tests, or release claim ambiguity.

## Stop Conditions

Stop on any Red, missing seam owner, legacy payload failure, unclassified UI/test failure, migration uncertainty, missing rollback path, production Swift touch during CS03A, or request to retire adjacent seams.

## Rollback / Repair Expectations

Preserve old values until proof is Green. CS03A rolls back by reverting docs/control files only. CS03B and CS03C must document the exact files and compatibility shims to retain or revert before implementation starts.

## Claims

CS03A may claim the Insights seam has been inventoried, compatibility ledgers exist, contextual-intelligence semantics are mapped, and the original broad prompt has been repaired into a staged compatibility path.

CS03B may claim only the specific compatibility behaviors proven by focused tests.

CS03C may claim only the specific internal names retired with proof.

## Non-Claims

CS03 must not claim the Insights seam is retired, Plan migration complete, `InsightsRouteTarget` replaced, accessibility identifiers renamed, physical-device proof, release readiness, App Store readiness, TestFlight readiness, public accessibility conformance, PXOS implementation, Signature Interface implementation, Product Depth implementation, or AmbitionsOS implementation unless matching evidence exists.

## Commit Message Recommendation

CS03A: `Repair CS03 Insights-to-Plan compatibility seam scope`

CS03B: `Preserve Insights compatibility while supporting Plan surface naming`

CS03C: `Retire safe Insights internals after Plan compatibility proof`

## Next Safe Prompt / Next Gate

After CS03A validates, commits, and pushes, run the CS03B dry-run. Continue only if it says `Execution allowed: YES`. After CS03B is Green or accepted Yellow, update status docs, commit/push, run drift checks, and select the next eligible global batch.
