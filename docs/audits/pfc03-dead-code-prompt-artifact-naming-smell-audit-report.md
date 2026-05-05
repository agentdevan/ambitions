# PFC03 Dead Code / Prompt Artifact / Naming Smell Audit Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance
Batch: PFC03

## Result

PFC03 completed as a docs-only maintainability audit. It identified prompt
artifact, placeholder, stale naming, and cleanup risks, then classified them by
owner and proof requirement. It did not delete files, rename identifiers, edit
production Swift, change shared packages, touch tests/previews, alter project
generation, modify workflows, add dependencies, or change signing/generated
output.

## Source Truth Used

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_Codex_Quality_System.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_SCRIPT_MAP.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/audits/pfc02-architecture-boundary-module-map-report.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/codex/batches/PFC03_Dead_Code_Prompt_Artifact_Naming_Smell_Audit_Prompt.md`
- `docs/audits/pfc03-dead-code-prompt-artifact-naming-smell-audit-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Audit Scope

PFC03 inspected prompt-smell, placeholder, stub, stale-copy, and naming-risk
signals across active native source, shared packages, tests, docs, scripts, and
Codex OS files using safe read-only searches and CQS advisory scans. Findings
are cleanup candidates, not deletion authorization.

## Classification Summary

| Classification | Evidence | Risk | Future treatment |
| --- | --- | --- | --- |
| Legitimate platform placeholder | `Native/AmbitionsWidgetExtension/NextStepWidget.swift` uses WidgetKit `placeholder(in:)`. | Green | Keep unless a WidgetKit owner changes provider behavior with tests. |
| Legitimate domain placeholder semantics | `placeholderOnly` appears in proof/resource graph domain and tests. | Green | Keep as domain meaning; do not treat as prompt residue. |
| Negative copy guard assertions | Test or script references to rejected terms such as `AI confidence` and `productivity score`. | Green | Keep when asserting absence or scanning forbidden product drift. |
| Deterministic preview/test fallback services | `StubGoalsService`, `StubTodayService`, `StubProfileService`, notification/EventKit stubs, and related dev injection seams. | Yellow | Keep until owner-specific proof shows a safer naming or injection model; no release-facing claim. |
| Future integration placeholder owner map | `Native/Ambitions/Support/FutureIntegrationPlaceholders.swift`. | Yellow | PFC13-PFC20 platform owners must prove which placeholders remain, defer, or retire before deletion. |
| Shell placeholder route seam | `AppShellPlaceholderRouteView` and `shell.placeholder` in app shell routing. | Yellow | Shell/route owner must prove route compatibility before rename/removal. |
| Stale F-series or temporary visible copy risk | `DayRailProjection.swift` copy says detail opens in a later F-series batch; shared surface primitives include temporary overlay wording. | Yellow | Future copy/source cleanup should verify whether these strings are user-facing, test-only, or preview-only before editing. |
| Legacy compatibility vocabulary | Profile/You, Insights, Habits/Ritual, ActiveFocus/TodayFocus, and failed-taxonomy seams exist in history and code. | Yellow | CS compatibility owners must retire only with raw-value, migration, route, and test proof. |
| Script pattern self-hits | CQS scripts and docs contain scan terms by design. | Green | Exclude from deletion queues; update scan allowlists only in a CQS script batch. |

## Cleanup Queue

| Priority | Candidate | Owner | Required proof before edit |
| --- | --- | --- | --- |
| P1 | Stale F-series visible copy in Today projection surfaces | FCP Today / copy-boundary owner | Prove current user-facing exposure, replace with Product Experience Pack language, run focused Today tests and copy scan. |
| P1 | `AppShellPlaceholderRouteView` and `shell.placeholder` route seam | Shell / route compatibility owner | Prove no raw-value, deep-link, App Intent, widget, notification, UI test, or fallback route break before rename/removal. |
| P1 | `FutureIntegrationPlaceholders.swift` | Platform external-surface owners | PFC13-PFC20 owner decision for widgets, Live Activities, App Intents, notifications, calendar/reminders, and shared storage. |
| P2 | Stub service naming and fallback injection seams | Feature/service owners | Prove whether each stub is preview/test/dev-only, then rename/extract only with focused tests. |
| P2 | Temporary overlay wording in shared primitives/previews | Shared UI / preview owner | Prove whether visible to users or preview-only; update copy without changing primitive behavior. |
| P2 | Compatibility vocabulary in public-visible copy | CS / copy-boundary owner | Run staged user-facing string inventory before renaming internal compatibility cases. |
| P3 | Script allowlists for known legitimate placeholders | CQS script owner | Add allowlists only if advisory noise blocks later review; do not weaken drift detection. |

## Dead Code / Deletion Boundary

PFC03 found no file safe to delete immediately. Deletion requires owner proof,
call-site search, build/test evidence, and compatibility review. Stubs,
placeholders, fixture markers, and compatibility names are not dead code merely
because their names look temporary.

## Naming Smell Rules For Later Batches

- Avoid expanding files already classified as oversized by PFC02.
- Do not rename internal compatibility cases just to match user-facing copy.
- Do not leave visible user copy that references future batch mechanics.
- Do not treat WidgetKit placeholders, negative test guards, scan patterns, or
  domain placeholder states as prompt-built residue.
- Any cleanup that touches routes, raw values, persistence, widgets, App
  Intents, notifications, or external snapshots needs an explicit owner batch.

## Non-Claims

PFC03 does not claim the repo has no dead code, no prompt-built residue, no
future cleanup debt, or FAANG handoff readiness. It creates a first cleanup
queue and proof boundary for future maintainability batches.

## Validation

Commands required for PFC03:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-prompt-built-smell-scan.sh Native || true`
- `scripts/cqs-prompt-built-smell-scan.sh Sources || true`
- `scripts/cqs-product-drift-scan.sh Native || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Result summary:

- `git status --short`: expected dirty tree before commit.
- `git diff --check`: PASS.
- Touched-doc trailing whitespace scan: PASS.
- `scripts/cqs-prompt-built-smell-scan.sh Native || true`: PASS WITH YELLOW. Findings are the legitimate/Yellow-owned placeholder, stub, and copy-risk signals classified above.
- `scripts/cqs-prompt-built-smell-scan.sh Sources || true`: PASS WITH YELLOW. Findings are shared primitive/preview placeholder and temporary overlay signals classified above.
- `scripts/cqs-product-drift-scan.sh Native || true`: PASS WITH YELLOW. Existing compatibility/test guard hits are Yellow-owned; no new source copy was introduced.
- `scripts/run-doc-qa.sh || true`: PASS WITH ADVISORY. Existing stale-guidance, deprecated-language, and markdownlint backlog remains; lychee reports no link errors.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW. The only current hint is expected dirty-worktree state before commit.
- No build/test command was required because PFC03 is docs-only and touched no
  production code.

## Repair Notes

An exploratory `rg` scan included a root `Tests` path that does not exist in
this repo; the correct test roots are `Native/AmbitionsTests` and
`Native/AmbitionsUITests`. This was a recoverable validation-command typo, not
a source finding. PFC03 validation uses the correct roots through CQS scans and
active-source searches.

## Rollback Path

Revert the PFC03 commit to remove this docs-only audit, generated prompt, and
associated train-state updates. No app behavior rollback is needed because
PFC03 changes no production code.

## Next Eligible Batch

PFC04 Dependency And Supply Chain Policy Enforcement is the next eligible
full-stack batch under `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` after
PFC03 closes.
