# AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05 Source Refactor Map

## Status
Supporting audit map only. Active authority remains `docs/truth/*` plus live source/project/test evidence.

## Metadata
- Date: 2026-05-20
- Branch: `main`
- Commit: `240a0477cf585ee698393c44d8c1b1946617f4be`
- Scope: docs-only ownership map for current source seams
- Source inspection basis: live source tree, current truth files, implementation map, and repo audit/status docs

## Authority Boundary
- This map does not prove implementation completeness, validation, or release readiness.
- This map does not move files or rename source ownership.
- Historical or compatibility names remain compatibility-only unless an active truth file says otherwise.
- Future extraction work is listed as future work only.

## Ownership Map

| Area | Classification | Current ownership / note | Extraction risk | Future extraction train | Validation command |
| --- | --- | --- | --- | --- | --- |
| `Native/Ambitions/App` | Active | App entry, shell, routing, environment, launch control, and top-level destination wiring. | High | None until a source-moving batch is explicitly approved. | `xcodegen generate` then targeted app build/test proof |
| `Native/Ambitions/Domain` | Active | Core models, runtime contracts, receipts, projections, and truth-bearing domain behavior. | High | None until model/package boundaries are separately approved. | Targeted unit tests plus source/proof scans |
| `Native/Ambitions/Services` | Active | Application services, projectors, command execution, adapters, and runtime-facing orchestration. | High | Future slice only if the service boundary becomes a verified move target. | Targeted unit tests and command-path validation |
| `Native/Ambitions/Persistence` | Active | SwiftData, local durability, snapshots, migration scaffolds, and trust-preserving storage seams. | High | Future slice only with explicit persistence migration approval. | Persistence-focused unit tests and local validation logs |
| `Native/Ambitions/Features/Today` | Active | Flagship Today surface and reality-meridian / Start Here composition. | High | Future extraction only if a narrow seam is proven isolated. | UI snapshot / simulator validation |
| `Native/Ambitions/Features/Goals` | Active | Goal atlas and mission-control surface. | High | Future extraction only if goal-surface subpackages are proven isolated. | UI snapshot / simulator validation |
| `Native/Ambitions/Features/Capture` | Active | Composer-led capture surface and intake routing. | High | Future extraction only if capture routing and intake are separately proven. | UI snapshot / simulator validation |
| `Native/Ambitions/Features/Time` | Active | Time / LifeShape Field surface and compatibility-owned plan routing. | High | Future extraction only if `Plan` compatibility is separately reduced. | UI snapshot / simulator validation |
| `Native/Ambitions/Features/You` | Active | You / User System Profile surface, trust controls, profile state, and local settings posture. | High | Future extraction only if trust/profile sub-seams are proven isolated. | UI snapshot / simulator validation |
| `Native/Ambitions/Features/Habits` | Compatibility seam | Exists as retained compatibility material, but Habits is not an active top-level destination. | Medium | Candidate for future collapse into rituals/reviews/plan-adjacent behaviors only after source proof. | Search-only seam audit plus targeted test coverage |
| `Native/Ambitions/Features/Insights` | Compatibility seam | Contextual intelligence and support surfaces, not top-level IA. | Medium | Candidate for future fold-in or prune if all user-facing references are reclassified. | Search-only seam audit plus targeted test coverage |
| Internal `Plan` naming | Compatibility seam | `plan`, `planNavigation()`, and related internal labels remain compatibility-only. | High | Candidate for future reduction only after current Time ownership is stable. | Search-only seam audit and route/label tests |
| `profile` naming | Compatibility seam | Profile-style naming remains internal compatibility debt under You. | Medium | Candidate for future normalization only when user-facing labels are stable. | Search-only seam audit and profile-route tests |
| `captures` naming | Compatibility seam | Older plural naming remains internal compatibility debt under Capture. | Medium | Candidate for future normalization only when capture source refs are fully traced. | Search-only seam audit and capture-route tests |
| `Native/Ambitions/UI` | Active/supporting | App-level shared UI primitives and shell-adjacent view support. | Medium | Future extraction only if shared UI boundaries are isolated from feature logic. | UI-focused compile/tests |
| `Sources/Accessibility` | Supporting | Accessibility claims lock and accessibility-oriented package utilities. | Medium | Future extraction only if accessibility rules become a dedicated package seam. | Accessibility-claim and view-surface scans |
| `Sources/**` | Active/supporting | Shared design-system, component, preview, and theme package surface. | High | Future extraction only with package-boundary approval and dependency review. | Package compile checks and source-boundary scans |
| `AppUI/Sources/**` | Active/supporting | Widget UI package surface for shared widget composition and previews. | Medium | Future extraction only if widget package ownership is re-cut explicitly. | Widget-target compile checks |
| `Native/AmbitionsTests/**` | Active | Unit tests for app, domain, services, and support behavior. | Medium | Future extraction only if test package ownership is restructured intentionally. | `xcodebuild ... -only-testing:AmbitionsTests test` |
| `Native/AmbitionsUITests/**` | Active | UI tests for shell and surface proof behavior. | Medium | Future extraction only if UI test ownership is restructured intentionally. | `xcodebuild ... -only-testing:AmbitionsUITests test` |
| `Native/Ambitions/Support` | Supporting | Proof, readiness, QA, and reporting support material for source and validation posture. | Low | Future extraction only if support reports are split into dedicated proof packages. | Report-only validation and scan checks |
| `docs/audits` | Supporting | Audit receipts, maps, and historical evidence. | Low | Future extraction only if a separate archive policy is approved. | JSON parse and doc audit checks |
| `docs/status` | Supporting | Current status and evidence posture docs. | Low | Future extraction only if status docs are re-homed by a truth-file update. | Status-doc consistency checks |
| Trust/privacy/local-first seams | Active/supporting | You, persistence, receipts, runtime, and source/trust controls that preserve local-first behavior. | High | Future extraction only if a dedicated trust boundary is proven. | Source-truth scans and trust/receipt tests |

