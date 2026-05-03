# CS05 ActiveFocus TodayFocus Retirement Prompt

<!-- markdownlint-disable MD013 -->

Status: Repaired Ambitions 4.0 compatibility batch; internally staged under formal global order `044`; CS05A is the next docs/protocol repair stage; CS05B may run only after CS05A is Green or accepted Yellow and dry-run says `Execution allowed: YES`; CS05C is blocked until CS05A and CS05B prove narrow retirement is safe.

## Batch Identity

- Formal batch ID: `CS05`
- Name: ActiveFocus TodayFocus Retirement
- Compatibility action: staged map/prove/retire
- Candidate seam: `activeFocus`, `TodayFocus*`, `.focus` Today entry context, FocusNow widget/App Intent compatibility, and external Today snapshot focus payloads.
- Global order number: `044`
- Formal batch count impact: none; CS05A, CS05B, and CS05C are internal stages of formal CS05, so the Ambitions 4.0 total remains `113 formal batches`.

## Repair Context

The original CS05 direct retirement dry-run returned `Execution allowed: NO` because ActiveFocus/TodayFocus is not a narrow deletion seam. Current repo truth shows:

- `activeFocus` is a live external snapshot/schema field in `CanonicalNowState`, `ExternalSurfaceNowState`, action payload projection, widget projection, and legacy snapshot decode tests.
- `TodayFocusState` and related `TodayFocus*` models are broad Today feature state/service seams, not isolated naming debris.
- `.focus` is used by shell command routing, Today entry context, App Intents, shortcut routes, external routing, and contextual return behavior.
- `FocusNowWidget` and `focusNow` are AppUI/widget compatibility surfaces.
- Current product direction prefers Today step/Step Session language, but old `focus` compatibility values must remain stable until a schema-versioned adapter, route adapter, widget migration, and focused test proof exist.

