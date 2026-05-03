# CS04 Habits Ritual Plan Compatibility Retirement Prompt

<!-- markdownlint-disable MD013 -->

Status: Repaired Ambitions 4.0 compatibility batch; internally staged under formal global order `043`; CS04A is the next docs/protocol repair stage; CS04B may run only after CS04A is Green or accepted Yellow and dry-run says `Execution allowed: YES`; CS04C is blocked until CS04A and CS04B prove narrow retirement is safe.

## Batch Identity

- Formal batch ID: `CS04`
- Name: Habits Ritual Plan Compatibility Retirement
- Compatibility action: staged map/prove/retire
- Candidate seam: `Habits` route/model/raw/default/accessibility compatibility for Ritual/Plan continuity.
- Global order number: `043`
- Formal batch count impact: none; CS04A, CS04B, and CS04C are internal stages of formal CS04, so the Ambitions 4.0 total remains `113 formal batches`.

## Repair Context

The original CS04 direct retirement dry-run returned `Execution allowed: NO` because Habits/Ritual/Plan is not a narrow deletion seam. Current repo truth shows:

- `Habits` is not a visible top-level tab.
- `AppTab.habits` remains a hidden raw compatibility value.
- Current navigation normalizes `.habits` to `.plan` and opens `planPath = [.habits]`.
- Plan owns the visible support route titled `Rituals`.
- `PlanRouteTarget.habits`, `ambitions://tab/habits`, `ambitions://plan/habits`, widget/notification `tab=habits`, `habits.*` accessibility identifiers, Habits feature/domain files, Ritual models/services, and Plan support-route copy are live compatibility surfaces.

