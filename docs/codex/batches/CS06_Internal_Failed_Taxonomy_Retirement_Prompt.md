# CS06 Internal Failed Taxonomy Compatibility Repair Prompt

Status: Formal Ambitions 4.0 compatibility batch `CS06`; internally staged as CS06A/CS06B/CS06C after dry-run Red. CS06A and CS06B/CS06C are internal repair stages only, not new formal batches. Formal Ambitions 4.0 batch count remains `113`.

## Batch Identity

- Batch ID: `CS06`
- Name: Internal Failed Taxonomy Retirement
- Repaired staging: `CS06A` map/ledger, `CS06B` focused proof, `CS06C` narrow retirement only if proven safe
- Candidate seam: `.failed` / `failed` / `failure` taxonomy spanning technical command state, external action state, async UI state, safe-automation receipt state, support/checklist language, copy/accessibility language, tests, logs, and historical docs
- Compatibility action: preserve technical failure semantics first; retire only proven unsafe user-facing language or dead compatibility seams later

## Purpose

Repair CS06 from a broad retirement prompt into a staged compatibility migration. CS06 must separate precise technical failure semantics from user-facing recovery language and historical truth before any rename, deletion, raw-value mutation, or copy change is attempted.

## Source Truth Files To Read First

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Product_Language_System.md`
- `docs/canon/Ambitions_3_0_Action_Verbs_And_Receipt_Grammar.md`
- `docs/canon/Ambitions_3_0_Surface_State_Matrix.md`
- `docs/canon/PXOS_Copy_Language_And_Explanation_System.md`
- `docs/canon/Ambitions_Beyond_3_0_Compatibility_Seam_Retirement_Plan.md`
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/skills/compatibility-migration-architect.md`
- `docs/audits/cs06-failed-taxonomy-compatibility-contract-ledger.md`
- `docs/audits/cs06-failed-taxonomy-copy-accessibility-language-ledger.md`
- `docs/audits/cs06-failed-taxonomy-technical-state-preservation-ledger.md`
- `docs/audits/cs06-failed-taxonomy-historical-docs-truth-ledger.md`
- `docs/audits/cs06-failed-taxonomy-retirement-risk-map.md`

## CS06A - Failed-Taxonomy Compatibility Map And Seam Ledger

Type: docs/protocol only.

Purpose: inventory and classify every meaningful failed/failure seam before code or copy edits.

Allowed files:

- `docs/audits/cs06-failed-taxonomy-compatibility-contract-ledger.md`
- `docs/audits/cs06-failed-taxonomy-copy-accessibility-language-ledger.md`
- `docs/audits/cs06-failed-taxonomy-technical-state-preservation-ledger.md`
- `docs/audits/cs06-failed-taxonomy-historical-docs-truth-ledger.md`
- `docs/audits/cs06-failed-taxonomy-retirement-risk-map.md`
- `docs/audits/cs06a-failed-taxonomy-compatibility-map-report.md`
- This prompt file
- Codex train/status docs under `docs/codex/**`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

Forbidden files:

- `Native/**`
- `Sources/**`
- `AppUI/**`
- Tests, unless only a non-production proof placeholder is explicitly justified
- Dependency manifests, workflows, signing/project release config

CS06A Green criteria:

- Compatibility contract ledger exists.
- User-facing copy/accessibility language ledger exists.
- Technical-state preservation ledger exists.
- Historical-doc truth ledger exists.
- Retirement risk map exists.
- This prompt is repaired into CS06A/CS06B/CS06C staging.
- No production Swift, tests, enum cases, raw values, route values, persistence/default behavior, accessibility identifiers, command behavior, async state behavior, safe-automation behavior, or historical truth is changed.

CS06A Red criteria:

- Production Swift is touched.
- Any enum/raw value, command status, external action outcome, receipt state, log state, accessibility identifier, persisted value, or behavior is changed.
- Historical `.failed` evidence is rewritten as if the historical event did not happen.
- CS06 still instructs broad failed-taxonomy retirement without proof.

## CS06B - Focused Failed-Taxonomy Compatibility Proof

Type: focused proof only.

Purpose: prove technical `.failed` semantics remain stable while user-facing recovery/copy candidates are isolated from technical states.

Allowed files:

- Focused test files proving command execution failure status, external action failure handling, async UI failure/error state behavior, safe-automation receipt failure semantics, and copy/accessibility mapping where testable
- CS06B proof report under `docs/audits/**`
- Codex train/status docs under `docs/codex/**` and `.codex/reports/**`

Forbidden files:

- Production Swift unless the CS06A ledger proves a tiny non-production fixture/helper cannot carry the proof and the change is explicitly justified
- Enum/raw-value changes
- Persistence/default-tab changes
- Accessibility identifier changes
- Broad command, receipt, automation, async-state, copy, or taxonomy refactors

Required proof:

- `AmbitionsCommandExecutionStatus.failed` remains the technical status for invalid commands and thrown command execution errors.
- `ExternalActionOutcome.failed` remains available for true external action failure.
- `AsyncViewState.failed` and launch/bootstrap failure states remain available for true async/load failures.
- `failedSafely`, `safeFailure`, and related receipt raw values remain stable where they mean safe non-execution or safe rollback.
- User-facing copy that should avoid blame is identified without changing behavior.
- Historical docs/logs remain truthful and are not rewritten as current product claims.

