# CS02 Profile To You Compatibility Seam Repair Prompt

Status: Repaired Ambitions 4.0 compatibility batch; internally staged under global order `041`; CS02A is docs/protocol, CS02B is narrow compatibility proof, CS02C is blocked retirement.

## Batch Identity

- Formal batch ID: `CS02`
- Formal global order: `041`
- Repaired name: Profile-To-You Compatibility Seam Repair And Narrow Retirement
- Formal batch count impact: none; the Ambitions 4.0 order remains `113 formal batches`.
- Internal stages:
  - `CS02A` Profile/You Compatibility Map And Migration Design.
  - `CS02B` User-Facing You Alias And Compatibility Preservation.
  - `CS02C` Narrow Internal Naming Retirement, blocked until CS02A and CS02B are Green or accepted Yellow.

## Why CS02 Was Repaired

The original retirement prompt was too broad for the current repo. `Profile` is not a single removable name. It is currently part of route/raw-value compatibility, shell selection, feature owner names, accessibility identifiers, tests, previews, default-tab behavior, and external-route assumptions. User-facing canon already says `You` where the top-level tab is visible, while internal compatibility seams still intentionally use `profile`.

CS02 must therefore preserve `You` as product language without deleting `profile` compatibility.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_4_0_Execution_Program.md`
- `docs/canon/PXOS_Surface_Hierarchy_And_Navigation.md`
- `docs/canon/PXOS_Visual_Interaction_System.md`
- `docs/canon/Ambitions_Signature_Interface_System.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `.codex/skills/compatibility-migration-architect.md`
- `docs/audits/cs02-profile-you-compatibility-seam-inventory.md`
- `docs/audits/cs02-profile-you-compatibility-contract-ledger.md`
- `docs/audits/cs02-profile-you-accessibility-identifier-ledger.md`

## Mandatory Dry-Run Selection

Before each internal stage, report:

- selected stage
- allowed files
- forbidden files
- required gates
- expected validation strength
- route/raw-value risk
- default-tab/persistence risk
- accessibility identifier risk
- whether execution is allowed

Do not edit files unless the dry-run says `Execution allowed: YES`.

## Display Name Versus Internal Seam Rule

- User-facing top-level product language should say `You`.
- Internal `Profile` symbols may remain when tied to routing, persistence, feature ownership, historical tests, accessibility identifiers, or external assumptions.
- A file/type/folder rename is not required for user-facing canon compliance.
- `AppTab.profile.rawValue` must remain compatible with `profile` unless a compatibility parser, migration proof, and rollback path exist.
- Accessibility identifiers are compatibility surfaces and must remain stable unless alias/deprecation proof exists.
- CS02 Green or accepted Yellow may leave internal `Profile` names intentionally preserved.

## CS02A Profile/You Compatibility Map And Migration Design

Type: docs/audit/protocol only.

Purpose: Define the compatibility seam, migration plan, accessibility identifier freeze policy, route/default proof requirements, and rollback plan before any code rename.

Allowed files:

- `docs/audits/cs02-profile-you-compatibility-seam-inventory.md`
- `docs/audits/cs02-profile-you-compatibility-contract-ledger.md`
- `docs/audits/cs02-profile-you-accessibility-identifier-ledger.md`
- `docs/audits/cs02-profile-you-compatibility-seam-split-report.md`
- `docs/codex/batches/CS02_Profile_To_You_Internal_Naming_Retirement_Prompt.md`
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
- `Sources/**`
- `AppUI/**`
- tests
- workflows
- dependencies/lockfiles
- Xcode/project/signing/build config
- persistence/schema files
- route/raw-value implementation
- accessibility identifier implementation
- product behavior
- visual redesign
- release/platform claims

Green criteria:

- Seam inventory exists and classifies all relevant Profile/You seams.
- Compatibility contract ledger exists and names safe actions, unsafe actions, proof, and owner batch.
- Accessibility identifier ledger exists and freezes existing `profile.*` identifiers until proof.
- Original broad-retirement Red is repaired at prompt/protocol level.
- No production Swift or tests are edited.
- CS02B has a narrow executable proof plan.

## CS02B User-Facing You Alias And Compatibility Preservation

Type: narrow compatibility proof; test/code only if CS02A says the exact change is safe.

Purpose: Prove that visible `You` naming and old `profile` compatibility coexist without creating duplicate destinations or changing shell behavior.

Allowed files:

- Focused app shell / external routing / Profile or You tests.
- Narrow non-breaking display helpers or parser aliases only if current repo evidence proves they reduce migration risk.
- CS02 audit/report/status files.

Forbidden:

- deleting `AppTab.profile`
- changing `AppTab.profile.rawValue`
- changing persisted/default selected-tab semantics without migration proof
- renaming `Native/Ambitions/Features/Profile`
- renaming `ProfileScreen`, `ProfileFeatureService`, `ProfileModels`, or broad symbols
- changing accessibility identifiers
- adding a new top-level tab or destination
- changing visible product behavior beyond proven `You` display helpers
- weakening tests

