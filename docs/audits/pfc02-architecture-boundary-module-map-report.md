# PFC02 Architecture Boundary And Module Map Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance
Batch: PFC02

## Result

PFC02 completed as a docs-only architecture boundary map. It did not edit
production Swift, shared packages, tests, previews, persistence, runtime,
project generation, workflows, dependencies, signing, or generated output.

## Source Truth Used

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_Beyond_3_0_Maintainability_Extraction_Plan.md`
- `docs/audits/me12-maintainability-handoff-report.md`
- `docs/audits/pfc01-repo-build-system-inventory-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/codex/batches/PFC02_Architecture_Boundary_And_Module_Map_Prompt.md`
- `docs/audits/pfc02-architecture-boundary-module-map-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Module Boundary Map

| Boundary | Repo paths | Ownership rule |
| --- | --- | --- |
| App shell / DI / routing | `Native/Ambitions/App/**` | Owns app entry, dependency container, shell, routing, environment injection, and top-level tab hosting. |
| Domain | `Native/Ambitions/Domain/**` | Owns pure product/domain contracts, value models, state machines, proof/receipt contracts, recommendation/planning models, and compatibility models. |
| Services | `Native/Ambitions/Services/**` | Owns service protocols/implementations, projectors, local computation, and behavior adapters. |
| Persistence | `Native/Ambitions/Persistence/**` | Owns SwiftData persistence, repositories, schema/migration implications, and local data boundary. |
| Runtime | `Native/Ambitions/Runtime/**` | Owns runtime host/adaptation seams when explicitly scoped. |
| Feature UI | `Native/Ambitions/Features/**` | Owns Today, Goals, Capture, Plan, You/Profile, Insights compatibility, Habits/Ritual compatibility, and secondary user-facing surfaces. |
| Shared native UI | `Native/Ambitions/UI/**` | Owns app-local shared UI helpers that are not exported through the Swift package. |
| Design system package | `Sources/**` | Owns `AmbitionsDesignSystem`: shared primitives, theme, accessibility helpers, and previews. |
| Widget UI package | `AppUI/Sources/**` | Owns `AmbitionsWidgetUI`: shared widget/extension UI components. |
| External surfaces | `Native/AmbitionsWidgetExtension/**`, `Native/AmbitionsShareExtension/**`, `Native/Ambitions/AppIntents/**`, `Native/Ambitions/ExternalSnapshots/**`, `Native/Ambitions/Notifications/**`, `Native/Ambitions/Integrations/**` | Own platform/external entry points, privacy-safe snapshots, App Intents, notifications, EventKit/Reminders integration, and shared external payloads. |
| Preview support | `Native/Ambitions/PreviewSupport/**`, `Sources/Previews/**` | Owns deterministic preview/demo scenarios and non-production fixture surfaces. |
| Tests | `Native/AmbitionsTests/**`, `Native/AmbitionsUITests/**` | Own focused unit, service, domain, persistence, profile, plan, goals, capture, runtime, and UI evidence. |

## Boundary Risk Findings

| Finding | Evidence | Severity | Owner / repair path |
| --- | --- | --- | --- |
| Domain imports SwiftUI | `scripts/cqs-architecture-boundary-scan.sh` flags `Native/Ambitions/Domain/AppSession.swift:3:import SwiftUI`. | Yellow | PFC02 records; future architecture repair should decide whether `AppSession` belongs in App/Support or needs a domain-pure wrapper. |
| Oversized feature services/screens remain | Current line scan flags `GoalsFeatureService.swift` 4867, `TodayFeatureService.swift` 2701, `ProfileScreen.swift` 2477, `PlanFeatureService.swift` 2367, `ProfileFeatureService.swift` 1907, `PlanScreen.swift` 1874, `GoalsFeatureModels.swift` 1793, `TodayPanels.swift` 1783. | Yellow | PFC03/PFC05/FCP owner batches and prior ME standards own extraction before expansion. |
| Large domain/shared files exist | Current scan flags `ActionClosureReceiptModels.swift` 1511, `GoalEngineContracts.swift` 1436, `LifeGraphModels.swift` 1135, `SwiftDataRepositories.swift` 1076, and `DynamicAdaptiveVisualPrimitives.swift` 1203. | Yellow | PFC02 records; future owner batches split only with behavior-preserving tests. |
| Feature UI and service logic still co-located in some owners | Large feature service/screen files imply mixed projection/presentation responsibilities remain. | Yellow | PFC03 names cleanup queue; implementation batches must avoid expanding these files without extraction review. |
| Compatibility seams remain intentional | Profile/You, Insights, Habits/Ritual, ActiveFocus/TodayFocus, failed-taxonomy seams remain in history and tests. | Green/Yellow | CS maps own retirement; PFC/FCP must not rename/delete without compatibility proof. |