Therefore CS04 must not delete, rename, or retire Habits symbols until compatibility proof is stronger than the seam being removed.

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
- CS01, CS07, CS08, CS02, and CS03 compatibility reports and ledgers.
- `.codex/skills/compatibility-migration-architect.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `rg -n "AppTab.habits|\\.habits|PlanRouteTarget|HabitsScreen|HabitsFeatureService|HabitsModels|RitualModels|RitualOrchestrationService|HabitGoalSemantics" Native docs .codex || true`
- `rg -n "habits|Habits|ritual|Ritual|plan|Plan" Native/AmbitionsTests Native/AmbitionsUITests docs/codex docs/canon .codex || true`
- `rg -n "accessibilityIdentifier|accessibility\\(identifier" Native || true`
- `rg -n "defaultTab|selectedTab|preferredTab|rawValue|AppTab|PlanRouteTarget" Native || true`
- `find Native -iname "*Habit*" -o -iname "*Ritual*" -o -iname "*Plan*" | sort`

Stop if predecessor CS gates are not Green or accepted Yellow, if the seam owner is unclear, if source truth conflicts would cause implementation risk, or if route/raw/default/accessibility/external/persistence/import/export impact cannot be mapped.

## CS04A — Habits/Ritual/Plan Compatibility Map And Retirement Ledger

Type: docs/audit/protocol only.

Purpose: define the compatibility seam, migration plan, aliases, Ritual/Plan semantics, test strategy, rollback path, and allowed retirement sequence.

Allowed files:

- `docs/audits/cs04-habits-ritual-plan-compatibility-seam-inventory.md`
- `docs/audits/cs04-habits-ritual-plan-compatibility-contract-ledger.md`
- `docs/audits/cs04-habits-ritual-plan-accessibility-identifier-ledger.md`
- `docs/audits/cs04-habits-ritual-plan-retirement-risk-map.md`
- `docs/audits/cs04-habits-ritual-plan-compatibility-seam-split-report.md`
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
- release/platform claim docs unrelated to CS04 status truth

Green criteria:

- Full Habits/Ritual/Plan seam inventory exists.
- Compatibility contract ledger exists.
- Accessibility identifier ledger exists.
- Retirement risk map exists.
- Original CS04 prompt is repaired into staged execution.
- No production code or tests are touched.
- No route/raw/default/persistence/accessibility behavior changes occur.
- CS04B is narrow enough to dry-run safely.

## CS04B — Ritual/Plan Compatibility Preservation Proof

Type: focused compatibility proof implementation only if dry-run says `Execution allowed: YES`.

Purpose: prove current visible Ritual/Plan canon and legacy `habits` compatibility can coexist without duplicate destinations, route/raw/default/persistence drift, accessibility identifier break, or product-semantic loss.

Allowed files:

- Focused app shell/navigation tests.
- Focused external routing tests.
- Focused Plan/Habits/Ritual service tests.
- Focused compatibility fixtures for legacy `habits` values, if already supported by repo test conventions.
- CS04B audit/report/status docs.

Production Swift may be edited only if CS04B dry-run identifies a specific, compatibility-preserving adapter gap that cannot be proven by tests alone. Any production change must be narrowly limited to route/default/display compatibility helpers and must preserve old raw values.

Forbidden work:

- Deleting `AppTab.habits`.
- Deleting `PlanRouteTarget.habits`.
- Broad Habits-to-Rituals or Habits-to-Plan rename.
- Renaming Habits folders/types.
- Changing route raw values without migration proof.
- Changing selected/default/preferred-tab persistence without fallback proof.
- Changing accessibility identifiers without alias/deprecation proof.
- Creating duplicate `Habits` and `Rituals` top-level destinations.
- Changing shell navigation behavior except to preserve compatibility.
- Weakening tests.

Green criteria:

- Old `habits` raw values and external routes still resolve to the current Plan-owned Rituals support surface.
- Visible top-level tabs remain `Today / Goals / Capture / Plan / You`.
- No visible top-level `Habits` tab appears.
- `PlanRouteTarget.habits` remains compatible or is safely delegated with proof.
- Focused route/shell/external/Plan/Habits tests pass.
- Accessibility identifiers are unchanged or explicitly aliased with proof.
- Default/preferred-tab behavior is unchanged or proven compatible.

## CS04C — Narrow Internal Habits Retirement

Type: implementation, blocked until CS04A and CS04B are Green or accepted Yellow.

Purpose: retire only internal Habits names that are proven safe and not part of routes, raw values, persistence/defaults, accessibility identifiers, external assumptions, Ritual/Plan semantics, tests, previews, or compatibility.

Allowed work:

- Small internal type/file renames where all references are local and focused tests prove no behavior change.
- Deprecated aliases or wrappers where migration risk remains.
- CS04C report/status docs.

Forbidden work:

- Broad rename.
- Route/raw/default/accessibility break.
- Removing aliases prematurely.
- Deleting `PlanRouteTarget.habits` without proof.
- Behavior changes.
- Ritual/Plan semantic deletion.
- Folder/type churn without proof.

Green criteria:

- No compatibility break.
- No route/default/accessibility/persistence break.
- No Ritual/Plan semantic loss.
- Focused tests pass.
- Diff stays narrow and reviewable.
- Rollback path is clear.

## Required Route And Compatibility Proof Matrix

| Input / legacy assumption | Expected resolution | Required proof |
| --- | --- | --- |
| `habits` raw tab value | `AppTab.habits`; canonical top-level `.plan`; Plan route `.habits` opens. | CS04B shell/navigation test |
| `PlanRouteTarget.habits` usage | Compatible Plan-owned Rituals route behavior. | CS04B app navigation and Plan tests |
| `ambitions://tab/habits` | Compatible legacy tab handling without visible Habits tab. | CS04B external route test |
| `ambitions://plan/habits` | Compatible Plan support route. | CS04B external route test |
| Widget/notification payload `tab=habits` | Compatible legacy payload handling. | CS04B external route test |
| Preferred/default tab `.habits` | Canonicalizes to `.plan` without storing a visible Habits default. | CS04B shell/default proof |
| Unknown route value | Safe fallback. | Existing external routing proof or CS04B added proof |
| Duplicate Habits/Rituals top-level destination | Must not exist. | Shell test |
| User-facing tab labels | Must remain `Today / Goals / Capture / Plan / You`; route copy may say `Rituals`. | Shell/display proof |

## Accessibility Identifier Freeze Policy

Accessibility identifiers are compatibility surfaces. CS04 must inventory every `habits.*`, `plan.*`, and route-adjacent identifier, keep old identifiers stable unless an alias/deprecation strategy exists, and update tests only in the batch that explicitly owns proof.

## Ritual/Plan Semantics Preservation Rule

`Habits` may mean legacy route compatibility, internal domain/support models, a Plan-owned Rituals route, recurring goal semantics, external snapshot ritual cues, or future PD/SI/AOS-owned recurring-loop expression. Do not delete a `Habits` symbol merely because user-facing top-level IA no longer says Habits.