Required proof:

- `AppTab(rawValue: "profile")` resolves to `.profile`.
- `.profile.title` remains `You`.
- legacy external tab route `profile` resolves to the You surface.
- no visible top-level `Profile` tab exists.
- no duplicate `Profile` and `You` destinations exist.
- selected-tab/default-tab behavior is unchanged or explicitly proven compatible.

Green criteria:

- Old `profile` route/default assumptions remain compatible.
- User-facing `You` canon is preserved.
- Focused tests pass.
- No route/raw-value/persistence/accessibility identifier break occurs.

## CS02C Narrow Internal Naming Retirement

Type: blocked narrow implementation.

Purpose: Retire only internal `Profile` symbols that CS02A and CS02B prove are local, non-persistent, non-route, non-accessibility, non-external, and safe.

Allowed:

- small local internal type/file renames with full call-site and test proof.
- staged typealias/wrapper only when it reduces migration risk.
- report/status updates.

Forbidden:

- broad Profile-to-You rename
- route/raw-value changes
- deletion of compatibility aliases before proof
- accessibility identifier renames
- feature-folder churn without proof
- product behavior changes
- visual redesign

CS02C is not required for user-facing `You` compliance. It remains blocked until CS02B proof is Green and the owner file list is exact.

## Required Validation Commands

CS02A:

- `git status --short`
- `git diff --check`
- `grep -R "CS02A\\|CS02B\\|CS02C\\|Profile/You Compatibility\\|Profile-To-You Compatibility" docs .codex | cat || true`
- `grep -R "Profile To You Internal Naming Retirement" docs/codex/batches docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md docs/codex/BATCH_REGISTRY.md | cat || true`
- `grep -R "AppTab.profile\\|profile.*You\\|You.*profile\\|defaultTab\\|selectedTab\\|accessibilityIdentifier" docs/audits docs/codex/batches .codex | cat || true`
- `grep -R "App Store ready\\|TestFlight ready\\|production ready\\|physical device passed\\|Profile seam retired\\|You migration complete" README.md docs .codex | cat || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

CS02B/CS02C add focused tests for app tab routing, default/selected tab compatibility, shell navigation, Profile/You tests, accessibility identifier expectations, and existing UI tests that select the You/Profile surface when those files are touched.

## Green / Yellow / Red Criteria

Green:

- CS02A ledgers and repair report exist.
- CS02B proof passes if implementation/test proof is attempted.
- old `profile` compatibility is preserved.
- user-facing `You` canon is preserved.
- no unsupported release/platform claim is introduced.
- no forbidden files are touched.

Yellow:

- internal `Profile` names remain intentionally as compatibility seams with CS02C or CS10 owner.
- UI automation coverage gap is documented with owner and does not weaken route/raw/default safety.
- existing repo-wide docs QA backlog remains advisory.

Red:

- broad rename attempted.
- route/raw value changed without compatibility proof.
- persisted/default-tab behavior changed without proof.
- accessibility identifiers changed without proof.
- duplicate Profile and You destinations created.
- visible top-level tab regresses from `You` to `Profile`.
- production Swift touched during CS02A.
- tests weakened.
- CS02 marked fully retired without proof.

## Stop Conditions

Stop on unresolved Red, unsafe dirty tree, missing inventory/ledger, route/raw/default uncertainty, accessibility identifier uncertainty, forbidden file touch, weak implementation validation, unsupported claim, or inability to identify the next narrowed CS02 action.

## Rollback And Repair

CS02A rollback is a docs/control revert. CS02B rollback must preserve any compatibility parser/helper that protects old `profile` values until an equivalent proof exists. CS02C rollback must restore old internal symbols and keep aliases if external/test/accessibility seams depended on them.

## Claims

CS02 may claim only that Profile/You compatibility seams are mapped, that user-facing `You` remains canonical, and that old `profile` compatibility remains preserved when focused proof passes.

## Non-Claims

CS02 must not claim the Profile seam is retired, You migration complete, release readiness, App Store readiness, TestFlight readiness, physical-device proof, signed archive proof, public accessibility conformance, PXOS implementation, Signature Interface implementation, Product Depth implementation, or AmbitionsOS implementation.

## Commit Messages

- CS02A: `Repair CS02 Profile-to-You compatibility seam scope`
- CS02B: `Preserve Profile compatibility while supporting You surface naming`
- CS02C: `Retire safe Profile internals after You compatibility proof`

## Next Safe Path

After CS02A is committed and pushed, dry-run CS02B. After CS02B is Green or accepted Yellow and committed, either leave CS02C blocked with owner evidence or execute CS02C only if its dry-run says `Execution allowed: YES`. Continue to CS03 only after CS02 is Green or accepted Yellow and post-commit drift checks pass.