## Extraction Queue

| Priority | Owner path | Suggested future treatment |
| --- | --- | --- |
| P1 | `Native/Ambitions/Features/Goals/GoalsFeatureService.swift` | Continue service/projector extraction before FCP Goals object expansion. |
| P1 | `Native/Ambitions/Features/Today/TodayFeatureService.swift` | Extract stable projection families before Start Here / Reality Rail work. |
| P1 | `Native/Ambitions/Features/Profile/ProfileScreen.swift` | Keep composing You sub-surfaces out of root screen before Personal System Center work. |
| P1 | `Native/Ambitions/Features/Plan/PlanFeatureService.swift` | Extract Plan capacity/reflow/LifeShape families before FCP Plan object work. |
| P2 | `Native/Ambitions/Features/Profile/ProfileFeatureService.swift` | Split trust/history/defaults projections before expanding You. |
| P2 | `Native/Ambitions/Features/Plan/PlanScreen.swift` | Continue view extraction before LifeShape/Reflow/Pressure FCP work. |
| P2 | `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift` | Split presentation/state groups as FCP Goals primitives mature. |
| P2 | `Native/Ambitions/Features/Today/TodayPanels.swift` | Keep panel families extracted before additional Today visual/object work. |
| P3 | Large domain and shared primitive files | Split only with domain/package test proof and no product behavior change. |

## Architecture Rules For Later Batches

- Do not put business logic directly in SwiftUI view bodies.
- Do not add behavior to known oversized owner files without an extraction
  review or a narrow owner-specific justification.
- Domain files should remain UI-framework-light; `SwiftUI` imports in domain are
  architecture Yellow until justified or moved.
- Feature UI may depend on domain, services, and shared UI; domain must not
  depend on feature UI.
- Persistence and sync/schema changes require explicit PFC owners and tests.
- Route/raw-value compatibility remains CS-owned.
- Shared packages must stay reusable and not import app feature modules.
- Tests should follow touched owner behavior; broad UI tests do not replace
  focused contract tests.

## Non-Claims

PFC02 does not claim the architecture is fully clean, extracted, modularized, or
FAANG handoff-ready. It produces a current boundary map and extraction queue.

## Validation

Commands required for PFC02:

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/cqs-architecture-boundary-scan.sh Native/Ambitions Sources AppUI/Sources Native/AmbitionsTests || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Result summary:

- `git status --short`: expected dirty tree before commit.
- `git diff --check`: PASS.
- Touched-doc trailing whitespace scan: PASS.
- `scripts/cqs-architecture-boundary-scan.sh Native/Ambitions Sources AppUI/Sources Native/AmbitionsTests || true`: PASS WITH YELLOW. It reports `Native/Ambitions/Domain/AppSession.swift:3:import SwiftUI` and the known oversized files recorded in this report.
- `scripts/run-doc-qa.sh || true`: PASS WITH ADVISORY. Existing stale-guidance,
  deprecated-language, and markdownlint backlog remains; lychee reports 650 OK
  and 0 errors.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW. The only
  current hint is expected dirty-worktree state before commit.
- No build/test command was required because PFC02 is docs-only and touched no
  production code.

## Rollback Path

Revert the PFC02 commit to remove this docs-only boundary map, generated prompt,
and associated train-state updates. No app behavior rollback is needed because
PFC02 changes no production code.

## Next Eligible Batch

PFC03 Dead Code / Prompt Artifact / Naming Smell Audit is the next eligible
full-stack batch under `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` after
PFC02 closes.