Therefore CS05 must not delete, rename, or retire `activeFocus`, `TodayFocus*`, `.focus`, or FocusNow symbols until compatibility proof is stronger than the seam being removed.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md`
- `docs/canon/Ambitions_3_0_Content_QA_And_Copy_Guard.md`
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
- CS01, CS07, CS08, CS02, CS03, and CS04 compatibility reports and ledgers.
- `.codex/skills/compatibility-migration-architect.md`

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `rg -n "activeFocus|TodayFocus|\\.focus|context=focus|quick_focus|focusNow|FocusNowWidget|ExternalSurfaceNowState|NowActionKind\\.focus" Native AppUI Sources docs .codex || true`
- `rg -n "accessibilityIdentifier|accessibility\\(identifier" Native AppUI Sources || true`
- `rg -n "defaultTab|selectedTab|preferredTab|rawValue|AppTab|TodayEntryContext|ExternalRoute|AppIntent|Widget" Native AppUI Sources || true`
- `find Native AppUI Sources -iname "*Focus*" -o -iname "*Today*" | sort`

Stop if predecessor CS gates are not Green or accepted Yellow, if the seam owner is unclear, if source truth conflicts would cause implementation risk, or if route/raw/default/accessibility/external/persistence/import/export/widget/App Intent impact cannot be mapped.

## CS05A — ActiveFocus/TodayFocus Compatibility Map And Retirement Ledger

Type: docs/audit/protocol only.

Purpose: define the compatibility seam, schema contract, route/App Intent/widget compatibility map, Today state owner map, test strategy, rollback path, and allowed retirement sequence.

Allowed files:

- `docs/audits/cs05-activefocus-todayfocus-compatibility-seam-inventory.md`
- `docs/audits/cs05-activefocus-todayfocus-compatibility-contract-ledger.md`
- `docs/audits/cs05-activefocus-todayfocus-accessibility-route-payload-ledger.md`
- `docs/audits/cs05-activefocus-todayfocus-retirement-risk-map.md`
- `docs/audits/cs05-activefocus-todayfocus-compatibility-seam-split-report.md`
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
- `AppUI/**`
- `Sources/**`
- production Swift
- tests
- route/raw values
- persistence/defaults
- accessibility identifiers
- dependencies/lockfiles/workflows
- release/platform claim docs unrelated to CS05 status truth

Green criteria:

- Full ActiveFocus/TodayFocus seam inventory exists.
- Compatibility contract ledger exists.
- Accessibility/route/payload ledger exists.
- Retirement risk map exists.
- Original CS05 prompt is repaired into staged execution.
- No production code, AppUI code, Sources code, or tests are touched.
- No route/raw/default/persistence/accessibility/widget/App Intent behavior changes occur.
- CS05B is narrow enough to dry-run safely.

## CS05B — ActiveFocus Compatibility Preservation Proof

Type: focused compatibility proof implementation only if dry-run says `Execution allowed: YES`.

Purpose: prove current Today step semantics and legacy `activeFocus` / `.focus` / FocusNow compatibility can coexist without schema drift, external payload break, widget/App Intent break, duplicate route behavior, accessibility identifier break, or product-language regression.

Allowed files:

- Focused external snapshot tests.
- Focused external action payload tests.
- Focused external widget projection tests.
- Focused App Intent and external routing tests.
- Focused app shell command routing tests.
- Focused Today feature service/model tests.
- Focused compatibility fixtures for old `activeFocus`, `.focus`, `quick_focus`, `focusNow`, and external Today payload values, if already supported by repo test conventions.
- CS05B audit/report/status docs.

Production Swift may be edited only if CS05B dry-run identifies a specific, compatibility-preserving adapter gap that cannot be proven by tests alone. Any production change must be narrowly limited to additive route/schema/display compatibility helpers and must preserve old raw values and old JSON keys.

Forbidden work:

- Deleting or renaming `activeFocus`.
- Deleting or renaming `ExternalSurfaceNowState.activeFocus`.
- Deleting or renaming `TodayFocusState` or related `TodayFocus*` models.
- Deleting `.focus` route contexts.
- Deleting `quick_focus`, `focusNow`, or `FocusNowWidget`.
- Changing raw values without migration proof.
- Changing selected/default/preferred-tab persistence without fallback proof.
- Changing accessibility identifiers without alias/deprecation proof.
- Creating duplicate focus and Step Session destinations.
- Changing shell navigation behavior except to preserve compatibility.
- Weakening tests.

Green criteria:

- Old `activeFocus` payloads and external snapshots still decode and project.
- Old `.focus` external routes, App Intent routes, and shell quick-focus commands still resolve to the current Today-compatible step posture.
- Current user-facing Today canon remains Step/Start-now oriented and does not reintroduce `Start Focus` or fake Focus-mode product language on active app surfaces.
- FocusNow widget compatibility remains stable or is explicitly mapped with proof.
- Focused route/shell/external/Today/widget tests pass.
- Accessibility identifiers are unchanged or explicitly aliased with proof.
- Default/preferred-tab behavior is unchanged or proven compatible.

## CS05C — Narrow Internal Today Focus Retirement

Type: implementation, blocked until CS05A and CS05B are Green or accepted Yellow.

Purpose: retire only internal Focus names that are proven safe and not part of external snapshot schema, routes, raw values, persistence/defaults, accessibility identifiers, widgets, App Intents, tests, previews, Today state ownership, or compatibility.

Allowed work:

- Small internal type/file renames where all references are local and focused tests prove no behavior change.
- Deprecated aliases or wrappers where migration risk remains.
- Schema-versioned adapters for external payloads, only if CS05B proof has already established old payload compatibility.
- CS05C report/status docs.

Forbidden work:

- Broad Focus-to-Step-Session rename.
- Route/raw/default/accessibility break.
- External snapshot `activeFocus` deletion without schema-versioned compatibility proof.
- Removing aliases prematurely.
- Deleting FocusNow widget compatibility without proof.
- Behavior changes.
- Today step semantic deletion.
- Folder/type churn without proof.

Green criteria:

- No compatibility break.
- No route/default/accessibility/persistence/widget/App Intent break.
- No external snapshot schema break.
- No Today step semantic loss.
- Focused tests pass.
- Diff stays narrow and reviewable.
- Rollback path is clear.

## Required Route, Schema, And Compatibility Proof Matrix

| Input / legacy assumption | Expected resolution | Required proof |
| --- | --- | --- |
| External snapshot key `activeFocus` | Old JSON decodes; new projection preserves compatible key or schema-versioned adapter. | CS05B external snapshot test |
| `CanonicalNowState.activeFocus` | Current runtime projection remains compatible with `bestNextStep` fallback. | CS05B domain/projection test |
| `ExternalSurfaceNowState.activeFocus` | External contract remains stable. | CS05B contract decode/encode test |
| `ExternalSurfaceActionPayload` primary reference fallback | `activeFocus ?? bestNextStep` behavior remains or is migrated with proof. | CS05B action payload test |
| `.focus` Today entry context | Opens the current Today-compatible step posture. | CS05B shell/navigation test |
| `ambitions://tab/today?context=focus` | Compatible legacy external route. | CS05B external route test |
| App Intent / shortcut quick focus route | Compatible Today route behavior. | CS05B App Intent route test |
| Shell command `quick_focus` | Compatible quick command behavior and receipt. | CS05B shell command test |
| Widget family `focusNow` / `FocusNowWidget` | Compatible widget projection or documented adapter path. | CS05B widget projection test |
| Duplicate Focus/Step Session destination | Must not exist. | CS05B shell/display proof |
| User-facing active app copy | Must prefer `Start now`, Step, and Step Session where the current surface is user-facing. | CS05B copy scan/test |

## Accessibility Identifier Freeze Policy

Accessibility identifiers and automation-facing labels are compatibility surfaces. CS05 must inventory every `focus`, `today`, `widget`, action-payload, and route-adjacent identifier it touches, keep old identifiers stable unless an alias/deprecation strategy exists, and update tests only in the batch that explicitly owns proof.

## Today Step Semantics Preservation Rule

`Focus` may mean legacy route compatibility, external snapshot schema, widget family naming, App Intent compatibility, shell quick command naming, or internal Today state. Do not delete a Focus symbol merely because user-facing 3.0 product language prefers Step Session.

## Display Name Versus Internal Seam Rule

User-facing Today product language should not restore `Start Focus` or a generic Focus-mode product. Internal `activeFocus`, `TodayFocus*`, `.focus`, and FocusNow symbols may remain when they preserve routing, payloads, historical tests, widgets, external assumptions, or compatibility identifiers. A file/type/folder rename is not required for user-facing canon compliance.

## Required Validation Commands

For CS05A:

- `git status --short`
- `git diff --check`
- `grep -R "CS05A\\|CS05B\\|CS05C\\|ActiveFocus/TodayFocus Compatibility\\|ActiveFocus TodayFocus Compatibility" docs .codex | cat || true`
- `grep -R "ActiveFocus TodayFocus Retirement" docs/codex/batches docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md docs/codex/BATCH_REGISTRY.md | cat || true`
- `grep -R "activeFocus\\|TodayFocus\\|context=focus\\|quick_focus\\|focusNow\\|FocusNowWidget\\|ExternalSurfaceNowState\\|accessibilityIdentifier" docs/audits docs/codex/batches .codex | cat || true`
- `grep -R "App Store ready\\|TestFlight ready\\|production ready\\|physical device passed\\|activeFocus seam retired\\|TodayFocus migration complete\\|AmbitionsOS implemented" README.md docs .codex | cat || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

For CS05B/CS05C when implementation or tests are touched:

- the CS05A commands above
- focused external snapshot tests
- focused external action payload tests
- focused external widget projection tests
- focused App Intent routing tests
- focused external routing tests
- focused shell command routing tests
- focused Today feature state/service tests
- focused accessibility identifier expectations, if identifiers are touched
- `scripts/build-local.sh || true` when production app code changes

## Green / Yellow / Red Criteria

Green: replacement/compatibility map is complete, old payloads still open, focused compatibility proof passes when implementation/tests are touched, rollback exists, Today step semantics are preserved or owned, and no release/platform claim is introduced.

Yellow: a nonblocking legacy seam remains intentionally preserved with owner; internal `activeFocus`, `TodayFocus*`, `.focus`, `focusNow`, or FocusNow names remain because they are route/raw/schema/widget/test/domain compatibility surfaces; docs/tooling backlog is advisory only.

Red: broad Focus-to-Step-Session rename, route/deep-link uncertainty, raw-value uncertainty, default/persistence uncertainty, external snapshot schema uncertainty, `activeFocus` deletion without proof, FocusNow widget deletion without proof, accessibility identifier mismatch, duplicate Focus/Step Session destination, Today step semantic deletion, public copy regression, deletion before proof, weakened tests, or release claim ambiguity.

## Stop Conditions

Stop on any Red, missing seam owner, legacy payload failure, unclassified UI/test failure, migration uncertainty, missing rollback path, production Swift/AppUI/Sources touch during CS05A, or request to retire adjacent seams.

## Rollback / Repair Expectations

Preserve old values until proof is Green. CS05A rolls back by reverting docs/control files only. CS05B and CS05C must document the exact files and compatibility shims to retain or revert before implementation starts.

## Claims

CS05A may claim the ActiveFocus/TodayFocus seam has been inventoried, compatibility ledgers exist, retirement risk is mapped, and the original broad prompt has been repaired into a staged compatibility path.

CS05B may claim only the specific compatibility behaviors proven by focused tests.

CS05C may claim only the specific internal names retired with proof.

## Non-Claims

CS05 must not claim the activeFocus seam is retired, TodayFocus migration complete, FocusNow widget migration complete, `.focus` route replaced, external snapshot schema migrated, accessibility identifiers renamed, physical-device proof, release readiness, App Store readiness, TestFlight readiness, public accessibility conformance, PXOS implementation, Signature Interface implementation, Product Depth implementation, or AmbitionsOS implementation unless matching evidence exists.

## Commit Message Recommendation

- CS05A: `Repair CS05 ActiveFocus TodayFocus compatibility seam scope`
- CS05B: `Preserve activeFocus compatibility while supporting Today step semantics`
- CS05C: `Retire safe Today focus internals after compatibility proof`

## Next Safe Prompt / Next Gate

After CS05A is Green or accepted Yellow, run CS05B dry-run. Continue only if `Execution allowed: YES`. CS05C remains blocked until CS05B proves a narrow retirement is safe.