## CS06C - Narrow Internal Failed-Taxonomy Retirement

Type: implementation or copy retirement only if CS06A and CS06B prove a seam is safe.

Purpose: retire only seams classified as safe, preserving all technical failure semantics and historical truth.

CS06C is blocked until CS06A and CS06B are Green or accepted Yellow. If no seam is proven safe, CS06C must remain deferred as accepted Yellow.

Allowed changes:

- User-facing copy/accessibility wording classified by CS06A as a rename candidate and proven safe by CS06B
- Dead compatibility aliases classified as safe to retire by CS06A and proven unused by CS06B
- Focused tests and reports proving no behavior, persistence, accessibility, or raw-value break

Forbidden changes:

- Broad failed/failure rename
- Removing `AmbitionsCommandExecutionStatus.failed`, `ExternalActionOutcome.failed`, async `.failed` state, `failedSafely`, `safeFailure`, or persisted receipt raw values without explicit migration proof
- Rewriting historical docs/logs
- Weakening tests
- Expanding into command, receipt, automation, architecture, copywriting, support, accessibility, or repo-wide taxonomy cleanup

## Required Preflight Checks

- `git status --short`
- `git branch --show-current`
- `git rev-parse HEAD`
- `git log -1 --oneline`
- `rg -n "\\.failed|failed|Failed|failure|Failure|safeFailure|failedSafely|unavailableFailed" Native Sources AppUI docs .codex scripts || true`

Stop if predecessor CS gates are not Green or accepted Yellow, if any failed/failure seam cannot be classified, or if a proposed retirement touches raw values, persistence, accessibility, command execution, async UI state, safe-automation receipts, external actions, or historical truth without proof.

## Required Validation Commands

CS06A:

- `git status --short`
- `git diff --check`
- Changed-file boundary check proving docs/protocol-only changes
- `grep -R "CS06A\\|CS06B\\|CS06C\\|Failed Taxonomy\\|failed-taxonomy" docs .codex | cat || true`
- `grep -R "App Store ready\\|TestFlight ready\\|production ready\\|physical device passed\\|failed taxonomy retired\\|failure taxonomy retired\\|CS06 complete" README.md docs .codex | cat || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

CS06B/CS06C:

- Narrowest focused xcodebuild test set for command execution, external action commands, async UI state, safe-automation receipts, and any touched copy/accessibility seam
- Broader relevant command/external-action/automation/receipt/navigation tests if available
- `git diff --check`
- Changed-file boundary check
- Release-claim scan
- Existing Codex/batch gate checks

## Required Evidence Outputs

- CS06A compatibility contract ledger
- CS06A copy/accessibility language ledger
- CS06A technical-state preservation ledger
- CS06A historical-doc truth ledger
- CS06A retirement risk map
- CS06A audit report
- CS06B focused proof report before any CS06C retirement
- CS06C retirement report only if a narrow retirement is executed

## Green / Yellow / Red Criteria

Green: all meaningful failed/failure seams are classified, technical states are preserved, focused proof passes, no forbidden files are touched, rollback exists, and no release/platform claim is introduced.

Yellow: a technical or historical seam remains intentionally preserved; a user-facing copy candidate is deferred until CS06C; exact rendered UI/accessibility exposure requires later proof; existing repo-wide docs QA backlog remains advisory.

Red: enum/raw-value uncertainty, command status uncertainty, external action uncertainty, async UI uncertainty, safe-automation receipt uncertainty, persistence uncertainty, accessibility identifier mismatch, public copy regression, deletion before proof, historical truth rewrite, test weakening, broad taxonomy refactor, or release claim ambiguity.

## Stop Conditions

Stop on any Red, missing seam owner, legacy payload/state failure, unclassified UI/test failure, migration uncertainty, missing rollback path, forbidden file touch, or request to retire adjacent seams.

## Rollback / Repair Expectations

Preserve technical `.failed` / `failedSafely` / `safeFailure` values until proof is Green. Repair through CS09 only after classifying the compatibility failure. Do not remove fallback decoders, route aliases, command statuses, receipt states, test fixtures, or historical evidence without documented retirement proof.

## Claims

CS06A may claim only that the failed-taxonomy seam has been mapped and staged. CS06B may claim focused compatibility proof for the tested seams. CS06C may claim only the specific safe retirement it performs.

## Non-Claims

CS06 must not claim the failed taxonomy is retired unless CS06C actually retires a proven-safe seam. It must not claim all compatibility seams are retired, external platform readiness, App Store/TestFlight/device readiness, public accessibility conformance, AmbitionsOS implementation, Signature Interface implementation, Product Depth implementation, or release readiness.

## Commit Message Recommendation

CS06A: `Repair CS06 failed taxonomy compatibility seam scope`

CS06B: `Prove failed taxonomy compatibility semantics`

CS06C: `Retire safe failed taxonomy seam after proof`

## Next Safe Prompt / Next Gate

After CS06A Green or accepted Yellow, run the narrowed CS06B proof dry-run. Continue only if `Execution allowed: YES`. After CS06B proof, defer CS06C unless a narrow retirement is proven safe. Continue to CS09 only after CS06 is Green or accepted Yellow and evidence is committed and pushed.