## Display Name Versus Internal Seam Rule

User-facing top-level product language should not restore a top-level `Habits` tab. Plan may expose a support route titled `Rituals`. Internal `Habits` symbols may remain when they preserve routing, payloads, historical tests, recurring-goal semantics, external assumptions, or accessibility identifiers. A file/type/folder rename is not required for user-facing canon compliance.

## Required Validation Commands

For CS04A:

- `git status --short`
- `git diff --check`
- `grep -R "CS04A\\|CS04B\\|CS04C\\|Habits/Ritual/Plan Compatibility\\|Habits Ritual Plan Compatibility" docs .codex | cat || true`
- `grep -R "Habits Ritual Plan Compatibility Retirement" docs/codex/batches docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md docs/codex/BATCH_REGISTRY.md | cat || true`
- `grep -R "AppTab.habits\\|PlanRouteTarget.habits\\|habits.*Ritual\\|Ritual.*habits\\|defaultTab\\|preferredTab\\|selectedTab\\|accessibilityIdentifier" docs/audits docs/codex/batches .codex | cat || true`
- `grep -R "App Store ready\\|TestFlight ready\\|production ready\\|physical device passed\\|Habits seam retired\\|Ritual/Plan migration complete\\|AmbitionsOS implemented" README.md docs .codex | cat || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

For CS04B/CS04C when implementation or tests are touched:

- the CS04A commands above
- focused app tab routing tests
- focused default/preferred/selected tab compatibility tests
- focused shell navigation tests
- focused external routing tests
- focused Plan/Habits/Ritual service tests
- focused accessibility identifier expectations, if identifiers are touched
- tests around `PlanRouteTarget.habits`, if the route target is touched
- `scripts/build-local.sh || true` when production app code changes

## Green / Yellow / Red Criteria

Green: replacement/compatibility map is complete, old payloads still open, focused compatibility proof passes when implementation/tests are touched, rollback exists, Ritual/Plan semantics are preserved or owned, and no release/platform claim is introduced.

Yellow: a nonblocking legacy seam remains intentionally preserved with owner; internal `Habits` names remain because they are route/raw/accessibility/test/domain compatibility surfaces; docs/tooling backlog is advisory only.

Red: broad Habits-to-Rituals or Habits-to-Plan rename, route/deep-link uncertainty, raw-value uncertainty, default/persistence uncertainty, `PlanRouteTarget.habits` deletion without proof, accessibility identifier mismatch, duplicate Habits/Rituals destination, recurring-loop semantic deletion, public copy regression, deletion before proof, weakened tests, or release claim ambiguity.

## Stop Conditions

Stop on any Red, missing seam owner, legacy payload failure, unclassified UI/test failure, migration uncertainty, missing rollback path, production Swift touch during CS04A, or request to retire adjacent seams.

## Rollback / Repair Expectations

Preserve old values until proof is Green. CS04A rolls back by reverting docs/control files only. CS04B and CS04C must document the exact files and compatibility shims to retain or revert before implementation starts.

## Claims

CS04A may claim the Habits/Ritual/Plan seam has been inventoried, compatibility ledgers exist, retirement risk is mapped, and the original broad prompt has been repaired into a staged compatibility path.

CS04B may claim only the specific compatibility behaviors proven by focused tests.

CS04C may claim only the specific internal names retired with proof.

## Non-Claims

CS04 must not claim the Habits seam is retired, Ritual/Plan migration complete, `PlanRouteTarget.habits` replaced, accessibility identifiers renamed, physical-device proof, release readiness, App Store readiness, TestFlight readiness, public accessibility conformance, PXOS implementation, Signature Interface implementation, Product Depth implementation, or AmbitionsOS implementation unless matching evidence exists.

## Commit Message Recommendation

CS04A: `Repair CS04 Habits Ritual Plan compatibility seam scope`

CS04B: `Preserve Habits compatibility while supporting Ritual Plan semantics`

CS04C: `Retire safe Habits internals after Ritual Plan compatibility proof`

## Next Safe Prompt / Next Gate

Continue only to CS04B after CS04A evidence is recorded, committed, pushed, and dry-run selection says `Execution allowed: YES`. Continue beyond formal CS04 only after CS04B is Green or accepted Yellow and CS04C is either complete or explicitly deferred with owner.