## Current Classification Notes

- `Today / Goals / Capture / Time / You` remains the active user-facing IA.
- `Plan` remains an internal compatibility seam or contextual noun only.
- `Habits` and `Insights` remain compatibility/support seams, not top-level destinations.
- `profile` and `captures` remain internal compatibility debt, not active IA.
- `Sources/**` and `AppUI/Sources/**` are shared packages, not app-feature ownership replacements.
- `Native/Ambitions/Support`, `docs/audits`, and `docs/status` are supporting evidence surfaces, not product truth.

## Future Extraction Trains

These are future work only, not current batch claims:

1. Split `Plan` compatibility labels from `Time`-owned runtime behavior if source proof shows the seam is isolated.
2. Fold or remove `Habits` only if no active runtime, test, or proof path depends on it.
3. Reclassify `Insights` only after current contextual intelligence calls are exhaustively traced.
4. Normalize `profile` and `captures` naming only when user-facing behavior remains stable.
5. Consider package boundary extraction for `Sources/**` or `AppUI/Sources/**` only after compile and dependency evidence supports the move.

## Non-Claims

- No source move was performed.
- No empty folder was created.
- No project regeneration was performed.
- No app source, test source, or project file was edited.
- No implementation completeness claim is made.
- No release readiness claim is made.

## Validation

Planned and/or run for this docs-only patch:

- `python3 scripts/ambitions_validate_prompt_headers.py`
- `python3 scripts/ambitions-repo-authority-validate.py`
- `python3 scripts/ambitions-codex-os-validate.py --report-path /tmp/ambitions-codex-os-validate-source-refactor-map.json`
- `bash scripts/si-file-size-scan.sh`
- `python3 -m json.tool docs/audits/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.json >/dev/null`
- `git diff --check`
- `git status --short`
